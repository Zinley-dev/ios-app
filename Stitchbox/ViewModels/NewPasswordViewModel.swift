//
//  NewPasswordViewModel.swift
//  Stitchbox
//
//  Created by Nghiem Minh Hoang on 17/02/2023.
//

import Foundation
import RxSwift

class NewPasswordViewModel : ViewModelProtocol {
  struct Input {
    let passwordObserver: AnyObserver<String>
    let rePasswordObserver: AnyObserver<String>
  }
  struct Action {
    let submitDidTap: AnyObserver<(String, String)>
  }
  struct Output {
    let submitResultObservable: Observable<String>
    let errorsObservable: Observable<Error>
  }
  
  let input: Input
  let action: Action
  let output: Output
  
  private let passwordSubject = PublishSubject<String>()
  private let rePasswordSubject = PublishSubject<String>()
  private let submitDidTapSubject = PublishSubject<(String, String)>()
  
  private let submitResultSubject = PublishSubject<String>()
  private let errorsSubject = PublishSubject<Error>()
  private let disposeBag = DisposeBag()
  
  var isValidInput:Observable<Bool> {
    return Observable.combineLatest(isValidPassword, isHasUppercase, isHasLowercase, isHasNumber, isHasSpecial).map({ $0 && $1 && $2 && $3 && $4})
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
//  var isMatch:Observable<Bool> {
//    rePasswordSubject.s
//    passwordSubject.map { $0 ==  }
//  }
  
  
  public init() {
    input = Input(passwordObserver: passwordSubject.asObserver(),
                  rePasswordObserver: rePasswordSubject.asObserver())
    
    action = Action(submitDidTap: submitDidTapSubject.asObserver())
    
    output = Output(submitResultObservable: submitResultSubject.asObservable(),
                    errorsObservable: errorsSubject.asObservable())
    
    logic()
  }
  
  func logic() {
    submitDidTapSubject.subscribe(onNext: { (pwd, rePwd) in
      if pwd != rePwd {
        self.errorsSubject.onNext(NSError(domain: "Password not match", code: 400))
      } else {
          APIManager.shared.updatePassword(params: ["newPassword": pwd]) { result in
          print(result)
          switch result {
            case .success(let response):
              print(response)
              self.submitResultSubject.onNext("success")
            case .failure(let error):
              self.errorsSubject.onNext(NSError(domain: "Update password fail", code: 400))
          }
        }
      }
    })
  }
}
