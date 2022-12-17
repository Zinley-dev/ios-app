//
//  SettingViewModel.swift
//  Stitchbox
//
//  Created by Khanh Duy Nguyen on 12/17/22.
//

import Foundation
import UIKit
import RxSwift

class SettingViewModel: ViewModelProtocol {
    var input: Input
    
    var action: Action
    
    var output: Output
    
    struct Input {}
    
    struct Action {}
    
    struct Output {}
    
    init() {
        input = Input()
        
        action = Action()
        
        output = Output()
        
        logic()
        
    }
    
    func logic() {
        
    }
    
}
