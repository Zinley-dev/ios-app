//
//  ChangePasswordViewModel.swift
//  Stitchbox
//
//  Created by Khanh Duy Nguyen on 1/3/23.
//

import Foundation
import RxSwift

class ChangePasswordViewModel: ViewModelProtocol {
    
    struct Input {
        
    }
    struct Action {
        var didTapChangePassword: AnyObserver<(String, String)>
    }
    struct Output {
        let successObservable: Observable<Bool>
        let errorsObservable: Observable<Error>
    }
    
    let input: Input
    let action: Action
    let output: Output
    
    private let didTapChangePassword = PublishSubject<(String, String)>()
    private let successObservable = PublishSubject<Bool>()
    private let errorsSubject = PublishSubject<Error>()
    private let disposeBag = DisposeBag()
    
    public init() {
        input = Input()
        action = Action(didTapChangePassword: didTapChangePassword.asObserver())
        output = Output(successObservable: successObservable.asObservable(), errorsObservable: errorsSubject.asObservable())
    }
    
    func logic() {
        didTapChangePassword
            .subscribe (onNext: {  oldPassword, newPassword in
                // check username or password in the right format
                if (isNotValidInput(Input: newPassword, RegEx: "\\w{6,18}")) {
                    self.errorsSubject.onNext(NSError(domain: "New password in wrong format", code: 400))
                    return;
                }
                // call api toward changepassword api of backend
                APIManager().changepassword(params: ["oldPassword": oldPassword, "newPassword": newPassword]) { result in switch result {
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
