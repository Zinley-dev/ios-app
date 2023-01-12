//
//  StartViewModel.swift
//  Stitchbox
//
//  Created by Hisoft Hoangnm on 12/12/2022.
//

import Foundation
import RxSwift
import ObjectMapper

class StartViewModel: ViewModelProtocol {
    
    struct Input {}
    struct Action {}
    struct Output {
        let loginResultObservable: Observable<Bool>
        let errorsObservable: Observable<Error>
    }
    
    let input: Input
    let action: Action
    let output: Output
    
    let vc: UIViewController
    
    private let loginResultSubject = PublishSubject<Bool>()
    private let errorsSubject = PublishSubject<Error>()
    
    public var selectedSignInMethod: SocialLoginType!
    
    private var currentSignInService: LoginCoordinatorProtocol {
        switch selectedSignInMethod {
        case .google: return GoogleSignInService(vm: self)
        case .apple: return AppleSignInService(vm: self)
        case .facebook: return FacebookSignInService(vm: self)
        case .twitter: return TwitterSignInService(vm: self)
        case .tiktok: return TiktokSignInService(vm: self)
        case .none: fatalError("SignIn Method not selected")
        }
    }
    
    public init(vc: UIViewController) {
        self.vc = vc
        input = Input()
        action = Action()
        output = Output(loginResultObservable: loginResultSubject.asObservable(),
                        errorsObservable: errorsSubject.asObservable())
    }
    
    func logic() {
    }
    
    /// Triggered when authentication succeeded from related provider.
    open func completeSignIn(with authResult: AuthResult) {
        print(authResult)
        // call api --> check auth
        var params = ["socialId": authResult.idToken!]
        if selectedSignInMethod == .google {
            params["provider"] = "google"
        }
        if selectedSignInMethod == .facebook {
            params["provider"] = "facebook"
        }
        APIManager().socialLogin(params: params) { result in
            switch result {
            case .success(let response):
                let data = response.body?["data"] as! [String: Any]?
                let account = Account(JSON: data ?? [:])
                
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
                
                _AppCoreData.userData.accept(account?.user)
                self.loginResultSubject.onNext(true)
            case .failure(let error):
                print("**** ERROR ****")
                print(error)
                
                // save datasource signinMethod for first time login
                let initMap = ["signinMethod": params["provider"], "socialId": authResult.idToken!]
                let newUserData = Mapper<UserDataSource>().map(JSON: initMap)
                _AppCoreData.userDataSource.accept(newUserData)
                
                self.errorsSubject.onNext(NSError(domain: "Login fail", code: 401))
            }
        }
        
    }
    
    /// Trigger this method (from related provider's button action) to start process.
    open func startSignInProcess(with method: SocialLoginType) {
        switch method {
        case .apple: selectedSignInMethod = .apple
        case .google: selectedSignInMethod = .google
        case .facebook: selectedSignInMethod = .facebook
        case .twitter: selectedSignInMethod = .twitter
        case .tiktok: selectedSignInMethod = .tiktok
        }
        currentSignInService.triggerSignIn()
    }
    
    open func logout() {
        //        signInSucceeded = false
        currentSignInService.logout()
    }
}
