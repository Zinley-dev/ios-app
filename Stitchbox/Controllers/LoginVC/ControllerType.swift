//
//  ControllerType.swift
//  Stitchbox
//
//  Created by Khanh Duy Nguyen on 11/12/22.
//

import Foundation
import UIKit

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
        let alert = UIAlertController(title: "Error", message: error._domain, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Return", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func presentMessage(message: String) {
        let alert = UIAlertController(title: "Message", message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Return", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}


