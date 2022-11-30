//
//  usernameViewModel.swift
//  Stitchbox
//
//  Created by Khanh Duy Nguyen on 11/12/22.
//

import Foundation
import RxSwift


class LoginControllerViewModel: ViewModelProtocol {
    
    // MARK: Struct Declaration
    struct Input {}
    
    struct Action {
        let signInDidTap: AnyObserver<(String, String)>
    }
    struct Output {
        let loginResultObservable: Observable<Bool>
        let errorsObservable: Observable<Error>
    }
    
    // MARK: Variable Declaration
    let input: Input
    let action: Action
    let output: Output
    
    // MARK: Subject Instantiation
    private let signInDidTapSubject = PublishSubject<(String, String)>()
    private let loginResultSubject = PublishSubject<Bool>()
    private let errorsSubject = PublishSubject<Error>()
    private let disposeBag = DisposeBag()
    
    init() {
        input = Input()
        
        action = Action(signInDidTap: signInDidTapSubject.asObserver())
        
        output = Output(loginResultObservable: loginResultSubject.asObservable(),
                        errorsObservable: errorsSubject.asObservable())
        
        logic()
    }
    
    // MARK: Logic function
    func logic() {
        signInDidTapSubject
            .subscribe (onNext: { (username, password) in
                // check username or password in the right format
//                if (isNotValidInput(Input: username, RegEx: "\\w{7,18}") ||
//                    isNotValidInput(Input: password, RegEx: "\\w{7,18}")) {
//                    self.errorsSubject.onNext(NSError(domain: "Username or Password in wrong format", code: 400))
//                    return;
//                }
                // call api toward login api of backend
                APIManager().normalLogin(username: username, password: password) { result in switch result {
                case .success(let apiResponse):
                    // get and process data
                    let data = apiResponse.body?["data"] as! [String: Any]?
                    do{
                        let account = try Account(JSONbody: data, type: .normalLogin)
                        // Store account to UserDefault as "userAccount"
                        do {
                            // Create JSON Encoder
                            let encoder = JSONEncoder()
                            
                            // Encode Note
                            let data = try encoder.encode(account)
                            
                            // Write/Set Data
                            UserDefaults.standard.set(data, forKey: "userAccount")
                            
                            
                        } catch {
                            print("Unable to Encode Account (\(error))")
                        }
                        self.loginResultSubject.onNext(true)
                    }catch{
                        self.errorsSubject.onNext(error)
                    }
                case .failure:
                    self.errorsSubject.onNext(NSError(domain: "Wrong username or password", code: 400))
                }
                }
            }, onError: { (err) in
                print("Error \(err.localizedDescription)")
            }, onCompleted: {
                print("Completed")
            })
            .disposed(by: disposeBag);
    }
    
}
