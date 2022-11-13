//
//  LoginByPhoneViewController.swift
//  Stitchbox
//
//  Created by Khanh Duy Nguyen on 11/13/22.
//

import Foundation
import RxSwift

class LoginByPhoneVerifyViewModel: ViewModelProtocol {
    struct Input {
        let phone: AnyObserver<String?>
        let countryCode: AnyObserver<String?>
        let code: AnyObserver<String?>
        let verifyOTPDidTap: AnyObserver<Void>
    }
    struct Output {
        let OTPSentObservable: Observable<String>
        let errorsObservable: Observable<Error>
    }
    
    let input: Input
    let output: Output
    
    private let phoneSubject = PublishSubject<String?>()
    private let countryCodeSubject = PublishSubject<String?>()
    private let codeSubject = PublishSubject<String?>()
    private let verifyOTPDidTapSubject = PublishSubject<Void>()
    private let OTPSentSubject = PublishSubject<String>()
    private let errorsSubject = PublishSubject<Error>()
        
    init() {
        input = Input(phone: phoneSubject.asObserver(),
                      countryCode: countryCodeSubject.asObserver(),
                      code: codeSubject.asObserver(),
                      verifyOTPDidTap: verifyOTPDidTapSubject.asObserver())
        
        output = Output(OTPSentObservable: OTPSentSubject.asObservable(),
                        errorsObservable: errorsSubject.asObservable())
    }
}
