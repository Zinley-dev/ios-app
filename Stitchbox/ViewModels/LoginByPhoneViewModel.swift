//
//  LoginByPhoneViewController.swift
//  Stitchbox
//
//  Created by Khanh Duy Nguyen on 11/13/22.
//

import Foundation
import RxSwift
import ObjectMapper
import OneSignal

class LoginByPhoneSendCodeViewModel: ViewModelProtocol {
    struct Input {}
    struct Action {
        let sendOTPDidTap: AnyObserver<(String, String)>
    }
    struct Output {
        let OTPSentObservable: Observable<Bool>
        let errorsObservable: Observable<Error>
    }
    struct sendAPIInput {
        let phone: String
        let countryCode: String
        let via: String
    }
    let input: Input
    let action: Action
    let output: Output
    
    private let sendOTPDidTapSubject = PublishSubject<(String, String)>()
    private let OTPSentSubject = PublishSubject<Bool>()
    private let logInResultSubject = PublishSubject<Bool>()
    private let errorsSubject = PublishSubject<Error>()
    private let disposeBag = DisposeBag()
    
    init() {
        input = Input()
        action = Action(sendOTPDidTap: sendOTPDidTapSubject.asObserver())
        output = Output(OTPSentObservable: OTPSentSubject.asObservable(),
                        errorsObservable: errorsSubject.asObservable())
        logic()
    }
    
    func logic() {
        sendOTPDidTapSubject.asObservable()
            .subscribe (onNext: { (phone, countryCode) in
                
                if(isNotValidInput(Input: phone, RegEx: #"^\(?\d{3}\)?[ -]?\d{3}[ -]?\d{3,4}$"#)
                   || isNotValidInput(Input: countryCode, RegEx: "^(\\+?\\d{1,3}|\\d{1,4})$")) {
                    self.errorsSubject.onNext(NSError(domain: "Phone Number in wrong format", code: 200))
                    return;
                }
                
                print("=====LOGIN=====")
                print(phone, countryCode)
                print(phone.formatPhoneNumber())
                // call api toward login api of backend
                APIManager.shared.phoneLogin(phone: countryCode + phone.formatPhoneNumber()) { [weak self] result in
                    guard let self = self else { return }
                    
                    switch result {
                    case .success(let apiResponse):
                        // get and process data
                        print(apiResponse)
                        if let data = apiResponse.body?["data"], data != nil {
                            let newUserData = Mapper<UserDataSource>().map(JSON: ["phone": "\(countryCode)\(phone.formatPhoneNumber())", "signinMethod": "phone"])
                            _AppCoreData.userDataSource.accept(newUserData)
                            self.OTPSentSubject.onNext(true)
                        } else {
                            self.OTPSentSubject.onNext(false)
                        }
                    case .failure(let error):
                        print(error)
                        self.errorsSubject.onNext(NSError(domain: "Error in send OTP", code: 300))
                    }
                }
            }).disposed(by: disposeBag)
    }
}


class LoginByPhoneVerifyViewModel: ViewModelProtocol {
    
    struct Input {
        let phoneObserver: AnyObserver<String>
        let countryCodeObserver: AnyObserver<String>
    }
    struct Action {
        let verifyOTPDidTap: AnyObserver<String>
        let sendOTPDidTap: AnyObserver<Void>
    }
    struct Output {
        let loadingObservable: Observable<Bool>
        let successObservable: Observable<SuccessMessage>
        let errorsObservable: Observable<Error>
        var phoneNumber: String
        var type: String
        var method: String
    }
    enum SuccessMessage{
        case sendCodeSuccess
        case logInSuccess
        case changePassword
    }
    let input: Input
    let action: Action
    var output: Output
    
    private let phoneSubject = PublishSubject<String>()
    private let countryCodeSubject = PublishSubject<String>()
    private let codeSubject = PublishSubject<String>()
    private let verifyOTPDidTapSubject = PublishSubject<String>()
    private let sendOTPDidTapSubject = PublishSubject<Void>()
    private let successSubject = PublishSubject<SuccessMessage>()
    private let errorsSubject = PublishSubject<Error>()
    private let loadingSubject = PublishSubject<Bool>()
    private let disposeBag = DisposeBag()
    
