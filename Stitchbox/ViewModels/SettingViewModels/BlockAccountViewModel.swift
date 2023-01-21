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
    enum SuccessMessage {
        case logout
        case updateState
        case other
    }
    
    struct Output {
        //        var errorsObservable: Observable<Error>
        //        var successObservable: Observable<SuccessMessage>
    }
    
    private let blockAccountRelay = BehaviorRelay<[BlockUserModel]>(value: Mapper<BlockUserModel>().mapArray(JSONArray: []))
    private let allowChallengeRelay = BehaviorRelay<Bool>(value: true)
    private let allowDiscordLinkRelay = BehaviorRelay<Bool>(value: true)
    private let privateAccountRelay = BehaviorRelay<Bool>(value: true)
    private let autoPlaySoundRelay = BehaviorRelay<Bool>(value: true)
    private let challengeNotificationRelay = BehaviorRelay<Bool>(value: true)
    private let commentNotificationRelay = BehaviorRelay<Bool>(value: true)
    private let followNotificationRelay = BehaviorRelay<Bool>(value: true)
    private let postsNotificationRelay = BehaviorRelay<Bool>(value: true)
    private let mentionNotificationRelay = BehaviorRelay<Bool>(value: true)
    private let messageNotificationRelay = BehaviorRelay<Bool>(value: true)
    private let errorsSubject = PublishSubject<String>()
    private let successSubject = PublishSubject<SuccessMessage>()
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
            
        )
        
        logic()
        getAPISetting()
    }
    
    func getAPISetting() {
        APIManager().getBlocks{
            result in switch result {
            case .success(let response):
                print(response)
                if let data = response.body {
                    if let listData = data["data"] as? [[String: Any]] {
                        self.blockAccountRelay.accept(Mapper<BlockUserModel>().mapArray(JSONArray: listData))
                    }
                }
            case .failure:
                self.errorsSubject.onNext("Cannot get user's block information")
            }
        }
    }
    
    
    func logic() {
        
    }
}
