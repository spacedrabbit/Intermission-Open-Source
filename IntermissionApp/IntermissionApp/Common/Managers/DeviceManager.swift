//
//  DeviceManager.swift
//  IntermissionApp
//
//  Created by Louis Tur on 3/16/19.
//  Copyright © 2019 intermissionsessions. All rights reserved.
//

import Foundation
import UIKit
import MessageUI

final class DeviceManager {
    
    // MARK: - Model
    
    public enum Model : String {
        case simulator   = "simulator",
        iPod1            = "iPod 1",
        iPod2            = "iPod 2",
        iPod3            = "iPod 3",
        iPod4            = "iPod 4",
        iPod5            = "iPod 5",
        iPad2            = "iPad 2",
        iPad3            = "iPad 3",
        iPad4            = "iPad 4",
        iPhone4          = "iPhone 4",
        iPhone4S         = "iPhone 4S",
        iPhone5          = "iPhone 5",
        iPhone5S         = "iPhone 5S",
        iPhone5C         = "iPhone 5C",
        iPadMini1        = "iPad Mini 1",
        iPadMini2        = "iPad Mini 2",
        iPadMini3        = "iPad Mini 3",
        iPadAir1         = "iPad Air 1",
        iPadAir2         = "iPad Air 2",
        iPadPro9_7       = "iPad Pro 9.7",
        iPadPro9_7_2nd   = "iPad Pro 9.7, 2nd Gen / iPad 5th Gen",
        iPadPro10_5      = "iPad Pro 10.5",
        iPadPro12_9      = "iPad Pro 12.9",
        iPadPro12_9_2nd  = "iPad Pro 12.9, 2nd Gen",
        iPhone6          = "iPhone 6",
        iPhone6plus      = "iPhone 6 Plus",
        iPhone6S         = "iPhone 6S",
        iPhone6Splus     = "iPhone 6S Plus",
        iPhoneSE         = "iPhone SE",
        iPhone7          = "iPhone 7",
        iPhone7plus      = "iPhone 7 Plus",
        iPhone8          = "iPhone 8",
        iPhone8plus      = "iPhone 8 Plus",
        iPhoneX          = "iPhone X",
        iPhoneXR         = "iPhone XR",
        iPhoneXS         = "iPhone XS",
        iPhoneXSMax      = "iPhone XS Max",
        unrecognized     = "unrecognized"
    }
    
    // MARK: - Model Map
    
    // https://www.theiphonewiki.com/wiki/Models
    private class var modelMap: [String : Model] {
        return [ "i386"       : .simulator,
                 "x86_64"     : .simulator,
                 "iPod1,1"    : .iPod1,
                 "iPod2,1"    : .iPod2,
                 "iPod3,1"    : .iPod3,
                 "iPod4,1"    : .iPod4,
                 "iPod5,1"    : .iPod5,
                 "iPad2,1"    : .iPad2,
                 "iPad2,2"    : .iPad2,
                 "iPad2,3"    : .iPad2,
                 "iPad2,4"    : .iPad2,
                 "iPad2,5"    : .iPadMini1,
                 "iPad2,6"    : .iPadMini1,
                 "iPad2,7"    : .iPadMini1,
                 "iPhone3,1"  : .iPhone4,
                 "iPhone3,2"  : .iPhone4,
                 "iPhone3,3"  : .iPhone4,
                 "iPhone4,1"  : .iPhone4S,
                 "iPhone5,1"  : .iPhone5,
                 "iPhone5,2"  : .iPhone5,
                 "iPhone5,3"  : .iPhone5C,
                 "iPhone5,4"  : .iPhone5C,
                 "iPad3,1"    : .iPad3,
                 "iPad3,2"    : .iPad3,
                 "iPad3,3"    : .iPad3,
                 "iPad3,4"    : .iPad4,
                 "iPad3,5"    : .iPad4,
                 "iPad3,6"    : .iPad4,
                 "iPhone6,1"  : .iPhone5S,
                 "iPhone6,2"  : .iPhone5S,
                 "iPad4,1"    : .iPadAir1,
                 "iPad4,2"    : .iPadAir2,
                 "iPad4,4"    : .iPadMini2,
                 "iPad4,5"    : .iPadMini2,
                 "iPad4,6"    : .iPadMini2,
                 "iPad4,7"    : .iPadMini3,
                 "iPad4,8"    : .iPadMini3,
                 "iPad4,9"    : .iPadMini3,
                 "iPad6,3"    : .iPadPro9_7,
                 "iPad6,4"    : .iPadPro9_7,
                 "iPad6,11"   : .iPadPro9_7_2nd,
                 "iPad6,12"   : .iPadPro9_7_2nd,
                 "iPad6,7"    : .iPadPro12_9,
                 "iPad6,8"    : .iPadPro12_9,
                 "iPad7,1"    : .iPadPro12_9_2nd,
                 "iPad7,2"    : .iPadPro12_9_2nd,
                 "iPad7,3"    : .iPadPro10_5,
                 "iPad7,4"    : .iPadPro10_5,
                 "iPhone7,1"  : .iPhone6plus,
                 "iPhone7,2"  : .iPhone6,
                 "iPhone8,1"  : .iPhone6S,
                 "iPhone8,2"  : .iPhone6Splus,
                 "iPhone8,4"  : .iPhoneSE,
                 "iPhone9,1"  : .iPhone7,
                 "iPhone9,2"  : .iPhone7plus,
                 "iPhone9,3"  : .iPhone7,
                 "iPhone9,4"  : .iPhone7plus,
                 "iPhone10,1" : .iPhone8,
                 "iPhone10,2" : .iPhone8plus,
                 "iPhone10,3" : .iPhoneX,
                 "iPhone10,6" : .iPhoneX,
                 "iPhone11,2" : .iPhoneXS,
                 "iPhone11,4" : .iPhoneXSMax,
                 "iPhone11,6" : .iPhoneXSMax,
                 "iPhone11,8" : .iPhoneXR,
        ]
    }
    
