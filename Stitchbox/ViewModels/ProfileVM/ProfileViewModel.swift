//
//  ProfileViewModel.swift
//  Stitchbox
//
//  Created by Hisoft Hoangnm on 20/01/2023.
//
import Foundation
import RxSwift
import ObjectMapper
import AsyncDisplayKit

class ProfileViewModel: ViewModelProtocol {
    struct Input {
        
    }
    
    struct Action {
        
    }
    
    struct Output {
        let followersObservable: Observable<Int>
        let followingObservable: Observable<Int>
        let fistbumpObservable: Observable<Int>
        let followerListObservable: Observable<[FollowModel]>
        let followingListObservable: Observable<[FollowModel]>
        let allFollowingListObservable: Observable<[FollowModel]>
        let myPostObservable: Observable<[PostModel]>
    }
    
    
    let input: Input
    let action: Action
    let output: Output
    
    
    private let followersSubject = PublishSubject<Int>()
    private let followingSubject = PublishSubject<Int>()
    private let fistbumpSubject = PublishSubject<Int>()
    private let followerListSubject = PublishSubject<[FollowModel]>()
    private let followingListSubject = PublishSubject<[FollowModel]>()
    private let allFollowingListSubject = PublishSubject<[FollowModel]>()
    private let myPostSubject = PublishSubject<[PostModel]>()
    
    init() {
        input = Input()
        action = Action()
        output = Output(
            followersObservable: followersSubject.asObservable(),
            followingObservable: followingSubject.asObservable(),
            fistbumpObservable: fistbumpSubject.asObservable(),
            followerListObservable: followerListSubject.asObserver(),
            followingListObservable: followingListSubject.asObserver(),
            allFollowingListObservable: allFollowingListSubject.asObserver(),
            myPostObservable: myPostSubject.asObserver()
        )
        logic()
    }
    
    func logic() {
        
    }
    func getMyPost(page: Int = 1) {
        APIManager.shared.getMyPost(page: page) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let response):
                print("================ooooOOOoooo=================================")
                guard response.body?["message"] as? String == "success",
                      let data = response.body?["data"] as? [[String: Any]] else {
                    print("err")
                    return
                }
                let posts = data.map { item in
                    let mypost = PostModel(JSON: item)!
                    return mypost
                }
                self.myPostSubject.onNext(posts)
            case .failure(let error):
                print(error)
            }
        }
    }
    func getFollowing(page: Int = 1) {
        print("LOAD PAGE \(page)")
        APIManager.shared.getFollows(page:page) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let response):
                guard response.body?["message"] as? String == "success",
                      let data = response.body?["data"] as? [[String: Any]] else {
                    return
                }
                let list = data.map { item in
                    return FollowModel(JSON: item)!
                }
                print("Following List: ", list)
                self.followingSubject.onNext(data.count)
                self.followingListSubject.onNext(list)
            case .failure(let error):
                print("Error loading following: ", error)
            }
        }
    }
    func getFollowers(page: Int = 1) {
        print("LOAD PAGE \(page)")
        APIManager.shared.getFollowers(page: page) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let response):
                guard response.body?["message"] as? String == "success",
                      let data = response.body?["data"] as? [[String: Any]] else {
                    return
                }
                let list = data.map { item in
                    return FollowModel(JSON: item)!
                }
                print("Follower List: ", list)
                self.followersSubject.onNext(data.count)
                self.followerListSubject.onNext(list)
            case .failure(let error):
                print(error)
            }
        }
    }
    func getFistBumperCount(userID: String =  _AppCoreData.userDataSource.value?.userID ?? "", completion: @escaping (Int) -> Void = {_ in}) -> Void  {
        APIManager.shared.getFistBumperCount(userID: userID){ [weak self] result in
            guard let self = self else { return }

            switch result {
            case .success(let response):
                if let data = response.body {
                    if let message = data["message"] as? String, message == "success"{
                        print("go here")
                        if let bodyData = data["data"] as? [[String: Any]] {
                            if let count = bodyData.first?["count"] as? Int {
                                self.fistbumpSubject.onNext(count)
                                completion(count)
                            }
                        } else {
                            self.fistbumpSubject.onNext(0)
                        }
                    }
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    func unfollow(userId: String = "") {
        
        APIManager.shared.unFollow(params: ["FollowId": userId]) { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .success(_):
                showNote(text: "Unfollowed!")
                
            case .failure(_):
                showNote(text: "Something happened!")
                
            }
        }
    }
    
    
    func insertfollow(userId: String = "") {
        APIManager.shared.insertFollows(params: ["FollowId": userId]) { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .success(_):
                showNote(text: "Followed!")
            case .failure(_):
                showNote(text: "Something happened!")
            }
            
        }
    }
    //    func getAllFollowing() {
    //        APIManager().getAllFollow { result in
    //            switch result {
    //            case .success(let response):
    //                guard response.body?["message"] as? String == "success",
    //                      let data = response.body?["data"] as? [[String: Any]] else {
    //                    return
    //                }
    //                let list = data.map { item in
    //                    return FollowerModel(JSON: item)!
    //                }
    //                print("Following List: ", list)
    //                self.allFollowingListSubject.onNext(list)
    //            case .failure(let error):
    //                print("Error loading following: ", error)
    //            }
    //        }
    //    }
}
