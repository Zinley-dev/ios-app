//
//  IntroTacticsVC.swift
//  Stitchbox
//
//  Created by Khoi Nguyen on 4/8/23.
//

import UIKit
import SafariServices
import AsyncDisplayKit


class TrendingVC: UIViewController {
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        navigationItem.title = "Trending"
        navigationControllerDelegate()
        
        
        let navigationBarAppearance = UINavigationBarAppearance()
        navigationBarAppearance.configureWithOpaqueBackground()
        navigationBarAppearance.backgroundColor = .background
        navigationBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        navigationBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        
        if let navigationController = self.navigationController {
            navigationController.navigationBar.prefersLargeTitles = false
            navigationController.navigationBar.standardAppearance = navigationBarAppearance
            navigationController.navigationBar.scrollEdgeAppearance = navigationBarAppearance
            navigationController.navigationBar.isTranslucent = false
        }
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        showMiddleBtn(vc: self)
        
        let navigationBarAppearance = UINavigationBarAppearance()
        navigationBarAppearance.configureWithOpaqueBackground()
        navigationBarAppearance.backgroundColor = .background
        navigationBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        navigationBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        
        if let navigationController = self.navigationController {
            navigationController.navigationBar.prefersLargeTitles = false
            navigationController.navigationBar.standardAppearance = navigationBarAppearance
            navigationController.navigationBar.scrollEdgeAppearance = navigationBarAppearance
            navigationController.navigationBar.isTranslucent = false
        }
        
       
    }

    
}


extension TrendingVC {

    func showErrorAlert(_ title: String, msg: String) {
        
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        
        
        present(alert, animated: true, completion: nil)
        
    }
    
    
}

extension TrendingVC: UINavigationBarDelegate, UINavigationControllerDelegate {
    
    func navigationControllerDelegate() {
        self.navigationController?.delegate = self
    }
    
}
