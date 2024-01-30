//
//  ImageManager.swift
//  IntermissionApp
//
//  Created by Louis Tur on 1/21/19.
//  Copyright © 2019 intermissionsessions. All rights reserved.
//

import UIKit
import Kingfisher
// Ugh.. YPImagePicker has a dependency on another autolayout library, Stevia. Need to consider replacing this for
// another that doesn't dependencies
import YPImagePicker
import AVFoundation
import Photos

enum PermissionIntent {
    case camera, photoLibrary
}

// TODO: figure out how to clean up these unused errors and this ImageManager overall
enum PermissionError: Error, ErrorDisplayable {
    case denied(PermissionIntent)
    case notDetermined(PermissionIntent)
    case unknown(Error)
    
    var displayError: DisplayableError {
        switch self {
        case .denied(let intent):
            if intent == .camera {
                return DisplayableError(title: "Can't Access your Camera", message: "")
            } else {
                return DisplayableError(title: "Can't Access your Photos", message: "")
            }
            
        case .notDetermined(let intent):
            if intent == .camera {
                return DisplayableError(title: "Need To Access your Camera", message: "")
            } else {
                return DisplayableError(title: "Need To Access your Photos", message: "")
            }
            
        case .unknown(let error):
            return DisplayableError(title: "Something Went Wrong", message: error.localizedDescription)
        }
    }
}

protocol ImageManagerDelegate: class {
    
    func imageManagerDidError(_ imageManager: ImageManager, error: PermissionError, alert: AlertViewController?)
    
    func imageManagerDidSucceed(_ imageManager: ImageManager)
    
    func imageManager(_ imageManager: ImageManager, requests alert: AlertViewController)

}

class ImageManager {
    
    weak var delegate: ImageManagerDelegate?

    private let picker: YPImagePicker
    private var config: YPImagePickerConfiguration
    
    init() {
        config = YPImagePickerConfiguration()
        config.usesFrontCamera = true
        config.shouldSaveNewPicturesToAlbum = false
        config.showsCrop = YPCropType.rectangle(ratio: 1.0)
        config.targetImageSize = YPImageSize.cappedTo(size: 1000.0)
        config.hidesStatusBar = true
        config.bottomMenuItemSelectedColour = .cta
        config.bottomMenuItemUnSelectedColour = .lightTextColor
        config.showsPhotoFilters = false

        config.library.mediaType = .photo
        config.library.maxNumberOfItems = 1
        config.library.minNumberOfItems = 1
        config.library.numberOfItemsInRow = 4
        config.library.minWidthForItem = 400.0
        config.library.spacingBetweenItems = 4.0

        config.colors.tintColor = .cta
        config.icons.capturePhotoImage = config.icons.captureVideoImage

        picker = YPImagePicker(configuration: config)
    }
    
    deinit {
        print("IMAGE MANAGER DE-INIT")
    }
    
    func present(in viewController: UIViewController, completion: @escaping (UIImage?) -> Void) {
        UINavigationBar.appearance().tintColor = .cta
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.textColor,
                                                            NSAttributedString.Key.font : UIFont(name: Font.identifier(for: .semiBold), size: 18.0) ?? UIFont.systemFont(ofSize: 18.0)]

