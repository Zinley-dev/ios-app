//
//  ProfileViewModel.swift
//  Stitchbox
//
//  Created by Hisoft Hoangnm on 20/01/2023.
//
import Foundation
import RxSwift
import ObjectMapper

class ProfileViewModel: ViewModelProtocol {
    struct Input {
        
    }
     
    struct Action {
        
    }
    
    struct Output {
        let followersObservable: Observable<Int>
        let followingObservable: Observable<Int>
    }
    
    
    let input: Input
    let action: Action
    let output: Output
    
    
    private let followersSubject = PublishSubject<Int>()
    private let followingSubject = PublishSubject<Int>()
    
    init() {
        input = Input()
        action = Action()
        output = Output(
            followersObservable: followersSubject.asObserver(),
            followingObservable: followingSubject.asObserver()
        )
        logic()
    }
    
    func logic() {
        
    }
    func getFollowing() {
        APIManager().getFollowing() { result in
            switch result {
                case .success(let response):
                    print("=================================================")
                    // get and process data
                    if (response.body?["message"] as! String == "success") {
                        // get and process data
                        let data: [Any] = response.body?["data"] as! [Any]
                        print(data.count)
                        self.followingSubject.onNext(data.count)
                    }
                    print("=================================================")
                case .failure(let error):
                    print(error)
            }
        }
    }
    func getFollowers() {
        APIManager().getFollower { result in
            switch result {
                case .success(let response):
                    print("=================================================")
                    // get and process data
                    if (response.body?["message"] as! String == "success") {
                        // get and process data
                        let data: [Any] = response.body?["data"] as! [Any]
                        print(data.count)
                        self.followersSubject.onNext(data.count)
                    }
                    print("=================================================")
                case .failure(let error):
                    print(error)
            }
        }
    }
}
