//
//  StartViewModel.swift
//  Stitchbox
//
//  Created by Hisoft Hoangnm on 12/12/2022.
//

import Foundation
import UIKit
import RxSwift

class StartViewModel: ViewModelProtocol {
    
    struct Input {}
    struct Action {}
    struct Output {
        let loginResultObservable: Observable<Bool>
        let errorsObservable: Observable<Error>
    }
        
    let input: Input
    let action: Action
    let output: Output
    
    let vc: UIViewController
    
    private let loginResultSubject = PublishSubject<Bool>()
    private let errorsSubject = PublishSubject<Error>()
    
    public var selectedSignInMethod: SocialLoginType!
    
    private var currentSignInService: LoginCoordinatorProtocol {
        switch selectedSignInMethod {
        case .google: return GoogleSignInService(vm: self)
        case .apple: return AppleSignInService(vm: self)
        case .facebook: return FacebookSignInService(vm: self)
        case .twitter: return TwitterSignInService(vm: self)
        case .tiktok: return TiktokSignInService(vm: self)
        case .none: fatalError("SignIn Method not selected")
        }
    }
    
    public init(vc: UIViewController) {
        self.vc = vc
        input = Input()
        action = Action()
        output = Output(loginResultObservable: loginResultSubject.asObservable(),
                        errorsObservable: errorsSubject.asObservable())
    }
    
    func logic() {
    }
    
    /// Triggered when authentication succeeded from related provider.
    open func completeSignIn(with authResult: AuthResult) {
        print(authResult)
        // call api --> check auth
        
        self.loginResultSubject.onNext(true)
    }
    
    /// Trigger this method (from related provider's button action) to start process.
    open func startSignInProcess(with method: SocialLoginType) {
        switch method {
        case .apple: selectedSignInMethod = .apple
        case .google: selectedSignInMethod = .google
        case .facebook: selectedSignInMethod = .facebook
        case .twitter: selectedSignInMethod = .twitter
        case .tiktok: selectedSignInMethod = .tiktok
        }
        currentSignInService.triggerSignIn()
    }
    
    open func logout() {
//        signInSucceeded = false
        currentSignInService.logout()
    }
}
