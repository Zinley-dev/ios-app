//
//  TrendingHashtagVC.swift
//  Stitchbox
//
//  Created by Khoi Nguyen on 7/19/23.
//

import UIKit

class TrendingHashtagVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        getHastag()
        getSuggestUser()
    }


    func getHastag() {
        
        APIManager.shared.getPostTrendingTag { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let apiResponse):
                
                print("Trending Hashtags: \(apiResponse)")
                
            case .failure(let error):
                print(error)
                
            }
        }
        
    }
    
    func getSuggestUser() {
        
        APIManager.shared.suggestUser(page: 1) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let apiResponse):
                
                print("SuggestUser: \(apiResponse)")
                
            case .failure(let error):
                print(error)
                
            }
        }
        
        
    }

}
