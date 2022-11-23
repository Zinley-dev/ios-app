//
//  RegisterViewModel.swift
//  Stitchbox
//
//  Created by Anh Nguyen on 11/9/22.
//

import RxCocoa
import UIKit
import RxSwift

struct PasswordError: Error {
    let minCharacters: Bool
    let minNumber: Bool
    let minUppercase: Bool
    let minLowercase: Bool
    let minSpecialCharacter: Bool
    let isEmpty: Bool
}


class RegisterViewModel: ViewModelProtocol{
    
    struct Input {
        let userName: AnyObserver<String>
        let password: AnyObserver<String>
        let reEnterPassword: AnyObserver<String>
    }
    
    struct Action {
        let registerDidTap: AnyObserver<(String, String)>
    }
    
    struct Output {
        let errorsObservable: Observable<Error>
        let isValidPasswordObservable: Observable<PasswordError>
        let registerResultObservable: Observable<Bool>
        var validMatch: Observable<Bool>
    }
    
    let input: Input
    let action: Action
    let output: Output
    private let disposeBag = DisposeBag()
    
    private let userNameTextSubject = PublishSubject<String>()
    private let passwordTextSubject = PublishSubject<String>()
    private var reEnterPasswordTextSubject = PublishSubject<String>()
    private let registerDidTapSubject = PublishSubject<(String, String)>()
    private let validReEnterPasswordSubject = PublishSubject<Bool>()
    private let errorsSubject = PublishSubject<Error>()
    private let isValidPasswordSubject = PublishSubject<PasswordError>()
    private let registerResultSubject = PublishSubject<Bool>()
    private let registerModelSubject = PublishSubject<RegisterModel>()
    
 
    
    
    init() {
        input = Input(userName: userNameTextSubject.asObserver(),
                      password: passwordTextSubject.asObserver(),
                      reEnterPassword: reEnterPasswordTextSubject.asObserver())
        
        action = Action(registerDidTap: registerDidTapSubject.asObserver())
        
        output = Output(errorsObservable: errorsSubject.asObservable(), isValidPasswordObservable: isValidPasswordSubject.asObservable(), registerResultObservable: registerResultSubject.asObservable(), validMatch: validReEnterPasswordSubject.asObservable())
        
        logic()
    }
    
    func logic() {
        
        var validMatch: Observable<Bool> {
            return Observable.combineLatest(passwordTextSubject.asObservable(), reEnterPasswordTextSubject.asObservable()) {(pass,repass) in
                if (pass.isEqualToString(find: repass)) {
                    self.validReEnterPasswordSubject.onNext(true)
                    return true
                }else {self.validReEnterPasswordSubject.onNext(false)
                    return false
                }
                    }
            
        }

        var registerModelObservable: Observable<RegisterModel> {
            return Observable.combineLatest(userNameTextSubject.asObservable(), passwordTextSubject.asObservable()) {(userName, password) in
                return RegisterModel(userName: userName, password: password)
            }
        }
        
        // Password TextField Strength Checker
        passwordTextSubject.asObservable()
            .subscribe(onNext: { [self] (password) in
                isValidPasswordSubject.onNext(PasswordError(
                    minCharacters: (isNotValidInput(Input: password, RegEx: "^.{8,}$")) ,
                    minNumber: (isNotValidInput(Input: password, RegEx: ".*[0-9]+.*")),
                    minUppercase: (isNotValidInput(Input: password, RegEx: ".*[A-Z]+.*")),
                    minLowercase: (isNotValidInput(Input: password, RegEx: ".*[a-z]+.*")) ,
                    minSpecialCharacter: (isNotValidInput(Input: password, RegEx: ".*[!&^%$#@()/]+.*")),
                    isEmpty: (password == "")))
            })
        
        // Password comfirmed checker
        reEnterPasswordTextSubject.asObservable()
            .withLatestFrom(validMatch.asObservable())
            .subscribe(onNext:{ [self] repass in
                if (repass){
                    self.validReEnterPasswordSubject.onNext(true)
                }else {self.validReEnterPasswordSubject.onNext(false)}
            })
        
        //
        registerDidTapSubject
            .withLatestFrom(registerModelObservable)
            .subscribe { [self] (registerModels) -> Void in
                let params = ["name": registerModels.userName, "password": registerModels.password]
                APIManager().signUp(params){ result in
                    switch result{
                    case .success(let apiResponse):
                        let data = apiResponse.body?["data"] as! [String: Any]?
                        do {
                            let account = try RegisterAccount(JSONbody: data)
                            do {
                                let encoder = JSONEncoder()
                                let data = try encoder.encode(account)
                                UserDefaults.standard.set(data, forKey: "RegisterAccount")
                            } catch {
                                print("Unable to encode the account(\(error)")
                            }
                            self.registerResultSubject.onNext(true)
                        } catch {
                            self.errorsSubject.onNext(error)
                        }
                    case .failure:
                        self.errorsSubject.onNext(NSError(domain: "Error", code: 301))
                    }
                    
                }
            }
    }
    
    // MARK: Get missing validation for password
    func isNotValidInput(Input:String, RegEx: String) -> Bool {
        let Test = NSPredicate(format:"SELF MATCHES %@", RegEx)
        print(Input + String(Test.evaluate(with: Input)))
        return !Test.evaluate(with: Input)
    }
    
    
    // MARK: register function call API
    func register(userName: String, password: String){
        let params = ["username": userName, "password": password]
        APIManager().signUp(params){ result in
            print(result)
        }
    }
}

extension String {
    func isEqualToString(find: String) -> Bool {
        if (String(format: self) == "" || find == "") {
            return false
        }
        else {
            return String(format: self) == find
            
        }
    }
}
