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
    let passwordMatched: Bool
}


class RegisterViewModel: ViewModelProtocol{
    
    struct Input{
        let userName: AnyObserver<String>
        let password: AnyObserver<String>
        let reEnterPassword: AnyObserver<String>
        let registerTapped: AnyObserver<Void>
    }
    
    struct Output{
        let errorsObservable: Observable<Error>
        let isValidPasswordObservable: Observable<PasswordError>
        let registerResultObservable: Observable<Bool>
        let validReEnterPasswordObservable: Observable<Bool>
    }
    
    let input: Input
    let output: Output
    
    private let disposeBag = DisposeBag()
    private let userNameTextPublishedSubject = PublishSubject<String>()
    private let passwordTextPublishedSubject = PublishSubject<String>()
    private let reEnterPasswordTextPublishedSubject = PublishSubject<String>()
    private let registerDidTapPublishedSubject = PublishSubject<Void>()
    private let validReEnterPasswordSubject = PublishSubject<Bool>()
    private let errorsPublishedSubject = PublishSubject<Error>()
    private let isValidPasswordSubject = PublishSubject<PasswordError>()
    private let registerResultSubject = PublishSubject<Bool>()
    private let registerModelSubject = PublishSubject<RegisterModel>()
    
    
    private var registerModelObservable: Observable<RegisterModel> {
        return Observable.combineLatest(userNameTextPublishedSubject.asObservable(), passwordTextPublishedSubject.asObservable()) {(userName, password) in
            return RegisterModel(userName: userName, password: password)
        }
    }
    
    init() {
        input = Input(userName: userNameTextPublishedSubject.asObserver(),
                      password: passwordTextPublishedSubject.asObserver(),
                      reEnterPassword: reEnterPasswordTextPublishedSubject.asObserver(),
                      registerTapped: registerDidTapPublishedSubject.asObserver())
        
        output = Output(errorsObservable: errorsPublishedSubject.asObservable(), isValidPasswordObservable: isValidPasswordSubject.asObservable(), registerResultObservable: registerResultSubject.asObservable(), validReEnterPasswordObservable: validReEnterPasswordSubject.asObservable())
        
        passwordTextPublishedSubject.asObservable()
            .subscribe(onNext: { [self] (password) in
            isValidPasswordSubject.onNext(PasswordError(
                minCharacters: (isNotValidInput(Input: password, RegEx: "^.{8,}$")) ,
                minNumber: (isNotValidInput(Input: password, RegEx: ".*[0-9]+.*")),
                minUppercase: (isNotValidInput(Input: password, RegEx: ".*[A-Z]+.*")),
                minLowercase: (isNotValidInput(Input: password, RegEx: ".*[a-z]+.*")) ,
                minSpecialCharacter: (isNotValidInput(Input: password, RegEx: ".*[!&^%$#@()/]+.*")),
                isEmpty: (password == ""),
                passwordMatched: (password == "")))
        })
        
        reEnterPasswordTextPublishedSubject.asObservable().withLatestFrom(passwordTextPublishedSubject.asObservable())
        {
            repassword, pass in
            if(repassword == pass) {
                self.validReEnterPasswordSubject.onNext(true)
            }
        }
        
        registerDidTapPublishedSubject
            .withLatestFrom(registerModelObservable)
            .subscribe { [self] (registerModels) -> Void in
                if (registerModels.userName == "" || registerModels.password == "") {
                    self.errorsPublishedSubject.onNext(NSError(domain: "Empty Username or Password", code: 201))
                    self.registerResultSubject.onNext(false)
                    return;
                }
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
                            self.errorsPublishedSubject.onNext(error)
                        }
                    case .failure:
                        self.errorsPublishedSubject.onNext(NSError(domain: "Error", code: 301))
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

