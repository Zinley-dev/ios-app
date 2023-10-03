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
    
    var isUsernameFilled: Observable<Bool>
    var isPasswordFilled: Observable<Bool>
    
    init() {
        input = Input(
            usernameSubject: BehaviorSubject<String>(value: ""),
            passwordSubject: BehaviorSubject<String>(value: ""),
            refSubject: BehaviorSubject<String>(value: "")
        )
        action = Action(submitDidTap: submitDidTapSubject.asObserver())
        output = Output(usernameExistObservable: usernameExistSubject.asObservable(), registerSuccessObservable: registerResultSubject.asObserver(), errorsObservable: errorsSubject.asObserver())
        
        isUsernameFilled = input.usernameSubject.map { !$0.isEmpty }
        isPasswordFilled = input.passwordSubject.map { !$0.isEmpty }
        
        logic()
    }
    
    var isValidInput:Observable<Bool> {
        return Observable.combineLatest(isUsernameFilled, isValidUsername, isPasswordFilled, isValidPassword, isHasUppercase, isHasLowercase, isHasNumber, isHasSpecial)
            .map({ (usernameFilled, validUsername, passwordFilled, validPassword, hasUppercase, hasLowercase, hasNumber, hasSpecial) -> Bool in
                // Check if password is either not filled (in which case a random password will be created server-side) or if it is filled and valid
                let isPasswordOk = !passwordFilled || (passwordFilled && validPassword && hasUppercase && hasLowercase && hasNumber && hasSpecial)
                return usernameFilled && validUsername && isPasswordOk && self.usernameExist
            })
    }
    
    
    var isValidUsername:Observable<Bool> {
        return input.usernameSubject.map { $0.count >= 3 }
    }
    
    var isValidPassword:Observable<Bool> {
        return input.passwordSubject.map { $0.count > 8 }
    }
    
    var isHasUppercase:Observable<Bool> {
        let regex = try! NSRegularExpression(pattern: ".*[A-Z]+.*")
        return input.passwordSubject.map { regex.firstMatch(in: $0, range: NSRange(location: 0, length: $0.count)) != nil }
    }
    var isHasLowercase:Observable<Bool> {
        return input.passwordSubject.map { $0 ~= ".*[a-z]+.*" }
    }
    var isHasNumber:Observable<Bool> {
        return input.passwordSubject.map { $0 ~= ".*[0-9]+.*" }
    }
    var isHasSpecial:Observable<Bool> {
        return input.passwordSubject.map { $0 ~= ".*[@!#$%^&*~]+.*" }
    }
    
    
    
    func logic() {
        
        self.usernameExistSubject.subscribe { [weak self] isExist in
            guard let self = self else { return }
            self.usernameExist = isExist
        }
        
        input.usernameSubject.subscribe(onNext: { [weak self] uname in
            guard let self = self else { return }
            
            print("SUBCRIBE>...")
            if uname.count >= 3 {
                
                APIManager.shared.checkUsernameExist(username: uname) { [unowned self] result in
                  
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
        
        submitDidTapSubject.subscribe(onNext: { [weak self] (username, password, ref) in
            guard let self = self else { return }
            print("Register with uname: \(username) and pwd: \(password) and ref: \(ref)")
            // get phone
            if let phone = _AppCoreData.userDataSource.value?.phone, phone != "" {
                
                let params = ["username": username, "password": password, "phone": phone, "referralCode": ref]
                
                Dispatch.main.async {
                    presentSwiftLoader()
                }
                
                APIManager.shared.register(params: params) { [unowned self] result in
                   
                    switch result {
                    case .success(let response):
                        print(response)
                        
                        Dispatch.main.async {
                            SwiftLoader.hide()
                        }
                        
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
                    APIManager.shared.socialRegister(params: params) { [unowned self] result in
                        
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
