//
//  RegisterViewModel.swift
//  Stitchbox
//
//  Created by Anh Nguyen on 11/9/22.
//

import RxCocoa
import UIKit
import RxSwift

class RegisterViewModel{
    
    let emailTextPublishedSubject = PublishSubject<String>()
    let passwordTextPublishedSubject = PublishSubject<String>()
    let phoneTextPublishedSubject = PublishSubject<String>()
    let nameTextPublishedSubject = PublishSubject<String>()
    
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

