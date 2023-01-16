//
//  EditProfileViewModel.swift
//  Stitchbox
//
//  Created by Khanh Duy Nguyen on 12/26/22.
//

import UIKit
import RxSwift

class ProfileViewModel: ViewModelProtocol {
    var input: Input
    
    var action: Action
    
    var output: Output
    
    struct Input {
        var name: AnyObserver<String>
        var username: AnyObserver<String>
        var email: AnyObserver<String>
        var phone: AnyObserver<String>
        var avatar: AnyObserver<String>
        var cover: AnyObserver<String>
        var about: AnyObserver<String>
        var bio: AnyObserver<String>
        var friendsID: AnyObserver<String>
        var birthday: AnyObserver<String>
    }
    
    struct Action {
        var edit: AnyObserver<Void>
    }
    enum SuccessMessage {
        case logout
        case updateState
        case other(message: String)
    }
    
    struct Output {
        var name: Observable<String>
        var username: Observable<String>
        var email: Observable<String>
        var phone: Observable<String>
        var avatar: Observable<String>
        var cover: Observable<String>
        var about: Observable<String>
        var bio: Observable<String>
        var referralCode: Observable<String>
        var facebook: Observable<String>
        var google: Observable<String>
        var tiktok: Observable<String>
        var apple: Observable<String>
        var friendsID: Observable<String>
        var birthday: Observable<String>
        var errorsObservable: Observable<Error>
        var successObservable: Observable<SuccessMessage>
    }
    
    var nameSubject = PublishSubject<String>()
    var usernameSubject = PublishSubject<String>()
    var emailSubject = PublishSubject<String>()
    var phoneSubject = PublishSubject<String>()
    var avatarSubject = PublishSubject<String>()
    var coverSubject = PublishSubject<String>()
    var aboutSubject = PublishSubject<String>()
    var bioSubject = PublishSubject<String>()
    var referralCodeSubject = PublishSubject<String>()
    var facebookSubject = PublishSubject<String>()
    var googleSubject = PublishSubject<String>()
    var tiktokSubject = PublishSubject<String>()
    var appleSubject = PublishSubject<String>()
    var birthdaySubject = PublishSubject<String>()
    var friendsIDSubject = PublishSubject<String>()
    var locationSubject = PublishSubject<String>()
    var editSubject = PublishSubject<Void>()
    
    var updatemeObservable: Observable<[String:Any]>
    private let errorsSubject = PublishSubject<Error>()
    private let successSubject = PublishSubject<SuccessMessage>()
    private let disposeBag = DisposeBag()
    
    init() {
        input = Input(name: nameSubject.asObserver(), username: usernameSubject.asObserver(), email: emailSubject.asObserver(), phone: phoneSubject.asObserver(), avatar: avatarSubject.asObserver(), cover: coverSubject.asObserver(), about: aboutSubject.asObserver(), bio: bioSubject.asObserver(), friendsID: friendsIDSubject.asObserver(), birthday: birthdaySubject.asObserver()
        )
        
        action = Action(
            edit: editSubject.asObserver())
        
        output = Output(name: nameSubject.asObservable(), username: usernameSubject.asObservable(), email: emailSubject.asObservable(), phone: phoneSubject.asObservable(), avatar: avatarSubject.asObservable(), cover: coverSubject.asObservable(), about: aboutSubject.asObservable(), bio: bioSubject.asObservable(), referralCode: referralCodeSubject.asObservable(), facebook: facebookSubject.asObservable(), google: googleSubject.asObservable(), tiktok: tiktokSubject.asObservable(), apple: appleSubject.asObservable(), friendsID: friendsIDSubject.asObservable(), birthday: birthdaySubject.asObservable(), errorsObservable: errorsSubject.asObservable(), successObservable: successSubject.asObservable()
        )
        
        updatemeObservable = Observable<[String:Any]>.combineLatest( aboutSubject.asObservable(), emailSubject.asObservable(), nameSubject.asObservable(), phoneSubject.asObservable(), usernameSubject.asObservable(), bioSubject.asObservable(), birthdaySubject.asObservable()) {
            ["about": $0, "email": $1, "name": $2,
             "phone": $3, "username": $4, "bio": $5, "birthday": $6]
        }
        
        
        self.editSubject.asObservable()
            .debounce(.milliseconds(3000), scheduler: MainScheduler.instance)
            .withLatestFrom(updatemeObservable).subscribe(onNext: { params in
            print(params)
            APIManager().updateme(params: params) {
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
        }, onDisposed: disposeBag)
        
        logic()
        getAPISetting()
        
    }
    func getAPISetting() {
        APIManager().{
            result in switch result {
            case .success(let response):
                print(response)
                let data = response.body!
                
            case .failure:
                self.errorsSubject.onNext(NSError(domain: "Cannot get user's setting information", code: 400))
            }
        }
    }
    
    
    func logic() {
        _AppCoreData.userDataSource.subscribe(onNext: {userData in
            self.nameSubject.onNext(userData?.name)
            self.usernameSubject.onNext(userData?.userName)
            self.emailSubject.onNext(userData?.email)
            self.phoneSubject.onNext(userData?.phone)
            self.avatarSubject.onNext(userData?.avatarURL)
            self.coverSubject.onNext(userData?.cover)
            self.aboutSubject.onNext(userData?.about)
            self.locationSubject.onNext(userData?.location)
            self.bioSubject.onNext(userData?.bio)
            self.referralCodeSubject.onNext(userData?.referralCode)
            self.facebookSubject.onNext(userData?.facebook?.uid)
            self.googleSubject.onNext(userData?.google?.uid)
            self.tiktokSubject.onNext(userData?.tiktok?.uid)
            self.appleSubject.onNext(userData?.apple?.uid)
            self.friendsIDSubject.onNext(userData?.FriendsIds)
            self.birthdaySubject.onNext(userData?.birthday)
        }, onError: {error in
            print(error)
            self.errorsSubject.onNext(error)
        }, onCompleted: {}).disposed(by: disposeBag)
    }
    
    func processBirthday(birthday: String) -> String {
        return String()
    }
    
}
