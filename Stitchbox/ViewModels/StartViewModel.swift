//
//  StartViewModel.swift
//  Stitchbox
//
//  Created by Hisoft Hoangnm on 12/12/2022.
//

import Foundation
import RxSwift
import ObjectMapper
import OneSignal

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
        
        // call api --> check auth
        var params = ["socialId": authResult.idToken!]
        
        if selectedSignInMethod == .google {
            params["provider"] = "google"
        } else if selectedSignInMethod == .facebook {
            params["provider"] = "facebook"
        } else {
            params["provider"] = "apple"
        }
        
        presentSwiftLoader()
        
        APIManager.shared.socialLogin(params: params) { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .success(let response):
                let data = response.body?["data"] as! [String: Any]?
                let account = Mapper<Account>().map(JSONObject: data)
                
                print("account \(Mapper().toJSON(account!))")
                
                
                // Write/Set Data
                let sessionToken = SessionDataSource.init(JSONString: "{}")!
                sessionToken.accessToken = account?.accessToken
                sessionToken.refreshToken = account?.refreshToken
                _AppCoreData.userSession.accept(sessionToken)
                
                // write usr data
                if let newUserData = Mapper<UserDataSource>().map(JSON: data?["user"] as! [String: Any]) {
                    _AppCoreData.userDataSource.accept(newUserData)
                  
                  if newUserData.userID != ""{
                    let externalUserId = newUserData.userID!
                    
                    OneSignal.setExternalUserId(externalUserId, withSuccess: { results in
                      print("External user id update complete with results: ", results!.description)
                    }, withFailure: {error in
                      print("Set external user id done with error: " + error.debugDescription)
                    })
                  }
                }
                
                Dispatch.main.async {
                    SwiftLoader.hide()
                }
                
                
                self.loginResultSubject.onNext(true)
            case .failure(let error):
                
                
                Dispatch.main.async {
                    SwiftLoader.hide()
                }
                

                switch error {
                case .noInternet:
                    self.showAlert(title: "Error", message: "No Internet Connection")
                case .authRequired(let body):
                    self.showAlert(title: "Error", message: "Authentication Required: \(body ?? [:])")
                case .badRequest:
                    self.showAlert(title: "Error", message: "Bad Request")
                case .outdatedRequest:
                    self.showAlert(title: "Error", message: "Outdated Request")
                case .requestFailed(let body):
                    if let message = body?["message"] as? String, message == "User is not exist!" {
                        self.createNewAccount(with: authResult, params: params)
                    } else {
                        self.showAlert(title: "Error", message: "Request Failed: \(body ?? [:])")
                    }
                case .invalidResponse:
                    self.showAlert(title: "Error", message: "Invalid Response")
                case .noData:
                    self.showAlert(title: "Error", message: "No Data Received")
                }


                
            }
        }
        
    }
    
    func createNewAccount(with authResult: AuthResult, params: [String:Any]) {
        
        
        // save datasource signinMethod for first time login
        let initMap = ["signinMethod": params["provider"]!, "socialId": authResult.idToken!,
                       "avatar": authResult.avatar ?? "", "name": authResult.name ?? "", "email": authResult.email ?? ""] as [String : Any]
            
            
        let newUserData = Mapper<UserDataSource>().map(JSON: initMap)
        _AppCoreData.userDataSource.accept(newUserData)
         
        
        self.errorsSubject.onNext(NSError(domain: "Login fail", code: 401))
        
    }
    
    func showAlert(title: String, message: String) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            // Using 'vc' to present the UIAlertController
            self.vc.present(alert, animated: true, completion: nil)
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
