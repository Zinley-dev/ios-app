//
//  FistBumpViewModel.swift
//  Stitchbox
//
//  Created by Khanh Duy Nguyen on 2/6/23.
//
import UIKit
import RxSwift
import RxRelay
import ObjectMapper

class FistBumpViewModel: ViewModelProtocol {
    var input: Input
    
    var action: Action
    
    var output: Output
    
    struct Input {
        var fistBumperAccounts: BehaviorRelay<[FistBumpUserModel]>
        var fistBumpeeAccounts: BehaviorRelay<[FistBumpUserModel]>
        var fistBumperAccountsCount: BehaviorRelay<Int>
        var fistBumpeeAccountsCount: BehaviorRelay<Int>
        var userID: String
    }
    
    struct Action {
        var submitChange: AnyObserver<Void>
    }
    
    struct Output {
        var errorsObservable: Observable<String>
        var successObservable: Observable<successMessage>
    }
    enum successMessage {
        case fistbump(messsage: String = "Successfully fist-bump user")
        case follow(messsage: String = "Successfully follow user")
        case unfollow(messsage: String = "Successfully unfollow user")
        case unfistbump(messsage: String = "Successfully unfistbump user")
    }
    
    private let fistBumperAccountRelay = BehaviorRelay<[FistBumpUserModel]>(value: Mapper<FistBumpUserModel>().mapArray(JSONArray: []))
    private let fistBumpeeAccountRelay = BehaviorRelay<[FistBumpUserModel]>(value: Mapper<FistBumpUserModel>().mapArray(JSONArray: []))
    private let fistBumperAccountsCountRelay = BehaviorRelay<Int>(value: 0)
    private let fistBumpeeAccountsCountRelay = BehaviorRelay<Int>(value: 0)
    private let errorsSubject = PublishSubject<String>()
    private let successSubject = PublishSubject<successMessage>()
    private let submitChangeSubject = PublishSubject<Void>()
    private let disposeBag = DisposeBag()
    
    
    init(userID: String = _AppCoreData.userDataSource.value?.userID ?? "") {
        input = Input(
            fistBumperAccounts: fistBumperAccountRelay,
            fistBumpeeAccounts: fistBumpeeAccountRelay,
            fistBumperAccountsCount: fistBumperAccountsCountRelay,
            fistBumpeeAccountsCount: fistBumpeeAccountsCountRelay,
            userID: userID
        )
        
        action = Action(
            submitChange: submitChangeSubject.asObserver()
        )
        
        output = Output(
            errorsObservable: errorsSubject.asObservable(),
            successObservable: successSubject.asObservable()
        )
        
        logic()
    }
    
