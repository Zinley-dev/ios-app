//
//  ResetPasswordViewModel.swift
//  Stitchbox
//
//  Created by Khanh Duy Nguyen on 1/3/23.
//

import UIKit
import RxSwift

class ResetPasswordViewModel: ViewModelProtocol {
    
    struct Input {
        var newPassword: AnyObserver<String>
        
    }
    struct Action {
    }
    struct Output {
        let successObservable: Observable<Bool>
        let errorsObservable: Observable<Error>
    }
        
    let input: Input
    let action: Action
    let output: Output
    
    private let newPassword = PublishSubject<String>()
    private let successObservable = PublishSubject<Bool>()
    private let errorsSubject = PublishSubject<Error>()
    private let disposeBag = DisposeBag()
    
    public init() {
        input = Input(newPassword: newPassword.asObserver())
        action = Action()
        output = Output(successObservable: successObservable.asObservable(), errorsObservable: errorsSubject.asObservable())
    }
    
    func logic() {
        newPassword
            .subscribe (onNext: {  password in
                // check username or password in the right format
                if (isNotValidInput(Input: password, RegEx: "\\w{6,18}")) {
                    self.errorsSubject.onNext(NSError(domain: "Username or Password in wrong format", code: 400))
                    return;
                }
                // call api toward resetpassword api of backend
                APIManager().resetpassword(params: ["token": _AppCoreData.userSession.value!.accessToken, "newPassword": password]) { result in switch result {
                case .success(let apiResponse):
                    // get and process data
                    print("Response \(apiResponse)`")
                    self.successObservable.onNext(true)
                case .failure:
                    self.errorsSubject.onNext(NSError(domain: "Wrong username or password", code: 400))
                }
                }}, onError: { (err) in
                print("Error \(err.localizedDescription)")
            }, onCompleted: {
                print("Completed")
            })
            .disposed(by: disposeBag);
    }
    

}
