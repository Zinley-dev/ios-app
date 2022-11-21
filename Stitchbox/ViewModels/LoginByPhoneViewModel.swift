//
//  LoginByPhoneViewController.swift
//  Stitchbox
//
//  Created by Khanh Duy Nguyen on 11/13/22.
//

import Foundation
import RxSwift

class LoginByPhoneViewModel: ViewModelProtocol {
    struct Input {
        let phone: AnyObserver<String>
        let countryCode: AnyObserver<String>
        let code: AnyObserver<String>
        let verifyOTPDidTap: AnyObserver<Void>
        let sendOTPDidTap: AnyObserver<Void>
    }
    struct Output {
        let OTPSentObservable: Observable<Bool>
        let logInResultObservable: Observable<Bool>
        let errorsObservable: Observable<Error>
    }
    struct verifyAPIInput {
        let phone: String
        let countryCode: String
        let code: String
    }
    struct sendAPIInput {
        let phone: String
        let countryCode: String
        let via: String
    }
    let input: Input
    let output: Output
    
    private let phoneSubject = PublishSubject<String>()
    private let countryCodeSubject = PublishSubject<String>()
    private let codeSubject = PublishSubject<String>()
    private let verifyOTPDidTapSubject = PublishSubject<Void>()
    private let sendOTPDidTapSubject = PublishSubject<Void>()
    private let OTPSentSubject = PublishSubject<Bool>()
    private let logInResultSubject = PublishSubject<Bool>()
    private let errorsSubject = PublishSubject<Error>()
    
    
    init() {
        input = Input(phone: phoneSubject.asObserver(),
                      countryCode: countryCodeSubject.asObserver(),
                      code: codeSubject.asObserver(),
                      verifyOTPDidTap: verifyOTPDidTapSubject.asObserver(),
                      sendOTPDidTap: sendOTPDidTapSubject.asObserver())
        
        output = Output(OTPSentObservable: OTPSentSubject.asObservable(),
                        logInResultObservable: logInResultSubject.asObservable(),
                        errorsObservable: errorsSubject.asObservable())
        
        let verifyApiInputObservable = Observable.combineLatest(phoneSubject.asObservable(), countryCodeSubject.asObservable(), codeSubject.asObservable()){ (phone, countryCode, code) in return verifyAPIInput(phone: phone, countryCode: countryCode, code: code)}
        
        
        verifyOTPDidTapSubject
            .withLatestFrom(verifyApiInputObservable)
            .subscribe { [self] (input) -> Void in
                // check username or password in the right format
                if (isNotValidInput(Input: input.phone, RegEx: "^\\(?\\d{3}\\)?[ -]?\\d{3}[ -]?\\d{4}$")
                    || isNotValidInput(Input: input.countryCode, RegEx: "^(\\+?\\d{1,3}|\\d{1,4})$")
                    || isNotValidInput(Input: input.code, RegEx: "^[0-9]{6}$")) {
                    self.errorsSubject.onNext(NSError(domain: "OTP in wrong format", code: 200))
                    return;
                }
                // call api toward login api of backend
                APIManager().phoneVerify(phone: input.phone, countryCode: input.countryCode, code: input.code) { result in switch result {
                    
                case .success(let apiResponse):
                    // get and process data
                    if (apiResponse.body?["status"] as! String == "ok") {
                        // get and process data
                        let data = apiResponse.body?["data"] as! [String: Any]?
                        do{
                            let account = try Account(JSONbody: data, type: .phoneLogin)
                            print(account)
                            //                             Create JSON Encoder
                            let encoder = JSONEncoder()
                            
                            // Encode Note
                            let data = try encoder.encode(account)
                            
                            // Write/Set Data
                            UserDefaults.standard.set(data, forKey: "userAccount")
                            
                            if let data = UserDefaults.standard.data(forKey: "userAccount") {
                                // Create JSON Decoder
                                let decoder = JSONDecoder()
                                
                                // Decode Note
                                let accountDecoded = try decoder.decode(Account.self, from: data)
                                print(accountDecoded)
                            }
                            self.logInResultSubject.onNext(true);
                            
                        } catch {
                            print("Unable to Create Account (\(error))")
                        }        }
                    
                case .failure(let error):
                    print(error)
                    switch error {
                    case .authRequired(let body):
                        self.errorsSubject.onNext(NSError(domain: body?["message"] as? String ?? "Cannot verify OTP", code: 401))
                    case .requestFailed(let body):
                        self.errorsSubject.onNext(NSError(domain: body?["message"] as? String ?? "Cannot verify OTP", code: 401))
                        
                    default:
                        self.errorsSubject.onNext(NSError(domain: "Cannot verify OTP", code: 401))
                        
                    }
                }
                }
            }
        let sendApiInputObservable = Observable.combineLatest(phoneSubject.asObservable(), countryCodeSubject.asObservable()){ (phone, countryCode) in return sendAPIInput(phone: phone, countryCode: countryCode, via: "sms")
        }
        
        sendOTPDidTapSubject
            .withLatestFrom(sendApiInputObservable)
            .subscribe { [self] (Input) -> Void in
                // check username or password in the right format
                if (isNotValidInput(Input: Input.phone, RegEx: #"^\(?\d{3}\)?[ -]?\d{3}[ -]?\d{4}$"#)
                    || isNotValidInput(Input: Input.countryCode, RegEx: "^(\\+?\\d{1,3}|\\d{1,4})$")) {
                    self.errorsSubject.onNext(NSError(domain: "Phone Number in wrong format", code: 200))
                    return;
                }
                // call api toward login api of backend
                print(Input)
                APIManager().phoneLogin(phone: Input.phone, countryCode: Input.countryCode, via: Input.via) { result in switch result {
                case .success(let apiResponse):
                    // get and process data
                    let data = apiResponse.body?["data"] as! [String: Any]?
                    do{
                        self.OTPSentSubject.onNext(true)
                    } catch {
                        self.errorsSubject.onNext(error)
                    }
                case .failure(let error):
                    print(error)
                    self.errorsSubject.onNext(NSError(domain: "Error in send OTP", code: 300))
                }
                }
            }
        // MARK: Helper function
        func isNotValidInput(Input:String, RegEx: String) -> Bool {
            let Test = NSPredicate(format:"SELF MATCHES %@", RegEx)
            print(Input + String(Test.evaluate(with: Input)))
            return !Test.evaluate(with: Input)
        }
    }
}
