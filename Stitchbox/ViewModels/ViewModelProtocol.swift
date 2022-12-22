//
//  ViewModelProtocol.swift
//  Stitchbox
//
//  Created by Khanh Duy Nguyen on 11/12/22.
//

import Foundation

protocol ViewModelProtocol {
    // MARK: Type declarations
    associatedtype Input
    associatedtype Action
    associatedtype Output
    var input: Input { get }
    var action: Action { get }
    var output: Output { get }
}

