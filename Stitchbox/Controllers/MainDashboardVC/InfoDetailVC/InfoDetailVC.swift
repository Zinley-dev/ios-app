//
//  InfoDetailVC.swift
//  Stitchbox
//
//  Created by Khoi Nguyen on 5/7/23.
//

import UIKit

class InfoDetailVC: UIViewController {
    
    @IBOutlet weak var bioTextView: UITextView!
    @IBOutlet weak var bioInfoLbl: UILabel!
    
    var userame = ""
    var bio = ""

    let backButton: UIButton = UIButton(type: .custom)


    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        if bio != "" {
            bioTextView.text = bio
        } else {
            bio = "No info yet!"
        }
        
        
        bioInfoLbl.text = ""
        
        setupButtons()
        
    }
    

}


extension InfoDetailVC {
    
    func setupButtons() {
        
        setupBackButton()
        
    }
    
    
    func setupBackButton() {
        
        // Do any additional setup after loading the view.
        backButton.setImage(UIImage.init(named: "back_icn_white")?.resize(targetSize: CGSize(width: 13, height: 23)), for: [])
        backButton.addTarget(self, action: #selector(onClickBack(_:)), for: .touchUpInside)
        backButton.frame = back_frame
        backButton.setTitleColor(UIColor.white, for: .normal)
        backButton.setTitle("", for: .normal)
        navigationItem.title = "\(userame)'s bio"
        backButton.sizeToFit()
        let backButtonBarButton = UIBarButtonItem(customView: backButton)
    
        self.navigationItem.leftBarButtonItem = backButtonBarButton
       
    }
    
    
   
    @objc func onClickBack(_ sender: AnyObject) {
        if let navigationController = self.navigationController {
            navigationController.popViewController(animated: true)
        }
    }

    
}
