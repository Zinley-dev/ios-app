//
//  NormalLoginViewModel.swift
//  Stitchbox
//
//  Created by Khanh Duy Nguyen on 11/12/22.
//

import Foundation

import RxSwift
import RxRealm
import RxCocoa

class NormalLoginViewModel {
    private let bag = DisposeBag()
    
    let account: Driver<NormalLoginAPI.AccountStatus>
    private(set) var loggedIn: Driver<Bool>!
    
    init(account: Driver<NormalLoginAPI.AccountStatus>) {
      
      self.account = account
      
      // fetch and store tweets
      bindOutput()

      fetcher.timeline
        .subscribe(Realm.rx.add(update: .all))
        .disposed(by: bag)
    }
    
    private func bindOutput() {
      
      // Bind if an account is available
      loggedIn = account
        .map { status in
          switch status {
          case .unavailable: return false
          case .authorized: return true
          }
        }
        .asDriver(onErrorJustReturn: false)
    }
}
    
