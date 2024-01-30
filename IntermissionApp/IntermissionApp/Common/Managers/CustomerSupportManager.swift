//
//  CustomerSupportManager.swift
//  IntermissionApp
//
//  Created by Louis Tur on 7/13/19.
//  Copyright © 2019 intermissionsessions. All rights reserved.
//

import UIKit
import MessageUI

enum CustomerSupportIntent {
    case comment, support, featureRequest, bug
    
    var subjectLine: String {
        switch self {
        case .comment: return "I have a comment about Intermission App"
        case .support: return "I need support in the Intermission App"
        case .featureRequest: return "The Intermission App is missing something I'd like"
        case .bug: return "I found a problem with the Intermission App"
        }
    }
    
    var bodyMessage: String {
        switch self {
        case .comment: return ""
        case .support: return "(Include as much info as you can about the issue you're having trouble with...)\n\n"
        case .featureRequest: return "(We're so excited to add new features based on your feedback! Leave as much detail as possible.)"
        case .bug: return "(Be sure to include as much info about how you are able to find and reproduce the bug, it will help our robots & engineers fix it faster)"
        }
    }
}

class CustomerSupportManager: NSObject {
    private var presentingViewController: UIViewController?
    public static let emailAddress = "intermissionapp@gmail.com"
    
    static let shared = CustomerSupportManager()
    
    private override init() {}
    
    func presentEmail(in viewController: UIViewController, intent: CustomerSupportIntent, delegate: MFMailComposeViewControllerDelegate? = nil, subject: String? = "", message: String? = "", showDeviceDetails: Bool = false) {
        
        guard DeviceManager.canSendMail else  {
            presentGenericInfoAlert(in: viewController)
            return
        }
        
        self.presentingViewController = viewController
        let mailController = MFMailComposeViewController()
        mailController.setToRecipients([CustomerSupportManager.emailAddress])
        
        if let subject = subject, !subject.isEmpty {
            mailController.setSubject(subject)
        } else {
            mailController.setSubject(intent.subjectLine)
        }
        
        if let delegate = delegate {
            mailController.mailComposeDelegate = delegate
        } else {
            mailController.mailComposeDelegate = self
        }
        
        var body = ""
        if let emailMessage = message, !emailMessage.isEmpty {
            body += emailMessage
        } else {
            body += intent.bodyMessage
        }
        
        if showDeviceDetails {
            body += DeviceManager.deviceSupportEmailDetails
        }
        
        mailController.setMessageBody(body, isHTML: false)
        viewController.present(mailController, animated: true, completion: nil)
    }
    
    func presentGenericInfoAlert(in viewController: UIViewController) {
        let title = "How to Contact Us"
        let message = "You can reach out to us for questions, bugs, feature requests or comments at \(CustomerSupportManager.emailAddress). We absolutely would love to hear from you on how we can help to make your Intermissions with us a pleasure!"
        viewController.presentAlert(with: title, message: message)
    }
}

extension CustomerSupportManager: MFMailComposeViewControllerDelegate {
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        // TODO: notifications
        
        controller.dismiss(animated: true, completion: nil)
    }
    
}
