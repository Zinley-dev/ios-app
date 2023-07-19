//
//  TrendingPostVC.swift
//  Stitchbox
//
//  Created by Khoi Nguyen on 7/19/23.
//

import UIKit

class TrendingPostVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        getTrendingPost()
    }
    


    func getTrendingPost() {
        
        APIManager.shared.getPostTrending { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let apiResponse):
                
                print("TrendingPost: \(apiResponse)")
                
            case .failure(let error):
                print(error)
                
            }
        }
        
    }
    
}
