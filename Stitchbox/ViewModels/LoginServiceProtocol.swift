//
//  LoginServiceProtocol.swift
//  Stitchbox
//
//  Created by Khanh Duy Nguyen on 11/12/22.
//

import Foundation
import RxSwift
import Unbox

protocol LoginServiceProtocol {
    func signIn(with credentials: Credentials) -> Observable<Account>
}

class LoginService: LoginServiceProtocol {
    func signIn(with credentials: Credentials) -> Observable<Account> {
        return Observable.create { observer in
            /*
             Networking logic here.
             */
            
            APIManager().normalLogin(email: credentials.email,
                                     password: credentials.password) {
                result in {
                    switch result{
                    case .success(let returnJSON):
                        observer.onNext(try Account(JSONbody: returnJSON.body))
                    case .failure(let error):
                        observer.onError(error)
                    }
                }
            } // Simulation of successful user authentication.
            return Disposables.create()
        }
    }
}
