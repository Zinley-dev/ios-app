//
//  EditEmailVC.swift
//  Stitchbox
//
//  Created by Khoi Nguyen on 2/10/23.
//

import UIKit

class EditEmailVC: UIViewController {

    let backButton: UIButton = UIButton(type: .custom)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupButtons()
    }
    
    
    

}

extension EditEmailVC {
    
    
    func setupDefaultInfo() {
        
        if let email = _AppCoreData.userDataSource.value?.email, email != "" {
            //birthdayTxtField.placeholder = birthday
        } else {
            //birthdayTxtField.placeholder = ""
        }
        
    }

    
    func setupButtons() {
        
        setupBackButton()
    
    }
    
    
    func setupBackButton() {
        
        // Do any additional setup after loading the view.
        backButton.setImage(UIImage.init(named: "back_icn_white")?.resize(targetSize: CGSize(width: 13, height: 23)), for: [])
        backButton.addTarget(self, action: #selector(onClickBack(_:)), for: .touchUpInside)
        backButton.frame = back_frame
        backButton.setTitleColor(UIColor.white, for: .normal)
        backButton.setTitle("     Edit Email", for: .normal)
        backButton.sizeToFit()
        let backButtonBarButton = UIBarButtonItem(customView: backButton)
    
        self.navigationItem.leftBarButtonItem = backButtonBarButton
       
    }
    
}

extension EditEmailVC {
    
    
    @objc func onClickBack(_ sender: AnyObject) {
        if let navigationController = self.navigationController {
            navigationController.popViewController(animated: true)
        }
    }
    
}
