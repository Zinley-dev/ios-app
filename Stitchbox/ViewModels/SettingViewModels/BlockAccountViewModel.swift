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
        var successObservable: Observable<String>
    }
    
    private let blockAccountRelay = BehaviorRelay<[BlockUserModel]>(value: Mapper<BlockUserModel>().mapArray(JSONArray: []))
    private let errorsSubject = PublishSubject<String>()
    private let successSubject = PublishSubject<String>()
    private let submitChangeSubject = PublishSubject<Void>()
    private let disposeBag = DisposeBag()
    private let limitFetch = 10
    private let pagingSubject = BehaviorRelay<PagingModel>(value: Mapper<PagingModel>().map(JSON: [
        "limit": 1,
        "page": -1,
        "total": 1])!)
//    private let group = DispatchGroup()
    
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
    
    func getBlocks(page: Int) -> Void  {
//        group.enter()
//        print(pagingSubject.value.toJSON())
//        if (pagingSubject.value.isEndOfPage()) {
//            return
//        }
//        let newPagingObject = ["limit": limitFetch, "page": page]
        APIManager().getBlocks(page: page){
            result in
            switch result {
            case .success(let response):
                if let data = response.body {
                    if let listData = data["data"] as? [[String: Any]] {
                        print("runned here")
                        print(listData)
                        self.blockAccountRelay.accept(Mapper<BlockUserModel>().mapArray(JSONArray: listData))
                    } else {
                        self.blockAccountRelay.accept([BlockUserModel]())                    }
//                    if let pagingInfo = data["paging"] as? [String: Any] {
//                        self.pagingSubject.accept(Mapper<PagingModel>().map(JSON: pagingInfo) ?? Mapper<PagingModel>().map(JSON: [
//                            "limit": 1,
//                            "page": 1,
//                            "total": 1])!)
//                    }
                    
                }
            case .failure(let error):
                print(error)
                self.errorsSubject.onNext("Cannot get user's block information")
            }
        }
//        group.leave()
//        completion(self.blockAccountRelay.value)
    }
    
    func unblock(blockId: String) -> Void {
        // do something with your strinf
        APIManager().deleteBlocks(params: ["blockId": blockId]){
            result in switch result {
            case .success(_):
                self.successSubject.onNext("Successfully unblock user")
            case .failure:
                self.errorsSubject.onNext("Cannot unblock user")
                
            }
        }
    }
    
    func follow(userId: String) -> Void {
        // do something with your strinf
        APIManager().insertFollows(params: ["blockId": userId]){
            result in switch result {
            case .success(_):
                self.successSubject.onNext("Successfully unblock user")
            case .failure:
                self.errorsSubject.onNext("Cannot unblock user")
                
            }
        }
    }
    
    
    
    func logic() {}
    deinit{}
}
