//
//  PushNotificationVC.swift
//  Stitchbox
//
//  Created by Khoi Nguyen on 1/17/23.
//

import UIKit

class PushNotificationVC: UIViewController {

    
    let backButton: UIButton = UIButton(type: .custom)
    
    @IBOutlet weak var PostsSwitch: UISwitch!
    @IBOutlet weak var CommentSwitch: UISwitch!
    @IBOutlet weak var MentionSwitch: UISwitch!
    @IBOutlet weak var FollowSwitch: UISwitch!
    @IBOutlet weak var MessageSwitch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupButtons()
        
    }
    
    @IBAction func PostsSwitchPressed(_ sender: Any) {
        
        
        
    }
    
    @IBAction func CommentSwitchPressed(_ sender: Any) {
        
        
        
    }
    
    @IBAction func MentionSwitchPressed(_ sender: Any) {
        
        
        
    }
    
    @IBAction func FollowSwitchPressed(_ sender: Any) {
        
        
        
    }
    
    @IBAction func MessageSwitchPressed(_ sender: Any) {
        
        
        
    }


}


extension PushNotificationVC {
    
    func setupButtons() {
        
        setupBackButton()
        
    }
    
    
    func setupBackButton() {
        
        
        // Do any additional setup after loading the view.
        backButton.setImage(UIImage.init(named: "back_icn_white")?.resize(targetSize: CGSize(width: 13, height: 23)), for: [])
        backButton.addTarget(self, action: #selector(onClickBack(_:)), for: .touchUpInside)
        backButton.frame = CGRect(x: -10, y: 0, width: 15, height: 25)
        backButton.setTitleColor(UIColor.white, for: .normal)
        backButton.setTitle("     Push Notification", for: .normal)
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
