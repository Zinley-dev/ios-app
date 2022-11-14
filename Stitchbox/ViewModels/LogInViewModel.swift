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
        let credentialsObservable: Observable<Credentials>
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
                        errorsObservable: errorsSubject.asObservable(),
                        credentialsObservable:  credentialSubject.asObservable())
        
        credentialsObservable.bind(to: credentialSubject)
        
        signInDidTapSubject
            .withLatestFrom(credentialsObservable)
            .subscribe { credentials in
                APIManager().normalLogin(username: credentials.username,
                                         password: credentials.password) {
                    result in switch result {
                    case .success(let returnJSON):
                        print(returnJSON.body!)
                    case .failure(let error):
                        print("error!")
                        print(error)
                    }
                }
            }
        //                print(loginService.signIn(with: credentials))
        //            }
        //                    .withLatestFrom(credentialsObservable)
        //                    .flatMapLatest { credentials in
        //                            return loginService.signIn(with: credentials).materialize()
        ////                        return Credentials(username:"username", password: "1111")
        ////                    }
        //                    .subscribe(onNext: { [weak self] event in
        //                        switch event {
        //                        case .next(let user):
        //                            self?.loginResultSubject.onNext(user)
        //                        case .error(let error):
        //                            self?.errorsSubject.onNext(error)
        //                        default:
        //                            break
        //                        }
        //                    })
        //                    .disposed(by: disposeBag)
        
    }
}
