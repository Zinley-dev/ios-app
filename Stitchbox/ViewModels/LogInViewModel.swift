//
//  usernameViewModel.swift
//  Stitchbox
//
//  Created by Khanh Duy Nguyen on 11/12/22.
//

import Foundation
import RxSwift


class LoginControllerViewModel: ViewModelProtocol {
    struct Input {
        let username: AnyObserver<String>
        let password: AnyObserver<String>
        let signInDidTap: AnyObserver<Void>
    }
    struct Output {
        let loginResultObservable: Observable<Account>
        let errorsObservable: Observable<Error>
    }
    
    let input: Input
    let output: Output
    
    private let usernameSubject = PublishSubject<String>()
    private let passwordSubject = PublishSubject<String>()
    private let signInDidTapSubject = PublishSubject<Void>()
    private let loginResultSubject = PublishSubject<Account>()
    private let errorsSubject = PublishSubject<Error>()
    private let credentialSubject = PublishSubject<Credentials>()
    private let disposeBag = DisposeBag()
    
    private var credentialsObservable: Observable<Credentials> {
        return Observable.combineLatest(usernameSubject.asObservable(), passwordSubject.asObservable()) { (username, password) in
            return Credentials(username: username, password: password)
        }
    }
    
    init() {
        input = Input(username: usernameSubject.asObserver(),
                      password: passwordSubject.asObserver(),
                      signInDidTap: signInDidTapSubject.asObserver())
        
        output = Output(loginResultObservable: loginResultSubject.asObservable(),
                        errorsObservable: errorsSubject.asObservable())
        
        signInDidTapSubject
            .withLatestFrom(credentialsObservable)
            .subscribe { [self] (credentials) -> Void in
                // check username or password in the right format
                if (isNotValidInput(Input: credentials.username) ||
                    isNotValidInput(Input: credentials.password)) {
                    self.errorsSubject.onNext(NSError(domain: "Username or Password in wrong format", code: 200))
                    return;
                }
                // call api toward login api of backend
                APIManager().normalLogin(username: credentials.username, password: credentials.password) { result in switch result {
                case .success(let apiResponse):
                    // get and process data
                    let data = apiResponse.body?["data"] as! [String: Any]?
                    do{
                        let account = try Account(JSONbody: data)
                        self.loginResultSubject.onNext(account)
                    }catch{
                        self.errorsSubject.onNext(error)
                    }
                case .failure:
                    self.errorsSubject.onNext(NSError(domain: "Wrong username or password", code: 300))
                }
                }
            }
        
    }
    
    // MARK: Helper function
    func isNotValidInput(Input:String) -> Bool {
        let RegEx = "\\w{7,18}"
        let Test = NSPredicate(format:"SELF MATCHES %@", RegEx)
        return !Test.evaluate(with: Input)
    }
    
}
