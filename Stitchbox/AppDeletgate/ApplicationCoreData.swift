//
//  ApplicationCoreData.swift
//  Stitchbox
//
//  Created by Hisoft Hoangnm on 15/12/2022.
//

import RxRelay
import RxSwift

class ApplicationCoreData: NSObject {
  public static let sharedInstance    = ApplicationCoreData()

  public var userSession              = BehaviorRelay<SessionDataSource?>(value: nil)
  public var userDataSource           = BehaviorRelay<UserDataSource?>(value: nil)
  
  private let disposeBag              = DisposeBag()
  
  private var timerRefeshToken: Timer?
  
  // MARK: - Initial
  override init() {
    super.init()
    self.initSync()
    
    DispatchQueue.global().asyncAfter(deadline: .now() + 0.1) {
      self.bindingData()
    }
  }
  
  private func bindingData() {
    self.userSession
      .observe(on: MainScheduler.instance)
      .subscribe { _ in
        self.syncDown()
      }
      .disposed(by: disposeBag)
    
    self.userDataSource
      .observe(on: MainScheduler.instance)
      .subscribe { _ in
        self.syncDown()
      }
      .disposed(by: disposeBag)
  }
  
  func signOut() {
    self.userSession.accept(nil)
    self.userDataSource.accept(nil)
    // Stop Refresh token
    self.timerRefeshToken?.invalidate()
    self.timerRefeshToken = nil
    self.syncDown()
  }
  
  // MARK: - Sync to local
    private func initSync() {
        // Sync userSession
        
        if UserDefaults.standard.object(forKey: kUserSession) is String {
            if let data = UserDefaults.standard.object(forKey: kUserSession) as? String {
                let sessionData = SessionDataSource.init(JSONString: data)
                if sessionData != nil {
                    self.userSession.accept(sessionData)
                } else {
                    UserDefaults.standard.removeObject(forKey: kUserSession)
                }
            } else {
                UserDefaults.standard.removeObject(forKey: kUserSession)
            }
        }
        
        // sync userDataSource
        if UserDefaults.standard.object(forKey: kUserProfile) is String {
            if let data = UserDefaults.standard.object(forKey: kUserProfile) as? String {
                let userData = UserDataSource.init(JSONString: data)
                if userData != nil {
                    self.userDataSource.accept(userData)
                } else {
                    UserDefaults.standard.removeObject(forKey: kUserProfile)
                }
            } else {
                UserDefaults.standard.removeObject(forKey: kUserProfile)
            }
        }
    }

    private func syncDown() {
        // Sync SessionDataSource
        if self.userSession.value == nil {
            UserDefaults.standard.removeObject(forKey: kUserSession)
        } else {
            let data = self.userSession.value?.toJSONString()
            UserDefaults.standard.setValue(data, forKey: kUserSession)
        }
        
        // Sync UserDataSource
        if self.userDataSource.value == nil {
            UserDefaults.standard.removeObject(forKey: kUserProfile)
        } else {
            let data = self.userDataSource.value?.toJSONString()
            UserDefaults.standard.setValue(data, forKey: kUserProfile)
        }
    }
    
    func reset() {
        // Clear userDataSource
        self.userDataSource.accept(nil)
        
        // Clear data in UserDefaults
        UserDefaults.standard.removeObject(forKey: kUserProfile)
        
        // Sync changes to UserDefaults
        self.syncDown()
    }
}