    init() {
        input = Input(phoneObserver: phoneSubject.asObserver(),
                      countryCodeObserver: countryCodeSubject.asObserver())
        action = Action(verifyOTPDidTap: verifyOTPDidTapSubject.asObserver(),
                        sendOTPDidTap: sendOTPDidTapSubject.asObserver())
        output = Output(loadingObservable: loadingSubject.asObservable(),
                        successObservable: successSubject.asObservable(),
                        errorsObservable: errorsSubject.asObservable(),
                        phoneNumber: "",
                        type: "",
                        method: "")
        logic()
    }
    
    func storeUserSession(account: Account?) {
        // Write/Set Data
        let sessionToken = SessionDataSource.init(JSONString: "{}")!
        sessionToken.accessToken = account?.accessToken
        sessionToken.refreshToken = account?.refreshToken
        _AppCoreData.userSession.accept(sessionToken)
    }
    
    func storeUserData(user newUserData: UserDataSource) {
        _AppCoreData.userDataSource.accept(newUserData)
    }
    
    func pushOneSignal(user newUserData: UserDataSource) {
        if newUserData.userID != "" {
            
            let externalUserId = newUserData.userID!
            
            OneSignal.setExternalUserId(externalUserId, withSuccess: { results in
                print("External user id update complete with results: ", results!.description)
            }, withFailure: {error in
                print("Set external user id done with error: " + error.debugDescription)
            })
        }
    }
    
