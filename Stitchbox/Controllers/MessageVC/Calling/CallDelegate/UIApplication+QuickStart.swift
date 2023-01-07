//
//  UIApplication+QuickStart.swift
//  QuickStart
//
//  Created by Jaesung Lee on 2020/04/13.
//  Copyright © 2020 SendBird Inc. All rights reserved.
//

import UIKit
import SendBirdCalls

extension UIApplication {
    
    func showCallController(with call: DirectCall) {
        
        // cancel any current direct call
        if let call = SendBirdCall.getCall(forCallId: call.callId) {
            call.end()
            CXCallManager.shared.endCXCall(call)
        }
        
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            // If there is termination: Failed to load VoiceCallViewController from Main.storyboard. Please check its storyboard ID")
            let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
            let viewController = storyboard.instantiateViewController(withIdentifier: "VoiceCallViewController")
            
            if var dataSource = viewController as? DirectCallDataSource {
                dataSource.call = call
                dataSource.isDialing = false
                dataSource.newcall = true
            }
            
            if let topViewController = UIViewController.topViewController {
                viewController.modalPresentationStyle = .fullScreen
                topViewController.present(viewController, animated: true, completion: nil)
            } else {
                self.keyWindow?.rootViewController = viewController
                self.keyWindow?.makeKeyAndVisible()
            }
        }
    }
    
    func showError(with errorDescription: String?) {
        let message = errorDescription ?? "Something went wrong. Please retry."
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            if let topViewController = UIViewController.topViewController {
                topViewController.presentErrorAlert(message: message)
            } else {
                self.keyWindow?.rootViewController?.presentErrorAlert(message: message)
                self.keyWindow?.makeKeyAndVisible()
            }
        }
    }
}
