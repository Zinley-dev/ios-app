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
        let myPostObservable: Observable<[MyPost]>
    }
    
    
    let input: Input
    let action: Action
    let output: Output
    
    
    private let followersSubject = PublishSubject<Int>()
    private let followingSubject = PublishSubject<Int>()
    private let followerListSubject = PublishSubject<[FollowerModel]>()
    private let myPostSubject = PublishSubject<[MyPost]>()
  
    init() {
        input = Input()
        action = Action()
        output = Output(
            followersObservable: followersSubject.asObserver(),
            followingObservable: followingSubject.asObserver(),
            followerListObservable: followerListSubject.asObserver(),
            myPostObservable: myPostSubject.asObserver()
        )
        logic()
    }
    
    func logic() {
        
    }
    func getMyPost(page: Int) {
        APIManager().getMyPost(page: page) { result in
            switch result {
                case .success(let response):
                    print("================ooooOOOoooo=================================")
                    
                    guard response.body?["message"] as? String == "success",
                          let data = response.body?["data"] as? [[String: Any]] else {
                        print("err")
                        return
                    }
                    let posts = data.map { item in
                      let mypost = MyPost(JSON: item)!
                      return mypost
                    }
                self.myPostSubject.onNext(posts)
                case .failure(let error):
                  print(error)
            }
        }
    }
    func getFollowing() {
      APIManager().getFollows(page: 1){ result in
            switch result {
                case .success(let response):
                    print("================XXX=================================")
                    // get and process data
                    guard response.body?["message"] as? String == "success",
                        let data = response.body?["data"] as? [FollowerModel] else {
                        print("err")
                        return
                    }
                    print(data.count)
                    self.followingSubject.onNext(data.count)
                    print("=================================================")
                case .failure(let error):
                    print(error)
            }
        }
    }
    func getFollowers() {
      APIManager().getFollowers(page: 1) { result in
            switch result {
                case .success(let response):
                    print("===================XXX==============================")
                    // get and process data
                    guard response.body?["message"] as? String == "success",
                          let data = response.body?["data"] as? [FollowerModel] else {
                        print("err")
//                        print(response.body?["data"])
                        
                        
                        let follower = FollowerModel(JSONString: "{\"avatar\": \"https://sgp1.digitaloceanspaces.com/dev.storage/6bab1242-88c5-4705-81e9-3a9e13c47d41.png\",\"userId\": \"639e674eab2572f58918d2e2\",\"username\":\"kai1004pro\"}")!
                        
                        self.followerListSubject.onNext([follower, follower, follower, follower, follower, follower, follower, follower, follower, follower, follower, follower])
                        return
                    }
                    print(data)
                    self.followersSubject.onNext(data.count)
                    self.followerListSubject.onNext(data)
                    print("=================================================")
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