    func logic() {
        print("LOGIC")
        Observable.zip(countryCodeSubject.asObservable(), phoneSubject.asObservable()) {$0 + " " + $1}.subscribe {
            self.output.phoneNumber = $0
        }
        verifyOTPDidTapSubject
            .withLatestFrom(phoneSubject.asObservable())
        {(phone: $1, code: $0)}
            .withLatestFrom(countryCodeSubject.asObservable())
        {(phone: $0.phone, countryCode: $1, code: $0.code)}
            .subscribe (onNext: {(phone, countryCode, code) in
                print("\(phone)========\(countryCode)====\(code)====== \(self.output.type)=====\(self.output.phoneNumber)")
                
                if (self.output.type == "email") {
                    self.loadingSubject.onNext(true)
                    APIManager.shared.emailVerify(email: phone, OTP: code) { [weak self] result in
                        guard let self = self else { return }
                        
                        switch result {
                        case .success(let apiResponse):
                            // get and process data
                            if (apiResponse.body?["message"] as! String == "success") {
                                // get and process data
                                let data = apiResponse.body?["data"] as! [String: Any]?
                                let account =  Mapper<Account>().map(JSONObject: data)
                                
                                self.storeUserSession(account: account)
                                // write usr data
                                if let newUserData = Mapper<UserDataSource>().map(JSON: data?["user"] as! [String: Any]) {
                                    self.storeUserData(user: newUserData)
                                    self.pushOneSignal(user: newUserData)
                                }
                                if self.output.method == "change-password" {
                                    self.successSubject.onNext(.changePassword)
                                } else {
                                    self.successSubject.onNext(.logInSuccess)
                                }
                                self.loadingSubject.onNext(false)
                                
                            }
                            
                        case .failure(let error):
                            print(error)
                            self.loadingSubject.onNext(false)
                            switch error {
                            case .authRequired(let body):
                                self.errorsSubject.onNext(NSError(domain: body?["message"] as? String ?? "Cannot verify OTP", code: 401))
                            case .requestFailed(let body):
                                self.errorsSubject.onNext(NSError(
                                    domain: body?["message"] as? String ?? "Cannot verify OTP",
                                    code: Int(body?["error"] as! String) ?? 404
                                ))
                                
                            default:
                                self.errorsSubject.onNext(NSError(domain: "Cannot verify OTP", code: 401))
                                
                            }
                        }
                    }
                }
                else if (self.output.type == "phone") {
                    self.loadingSubject.onNext(true)
                    print("VERIFY OTP \("+" + phone.formatPhoneNumber()) --- CODE \(code)")
                    APIManager.shared.phoneVerify(phone: "+" + phone.formatPhoneNumber(), OTP: code) { [weak self] result in
                        guard let self = self else { return }
                        
                        switch result {
                        case .success(let apiResponse):
                            // get and process data
                            if (apiResponse.body?["message"] as! String == "success") {
                                // get and process data
                                let data = apiResponse.body?["data"] as! [String: Any]?
                                let account =  Mapper<Account>().map(JSONObject: data)
                                
                                self.storeUserSession(account: account)
                                // write usr data
                                if let newUserData = Mapper<UserDataSource>().map(JSON: data?["user"] as! [String: Any]) {
                                    self.storeUserData(user: newUserData)
                                    self.pushOneSignal(user: newUserData)
                                }
                                
                                if self.output.method == "change-password" {
                                    self.successSubject.onNext(.changePassword)
                                } else {
                                    self.successSubject.onNext(.logInSuccess)
                                }
                                self.loadingSubject.onNext(false)
                                
                            }
                            
                        case .failure(let error):
                            print(error)
                            self.loadingSubject.onNext(false)
                            switch error {
                            case .authRequired(let body):
                                self.errorsSubject.onNext(NSError(domain: body?["message"] as? String ?? "Cannot verify OTP", code: 401))
                            case .requestFailed(let body):
                                self.errorsSubject.onNext(NSError(
                                    domain: body?["message"] as? String ?? "Cannot verify OTP",
                                    code: Int(body?["error"] as! String) ?? 404
                                ))
                                
                            default:
                                self.errorsSubject.onNext(NSError(domain: "Cannot verify OTP", code: 401))
                                
                            }
                        }
                    }
                } else {
                    
                    if (isNotValidInput(Input: phone, RegEx: "^\\(?\\d{3}\\)?[ -]?\\d{3}[ -]?\\d{3,4}$")
                        || isNotValidInput(Input: countryCode, RegEx: "^(\\+?\\d{1,3}|\\d{1,4})$")
                        || isNotValidInput(Input: code, RegEx: "^[0-9]{6}$")) {
                        self.errorsSubject.onNext(NSError(domain: "OTP in wrong format", code: 200))
                        return;
                    }
                    // call api toward login api of backend
                    self.loadingSubject.onNext(true)
                    APIManager.shared.phoneVerify(phone: countryCode + phone.formatPhoneNumber(), OTP: code) { [weak self] result in
                        guard let self = self else { return }
                        
                        switch result {
                        case .success(let apiResponse):
                            // get and process data
                            if (apiResponse.body?["message"] as! String == "success") {
                                // get and process data
                                let data = apiResponse.body?["data"] as! [String: Any]?
                                let account =  Mapper<Account>().map(JSONObject: data)
                                
                                self.storeUserSession(account: account)
                                // write usr data
                                if let newUserData = Mapper<UserDataSource>().map(JSON: data?["user"] as! [String: Any]) {
                                    self.storeUserData(user: newUserData)
                                    self.pushOneSignal(user: newUserData)
                                }
                                
                                
                                self.successSubject.onNext(.logInSuccess)
                                self.loadingSubject.onNext(false)
                                
                            }
                            
                        case .failure(let error):
                            print(error)
                            self.loadingSubject.onNext(false)
                            switch error {
                            case .authRequired(let body):
                                self.errorsSubject.onNext(NSError(domain: body?["message"] as? String ?? "Cannot verify OTP", code: 401))
                            case .requestFailed(let body):
                                self.errorsSubject.onNext(NSError(
                                    domain: body?["message"] as? String ?? "Cannot verify OTP",
                                    code: Int(body?["error"] as! String) ?? 404
                                ))
                                
                            default:
                                self.errorsSubject.onNext(NSError(domain: "Cannot verify OTP", code: 401))
                                
                            }
                        }
                    }
                }
            }).disposed(by: disposeBag)
        
        sendOTPDidTapSubject.asObservable()
            .withLatestFrom(phoneSubject.asObservable())
            .withLatestFrom(countryCodeSubject.asObservable()) {($0, $1)}
            .subscribe (onNext: { (phone, countryCode) in
                if(isNotValidInput(Input: phone, RegEx: #"^\(?\d{3}\)?[ -]?\d{3}[ -]?\d{3,4}$"#)
                   || isNotValidInput(Input: countryCode, RegEx: "^(\\+?\\d{1,3}|\\d{1,4})$")) {
                    self.errorsSubject.onNext(NSError(domain: "Phone Number in wrong format", code: 200))
                    return;
                }
                self.loadingSubject.onNext(true)
                // call api toward login api of backend
                APIManager.shared.phoneLogin(phone: countryCode + phone.formatPhoneNumber()) { [weak self] result in
                    guard let self = self else { return }

                    switch result {
                    case .success(let apiResponse):
                        // get and process data
                        _ = apiResponse.body?["data"] as! [String: Any]?
                        self.successSubject.onNext(.sendCodeSuccess)
                        self.loadingSubject.onNext(false)
                    case .failure(let error):
                        print(error)
                        self.loadingSubject.onNext(false)
                        self.errorsSubject.onNext(NSError(domain: "Error in send OTP", code: 300))
                    }
                }
                
                
            }).disposed(by: disposeBag)
    }
}
