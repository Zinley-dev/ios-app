//
//  ChangePasswordViewModel.swift
//  Stitchbox
//
//  Created by Khanh Duy Nguyen on 1/20/23.
//

import RxSwift
import ObjectMapper

class ChangePasswordViewModel: ViewModelProtocol {
    struct Input {
    }
    struct Action {
        let changePasswordDidTap: AnyObserver<(String, String, String)>
    }
    struct Output {
        let resetResultObservable: Observable<Bool>
        let errorsObservable: Observable<String>
    }
    
    let input: Input
    let action: Action
    let output: Output
    
    private let phoneSubject = PublishSubject<String>()
    private let countryCodeSubject = PublishSubject<String>()
    private let changePasswordDidTapSubject = PublishSubject<(String, String,String)>()
    private let resetResultSubject = PublishSubject<Bool>()
    private let errorsSubject = PublishSubject<String>()
    private let disposeBag = DisposeBag()
    
    public init() {
        input = Input()
        
        action = Action(changePasswordDidTap: changePasswordDidTapSubject.asObserver())
        
        output = Output(resetResultObservable: resetResultSubject.asObservable(),
                        errorsObservable: errorsSubject.asObservable())
        
        logic()
    }
    
    func logic() {
        changePasswordDidTapSubject.asObservable()
            .subscribe (onNext: { (currentPassword, newPassword, retypePassword) in
                // call api changePassword
                if (isNotValidInput(Input: newPassword, RegEx: "\\w{6,18}")) {
                    self.errorsSubject.onNext("New password in wrong format")
                    return;
                }
                if (newPassword != retypePassword) {
                    self.errorsSubject.onNext("New password and retype password does not match!")
                    return;
                }
                let params = [
                    "currentPassword": currentPassword,
                    "newPassword": newPassword]
                APIManager().changepassword(params: params) {
                    result in switch result {
                    case .success(_):
                        print("here")
                        self.resetResultSubject.onNext(true)
                    case .failure(let error):
                        print("there")
                        self.errorsSubject.onNext(error.localizedDescription)
                    }
                }
                
            }).disposed(by: disposeBag)
        
    }
    
    
}
