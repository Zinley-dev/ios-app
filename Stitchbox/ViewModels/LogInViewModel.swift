//
//  EmailViewModel.swift
//  Stitchbox
//
//  Created by Khanh Duy Nguyen on 11/12/22.
//

import Foundation
import RxSwift


class LoginControllerViewModel: ViewModelProtocol {
    struct Input {
        let email: AnyObserver<String>
        let password: AnyObserver<String>
        let signInDidTap: AnyObserver<Void>
    }
    struct Output {
        let loginResultObservable: Observable<Account>
        let errorsObservable: Observable<Error>
    }
    
    let input: Input
    let output: Output
    
    private let emailSubject = PublishSubject<String>()
    private let passwordSubject = PublishSubject<String>()
    private let signInDidTapSubject = PublishSubject<Void>()
    private let loginResultSubject = PublishSubject<Account>()
    private let errorsSubject = PublishSubject<Error>()
    private let credentialSubject = PublishSubject<Credentials?>()
    private let disposeBag = DisposeBag()
    
    private var credentialsObservable: Observable<Credentials> {
            return Observable.combineLatest(emailSubject.asObservable(), passwordSubject.asObservable()) { (email, password) in
                return Credentials(email: email, password: password)
            }
        }
        
    init(_ loginService: LoginServiceProtocol) {
        input = Input(email: emailSubject.asObserver(),
                      password: passwordSubject.asObserver(),
                      signInDidTap: signInDidTapSubject.asObserver())
        
        output = Output(loginResultObservable: loginResultSubject.asObservable(),
                        errorsObservable: errorsSubject.asObservable())
        
        signInDidTapSubject
            .withLatestFrom(credentialsObservable)
            .flatMapLatest{
                credentials in
                    return
            }
//        signInDidTapSubject
//                    .withLatestFrom(credentialsObservable)
//                    .flatMapLatest { credentials in
//                        return loginService.signIn(with: credentials).materialize()
//                    }
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
