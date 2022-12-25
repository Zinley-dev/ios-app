//
//  SettingViewModel.swift
//  Stitchbox
//
//  Created by Khanh Duy Nguyen on 12/17/22.
//

import Foundation
import UIKit
import RxSwift

class SettingViewModel: ViewModelProtocol {
    var input: Input
    
    var action: Action
    
    var output: Output
    
    struct Input {
        var allowChallenge: AnyObserver<Bool>
        var allowDiscordLink: AnyObserver<Bool>
        var autoMinimize: AnyObserver<Bool>
        var autoPlaySound: AnyObserver<Bool>
        var challengeNotification: AnyObserver<Bool>
        var commentNotification: AnyObserver<Bool>
        var followNotification: AnyObserver<Bool>
        var highlightNotification: AnyObserver<Bool>
        var mentionNotification: AnyObserver<Bool>
        var messageNotification: AnyObserver<Bool>
    }
    
    struct Action {
        var logOutDidTap: AnyObserver<Void>
        var edit: AnyObserver<Void>
    }
    enum SuccessMessage {
        case logout
        case updateState
        case other
    }
    
    struct Output {
        var allowChallenge: Observable<Bool>
        var allowDiscordLink: Observable<Bool>
        var autoMinimize: Observable<Bool>
        var autoPlaySound: Observable<Bool>
        var challengeNotification: Observable<Bool>
        var commentNotification: Observable<Bool>
        var followNotification: Observable<Bool>
        var highlightNotification: Observable<Bool>
        var mentionNotification: Observable<Bool>
        var messageNotification: Observable<Bool>
        var errorsObservable: Observable<Error>
        var successObservable: Observable<SuccessMessage>
    }
    
    var allowChallengeSubject = PublishSubject<Bool>()
    var allowDiscordLinkSubject = PublishSubject<Bool>()
    var autoMinimizeSubject = PublishSubject<Bool>()
    var autoPlaySoundSubject = PublishSubject<Bool>()
    var challengeNotificationSubject = PublishSubject<Bool>()
    var commentNotificationSubject = PublishSubject<Bool>()
    var followNotificationSubject = PublishSubject<Bool>()
    var highlightNotificationSubject = PublishSubject<Bool>()
    var mentionNotificationSubject = PublishSubject<Bool>()
    var messageNotificationSubject = PublishSubject<Bool>()
    var logOutSubject = PublishSubject<Void>()
    var editSubject = PublishSubject<Void>()
    
    var notificationObservable: Observable<[String:Any]>
    var settingObservable: Observable<[String:Any]>
    private let errorsSubject = PublishSubject<Error>()
    private let successSubject = PublishSubject<SuccessMessage>()
    private let disposeBag = DisposeBag()
    
    init() {
        input = Input(
            allowChallenge: allowChallengeSubject.asObserver(),
            allowDiscordLink: allowDiscordLinkSubject.asObserver(),
            autoMinimize: autoMinimizeSubject.asObserver(),
            autoPlaySound: autoPlaySoundSubject.asObserver(),
            challengeNotification: challengeNotificationSubject.asObserver(),
            commentNotification: commentNotificationSubject.asObserver(),
            followNotification: followNotificationSubject.asObserver(),
            highlightNotification:  highlightNotificationSubject.asObserver(),
            mentionNotification:  mentionNotificationSubject.asObserver(),
            messageNotification: messageNotificationSubject.asObserver()
        )
        
        action = Action(
            logOutDidTap: logOutSubject.asObserver(),
            edit: editSubject.asObserver())
        
        output = Output(
            allowChallenge: allowChallengeSubject.asObservable(),
            allowDiscordLink: allowDiscordLinkSubject.asObservable(),
            autoMinimize: autoMinimizeSubject.asObservable(),
            autoPlaySound: autoPlaySoundSubject.asObservable(),
            challengeNotification: challengeNotificationSubject.asObservable(),
            commentNotification: commentNotificationSubject.asObservable(),
            followNotification: followNotificationSubject.asObservable(),
            highlightNotification:  highlightNotificationSubject.asObservable(),
            mentionNotification:  mentionNotificationSubject.asObservable(),
            messageNotification: messageNotificationSubject.asObservable(),
            errorsObservable: errorsSubject.asObservable(),
            successObservable: successSubject.asObservable()
        )
        
        notificationObservable = Observable<[String:Any]>.combineLatest( commentNotificationSubject.asObservable(), followNotificationSubject.asObservable(), highlightNotificationSubject.asObservable(), mentionNotificationSubject.asObservable(), messageNotificationSubject.asObservable(),
                                                               challengeNotificationSubject.asObservable()) {
            ["comment": $0, "follow": $1, "highlight": $2,
             "mention": $3, "message": $4, "challenge": $5]
        }
        settingObservable = Observable<[String:Any]>.combineLatest(
            allowChallengeSubject.asObservable(),
            allowDiscordLinkSubject.asObservable(),
            autoPlaySoundSubject.asObservable(),
            autoMinimizeSubject.asObservable(),
            notificationObservable) {
                ["allowChallenge": $0, "allowDiscordLink": $1,
                 "autoPlaySound": $2, "autoMinimize": $3, "notifications": $4]}
        
        self.editSubject.asObservable()
            .debounce(.milliseconds(3000), scheduler: MainScheduler.instance)
            .withLatestFrom(settingObservable).subscribe(onNext: { params in
            print(params)
            SettingAPIManager().updateSettings(params: params) {
                result in switch result {
                case .success(let response):
                    print(response)
                    self.getAPISetting()
                case .failure(let error):
                    print(error)
                    self.errorsSubject.onNext(error)
                }
            }
        }, onError: { error in
            self.errorsSubject.onNext(error)
        }).disposed(by: disposeBag)
        
        logic()
        getAPISetting()
        
    }
    func getAPISetting() {
        SettingAPIManager().getSettings{
            result in switch result {
            case .success(let response):
                print(response)
                let data = response.body!
                self.populatePublishers(JSONObject: data)
            case .failure:
                self.errorsSubject.onNext(NSError(domain: "Cannot get user's setting information", code: 400))
            }
        }
    }
    
    
    func logic() {
        logOutSubject
            .subscribe (onNext: { Void in
                _AppCoreData.signOut()
                self.successSubject.onNext(.logout)
            }, onError: { (err) in
                print("Error \(err.localizedDescription)")
            }, onCompleted: {
                print("Completed")
            })
            .disposed(by: disposeBag);
    }
    
    func populatePublishers(JSONObject: [String: Any]) {
        print(JSONObject)
        self.allowChallengeSubject.onNext((JSONObject["AllowChallenge"] as! Int == 1))
        self.allowDiscordLinkSubject.onNext((JSONObject["AllowDiscordLink"] as! Int == 1))
        self.autoMinimizeSubject.onNext((JSONObject["AutoMinimize"] as! Int == 1))
        self.autoPlaySoundSubject.onNext((JSONObject["AutoPlaySound"] as! Int == 1))
        let notifications = JSONObject["Notifications"]! as! [String: Any]
        self.challengeNotificationSubject.onNext((notifications["Challenge"] as! Int == 1))
        self.commentNotificationSubject.onNext((notifications["Comment"] as! Int == 1))
        self.followNotificationSubject.onNext((notifications["Follow"] as! Int == 1))
        self.highlightNotificationSubject.onNext((notifications["Highlight"] as! Int == 1))
        self.mentionNotificationSubject.onNext((notifications["Mention"] as! Int == 1))
        self.messageNotificationSubject.onNext((notifications["Message"] as! Int == 1))
        self.successSubject.onNext(.updateState)
        
    }
}
