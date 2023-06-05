//
//  usernameViewModel.swift
//  Stitchbox
//
//  Created by Khanh Duy Nguyen on 11/12/22.
//

import Foundation
import RxSwift
import ObjectMapper
import OneSignal

enum LoginLevel {
    case normal
    case advance(type: String?, value: String?)
}

class LoginControllerViewModel: ViewModelProtocol {
    
    // MARK: Struct Declaration
    struct Input {}
    
    struct Action {
        let signInDidTap: AnyObserver<(String, String)>
    }
    struct Output {
        let loginResultObservable: Observable<LoginLevel>
        let errorsObservable: Observable<Error>
    }
    
    // MARK: Variable Declaration
    let input: Input
    let action: Action
    let output: Output
    
    // MARK: Subject Instantiation
    private let signInDidTapSubject = PublishSubject<(String, String)>()
    private let loginResultSubject = PublishSubject<LoginLevel>()
    private let errorsSubject = PublishSubject<Error>()
    private let disposeBag = DisposeBag()
    
    init() {
        input = Input()
        
        action = Action(signInDidTap: signInDidTapSubject.asObserver())
        
        output = Output(loginResultObservable: loginResultSubject.asObservable(),
                        errorsObservable: errorsSubject.asObservable())
        
        logic()
    }
    
    // MARK: Logic function
    func logic() {
        signInDidTapSubject
            .subscribe (onNext: { (username, password) in
                // check username or password in the right format
                /*
                 if (isNotValidInput(Input: username, RegEx: "\\w{3,18}") ||
                 isNotValidInput(Input: password, RegEx: "\\w{6,18}")) {
                 self.errorsSubject.onNext(NSError(domain: "Username or Password in wrong format", code: 400))
                 return;
                 }
                 */
                // call api toward login api of backend
                APIManager.shared.normalLogin(username: username, password: password) { [unowned self] result in
 
                    switch result {
                    case .success(let apiResponse):
                        // get and process data
                        
                        if let method = apiResponse.body?["method"] as? String, method == "2fa" {
                            let deviceType = apiResponse.body?["deviceType"] as? String
                            let emailOrPhone = apiResponse.body?["value"] as? String
                            self.loginResultSubject.onNext(LoginLevel.advance(type: deviceType, value: emailOrPhone))
                            
                            
                        } else {
                            let data = apiResponse.body?["data"] as! [String: Any]?
                            
                            let account =  Mapper<Account>().map(JSONObject: data)
                            
                            // Write/Set Data
                            let sessionToken = SessionDataSource.init(JSONString: "{}")!
                            sessionToken.accessToken = account?.accessToken
                            sessionToken.refreshToken = account?.refreshToken
                            _AppCoreData.userSession.accept(sessionToken)
                            
                            // write usr data
                            if let newUserData = Mapper<UserDataSource>().map(JSON: data?["user"] as! [String: Any]) {
                                _AppCoreData.userDataSource.accept(newUserData)
                                
                                if newUserData.userID != ""{
                                    let externalUserId = newUserData.userID!
                                    
                                    OneSignal.setExternalUserId(externalUserId, withSuccess: { results in
                                        print("External user id update complete with results: ", results!.description)
                                    }, withFailure: {error in
                                        print("Set external user id done with error: " + error.debugDescription)
                                    })
                                }
                                
                            }
                            self.loginResultSubject.onNext(LoginLevel.normal)
                        }
                    case .failure:
                        self.errorsSubject.onNext(NSError(domain: "Wrong username or password", code: 400))
                    }
                }
            }, onError: { (err) in
                print("Error \(err.localizedDescription)")
            }, onCompleted: {
                print("Completed")
            })
            .disposed(by: disposeBag);
    }
    
}
