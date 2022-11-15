//
//  ControllerType.swift
//  Stitchbox
//
//  Created by Khanh Duy Nguyen on 11/12/22.
//

import Foundation
import UIKit

protocol ControllerType {
    associatedtype ViewModelType: ViewModelProtocol
    /// Configurates controller with specified ViewModelProtocol subclass
    ///
    /// - Parameter viewModel: CPViewModel subclass instance to configure with
    func bindUI(with viewModel: ViewModelType)
    /// Factory function for view controller instatiation
    ///
    /// - Parameter viewModel: View model object
    /// - Returns: View controller of concrete type
    static func create(with viewModel: ViewModelType) -> UIViewController
}
