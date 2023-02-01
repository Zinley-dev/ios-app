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
        let followerListObservable: Observable<[FollowerModel]>
        let followingListObservable: Observable<[FollowerModel]>
    }
    
    
    let input: Input
    let action: Action
    let output: Output
    
    
    private let followersSubject = PublishSubject<Int>()
    private let followingSubject = PublishSubject<Int>()
    private let followerListSubject = PublishSubject<[FollowerModel]>()
    private let followingListSubject = PublishSubject<[FollowerModel]>()
    init() {
        input = Input()
        action = Action()
        output = Output(
            followersObservable: followersSubject.asObserver(),
            followingObservable: followingSubject.asObserver(),
            followerListObservable: followerListSubject.asObserver(),
            followingListObservable: followingListSubject.asObserver()
        )
        logic()
    }
    
    func logic() {
        
    }
    func getFollowing(page: Int = 1) {
        print("LOAD PAGE \(page)")
        APIManager().getFollowing(page:page) { result in
            switch result {
            case .success(let response):
                guard response.body?["message"] as? String == "success",
                      let data = response.body?["data"] as? [[String: Any]] else {
                    return
                }
                let list = data.map { item in
                    return FollowerModel(JSON: item)!
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
        APIManager().getFollower(page: page) { result in
            switch result {
            case .success(let response):
                guard response.body?["message"] as? String == "success",
                      let data = response.body?["data"] as? [[String: Any]] else {
                    return
                }
                let list = data.map { item in
                    return FollowerModel(JSON: item)!
                }
                print("Follower List: ", list)
                self.followersSubject.onNext(data.count)
                self.followerListSubject.onNext(list)
            case .failure(let error):
                print(error)
            }
        }
    }
    func unfollow(userId: String = "") {
        APIManager().deleteFollow(params: ["FollowId": userId]) { result in
            switch result {
            case .success(_):
                showNote(text: "Unfollowed!")
                
            case .failure(_):
                showNote(text: "Something happened!")
                
            }
        }
    }
    
    
    func insertfollow(userId: String = "") {
        APIManager().insertFollow(params: ["FollowId": userId]) { result in
            switch result {
            case .success(_):
                showNote(text: "Followed!")
            case .failure(_):
                showNote(text: "Something happened!")
            }
            
        }
    }
}
