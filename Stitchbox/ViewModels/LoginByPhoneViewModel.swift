////
////  LoginByPhoneViewController.swift
////  Stitchbox
////
////  Created by Khanh Duy Nguyen on 11/13/22.
////
//
//import Foundation
//import RxSwift
//
//class LoginByPhoneViewModel: ViewModelProtocol {
//    struct Input {
//        let phone: AnyObserver<String?>
//        let countryCode: AnyObserver<String?>
//        let via: AnyObserver<String?>
//        let getOTPDidTap: AnyObserver<Void>
//    }
//    struct Output {
//        let OTPSentObservable: Observable<String>
//        let errorsObservable: Observable<Error>
//    }
//    
//    let input: Input
//    let output: Output
//    
//    private let phoneSubject = PublishSubject<String>()
//    private let countryCodeSubject = PublishSubject<String>()
//    private let viaSubject = PublishSubject<String>()
//    private let getOTPDidTapSubject = PublishSubject<Void>()
//    private let OTPSentSubject = PublishSubject<String>()
//    private let errorsSubject = PublishSubject<Error>()
//        
//    init() {
//        input = Input(phone: phoneSubject.asObserver(),
//                      countryCode: countryCodeSubject.asObserver(),
//                      via: viaSubject.asObserver(),
//                      getOTPDidTap: getOTPDidTapSubject.asObserver())
//        
//        output = Output(OTPSentObservable: OTPSentSubject.asObservable(),
//                        errorsObservable: errorsSubject.asObservable())
//    }
//}
