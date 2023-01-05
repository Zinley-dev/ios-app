//
//  CreateAccountViewModel.swift
//  Stitchbox
//
//  Created by Nghiem Minh Hoang on 16/12/2022.
//

import RxSwift
import ObjectMapper

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
    let registerSuccessObservable: Observable<Bool>
    let errorsObservable: Observable<Error>
  }
  
  // MARK: Variable Declaration
  let input: Input
  let action: Action
  let output: Output
  
  // MARK: Subject Instantiation
  private let submitDidTapSubject = PublishSubject<(String, String)>()
  private let registerResultSubject = PublishSubject<Bool>()
  private let errorsSubject = PublishSubject<Error>()
  private let disposeBag = DisposeBag()
  
  init() {
    input = Input(
      usernameSubject: BehaviorSubject<String>(value: ""),
      passwordSubject: BehaviorSubject<String>(value: "")
    )
    action = Action(submitDidTap: submitDidTapSubject.asObserver())
    output = Output(registerSuccessObservable: registerResultSubject.asObserver(), errorsObservable: errorsSubject.asObserver())
    logic()
  }
  
  var isValidInput:Observable<Bool> {
    return Observable.combineLatest(isValidUsername, isValidPassword, isHasUppercase, isHasLowercase, isHasNumber, isHasSpecial).map({ $0 && $1 && $2 && $3 && $4 && $5})
  }
  
  var isValidUsername:Observable<Bool> {
    input.usernameSubject.map { $0.count > 4 }
  }
  
  var isValidPassword:Observable<Bool> {
    input.passwordSubject.map { $0.count > 8 }
  }
  
  var isHasUppercase:Observable<Bool> {
    let regex = try! NSRegularExpression(pattern: ".*[A-Z]+.*")
    return input.passwordSubject.map { regex.firstMatch(in: $0, range: NSRange(location: 0, length: $0.count)) != nil }
  }
  var isHasLowercase:Observable<Bool> {
    input.passwordSubject.map { $0 ~= ".*[a-z]+.*" }
  }
  var isHasNumber:Observable<Bool> {
    input.passwordSubject.map { $0 ~= ".*[0-9]+.*" }
  }
  var isHasSpecial:Observable<Bool> {
    input.passwordSubject.map { $0 ~= ".*[@!#$%^&*~]+.*" }
  }
  
  func logic() {
    submitDidTapSubject.subscribe(onNext: { (username, password) in
      print("Register with uname: \(username) and pwd: \(password)")
      // get phone
      if let phone = _AppCoreData.userDataSource.value?.phone, phone != "" {
        
        let params = ["username": username, "password": password, "phone": phone]
        
        APIManager().register(params: params) { result in
          switch result {
            case .success(let response):
              print(response)
              
              let data = response.body?["data"] as! [String: Any]?
              do{
                let account = try Account(JSONbody: data, type: .normalLogin)
                // Store account to UserDefault as "userAccount"
                print("account \(account)")
                
                // Write/Set Data
                let sessionToken = SessionDataSource.init(JSONString: "{}")!
                sessionToken.accessToken = account.accessToken
                sessionToken.refreshToken = account.refreshToken
                _AppCoreData.userSession.accept(sessionToken)
                
                // write usr data
                if let newUserData = Mapper<UserDataSource>().map(JSON: data?["user"] as! [String: Any]) {
                  _AppCoreData.userDataSource.accept(newUserData)
                }
                
                self.registerResultSubject.onNext(true)
              }catch{
                self.errorsSubject.onNext(error)
              }
            case .failure:
              self.errorsSubject.onNext(NSError(domain: "Wrong username or password", code: 400))
          }
        }
      }
      if let signinMethod = _AppCoreData.userDataSource.value?.signinMethod, signinMethod != "" {
        let socialId = _AppCoreData.userDataSource.value?.socialId ?? ""
        let params = ["username": username, "password": password, "provider": signinMethod, "socialId": socialId]
        
        APIManager().socialRegister(params: params) { result in
          switch result {
            case .success(let response):
              print(response)
              
              let data = response.body?["data"] as! [String: Any]?
              do{
                let account = try Account(JSONbody: data, type: .normalLogin)
                // Store account to UserDefault as "userAccount"
                print("account \(account)")
                
                // Write/Set Data
                let sessionToken = SessionDataSource.init(JSONString: "{}")!
                sessionToken.accessToken = account.accessToken
                sessionToken.refreshToken = account.refreshToken
                _AppCoreData.userSession.accept(sessionToken)
                
                // write usr data
                if let newUserData = Mapper<UserDataSource>().map(JSON: data?["user"] as! [String: Any]) {
                  _AppCoreData.userDataSource.accept(newUserData)
                }
                
                self.registerResultSubject.onNext(true)
              }catch{
                self.errorsSubject.onNext(error)
              }
            case .failure:
              self.errorsSubject.onNext(NSError(domain: "Wrong username or password", code: 400))
          }
        }
        
      }
      
      
      
    }, onError: { err in
      print("Error \(err.localizedDescription)")
    }, onCompleted: {
      print("Completed")
    })
    .disposed(by: disposeBag)
  }
  
}