        viewController.present(picker, animated: true)
        picker.didFinishPicking { [unowned picker] (items: [YPMediaItem], cancelled: Bool) in
            if cancelled {
                picker.dismiss(animated: true, completion: nil)
                return
            }

            guard let singlePhoto = items.singlePhoto else {
                completion(nil)
                return
            }
            
            completion(singlePhoto.image)
            picker.dismiss(animated: true, completion: nil)
        }
    }
    
    func launch(using delegate: ImageManagerDelegate) {
        self.delegate = delegate
        
        if ImageManager.cameraAuthorizationStatus == .notDetermined || ImageManager.photoLibraryAuthorizationStatus == .notDetermined {
            
            let alert = ImageManager.cameraAndLibraryPermissionAlert {[weak self] (allowed) in
                guard allowed else { return }
                self?.requestCameraAndLibrary()
            }
            
            self.delegate?.imageManager(self, requests: alert)
            
        } else {
            self.requestCameraAndLibrary()
        }
    }
    
    func requestCameraAndLibrary() {
        let cameraResult = ImageManager.asyncCameraRequest()
        
        switch cameraResult {
        case .success(_): break
        case .failure(let error as PermissionError):
            if case PermissionError.denied = error {
                delegate?.imageManagerDidError(self, error: error, alert: ImageManager.cameraPermissionDeniedAlert())
            } else  {
                delegate?.imageManagerDidError(self, error: .unknown(error), alert: nil)
            }
            return
        case .failure(let error):
            delegate?.imageManagerDidError(self, error: .unknown(error), alert: nil)
            return
        }
        
        let photoLibraryResult = ImageManager.asyncPhotoLibraryRequest()
        
        switch photoLibraryResult {
        case .success(_):
            delegate?.imageManagerDidSucceed(self)
            return
        case .failure(let error as PermissionError):
            if case PermissionError.denied = error {
                delegate?.imageManagerDidError(self, error: error, alert: ImageManager.photoLibraryPermissionDeniedAlert())
            } else  {
                delegate?.imageManagerDidError(self, error: .unknown(error), alert: nil)
            }
            return
        case .failure(let error):
            delegate?.imageManagerDidError(self, error: .unknown(error), alert: nil)
            return
        }
        
    }
    
    // MARK: - Helpers -
    
    static var isCameraAvailable: Bool {
        return UIImagePickerController.isSourceTypeAvailable(.camera)
    }
    
    static var isFrontFacingCameraAvailable: Bool {
        return isCameraAvailable && UIImagePickerController.isCameraDeviceAvailable(.front)
    }
    
    static var cameraAuthorizationStatus: AVAuthorizationStatus {
        return AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
    }
    
    static var photoLibraryAuthorizationStatus: PHAuthorizationStatus {
        return PHPhotoLibrary.authorizationStatus()
    }
    
    // MARK: - Core Request -
    
    static func requestCameraPlusLibrary(completion: @escaping (IAResult<Bool, PermissionError>) -> Void) {
        DispatchQueue.global(qos: .utility).async {
            
            let result = requestCamera().flatMap { _ in
                requestLibrary()
            }
            
            DispatchQueue.main.async {
                switch result {
                case .success(_):
                    completion(.success(true))
                case .failure(let error as PermissionError):
                    completion(.failure(error))
                case .failure(_):
                    completion(.failure(PermissionError.denied(.camera)))
                }
            }
        }
    }
    
    // MARK: - Request via Async Returns -

    static func requestCamera() -> Swift.Result<Bool, Error> {
        switch ImageManager.cameraAuthorizationStatus {
        case .authorized:
            return .success(true)
            
        case .notDetermined:
            
            return asyncCameraRequest()
            
        case .restricted, .denied:
           return .failure(PermissionError.denied(.camera))
        }
    }

    static func requestLibrary() -> Swift.Result<Bool, Error> {
        switch ImageManager.photoLibraryAuthorizationStatus {
        case .authorized:
            return .success(true)
            
        case .notDetermined:
            return asyncPhotoLibraryRequest()
            
        case .restricted, .denied:
            return .failure(PermissionError.denied(.photoLibrary))
        }
    }
    
    // MARK: - Request Via Async Callbacks -
    
    static func requestCamera(completion: @escaping (Swift.Result<Bool, Error>) -> Void) {
        switch ImageManager.cameraAuthorizationStatus {
        case .authorized:
            completion(.success(true))
            
        case .notDetermined:
            completion(asyncCameraRequest())
            
        case .restricted, .denied:
            completion(.failure(PermissionError.denied(.camera)))
        }
    }
    
    static func requestLibrary(completion: @escaping (Swift.Result<Bool, Error>) -> Void) {
        switch ImageManager.photoLibraryAuthorizationStatus {
        case .authorized:
            completion(.success(true))
            
        case .notDetermined:
            completion(asyncPhotoLibraryRequest())
            
        case .restricted, .denied:
            completion(.failure(PermissionError.denied(.photoLibrary)))
        }
    }
    
    // MARK: - "Async/Await" Request -
    
    // https://medium.com/@michaellong/how-to-chain-api-calls-using-swift-5s-new-result-type-and-gcd-56025b51033c
    private static func asyncCameraRequest() -> Swift.Result<Bool, Error> {
        var returnResult: (Swift.Result<Bool, Error>) = .failure(PermissionError.denied(.camera))
        let semaphore = DispatchSemaphore(value: 0)
        
        ImageManager.requestCameraAccess { (success) in
            if success { returnResult = .success(success) }
            else { returnResult = .failure(PermissionError.denied(.camera)) }
            
            semaphore.signal()
        }
        
        _ = semaphore.wait(wallTimeout: .distantFuture)
        return returnResult
    }
    
    // https://medium.com/@michaellong/how-to-chain-api-calls-using-swift-5s-new-result-type-and-gcd-56025b51033c
    private static func asyncPhotoLibraryRequest() -> Swift.Result<Bool, Error> {
        var returnResult: (Swift.Result<Bool, Error>) = .failure(PermissionError.denied(.photoLibrary))
        let semaphore = DispatchSemaphore(value: 0)
        
        ImageManager.requestPhotoLibraryAccess { (success) in
            if success { returnResult = .success(success) }
            else { returnResult = .failure(PermissionError.denied(.photoLibrary)) }
            
            semaphore.signal()
        }

        _ = semaphore.wait(wallTimeout: .distantFuture)
        return returnResult
    }
    
    // MARK: - Media Resource Requests -
    
    private static func requestCameraAccess(completion: @escaping (Bool) -> Void) {
        AVCaptureDevice.requestAccess(for: AVMediaType.video) { granted in
            completion(granted)
        }
    }

    private static func requestPhotoLibraryAccess(completion: @escaping (Bool) -> Void) {
        PHPhotoLibrary.requestAuthorization() { status in
            switch status {
            case .authorized:
                completion(true)
            default:
                completion(false)
            }
        }
    }
    
    // MARK: - Request Alerts -
    
    static func cameraAndLibraryPermissionAlert(completion: @escaping (Bool) -> Void) -> AlertViewController {
        
        let cancelAction = AlertAction(title: "Cancel") { (controller, _) in
            controller.dismiss(animated: true)
            completion(false)
        }
        
        let okAction = AlertAction(title: "OK") { (controller, _) in
            controller.dismiss(animated: true)
            completion(true)
        }
        
        let alertController = AlertViewController(with: "Camera & Library Needed", message: "In a moment, we're going to ask for permission to access your camera and photo library. We just need this to get a profile photo for you and you can remove access right after.", primaryAction: okAction, secondaryAction: cancelAction)
        
        return alertController
    }
 
    // MARK: - Error Alerts -
    
    static func cameraPermissionDeniedAlert() -> AlertViewController {
        let cancelAction = AlertAction(title: "Cancel") { (controller, _) in
            controller.dismiss(animated: true)
        }
        
        let settingsAction = AlertAction(title: "Settings") { (controller, button) in
            guard let appSettings = URL(string: UIApplication.openSettingsURLString) else { return }
            UIApplication.shared.open(appSettings)
        }
        
        let alertController = AlertViewController(with: "Camera Permission Required", message: "Please enable access to the camera in your settings for this app. Click on the Settings button below to be taken there", primaryAction: settingsAction, secondaryAction: cancelAction)
        
        return alertController
    }
    
    static func photoLibraryPermissionDeniedAlert() -> AlertViewController {
        let cancelAction = AlertAction(title: "Cancel") { (controller, _) in
            controller.dismiss(animated: true)
        }
        
        let settingsAction = AlertAction(title: "Settings") { (controller, button) in
            guard let appSettings = URL(string: UIApplication.openSettingsURLString) else { return }
            UIApplication.shared.open(appSettings)
        }
        
        let alertController = AlertViewController(with: "Photos Permission Required", message: "Please enable access to the photo library in your settings for this app. Click on the Settings button below to be taken there", primaryAction: settingsAction, secondaryAction: cancelAction)
        
        return alertController
    }
}
