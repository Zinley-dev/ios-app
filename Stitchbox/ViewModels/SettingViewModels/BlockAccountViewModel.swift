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
    
    func getBlocks(completion: ([BlockUserModel]) -> Void) {
        APIManager().getBlocks{
            result in switch result {
            case .success(let response):
                if let data = response.body {
                    if let listData = data["data"] as? [[String: Any]] {
                        self.blockAccountRelay.accept(Mapper<BlockUserModel>().mapArray(JSONArray: listData))
                    } else {
                        self.blockAccountRelay.accept([BlockUserModel]())                    }
                }
            case .failure:
                self.errorsSubject.onNext("Cannot get user's block information")
            }
        }
        
        completion(self.blockAccountRelay.value)
    }
    
    func unblock(blockId: String) -> Void {
        // do something with your strinf
        APIManager().deleteBlocks(params: ["blockId": blockId]){
            result in switch result {
            case .success(let response):
                self.successSubject.onNext("Successfully unblock user")
            case .failure:
                self.errorsSubject.onNext("Cannot unblock user")
                
            }
        }
    }
    
    func logic() {}
    deinit{}
}
