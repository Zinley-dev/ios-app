//
//  AddVC.swift
//  Stitchbox
//
//  Created by Khoi Nguyen on 1/21/23.
//

import UIKit

class AddVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        NotificationCenter.default.addObserver(self, selector: #selector(AddVC.updateProgressBar), name: (NSNotification.Name(rawValue: "updateProgressBar")), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(AddVC.switchvc), name: (NSNotification.Name(rawValue: "switchvc")), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(AddVC.switchvcToIndex), name: (NSNotification.Name(rawValue: "switchvcToIndex")), object: nil)
    
        
        let navigationBarAppearance = UINavigationBarAppearance()
        navigationBarAppearance.configureWithOpaqueBackground()
        navigationBarAppearance.backgroundColor = .background
        navigationBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        navigationBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        
        if let navigationController = self.navigationController {
                    navigationController.navigationBar.prefersLargeTitles = false
                    navigationController.navigationBar.isTranslucent = false
                }
        
    }


}


extension AddVC {
    
    @objc func switchvc() {
    
        print("switch request")
        self.tabBarController?.selectedViewController = self.tabBarController?.viewControllers![0]
        
        if let vc = UIViewController.currentViewController() as? FeedViewController {
            
            vc.setupTabBar()
            
        }
        
    }
    
    @objc func switchvcToIndex() {
    
        print("switchvcToIndex request \(selectedTabIndex)")
        self.tabBarController?.selectedViewController = self.tabBarController?.viewControllers![selectedTabIndex]
        
    }
    
    
    @objc func updateProgressBar() {
        
        
        NotificationCenter.default.post(name: (NSNotification.Name(rawValue: "updateProgressBar2")), object: nil)
        
        if (global_percentComplete == 0.00) || (global_percentComplete == 100.0) {
            
           
            global_percentComplete = 0.00
            
        }
        
        
        
    }
    
}
