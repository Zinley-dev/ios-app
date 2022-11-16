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
        let email: AnyObserver<String>
        let password: AnyObserver<String>
        let phone: AnyObserver<String>
        let name: AnyObserver<String>
        let registerTapped: AnyObserver<Void>
    }
    
    struct Output{
        let errorsObservable: Observable<Error>
        let registerResultObservable: Observable<Bool>
    }
    
    let input: Input
    let output: Output
    
    private let emailTextPublishedSubject = PublishSubject<String>()
    private let passwordTextPublishedSubject = PublishSubject<String>()
    private let phoneTextPublishedSubject = PublishSubject<String>()
    private let nameTextPublishedSubject = PublishSubject<String>()
    private let registerTappedPublishedSubject = PublishSubject<Void>()
    private let errorsPublishedSubject = PublishSubject<Error>()
    private let registerResultSubject = PublishSubject<Bool>()
    
    private var registerModelObservable: Observable<RegisterModel> {
        return Observable.combineLatest(emailTextPublishedSubject.asObservable(), passwordTextPublishedSubject.asObservable(), phoneTextPublishedSubject.asObservable(), nameTextPublishedSubject.asObservable()) {(email, password, phone, name) in
            return RegisterModel(email: email, password: password, phone: phone, name: name)
        }
    }
    
    init() {
        input = Input(email: emailTextPublishedSubject.asObserver(), password: passwordTextPublishedSubject.asObserver(), phone: phoneTextPublishedSubject.asObserver(), name: nameTextPublishedSubject.asObserver(), registerTapped: registerTappedPublishedSubject.asObserver())
        
        output = Output(errorsObservable: errorsPublishedSubject.asObservable(), registerResultObservable: registerResultSubject.asObservable())
        
        registerTappedPublishedSubject
            .withLatestFrom(registerModelObservable)
            .subscribe { [self] (registerModel) -> Void in
                // if (isNotValidInput)
                let params = ["email": registerModel.email, "password": registerModel.password, "phone": registerModel.phone, "name": registerModel.name]
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


    func register(email: String, password: String, phone: String, name: String){
        let params = ["email": email, "password": password, "phone": phone, "name": name]
        APIManager().signUp(params){ result in
            print(result)
        }
    }
}

