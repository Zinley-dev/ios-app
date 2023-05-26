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
    
    var isValidInput: Observable<Bool> {
        return Observable.combineLatest(
          isValidPassword, isHasUppercase, isHasLowercase, isHasNumber, isHasSpecial, isPasswordMatch
        ).map({ $0 && $1 && $2 && $3 && $4 && $5})
    }

  
  var isPasswordMatch:Observable<Bool> {
    return Observable.combineLatest(passwordSubject.asObservable(), rePasswordSubject.asObservable()).map { (pass, repass) in
      return pass == repass
    }
  }
  
  var isValidPassword:Observable<Bool> {
    passwordSubject.map { $0.count > 8 }
  }
  
  var isHasUppercase:Observable<Bool> {
    let regex = try! NSRegularExpression(pattern: ".*[A-Z]+.*")
    return passwordSubject.map { regex.firstMatch(in: $0, range: NSRange(location: 0, length: $0.count)) != nil }
  }
    
    var isHasLowercase:Observable<Bool> {
        let regex = try! NSRegularExpression(pattern: ".*[a-z]+.*")
        return passwordSubject.map { regex.firstMatch(in: $0, range: NSRange(location: 0, length: $0.count)) != nil }
    }
    var isHasNumber:Observable<Bool> {
        let regex = try! NSRegularExpression(pattern: ".*[0-9]+.*")
        return passwordSubject.map { regex.firstMatch(in: $0, range: NSRange(location: 0, length: $0.count)) != nil }
    }
    var isHasSpecial:Observable<Bool> {
        let regex = try! NSRegularExpression(pattern: ".*[@!#$%^&*~]+.*")
        return passwordSubject.map { regex.firstMatch(in: $0, range: NSRange(location: 0, length: $0.count)) != nil }
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
        
        debugObservables()
    }

    private func debugObservables() {
        isValidPassword.debug("isValidPassword").subscribe().disposed(by: disposeBag)
        isHasUppercase.debug("isHasUppercase").subscribe().disposed(by: disposeBag)
        isHasLowercase.debug("isHasLowercase").subscribe().disposed(by: disposeBag)
        isHasNumber.debug("isHasNumber").subscribe().disposed(by: disposeBag)
        isHasSpecial.debug("isHasSpecial").subscribe().disposed(by: disposeBag)
        isPasswordMatch.debug("isPasswordMatch").subscribe().disposed(by: disposeBag)
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
                APIManager.shared.changepassword(params: params) {
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
