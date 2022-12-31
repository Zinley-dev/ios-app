//
//  EditProfileViewModel.swift
//  Stitchbox
//
//  Created by Khanh Duy Nguyen on 12/26/22.
//

import UIKit
import RxSwift

class EditProfileViewModel: ViewModelProtocol {
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
    var friendsIDSubject = PublishSubject<String>()
    var locationSubject = PublishSubject<String>()
    var editSubject = PublishSubject<Void>()
    
    var updatemeObservable: Observable<[String:Any]>
    private let errorsSubject = PublishSubject<Error>()
    private let successSubject = PublishSubject<SuccessMessage>()
    private let disposeBag = DisposeBag()
    
    init() {
        input = Input(name: nameSubject.asObserver(), username: usernameSubject.asObserver(), email: emailSubject.asObserver(), phone: phoneSubject.asObserver(), avatar: avatarSubject.asObserver(), cover: coverSubject.asObserver(), about: aboutSubject.asObserver(), bio: bioSubject.asObserver(), friendsID: friendsIDSubject.asObserver()
        )
        
        action = Action(
            edit: editSubject.asObserver())
        
        output = Output(name: nameSubject.asObservable(), username: usernameSubject.asObservable(), email: emailSubject.asObservable(), phone: phoneSubject.asObservable(), avatar: avatarSubject.asObservable(), cover: coverSubject.asObservable(), about: aboutSubject.asObservable(), bio: bioSubject.asObservable(), referralCode: referralCodeSubject.asObservable(), facebook: facebookSubject.asObservable(), google: googleSubject.asObservable(), tiktok: tiktokSubject.asObservable(), apple: appleSubject.asObservable(), friendsID: friendsIDSubject.asObservable(), errorsObservable: errorsSubject.asObservable(), successObservable: successSubject.asObservable()
        )
        
        updatemeObservable = Observable<[String:Any]>.combineLatest( aboutSubject.asObservable(), emailSubject.asObservable(), nameSubject.asObservable(), phoneSubject.asObservable(), usernameSubject.asObservable()) {
            ["about": $0, "email": $1, "name": $2,
             "phone": $3, "username": $4]
        }
        
        
        self.editSubject.asObservable()
            .debounce(.milliseconds(3000), scheduler: MainScheduler.instance)
            .withLatestFrom(updatemeObservable).subscribe(onNext: { params in
            print(params)
            UserInfoAPIManager().updateme(params: params) {
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
        UserInfoAPIManager().getme{
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
        
    }
    
    func populatePublishers(JSONObject: [String: Any]) {
        print(JSONObject)
        self.nameSubject.onNext((JSONObject["name"] as? String ?? ""))
        self.usernameSubject.onNext((JSONObject["username"] as? String ?? ""))
        self.emailSubject.onNext((JSONObject["email"]  as? String ?? ""))
        self.phoneSubject.onNext((JSONObject["phone"]  as? String ?? ""))
        self.avatarSubject.onNext((JSONObject["avatar"]  as? String ?? ""))
        self.coverSubject.onNext((JSONObject["cover"]  as? String ?? ""))
        self.aboutSubject.onNext((JSONObject["about"]  as? String ?? ""))
        self.locationSubject.onNext((JSONObject["location"]  as? String ?? ""))
        self.bioSubject.onNext((JSONObject["bio"] as? String ?? ""))
        self.referralCodeSubject.onNext((JSONObject["referralCode"]  as? String ?? ""))
        self.facebookSubject.onNext((JSONObject["facebook"] as! [String:Any])["uid"]  as? String ?? "")
        self.googleSubject.onNext((JSONObject["google"] as! [String:Any])["uid"]  as? String ?? "")
        self.tiktokSubject.onNext((JSONObject["tiktok"] as! [String:Any])["uid"]  as? String ?? "")
        self.appleSubject.onNext((JSONObject["apple"] as! [String:Any])["uid"]  as? String ?? "")
        self.friendsIDSubject.onNext((JSONObject["FriendsIds"]  as? String ?? ""))
        self.successSubject.onNext(.updateState)
        
    }
}
