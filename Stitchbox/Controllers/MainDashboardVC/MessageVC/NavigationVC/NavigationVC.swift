//
//  NavigationVC.swift
//  Dual
//
//  Created by Khoi Nguyen on 9/21/21.
//

import UIKit
import SendBirdSDK
import SendBirdCalls

class NavigationVC: UINavigationController, UINavigationControllerDelegate, UINavigationBarDelegate {

    @IBOutlet weak var bar: UINavigationBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bar.delegate = self
        
    }
    
    func position(for bar: UIBarPositioning) -> UIBarPosition {
        return .topAttached
    }
    

}
