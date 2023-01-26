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
        getAPISetting()
    }
    
    func getAPISetting() {
        APIManager().getBlocks{
            result in switch result {
            case .success(let response):
                print(response)
                if let data = response.body {
                    if let listData = data["data"] as? [[String: Any]] {
                        print(listData)
                        self.blockAccountRelay.accept(Mapper<BlockUserModel>().mapArray(JSONArray: listData))
                    } else {
                        self.blockAccountRelay.accept([BlockUserModel]())
                    }
                }
            case .failure:
                self.errorsSubject.onNext("Cannot get user's block information")
            }
        }
    }
    
    // handle notification
    // For swift 4.0 and above put @objc attribute in front of function Definition
    @objc func unblock(_ notification: NSNotification) {
        if let blockId = notification.userInfo?["blockId"] as? String {
            // do something with your strinf
            APIManager().deleteBlocks(params: ["blockId": blockId]){
                result in switch result {
                case .success(let response):
                    print(response)
                    self.successSubject.onNext("Successfully unblock user")
                    self.getAPISetting()
                case .failure:
                    self.errorsSubject.onNext("Cannot unblock user")
                }
            }
        }
    }
    
    func logic() {
        NotificationCenter.default.addObserver(self, selector: #selector(unblock(_:)), name: NSNotification.Name("unblock"), object: nil)
    }
    deinit{
        NotificationCenter.default.removeObserver(self)
    }
}
