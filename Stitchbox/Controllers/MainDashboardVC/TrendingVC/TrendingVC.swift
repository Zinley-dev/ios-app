//
//  TrendingVC.swift
//  Stitchbox
//
//  Created by Khoi Nguyen on 7/15/23.
//

import UIKit

class TrendingVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupWhiteTabBar()
    }
    
    
    func setupWhiteTabBar() {
        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.configureWithOpaqueBackground()
        tabBarAppearance.backgroundColor = .white
        tabBarAppearance.stackedLayoutAppearance.selected.iconColor = .white
        tabBarAppearance.stackedLayoutAppearance.normal.iconColor = .white
        self.tabBarController?.tabBar.standardAppearance = tabBarAppearance
    }
    

}
