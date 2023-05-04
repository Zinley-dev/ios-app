//
//  PostNavVC.swift
//  Stitchbox
//
//  Created by Khoi Nguyen on 1/23/23.
//

import UIKit

class PostNavVC: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
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
