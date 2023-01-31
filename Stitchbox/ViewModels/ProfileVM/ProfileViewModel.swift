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
            followingListObservable: followerListSubject.asObserver()
        )
        logic()
    }
    
    func logic() {
        
    }
    func getFollowing(page: Int = 0) {
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
                    self.followingSubject.onNext(data.count)
                    self.followingListSubject.onNext(list)
                case .failure(let error):
                    print(error)
            }
        }
    }
    func getFollowers(page: Int = 0) {
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
                    self.followersSubject.onNext(data.count)
                    self.followerListSubject.onNext(list)
                case .failure(let error):
                    print(error)
            }
        }
    }
    
//    func createPost(body req: CreatePostRequest) {
//        let params = [
//            "content": req.content,
//            "images": req.images,
//            "video": req.video,
//            "tags": req.tags,
//            "setting": req.setting
//        ] as [String : Any]
//        APIManager().createPost(params: params) { result in
//            switch result {
//                case .success(let response):
//                    print("success")
//                case .failure(let err):
//                    print("err")
//            }
//        }
//    }
//
}
