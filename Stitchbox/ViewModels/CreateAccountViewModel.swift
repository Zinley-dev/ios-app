//
//  CreateAccountViewModel.swift
//  Stitchbox
//
//  Created by Nghiem Minh Hoang on 16/12/2022.
//

import RxSwift

class CreateAccountViewModel: ViewModelProtocol {
  // MARK: Struct Declaration
  struct Input {
    let usernameSubject: BehaviorSubject<String>
    let passwordSubject: BehaviorSubject<String>
  }
  
  struct Action {
    let submitDidTap: AnyObserver<(String, String)>
  }
  
  struct Output {
    let errorsObservable: Observable<Error>
  }
  
  // MARK: Variable Declaration
  let input: Input
  let action: Action
  let output: Output
  
  // MARK: Subject Instantiation
  private let submitDidTapSubject = PublishSubject<(String, String)>()
  
  private let errorsSubject = PublishSubject<Error>()
  private let disposeBag = DisposeBag()
  
  init() {
    input = Input(
      usernameSubject: BehaviorSubject<String>(value: ""),
      passwordSubject: BehaviorSubject<String>(value: "")
    )
    action = Action(submitDidTap: submitDidTapSubject.asObserver())
    output = Output(errorsObservable: errorsSubject.asObserver())
    logic()
  }
  
  var isValidInput:Observable<Bool> {
    return Observable.combineLatest(isValidUsername, isValidPassword).map({ $0 && $1 })
  }
  
  var isValidUsername:Observable<Bool> {
    input.usernameSubject.map { $0.count > 4 }
  }
  
  var isValidPassword:Observable<Bool> {
    input.passwordSubject.map { $0.count > 8 }
  }
  
  var isHasUppercase:Observable<Bool> {
    let regex = try Regex(pattern: #".*[0-9]+.*"#)
    input.passwordSubject.map { regex.firstMatch(in: $0, range: NSRange(location: 0, length: $0.count)) }
  }
  
  func logic() {
    submitDidTapSubject.subscribe(onNext: { (username, password) in
      print("Register with uname: \(username) and pwd: \(password)")
      print("Register with uname: \(username) and pwd: \(password)")
      print("Register with uname: \(username) and pwd: \(password)")
      print("Register with uname: \(username) and pwd: \(password)")
    })
    .disposed(by: disposeBag)
  }
  
}
