//
//  UserModel.swift
//  Stitchbox
//
//  Created by Khanh Duy Nguyen on 11/11/22.
//

import Foundation

import RxSwift
import RxCocoa

import Alamofire

typealias AccessToken = String

struct NormalLoginAPI{
    static private var email: String = "placeholder"
    static private var password: String = "placeholder"
    static var isLocal: Bool {
        return email == "placeholder"
    }
    private var refreshToken: String
    private var accessToken: String
    private var account: Account
    
    // logged or not
    enum AccountStatus {
        case unavailable
        case authorized(accessToken: AccessToken, refreshToken: AccessToken)
    }
    
    enum Errors: Error {
        case unableToGetToken, invalidResponse
    }
    
    var `default`: Driver<AccountStatus> {
        return login
    }
    
    private var login: Driver<AccountStatus> {
        return Observable.create({ observer in
            var request: DataRequest?
            
            if let storedAccessToken = UserDefaults.standard.string(forKey: "accessToken")
                , let storedRefreshToken =  UserDefaults.standard.string(forKey: "refreshToken"){
                observer.onNext(.authorized(accessToken: storedAccessToken, refreshToken: storedRefreshToken))
            } else {
                request = APIManager().normalLogin(email: NormalLoginViewModel.email, password: NormalLoginViewModel.password)
                { response in
                    guard let accessToken = response["accessToken"] else {
                        observer.onNext(.unavailable)
                        return
                    }
                    guard let refreshToken = response["refreshToken"] else {
                        observer.onNext(.unavailable)
                        return
                    }
                    self.account = Account(response)
                    UserDefaults.standard.set(refreshToken, forKey: "refreshToken")
                    UserDefaults.standard.set(accessToken, forKey: "accessToken")
                    observer.onNext(.authorized(accessToken: accessToken, refreshToken: refreshToken))
                }
            }
            
            return Disposables.create {
                request?.cancel()
            }
            
        }).asDriver(onErrorJustReturn: .unavailable)
    }
}
