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
        let refSubject: BehaviorSubject<String>
    }
    
    struct Action {
        let submitDidTap: AnyObserver<(String, String, String)>
    }
    
    struct Output {
        let usernameExistObservable: Observable<Bool>
        let registerSuccessObservable: Observable<Bool>
        let errorsObservable: Observable<Error>
    }
    
    // MARK: Variable Declaration
    let input: Input
    let action: Action
    let output: Output
    var prevText = ""
    var usernameExist = true
    
    // MARK: Subject Instantiation
    private let submitDidTapSubject = PublishSubject<(String, String, String)>()
    private let registerResultSubject = PublishSubject<Bool>()
    private let usernameExistSubject = PublishSubject<Bool>()
    private let errorsSubject = PublishSubject<Error>()
    private let disposeBag = DisposeBag()
    
    init() {
        input = Input(
            usernameSubject: BehaviorSubject<String>(value: ""),
            passwordSubject: BehaviorSubject<String>(value: ""),
            refSubject: BehaviorSubject<String>(value: "")
        )
        action = Action(submitDidTap: submitDidTapSubject.asObserver())
        output = Output(usernameExistObservable: usernameExistSubject.asObservable(), registerSuccessObservable: registerResultSubject.asObserver(), errorsObservable: errorsSubject.asObserver())
        logic()
    }
    
    var isValidInput:Observable<Bool> {
        
        return Observable.combineLatest(isValidUsername, isValidPassword, isHasUppercase, isHasLowercase, isHasNumber, isHasSpecial).map({ $0 && $1 && $2 && $3 && $4 && $5 && self.usernameExist})
    }
    
    var isValidUsername:Observable<Bool>
    {
       input.usernameSubject.map { $0.count >= 3 }
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
    
        self.usernameExistSubject.subscribe { isExist in
            self.usernameExist = isExist
        }
      
        input.usernameSubject.subscribe(onNext: { uname in
            
            
            print("SUBCRIBE>...")
            if uname.count >= 3 {

                APIManager().checkUsernameExist(username: uname) { result in
                  switch result {
                    case .success(let response):
                      if let data = response.body?["data"] as? String, data != "" {
                        self.usernameExistSubject.onNext(false)
                      } else {
                        self.usernameExistSubject.onNext(true)
                      }
                    case .failure:
                      self.usernameExistSubject.onNext(false)
                  }
            }
            
          }
        }, onError: { err in
          print("Error \(err.localizedDescription)")
        }, onCompleted: {
          print("Completed")
        })
        .disposed(by: disposeBag)
        
        submitDidTapSubject.subscribe(onNext: { (username, password, ref) in
            print("Register with uname: \(username) and pwd: \(password) and ref: \(ref)")
            // get phone
            if let phone = _AppCoreData.userDataSource.value?.phone, phone != "" {
                
                let params = ["username": username, "password": password, "phone": phone, "referralCode": ref]
                
                APIManager().register(params: params) { result in
                    switch result {
                    case .success(let response):
                        print(response)
                        
                        let data = response.body?["data"] as! [String: Any]?
                        let account = Account(JSON: data ?? [:])
                        
                        // Write/Set Data
                        let sessionToken = SessionDataSource.init(JSONString: "{}")!
                        sessionToken.accessToken = account?.accessToken
                        sessionToken.refreshToken = account?.refreshToken
                        _AppCoreData.userSession.accept(sessionToken)
                        
                        // write usr data
                        if let newUserData = Mapper<UserDataSource>().map(JSON: data?["user"] as! [String: Any]) {
                            _AppCoreData.userDataSource.accept(newUserData)
                        }
                        
                        self.registerResultSubject.onNext(true)
                        
                    case .failure:
                        Dispatch.main.async {
                            SwiftLoader.hide()
                        }
                        
                        self.errorsSubject.onNext(NSError(domain: "Can't register your account with provided information", code: 400))
                    }
                }
            }
            if let signinMethod = _AppCoreData.userDataSource.value?.signinMethod, signinMethod != "" {
                if let socialId = _AppCoreData.userDataSource.value?.socialId, socialId != "" {
                    let params = ["username": username, "password": password, "provider": signinMethod, "socialId": socialId, "name": _AppCoreData.userDataSource.value?.name ?? "", "avatar": _AppCoreData.userDataSource.value?.avatarURL ?? "", "email": _AppCoreData.userDataSource.value?.email ?? ""]
                    print("VAO IF..................... \(_AppCoreData.userDataSource.value?.toJSON())")
                    APIManager().socialRegister(params: params) { result in
                        switch result {
                            case .success(let response):
                                let data = response.body?["data"] as! [String: Any]?
                                let account =  Mapper<Account>().map(JSONObject: data)

                                print("account \(Mapper().toJSON(account!))")

                                // Write/Set Data
                                let sessionToken = SessionDataSource.init(JSONString: "{}")!
                                sessionToken.accessToken = account?.accessToken
                                sessionToken.refreshToken = account?.refreshToken
                                _AppCoreData.userSession.accept(sessionToken)

                                // write usr data
                                if let newUserData = Mapper<UserDataSource>().map(JSON: data?["user"] as! [String: Any]) {
                                    _AppCoreData.userDataSource.accept(newUserData)
                                }

                                self.registerResultSubject.onNext(true)
                            case .failure:
                                Dispatch.main.async {
                                    SwiftLoader.hide()
                                }
                            
                                self.errorsSubject.onNext(NSError(domain: "Can't register your account with provided information", code: 400))
                        }
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
