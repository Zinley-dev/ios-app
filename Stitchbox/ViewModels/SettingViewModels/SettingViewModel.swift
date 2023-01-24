//
//  SettingViewModel.swift
//  Stitchbox
//
//  Created by Khanh Duy Nguyen on 12/17/22.
//

import Foundation
import UIKit
import RxSwift
import RxRelay
import ObjectMapper

class SettingViewModel: ViewModelProtocol {
    var input: Input
    
    var action: Action
    
    var output: Output
    
    struct Input {
        var allowChallenge: BehaviorRelay<Bool>
        var allowDiscordLink: BehaviorRelay<Bool>
        var privateAccount: BehaviorRelay<Bool>
        var autoPlaySound: BehaviorRelay<Bool>
        var challengeNotification: BehaviorRelay<Bool>
        var commentNotification: BehaviorRelay<Bool>
        var followNotification: BehaviorRelay<Bool>
        var postsNotification: BehaviorRelay<Bool>
        var mentionNotification: BehaviorRelay<Bool>
        var messageNotification: BehaviorRelay<Bool>
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
    
    private let settingSubject = BehaviorRelay<SettingModel?>(value: Mapper<SettingModel>().map(JSON: [:]))
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
    private let errorsSubject = PublishSubject<Error>()
    private let successSubject = PublishSubject<SuccessMessage>()
    private let submitChangeSubject = PublishSubject<Void>()
    private let disposeBag = DisposeBag()
    
    init() {
        input = Input(
            allowChallenge: allowChallengeRelay,
            allowDiscordLink: allowDiscordLinkRelay,
            privateAccount: privateAccountRelay,
            autoPlaySound: autoPlaySoundRelay,
            challengeNotification: challengeNotificationRelay,
            commentNotification: commentNotificationRelay,
            followNotification: followNotificationRelay,
            postsNotification:  postsNotificationRelay,
            mentionNotification:  mentionNotificationRelay,
            messageNotification: messageNotificationRelay
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
        APIManager().getSettings{
            result in switch result {
            case .success(let response):
                print(response)
                if let data = response.body {
                    self.settingSubject.accept(Mapper<SettingModel>().map(JSON: data))
                }
            case .failure:
                self.errorsSubject.onNext(NSError(domain: "Cannot get user's setting information", code: 400))
            }
        }
    }
    
    
    func logic() {
        settingSubject.subscribe(onNext: {
            settingObject in
            self.allowChallengeRelay.accept(settingObject?.AllowChallenge ?? true)
            self.allowDiscordLinkRelay.accept(settingObject?.AllowDiscordLink ?? true)
            self.privateAccountRelay.accept(settingObject?.PrivateAccount ?? true)
            self.autoPlaySoundRelay.accept(settingObject?.AutoPlaySound ?? true)
            self.challengeNotificationRelay.accept(settingObject?.Notifications?.Challenge ?? true)
            self.commentNotificationRelay.accept(settingObject?.Notifications?.Comment ?? true)
            self.followNotificationRelay.accept(settingObject?.Notifications?.Follow ?? true)
            self.postsNotificationRelay.accept(settingObject?.Notifications?.Posts ?? true)
            self.mentionNotificationRelay.accept(settingObject?.Notifications?.Mention ?? true)
            self.messageNotificationRelay.accept(settingObject?.Notifications?.Message ?? true)
        }).disposed(by: disposeBag)

        submitChangeSubject.subscribe{
            _ in
            let params = [
                "allowChallenge": self.allowChallengeRelay.value,
                "allowDiscordLink": self.allowDiscordLinkRelay.value,
                "autoMinimize": self.privateAccountRelay.value,
                "autoPlaySound": self.autoPlaySoundRelay.value,
                "notifications": [
                  "challenge": self.challengeNotificationRelay.value,
                  "comment": self.commentNotificationRelay.value,
                  "follow": self.followNotificationRelay.value,
                  "highlight": self.postsNotificationRelay.value,
                  "mention": self.mentionNotificationRelay.value,
                  "message": self.messageNotificationRelay.value
                ]
              ]
            print(params)
            APIManager().updateSettings(params: params) {
                result in switch result {
                case .success(_):
                    print("Setting API update success")
                    self.getAPISetting()
                case.failure(_):
                        self.errorsSubject.onNext(NSError(domain: "Cannot update user's setting information", code: 400))
                }
            }
        }.disposed(by: disposeBag)
    }
}
