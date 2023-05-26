//
//  BlockAccountViewModel.swift
//  Stitchbox
//
//  Created by Khanh Duy Nguyen on 1/21/23.
//

import Foundation
import UIKit
import RxSwift
import RxRelay
import ObjectMapper

class BlockAccountsViewModel: ViewModelProtocol {
    var input: Input
    
    var action: Action
    
    var output: Output
    
    struct Input {
        var blockAccounts: BehaviorRelay<[BlockUserModel]>
    }
    
    struct Action {
        var submitChange: AnyObserver<Void>
    }
    
    struct Output {
        var errorsObservable: Observable<String>
        var successObservable: Observable<successMessage>
    }
    enum successMessage {
        case unblock(messsage: String = "Successfully unblock user")
        case follow(messsage: String = "Successfully follow user")
        case unfollow(messsage: String = "Successfully unfollow user")
    }
    
    private let blockAccountRelay = BehaviorRelay<[BlockUserModel]>(value: Mapper<BlockUserModel>().mapArray(JSONArray: []))
    private let errorsSubject = PublishSubject<String>()
    private let successSubject = PublishSubject<successMessage>()
    private let submitChangeSubject = PublishSubject<Void>()
    private let disposeBag = DisposeBag()
    
    init() {
        input = Input(
            blockAccounts: blockAccountRelay
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
    
    func getBlocks(page: Int, completion: @escaping () -> Void = {}) -> Void  {
        APIManager.shared.getBlocks(page: page){ [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let response):
                print("page number \(page)")
                if let data = response.body {
                    if let listData = data["data"] as? [[String: Any]] {
                        self.blockAccountRelay.accept(Mapper<BlockUserModel>().mapArray(JSONArray: listData))
                        if (!listData.isEmpty) {
                            completion()
                        }
                    } else {
                        self.blockAccountRelay.accept([BlockUserModel]())
                    }
                }
            case .failure(let error):
                print(error)
                self.errorsSubject.onNext("Cannot get user's block information")
            }
        }
    }
    
    func unblock(blockId: String, completion: @escaping () -> Void = {}) -> Void {
        // do something with your strinf
        APIManager.shared.deleteBlocks(params: ["blockId": blockId]){ [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(_):
                self.successSubject.onNext(.unblock())
                completion()
            case .failure:
                self.errorsSubject.onNext("Cannot unblock user")
                
            }
        }
    }
    
    func follow(userId: String, completion: @escaping () -> Void = {}) -> Void {
        // do something with your strinf
        APIManager.shared.insertFollows(params: ["FollowId": userId]){ [weak self] result in
            guard let self = self else { return }
            
            switch result {
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
        APIManager.shared.unFollow(params: ["FollowId": userId]){ [weak self] result in
            guard let self = self else { return }
            
            switch result {
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
