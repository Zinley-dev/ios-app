//
//  RegisterViewModel.swift
//  Stitchbox
//
//  Created by Anh Nguyen on 11/9/22.
//

import RxCocoa
import UIKit
import RxSwift



class RegisterViewModel: ViewModelProtocol{
    
    struct Input{
        let userName: AnyObserver<String>
        let password: AnyObserver<String>
        let registerTapped: AnyObserver<Void>
    }
    
    struct Output{
        let errorsObservable: Observable<Error>
        let registerResultObservable: Observable<Bool>
    }
    
    let input: Input
    let output: Output
    
    private let userNameTextPublishedSubject = PublishSubject<String>()
    private let passwordTextPublishedSubject = PublishSubject<String>()

    private let registerTappedPublishedSubject = PublishSubject<Void>()
    private let errorsPublishedSubject = PublishSubject<Error>()
    private let registerResultSubject = PublishSubject<Bool>()
    
  
    
    private var registerModelObservable: Observable<RegisterModel> {
        return Observable.combineLatest(passwordTextPublishedSubject.asObservable(), userNameTextPublishedSubject.asObservable()) {(userName, password) in
            return RegisterModel(userName: userName, password: password)
        }
    }
    
    init() {
        input = Input(userName: userNameTextPublishedSubject.asObserver(),
                      password: passwordTextPublishedSubject.asObserver(),
                      registerTapped: registerTappedPublishedSubject.asObserver())
        
        output = Output(errorsObservable: errorsPublishedSubject.asObservable(), registerResultObservable: registerResultSubject.asObservable())
        
        registerTappedPublishedSubject
            .withLatestFrom(registerModelObservable)
            .subscribe { [self] (registerModels) -> Void in
                //if (isValidPassword())
                let params = ["name": registerModels.userName, "password": registerModels.password]
                APIManager().signUp(params){ result in switch result{
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

    func isUpperCase() -> Bool {
        return NSPredicate(format:"SELF MATCHES %@", ".*[A-Z]+.*").evaluate(with: self)
    }
        
    func containsDigit() -> Bool {
        return NSPredicate(format:"SELF MATCHES %@", ".*[0-9]+.*").evaluate(with: self)
        }
    
    func containsOneSymbol() -> Bool {
        return NSPredicate(format:"SELF MATCHES %@", ".*[!&^%$#@()/]+.*").evaluate(with: self)
        }
    
    func isLowerCase()-> Bool {
        return NSPredicate(format:"SELF MATCHES %@", ".*[a-z]+.*").evaluate(with: self)
        }
//    func isMinCharacters()-> Bool {
//        return (self.count < 8)
//
//        }
      
    
    
//    func isValidPassword() -> Bool {
//        let passwordPattern =
//            // At least 8 characters
//            #"(?=.{8,})"# +
//
//            // At least one capital letter
//            #"(?=.*[A-Z])"# +
//
//            // At least one lowercase letter
//            #"(?=.*[a-z])"# +
//
//            // At least one digit
//            #"(?=.*\d)"# +
//
//            // At least one special character
//            #"(?=.*[ !$%&?._-])"#
//
//        let password = self.trimmingCharacters(in: CharacterSet.whitespaces)
//        let passwordRegx = "^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[#?!@$%^&<>*~:`-]).{8,}$"
//        let passwordCheck = NSPredicate(format: "SELF MATCHES %@",passwordRegx)
//        return passwordCheck.evaluate(with: password)
//
//    }
    
    
    func register(userName: String, password: String){
        let params = ["username": userName, "password": password]
        APIManager().signUp(params){ result in
            print(result)
        }
    }
}

