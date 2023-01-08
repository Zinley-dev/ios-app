//
//  ControllerType.swift
//  Stitchbox
//
//  Created by Khanh Duy Nguyen on 11/12/22.
//

import Foundation
import UIKit
import EzPopup
import SwiftUI

protocol ControllerType: UIViewController {
    associatedtype ViewModelType: ViewModelProtocol
    /// Configurates controller with specified ViewModelProtocol subclass
    ///
    /// - Parameter viewModel: CPViewModel subclass instance to configure with
    func bindUI(with viewModel: ViewModelType)
    /// Configurates controller actions with specified ViewModelProtocol subclass
    ///
    /// - Parameter viewModel: CPViewModel subclass instance to configure with
    func bindAction(with viewModel: ViewModelType)
    /// Factory function for view controller instatiation
    ///
    /// - Parameter viewModel: View model object
    /// - Returns: View controller of concrete type
    //    static func create(with viewModel: ViewModelType) -> UIViewController
}

extension UIViewController {
    
    
    func presentError(error: Error) {
        
        // For Dismissing the Popup
        dismissPopup()
        
        let alert = UIAlertController(title: "Error", message: error._domain, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Return", style: UIAlertAction.Style.default, handler: nil))
        DispatchQueue.main.async {
            if let window = UIApplication.shared.delegate?.window {
                if let viewController = window?.rootViewController {
                    viewController.present(alert, animated: true, completion: nil)
                }
            }
        }
    }
    
    func presentMessage(message: String) {
        
        // For Dismissing the Popup
        dismissPopup()
        
        // Dismiss current Viewcontroller and back to ViewController
        let alert = UIAlertController(title: "Message", message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Return", style: UIAlertAction.Style.default, handler: nil))
        if let window = UIApplication.shared.delegate?.window {
            if let viewController = window?.rootViewController {
                DispatchQueue.main.async {
                    viewController.present(alert, animated: true, completion: nil)
                }
            }
        }
    }
    func dismissPopup() {
        // For Dismissing the Popup
        DispatchQueue.main.async {
            if let window = UIApplication.shared.delegate?.window {
                if let viewController = window?.rootViewController {
                    // handle navigation controllers
                    if(viewController is PopupViewController){
                        viewController.dismiss(animated: true)
                    }
                }
            }
        }
    }
    func presentLoading() {
        let swiftUIView = LottieView(name: "loading-animation", loopMode: .loop)
            .frame(width: 100, height: 100)
        
        let viewCtrl = UIHostingController(rootView: swiftUIView)
        let popupVC = PopupViewController(contentController: viewCtrl, popupWidth: 100, popupHeight: 100)
        
        viewCtrl.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        
        DispatchQueue.main.async {
            if let window = UIApplication.shared.delegate?.window {
                if let viewController = window?.rootViewController {
                    viewController.present(popupVC, animated: true)
                }
            }
        }
    }
}

