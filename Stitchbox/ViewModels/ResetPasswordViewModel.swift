//
//  ResetPasswordViewModel.swift
//  Stitchbox
//
//  Created by Hisoft Hoangnm on 09/01/2023.
//

import Foundation
import RxSwift
import ObjectMapper

class ResetPasswordViewModel: ViewModelProtocol {
  struct Input {
    let phoneObserver: AnyObserver<String>
    let countryCodeObserver: AnyObserver<String>
  }
  struct Action {
    let sendOTPDidTap: AnyObserver<(String, String)>
    let sendOTPViaEmailDidTap: AnyObserver<String>
  }
  struct Output {
    let resetResultObservable: Observable<Bool>
    let errorsObservable: Observable<Error>
  }
  
  let input: Input
  let action: Action
  let output: Output
  
  let vc: UIViewController
  
  private let phoneSubject = PublishSubject<String>()
  private let countryCodeSubject = PublishSubject<String>()
  private let sendOTPDidTapSubject = PublishSubject<(String, String)>()
  private let sendOTPViaEmailDidTapSubject = PublishSubject<String>()
  private let resetResultSubject = PublishSubject<Bool>()
  private let errorsSubject = PublishSubject<Error>()
  private let disposeBag = DisposeBag()
  
  public init(vc: UIViewController) {
    self.vc = vc
    input = Input(phoneObserver: phoneSubject.asObserver(),
                  countryCodeObserver: countryCodeSubject.asObserver())
    
    action = Action(sendOTPDidTap: sendOTPDidTapSubject.asObserver(),
                    sendOTPViaEmailDidTap: sendOTPViaEmailDidTapSubject.asObserver())
    
    output = Output(resetResultObservable: resetResultSubject.asObservable(),
                    errorsObservable: errorsSubject.asObservable())
    
    logic()
  }
  
  func logic() {
    sendOTPDidTapSubject.asObservable()
      .subscribe (onNext: { (phone, countryCode) in
          // call api toward login api of backend
          let phoneNumber = "\(countryCode)\(phone)"
          print("PHONE NUMBER \(phoneNumber)")
          if let phoneResetVc = self.vc as? PhoneResetVC {
              Dispatch.main.async {
                  presentSwiftLoader()
              }
          }
          APIManager().forgotPasswordByPhone(params: ["phone": phoneNumber]) { result in
              switch result {
                case .success(let response):
                  print(response)
                  self.resetResultSubject.onNext(true)
                case .failure(let error):
                  print(error)
                  self.resetResultSubject.onNext(false)
                  self.errorsSubject.onNext(NSError(domain: "User not found", code: 300))
              }
            
              if let phoneResetVc = self.vc as? PhoneResetVC {
                  Dispatch.main.async {
                      SwiftLoader.hide()
                  }
              }
          }
      }).disposed(by: disposeBag)
    
    sendOTPViaEmailDidTapSubject.asObserver()
      .subscribe(onNext: { email in
        print("EMAIL \(email)")
        if let emailResetVc = self.vc as? EmailResetVC {
            Dispatch.main.async {
                presentSwiftLoader()
            }
        }
        
        APIManager().forgotPasswordByEmail(params: ["email": email]) { result in
          switch result {
            case .success(let response):
              print(response)
              self.resetResultSubject.onNext(true)
            case .failure(let error):
              print(error)
              self.errorsSubject.onNext(NSError(domain: "User not found", code: 300))
          }
        }
        
        if let emailResetVc = self.vc as? EmailResetVC {
            Dispatch.main.async {
                SwiftLoader.hide()
            }
        }
      })
  }

  
}
