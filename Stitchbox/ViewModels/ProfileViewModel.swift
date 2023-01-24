//
//  EditProfileViewModel.swift
//  Stitchbox
//
//  Created by Khanh Duy Nguyen on 12/26/22.
//

import UIKit
import RxSwift
import RxRelay
import ObjectMapper

class ProfileViewModel: ViewModelProtocol {
    public enum ProfileType {
        case me
        case other
    }
    var profileType : ProfileType = .me
    
    var input: Input
    
    var action: Action
    
    var output: Output
    
    struct Input {
        var name: BehaviorRelay<String>
        var username: BehaviorRelay<String>
        var email: BehaviorRelay<String>
        var phone: BehaviorRelay<String>
        var avatar: BehaviorRelay<String>
        var cover: BehaviorRelay<String>
        var about: BehaviorRelay<String>
        var bio: BehaviorRelay<String>
        var friendsID: BehaviorRelay<[String]>
        var birthday: BehaviorRelay<String>
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
        let headerObservable: Observable<ProfileHeaderData>
        let challengeCardObservable: Observable<ChallengeCardHeaderData>
        let postsObservable: Observable<[postThumbnail]>
    }
    
    var nameSubject = BehaviorRelay<String>(value: _AppCoreData.userDataSource.value?.name ?? "")
    var usernameSubject = BehaviorRelay<String>(value: _AppCoreData.userDataSource.value?.userName ?? "")
    var emailSubject = BehaviorRelay<String>(value: _AppCoreData.userDataSource.value?.email ?? "")
    var phoneSubject = BehaviorRelay<String>(value: _AppCoreData.userDataSource.value?.phone ?? "")
    var avatarSubject = BehaviorRelay<String>(value: _AppCoreData.userDataSource.value?.avatarURL ?? "")
    var coverSubject = BehaviorRelay<String>(value: _AppCoreData.userDataSource.value?.cover ?? "")
    var aboutSubject = BehaviorRelay<String>(value: _AppCoreData.userDataSource.value?.about ?? "")
    var bioSubject = BehaviorRelay<String>(value: _AppCoreData.userDataSource.value?.bio ?? "")
    var referralCodeSubject = BehaviorRelay<String>(value: _AppCoreData.userDataSource.value?.referralCode ?? "")
    var facebookSubject = BehaviorRelay<String>(value: _AppCoreData.userDataSource.value?.facebook?.uid ?? "")
    var googleSubject = BehaviorRelay<String>(value: _AppCoreData.userDataSource.value?.google?.uid ?? "")
    var tiktokSubject = BehaviorRelay<String>(value: _AppCoreData.userDataSource.value?.tiktok?.uid ?? "")
    var appleSubject = BehaviorRelay<String>(value: _AppCoreData.userDataSource.value?.apple?.uid ?? "")
    var birthdaySubject = BehaviorRelay<String>(value: _AppCoreData.userDataSource.value?.Birthday ?? "")
    var friendsIDSubject = BehaviorRelay<[String]>(value: _AppCoreData.userDataSource.value?.FriendsIds ?? [])
    var locationSubject = BehaviorRelay<String>(value: _AppCoreData.userDataSource.value?.location ?? "")
    var followersSubject = BehaviorRelay<Int>(value: 50)
    var followingssSubject = BehaviorRelay<Int>(value: 50)
    var streamingLink = BehaviorRelay<String>(value: _AppCoreData.userDataSource.value?.location ?? "")
    var editSubject = PublishSubject<Void>()
    var updatemeObservable: Observable<[String:Any]>
    private let errorsSubject = PublishSubject<Error>()
    private let successSubject = PublishSubject<SuccessMessage>()
    private let disposeBag = DisposeBag()
    
    init(UID: String = _AppCoreData.userDataSource.value?.userID ?? "") {
        if UID == _AppCoreData.userDataSource.value?.userID {
            self.profileType = .me
        } else {
            self.profileType = .other
        }
        
        input = Input(name: nameSubject, username: usernameSubject, email: emailSubject, phone: phoneSubject, avatar: avatarSubject, cover: coverSubject, about: aboutSubject, bio: bioSubject, friendsID: friendsIDSubject, birthday: birthdaySubject
        )
        
        action = Action(
            edit: editSubject.asObserver())
        
        let headerObservable = Observable<ProfileHeaderData>.combineLatest(nameSubject.asObservable(), usernameSubject.asObservable(), bioSubject.asObservable(), coverSubject.asObservable(), avatarSubject.asObservable(), followersSubject.asObservable(), followingssSubject.asObservable(), streamingLink.asObservable()){
             ProfileHeaderData(name: $0, username: $1, bio: $2, cover: $3, avatar: $4, followers: $5, followings: $6, streamingLink: $7)
        }
        let challengeCardObservable = Observable<ChallengeCardHeaderData>.combineLatest( nameSubject.asObservable(), coverSubject.asObservable()) { elem1, elem2 in
            return ChallengeCardHeaderData(name: "", accountType: "", postCount: 2)
        }
        
        let postsObservable = Observable<[postThumbnail]>.combineLatest( bioSubject.asObservable(), coverSubject.asObservable()) { elem1, elem2 in
            return []
        }
        
    
        output = Output(headerObservable: headerObservable, challengeCardObservable: challengeCardObservable, postsObservable: postsObservable)
            
        
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
        switch profileType {
        case .me:
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
        case .other:
            break
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
            self.nameSubject.accept(unwrapUserData.name)
            self.usernameSubject.accept(unwrapUserData.userName)
            self.emailSubject.accept(unwrapUserData.email)
            self.phoneSubject.accept(unwrapUserData.phone)
            self.avatarSubject.accept(unwrapUserData.avatarURL)
            self.coverSubject.accept(unwrapUserData.cover)
            self.aboutSubject.accept(unwrapUserData.about)
            self.locationSubject.accept(unwrapUserData.location)
            self.bioSubject.accept(unwrapUserData.bio)
            self.referralCodeSubject.accept(unwrapUserData.referralCode)
            self.facebookSubject.accept(unwrapUserData.facebook?.uid ?? "")
            self.googleSubject.accept(unwrapUserData.google?.uid ?? "")
            self.tiktokSubject.accept(unwrapUserData.tiktok?.uid ?? "")
            self.appleSubject.accept(unwrapUserData.apple?.uid ?? "")
            self.friendsIDSubject.accept(unwrapUserData.FriendsIds)
            self.birthdaySubject.accept(unwrapUserData.Birthday)
        } else {
            print("User info not in cache. Retrieve data from source")
            self.getUserData()
        }
    }
    
    
}
