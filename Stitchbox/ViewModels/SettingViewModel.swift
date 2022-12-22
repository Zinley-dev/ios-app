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
    
    struct Input {
//        var allowChallenge: AnyObserver<Bool>
//        var allowDiscordLink: AnyObserver<Bool>
//        var autoMinimize: AnyObserver<Bool>
//        var autoPlaySound: AnyObserver<Bool>
//        var challengeNotification: AnyObserver<Bool>
//        var commentNotification: AnyObserver<Bool>
//        var followNotification: AnyObserver<Bool>
//        var highlightNotification: AnyObserver<Bool>
//        var mentionNotification: AnyObserver<Bool>
//        var messageNotification: AnyObserver<Bool>
    }
    
    struct Action {}
    
    struct Output {
//        var allowChallenge: Observable<Bool>
//        var allowDiscordLink: Observable<Bool>
//        var autoMinimize: Observable<Bool>
//        var autoPlaySound: Observable<Bool>
//        var challengeNotification: Observable<Bool>
//        var commentNotification: Observable<Bool>
//        var followNotification: Observable<Bool>
//        var highlightNotification: Observable<Bool>
//        var mentionNotification: Observable<Bool>
//        var messageNotification: Observable<Bool>
    }
    
    
    
    init() {
        input = Input(
        )
        
        action = Action()
        
        output = Output()
        
        logic()
        
    }
    
    func logic() {
        
    }
    
}
