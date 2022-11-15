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
    
    init() {
        input = Input(email: emailTextPublishedSubject.asObserver(), password: passwordTextPublishedSubject.asObserver(), phone: phoneTextPublishedSubject.asObserver(), name: nameTextPublishedSubject.asObserver(), registerTapped: registerTappedPublishedSubject.asObserver())
        
        output = Output(errorsObservable: errorsPublishedSubject.asObservable(), registerResultObservable: registerResultSubject.asObservable())
    }
    
    func isValid() -> Observable<Bool>{
        return Observable.combineLatest(emailTextPublishedSubject.asObservable().startWith(""), passwordTextPublishedSubject.asObservable().startWith("") ).map{ email, password in
            return email.count > 0 && password.count > 0
        }.startWith(false)
    }

    func register(email: String, password: String, phone: String, name: String){
        let params = ["email": email, "password": password, "phone": phone, "name": name]
        APIManager().signUp(params){ result in
            print(result)
        }
    }
}

