//
//  MainFollowVC.swift
//  Stitchbox
//
//  Created by Khoi Nguyen on 1/20/23.
//

import UIKit

class MainFollowVC: UIViewController {
    
    let backButton: UIButton = UIButton(type: .custom)
    
    var type = ""
    var ownerID = ""

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupButtons()
        
    }
    


}

extension MainFollowVC {
    
    func setupButtons() {
        
        setupBackButton()
        setupTitle()
    }
    
    
    func setupBackButton() {
        
        // Do any additional setup after loading the view.
        backButton.setImage(UIImage.init(named: "back_icn_white")?.resize(targetSize: CGSize(width: 13, height: 23)), for: [])
        backButton.addTarget(self, action: #selector(onClickBack(_:)), for: .touchUpInside)
        backButton.frame = CGRect(x: -10, y: 0, width: 15, height: 25)
        backButton.setTitleColor(UIColor.white, for: .normal)
        backButton.setTitle("", for: .normal)
        backButton.sizeToFit()
        let backButtonBarButton = UIBarButtonItem(customView: backButton)
    
        self.navigationItem.leftBarButtonItem = backButtonBarButton
       
    }
    
    func setupTitle() {
        
        guard let userDataSource = _AppCoreData.userDataSource.value else {
            print("Can't get userDataSource")
            return
        }

        let loadUsername = userDataSource.userName ?? "default"
        
        self.navigationItem.title = loadUsername
       
       
    }

    
    @objc func onClickBack(_ sender: AnyObject) {
        if let navigationController = self.navigationController {
            navigationController.popViewController(animated: true)
        }
    }
    
    
}