    func getMyFistBumper(page: Int, completion: @escaping () -> Void = {}) -> Void  {
        APIManager().getFistBumper(page: page){
            result in
            switch result {
            case .success(let response):
                print("page number \(page)")
                if let data = response.body {
                    if let listData = data["data"] as? [[String: Any]] {
                        self.fistBumperAccountRelay.accept(Mapper<FistBumpUserModel>().mapArray(JSONArray: listData))
                        if (!listData.isEmpty) {
                            completion()
                        }
                    } else {
                        self.fistBumperAccountRelay.accept([FistBumpUserModel]())
                    }
                }
            case .failure(let error):
                print(error)
                self.errorsSubject.onNext("Cannot get user's fistBump information")
            }
        }
    }
    func getMyFistBumpee(page: Int, completion: @escaping () -> Void = {}) -> Void  {
        APIManager().getFistBumpee(page: page){
            result in
            switch result {
            case .success(let response):
                print("page number \(page)")
                if let data = response.body {
                    if let listData = data["data"] as? [[String: Any]] {
                        self.fistBumpeeAccountRelay.accept(Mapper<FistBumpUserModel>().mapArray(JSONArray: listData))
                        if (!listData.isEmpty) {
                            completion()
                        }
                    } else {
                        self.fistBumpeeAccountRelay.accept([FistBumpUserModel]())
                    }
                }
            case .failure(let error):
                print(error)
                self.errorsSubject.onNext("Cannot get user's fistBump information")
            }
        }
    }
    func getFistBumper(page: Int, completion: @escaping () -> Void = {}) -> Void  {
        APIManager().getFistBumper(userID: input.userID, page: page){
            result in
            switch result {
            case .success(let response):
                print("page number \(page)")
                if let data = response.body {
                    if let listData = data["data"] as? [[String: Any]] {
                        self.fistBumperAccountRelay.accept(Mapper<FistBumpUserModel>().mapArray(JSONArray: listData))
                        if (!listData.isEmpty) {
                            completion()
                        }
                    } else {
                        self.fistBumperAccountRelay.accept([FistBumpUserModel]())
                    }
                }
            case .failure(let error):
                print(error)
                self.errorsSubject.onNext("Cannot get user's fistBump information")
            }
        }
    }
    func getFistBumpee(page: Int, completion: @escaping () -> Void = {}) -> Void  {
        APIManager().getFistBumper(userID: input.userID, page: page){
            result in
            switch result {
            case .success(let response):
                print("page number \(page)")
                if let data = response.body {
                    if let listData = data["data"] as? [[String: Any]] {
                        self.fistBumpeeAccountRelay.accept(Mapper<FistBumpUserModel>().mapArray(JSONArray: listData))
                        if (!listData.isEmpty) {
                            completion()
                        }
                    } else {
                        self.fistBumpeeAccountRelay.accept([FistBumpUserModel]())
                    }
                }
            case .failure(let error):
                print(error)
                self.errorsSubject.onNext("Cannot get user's fistBump information")
            }
        }
    }
    func getFistBumpeeCount(completion: @escaping (Int) -> Void = {_ in}) -> Void  {
        APIManager().getFistBumpeeCount(userID: input.userID){
            result in
            switch result {
            case .success(let response):
                if let data = response.body {
                    if let message = data["message"] as? String, message == "success"{
                        print("go here")
                        if let bodyData = data["data"] as? [[String: Any]] {
                            if let count = bodyData.first?["count"] as? Int {
                                self.fistBumpeeAccountsCountRelay.accept(count)
                                completion(count)
                            }
                        } else {
                            self.fistBumpeeAccountsCountRelay.accept(0)
                        }
                    }
                }
            case .failure(let error):
                print(error)
                self.errorsSubject.onNext("Cannot get user's fistBumpee information")
            }
        }
    }
    
    func getFistBumperCount(completion: @escaping (Int) -> Void = {_ in}) -> Void  {
        APIManager().getFistBumperCount(userID: input.userID){
            result in
            switch result {
            case .success(let response):
                if let data = response.body {
                    if let message = data["message"] as? String, message == "success"{
                        print("go here")
                        if let bodyData = data["data"] as? [[String: Any]] {
                            if let count = bodyData.first?["count"] as? Int {
                                self.fistBumperAccountsCountRelay.accept(count)
                                completion(count)
                            }
                        } else {
                            self.fistBumperAccountsCountRelay.accept(0)
                        }
                    }
                }
            case .failure(let error):
                print(error)
                self.errorsSubject.onNext("Cannot get user's fistBumper information")
            }
        }
    }
    
    func deleteFistBump(fistBumpId: String, completion: @escaping () -> Void = {}) -> Void {
        // do something with your strinf
        APIManager().deleteFistBump(userID: fistBumpId){
            result in switch result {
            case .success(_):
                self.successSubject.onNext(.unfistbump())
                completion()
            case .failure:
                self.errorsSubject.onNext("Cannot unfistBump user")
                
            }
        }
    }
    
    func addFistBump(fistBumpId: String, completion: @escaping () -> Void = {}) -> Void {
        // do something with your strinf
        APIManager().addFistBump(userID: fistBumpId){
            result in switch result {
            case .success(_):
                self.successSubject.onNext(.fistbump())
                completion()
            case .failure:
                self.errorsSubject.onNext("Successfully fistbump user")
                
            }
        }
    }
    
    func follow(userId: String, completion: @escaping () -> Void = {}) -> Void {
        // do something with your strinf
        APIManager().insertFollows(params: ["FollowId": userId]){
            result in switch result {
            case .success(_):
                self.successSubject.onNext(.follow())
                completion()
            case .failure:
                self.errorsSubject.onNext("Cannot follow user")
            }
        }
    }
    
    func unfollow(userId: String, completion: @escaping () -> Void = {}) -> Void {
        // do something with your strinf
        APIManager().deleteFollows(params: ["FollowId": userId]){
            result in switch result {
            case .success(_):
                self.successSubject.onNext(.unfollow())
                completion()
            case .failure:
                self.errorsSubject.onNext("Cannot unfollow user")
            }
        }
    }
    
    
    
    func logic() {}
    deinit{}
}