    static var deviceInformation: [String : String] {
        var deviceInfo = [String:String]()
        
        deviceInfo["app_version"] = AppManager.appVersionSupportEmailString
        deviceInfo["os_version"] = UIDevice.current.systemVersion
        deviceInfo["device_model"] = deviceModel
        deviceInfo["device_type"] = UIDevice.current.model
        
        return deviceInfo
    }
    
    static var deviceSupportEmailDetails: String {
        var deviceDetails = "\n\n\n\n\n-----------------------------\n"
        
        if !AppManager.appVersionSupportEmailString.isEmpty {
            deviceDetails += "App Version: \(AppManager.appVersionSupportEmailString)\n"
        }
        
        if !UIDevice.current.systemVersion.isEmpty {
            deviceDetails += "OS Version: \(UIDevice.current.systemVersion)\n"
        }
        
        if !deviceModel.isEmpty {
            deviceDetails += "Device Model: \(deviceModel)\n"
        }
        
        if !UIDevice.current.model.isEmpty {
            deviceDetails += "Device Type: \(UIDevice.current.model)"
        }
        
        deviceDetails += "\n-----------------------------\n\n"
        
        return deviceDetails
    }
    
    static public var deviceModel: String {
        var size = 0
        sysctlbyname("hw.machine", nil, &size, nil, 0)
        var machine = [CChar](repeating: 0,  count: Int(size))
        sysctlbyname("hw.machine", &machine, &size, nil, 0)
        return String(cString: machine)
    }
    
    static public var canSendMail: Bool {
        return MFMailComposeViewController.canSendMail()
    }
    
    // Based on https://stackoverflow.com/questions/26028918/how-to-determine-the-current-iphone-device-model
    static public var model: Model {
        let modelCode = DeviceManager.deviceModel
        guard let model = DeviceManager.modelMap[modelCode] else {
            return Model.unrecognized
        }
        
        return model
    }
    
    /// `true` if device is an iPhone, `false` otherwise. Simulators always return `false`.
    static var isIPhone: Bool {
        if isSimulator { return false }
        return UIDevice.current.userInterfaceIdiom == .phone
    }
    
    /// `true` if device or simulator is an iPhone.
    static var isIPhoneEquivalent: Bool {
        return UIDevice.current.userInterfaceIdiom == .phone
    }
    
    /// `true` if device is an iPad, `false` otherwise. Simulators always return `false`.
    static var isIPad: Bool {
        if isSimulator { return false }
        return UIDevice.current.userInterfaceIdiom == .pad
    }
    
    /// `true` if device or simulator is an iPad.
    static var isIPadEquivalent: Bool {
        return UIDevice.current.userInterfaceIdiom == .pad
    }
    
    /// `true` if running on a simulator. `false` otherwise.
    static var isSimulator: Bool {
        var simulator: Bool = false
        #if targetEnvironment(simulator)
        simulator = true
        #endif
        return simulator
    }
    
    /// `true` if running on an iPod. Simulators return `false`
    static var isIPod: Bool {
        if isSimulator { return false }
        return [.iPod1, .iPod2, .iPod3, .iPod4, .iPod5].contains(DeviceManager.model)
    }
    
    /// `true` if a device has a screen width of 320pt (iPhone 4, 4s, 5, 5s, 5C)
    static var isCompactDisplay: Bool {
        return [.iPhone4, .iPhone4S, .iPhone5, .iPhone5S, .iPhone5C].contains(DeviceManager.model)
    }
    
    /// `true` if a device has a screen width of 375pt (iPhone 6, 6s, 7, 8
    static var isNormalDisplay: Bool {
        return [.iPhone6, .iPhone6S, .iPhone7, .iPhone8].contains(DeviceManager.model)
    }
    
    /// `true` if device has a screen with of 414pt, but a non-elongated display (736pt: iPhone 6+, 6s+, 7+, 8+)
    static var isTallDisplay: Bool {
        return [.iPhone6plus, .iPhone6Splus, .iPhone7plus, .iPhone8plus].contains(DeviceManager.model)
    }
    
    /// `true` if device has a screen height of 812pt (iPhoneX) or more (896pt: XR, XSMax)
    static var isExtraTallDisplay: Bool {
        return [.iPhoneX, .iPhoneXSMax, .iPhoneXR].contains(DeviceManager.model)
    }
}
