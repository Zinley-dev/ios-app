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
      let oldPasswordObserver: AnyObserver<String>
      let passwordObserver: AnyObserver<String>
      let rePasswordObserver: AnyObserver<String>
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
    
  private let oldPasswordSubject = PublishSubject<String>()
    private let passwordSubject = PublishSubject<String>()
  private let rePasswordSubject = PublishSubject<String>()
    private let changePasswordDidTapSubject = PublishSubject<(String, String,String)>()
    private let resetResultSubject = PublishSubject<Bool>()
    private let errorsSubject = PublishSubject<String>()
    private let disposeBag = DisposeBag()
    
  var isValidInput:Observable<Bool> {
    return Observable.combineLatest(
      isOldValidPassword, isValidPassword, isHasUppercase, isHasLowercase, isHasNumber, isHasSpecial, isPasswordMatch).map({ $0 && $1 && $2 && $3 && $4 && $5 && $6})
  }
  
  var isPasswordMatch:Observable<Bool> {
    return Observable.combineLatest(passwordSubject.asObservable(), rePasswordSubject.asObservable()).map { (pass, repass) in
      return pass == repass
    }
  }
  
  var isOldValidPassword:Observable<Bool> {
    oldPasswordSubject.map { $0.count > 6 }
  }
  
  var isValidPassword:Observable<Bool> {
    passwordSubject.map { $0.count > 8 }
  }
  
  var isHasUppercase:Observable<Bool> {
    let regex = try! NSRegularExpression(pattern: ".*[A-Z]+.*")
    return passwordSubject.map { regex.firstMatch(in: $0, range: NSRange(location: 0, length: $0.count)) != nil }
  }
  var isHasLowercase:Observable<Bool> {
    passwordSubject.map { $0 ~= ".*[a-z]+.*" }
  }
  var isHasNumber:Observable<Bool> {
    passwordSubject.map { $0 ~= ".*[0-9]+.*" }
  }
  var isHasSpecial:Observable<Bool> {
    passwordSubject.map { $0 ~= ".*[@!#$%^&*~]+.*" }
  }
  
    public init() {
        input = Input(
          oldPasswordObserver: oldPasswordSubject.asObserver(),
          passwordObserver: passwordSubject.asObserver(),
          rePasswordObserver: rePasswordSubject.asObserver())
        
        action = Action(changePasswordDidTap: changePasswordDidTapSubject.asObserver())
        
        output = Output(resetResultObservable: resetResultSubject.asObservable(),
                        errorsObservable: errorsSubject.asObservable())
        
        logic()
    }
    
    func logic() {
        changePasswordDidTapSubject.asObservable()
            .subscribe (onNext: { (currentPassword, newPassword, retypePassword) in
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
                        self.resetResultSubject.onNext(true)
                    case .failure(let error):
                        self.errorsSubject.onNext(error.localizedDescription)
                    }
                }
                
            }).disposed(by: disposeBag)
        
    }
    
    
}
