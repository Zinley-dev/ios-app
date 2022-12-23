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

extension ControllerType {
    
    func presentError(error: Error) {
        
        // For Dismissing the Popup
        self.dismiss(animated: true){
            
            let alert = UIAlertController(title: "Error", message: error._domain, preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "Return", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)}
    }
    
    func presentMessage(message: String) {
        
        // For Dismissing the Popup
        self.dismiss(animated: true) {
            
            // Dismiss current Viewcontroller and back to ViewController B
            self.navigationController?.popViewController(animated: true)
            let alert = UIAlertController(title: "Message", message: message, preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "Return", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func presentLoading() {
      self.dismiss(animated: true) {
        let popupVC = LoadingViewController()
        popupVC.providesPresentationContextTransitionStyle = true
        popupVC.definesPresentationContext = true
        popupVC.view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.3)
        popupVC.modalPresentationStyle = .overCurrentContext
        self.present(popupVC, animated: false, completion: nil)
      }
    }
    
}


