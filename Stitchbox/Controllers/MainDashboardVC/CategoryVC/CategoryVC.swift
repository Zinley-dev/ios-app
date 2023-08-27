//
//  CategoryVC.swift
//  Stitchbox
//
//  Created by Khoi Nguyen on 8/25/23.
//

import UIKit
import AsyncDisplayKit

class CategoryVC: UIViewController {
    
    deinit {
        print("CategoryVC is being deallocated.")
    }
    
    @IBOutlet weak var contentView: UIView!

    var collectionNode: ASCollectionNode!
    var categoryList = [UserNotificationModel]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        getCategory()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let navigationBarAppearance = UINavigationBarAppearance()
        navigationBarAppearance.configureWithOpaqueBackground()
        navigationBarAppearance.backgroundColor = .white
        navigationBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.black]
        navigationBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.black]
        
        self.navigationController?.navigationBar.standardAppearance = navigationBarAppearance
        self.navigationController?.navigationBar.scrollEdgeAppearance = navigationBarAppearance
        
    }
    

    @IBAction func skipBtnPressed(_ sender: Any) {
        
        dismissAndPost()
        
    }
    
    @IBAction func NextBtnPressed(_ sender: Any) {
        
        dismissAndPost()
        
    }
    
    func dismissAndPost() {
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reloadFeedAfterSetCategory"), object: nil)

        self.dismiss(animated: true)

    }
    
    func getCategory() {
        
        APIManager.shared.getCategory(page: 1, limit: 25) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let apiResponse):
                
                print(apiResponse)
                
                
            case .failure(let error):
                print(error)
                
            }
        }
        
        
    }
    
}
