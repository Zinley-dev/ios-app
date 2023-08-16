//
//  ApplicationCoreData.swift
//  Stitchbox
//
//  Created by Hisoft Hoangnm on 15/12/2022.
//

import RxRelay
import RxSwift
import OneSignal

class ApplicationCoreData: NSObject {
    static let shared = ApplicationCoreData()

    public var userSession = BehaviorRelay<SessionDataSource?>(value: nil)
    public var userDataSource = BehaviorRelay<UserDataSource?>(value: nil)

    private let disposeBag = DisposeBag()

    private override init() {
        super.init()
        loadSavedData()
        bindData()
    }

    private func loadSavedData() {
        if let data = UserDefaults.standard.string(forKey: kUserSession),
           let sessionData = SessionDataSource(JSONString: data) {
            self.userSession.accept(sessionData)
        }

        if let data = UserDefaults.standard.string(forKey: kUserProfile),
           let userData = UserDataSource(JSONString: data) {
            self.userDataSource.accept(userData)
        }
    }

    private func bindData() {
        Observable.combineLatest(userSession, userDataSource)
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] _, _ in
                self?.syncToUserDefaults()
            })
            .disposed(by: disposeBag)
    }

    private func syncToUserDefaults() {
        UserDefaults.standard.set(userSession.value?.toJSONString(), forKey: kUserSession)
        UserDefaults.standard.set(userDataSource.value?.toJSONString(), forKey: kUserProfile)
    }

    func reset() {
        userDataSource.accept(nil)
        UserDefaults.standard.removeObject(forKey: kUserProfile)
        syncToUserDefaults()
    }

    func signOut() {
        userSession.accept(nil)
        userDataSource.accept(nil)
        syncToUserDefaults()
        OneSignal.removeExternalUserId { results in
            print("External user id update complete with results: ", results?.description ?? "nil")
        }
    }
}
