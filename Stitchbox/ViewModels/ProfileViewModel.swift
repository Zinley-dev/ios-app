//
//  EditProfileViewModel.swift
//  Stitchbox
//
//  Created by Khanh Duy Nguyen on 12/26/22.
//

import UIKit
import RxSwift
import ObjectMapper

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
        var friendsID: AnyObserver<[String]>
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
        var friendsID: Observable<[String]>
        var birthday: Observable<String>
        var errorsObservable: Observable<Error>
        var successObservable: Observable<SuccessMessage>
    }
    
    var nameSubject = BehaviorSubject<String>(value: _AppCoreData.userDataSource.value?.name ?? "")
    var usernameSubject = BehaviorSubject<String>(value: _AppCoreData.userDataSource.value?.userName ?? "")
    var emailSubject = BehaviorSubject<String>(value: _AppCoreData.userDataSource.value?.email ?? "")
    var phoneSubject = BehaviorSubject<String>(value: _AppCoreData.userDataSource.value?.phone ?? "")
    var avatarSubject = BehaviorSubject<String>(value: _AppCoreData.userDataSource.value?.avatarURL ?? "")
    var coverSubject = BehaviorSubject<String>(value: _AppCoreData.userDataSource.value?.cover ?? "")
    var aboutSubject = BehaviorSubject<String>(value: _AppCoreData.userDataSource.value?.about ?? "")
    var bioSubject = BehaviorSubject<String>(value: _AppCoreData.userDataSource.value?.bio ?? "")
    var referralCodeSubject = BehaviorSubject<String>(value: _AppCoreData.userDataSource.value?.referralCode ?? "")
    var facebookSubject = BehaviorSubject<String>(value: _AppCoreData.userDataSource.value?.facebook?.uid ?? "")
    var googleSubject = BehaviorSubject<String>(value: _AppCoreData.userDataSource.value?.google?.uid ?? "")
    var tiktokSubject = BehaviorSubject<String>(value: _AppCoreData.userDataSource.value?.tiktok?.uid ?? "")
    var appleSubject = BehaviorSubject<String>(value: _AppCoreData.userDataSource.value?.apple?.uid ?? "")
    var birthdaySubject = BehaviorSubject<String>(value: _AppCoreData.userDataSource.value?.Birthday ?? "")
    var friendsIDSubject = BehaviorSubject<[String]>(value: _AppCoreData.userDataSource.value?.FriendsIds ?? [])
    var locationSubject = BehaviorSubject<String>(value: _AppCoreData.userDataSource.value?.location ?? "")
    var streamingLink = BehaviorSubject<String>(value: _AppCoreData.userDataSource.value?.location ?? "")
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
                    self.getUserData()
                    
                case .failure(let error):
                    print(error)
                    self.errorsSubject.onNext(error)
                }
            }
        }, onError: { error in
            self.errorsSubject.onNext(error)
        }).disposed(by: disposeBag)
        getUserData()
        logic()
    }
    func getUserData() {
        APIManager().getme{
            result in switch result {
            case .success(let response):
                print(response)
                if let data = response.body {
                        // write usr data
                        if let newUserData = Mapper<UserDataSource>().map(JSON: data) {
                            _AppCoreData.userDataSource.accept(newUserData)
                            print("newuserdata")
                            print(newUserData.toJSON())
                        }
                } else {
                    print("Cannot convert data object")
                    self.errorsSubject.onNext(NSError(domain: "Cannot get user's setting information", code: 400))
                }
                
            case .failure:
                self.errorsSubject.onNext(NSError(domain: "Cannot get user's setting information", code: 400))
            }
        }
    }
    
    
    func logic() {
        _AppCoreData.userDataSource.subscribe(onNext: {userData in
            print("fillupdatasource")
            self.fillUpSubjects(userData: userData)
        }, onError: {error in
            print(error)
            self.errorsSubject.onNext(error)
        }, onCompleted: {}).disposed(by: disposeBag)
    }
    
    func fillUpSubjects(userData: UserDataSource?) {
        if let unwrapUserData = userData {
            self.nameSubject.onNext(unwrapUserData.name)
            self.usernameSubject.onNext(unwrapUserData.userName)
            self.emailSubject.onNext(unwrapUserData.email)
            self.phoneSubject.onNext(unwrapUserData.phone)
            self.avatarSubject.onNext(unwrapUserData.avatarURL)
            self.coverSubject.onNext(unwrapUserData.cover)
            self.aboutSubject.onNext(unwrapUserData.about)
            self.locationSubject.onNext(unwrapUserData.location)
            self.bioSubject.onNext(unwrapUserData.bio)
            self.referralCodeSubject.onNext(unwrapUserData.referralCode)
            self.facebookSubject.onNext(unwrapUserData.facebook?.uid ?? "")
            self.googleSubject.onNext(unwrapUserData.google?.uid ?? "")
            self.tiktokSubject.onNext(unwrapUserData.tiktok?.uid ?? "")
            self.appleSubject.onNext(unwrapUserData.apple?.uid ?? "")
            self.friendsIDSubject.onNext(unwrapUserData.FriendsIds)
            self.birthdaySubject.onNext(unwrapUserData.Birthday)
        } else {
            print("User info not in cache. Retrieve data from source")
            self.getUserData()
        }
    }
    
    
}
