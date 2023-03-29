//
//  PushNotificationVC.swift
//  Stitchbox
//
//  Created by Khoi Nguyen on 1/17/23.
//

import UIKit
import RxSwift
import RxCocoa

class PushNotificationVC: UIViewController {
    
    let backButton: UIButton = UIButton(type: .custom)
    
    @IBOutlet weak var PostsSwitch: UISwitch!
    @IBOutlet weak var CommentSwitch: UISwitch!
    @IBOutlet weak var MentionSwitch: UISwitch!
    @IBOutlet weak var FollowSwitch: UISwitch!
    @IBOutlet weak var MessageSwitch: UISwitch!
    
   
    var isCommentNoti = false
    var isMessageNoti = false
    var isPostNoti = false
    var isFollowNoti = false
    var isMentionNoti = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupButtons()
        loadDefaultsValue()
       
    }
    
    func loadDefaultsValue() {
        
        if globalSetting.Notifications?.Posts == true {
            
            PostsSwitch.setOn(true, animated: true)
            isPostNoti = true
            
        } else {
            
            PostsSwitch.setOn(false, animated: true)
            isPostNoti = false
            
        }
        
        if globalSetting.Notifications?.Message == true {
            
            MessageSwitch.setOn(true, animated: true)
            isMessageNoti = true
            
        } else {
            
            MessageSwitch.setOn(false, animated: true)
            isMessageNoti = false
            
        }
        
        if globalSetting.Notifications?.Mention == true {
            
            MentionSwitch.setOn(true, animated: true)
            isMentionNoti = true
            
        } else {
            
            MentionSwitch.setOn(false, animated: true)
            isMentionNoti = false
            
        }
        
        if globalSetting.Notifications?.Follow == true {
            
            FollowSwitch.setOn(true, animated: true)
            isFollowNoti = true
            
        } else {
            
            FollowSwitch.setOn(false, animated: true)
            isFollowNoti = false
            
        }
        
        if globalSetting.Notifications?.Comment == true {
            
            CommentSwitch.setOn(true, animated: true)
            isCommentNoti = true
            
        } else {
            
            CommentSwitch.setOn(false, animated: true)
            isCommentNoti = false
            
        }
        
        
        
        
    }
    
    @IBAction func PostsSwitchPressed(_ sender: Any) {
        
        var params = ["notifications": ["posts": false]]
        
        if isPostNoti {
            
            params = ["notifications": ["posts": false]]
            isPostNoti = false
            
        } else {
            
            params = ["notifications": ["posts": true]]
            isPostNoti = true
        }
        
        APIManager().updateSettings(params: params) {
                        result in switch result {
                        case .success(_):
                            print("Setting API update success")
                            reloadGlobalSettings()
                        case.failure(let error):
                            DispatchQueue.main.async {
                                self.showErrorAlert("Oops!", msg: "Cannot update user's setting information \(error.localizedDescription)")
                            }
                        }
                    }
        
        
    }
    
    @IBAction func CommentSwitchPressed(_ sender: Any) {
        
        var params = ["notifications": ["comment": false]]
        
        if isCommentNoti {
            
            params = ["notifications": ["comment": false]]
            isCommentNoti = false
            
        } else {
            
            params = ["notifications": ["comment": true]]
            isCommentNoti = true
        }
        
        APIManager().updateSettings(params: params) {
                        result in switch result {
                        case .success(_):
                            print("Setting API update success")
                            reloadGlobalSettings()
                        case.failure(let error):
                            DispatchQueue.main.async {
                                self.showErrorAlert("Oops!", msg: "Cannot update user's setting information \(error.localizedDescription)")
                            }
                        }
                    }
        
    }
    
    @IBAction func MentionSwitchPressed(_ sender: Any) {
        
        var params = ["notifications": ["mention": false]]
        
        if isMentionNoti {
            
            params = ["notifications": ["mention": false]]
            isMentionNoti = false
            
        } else {
            
            params = ["notifications": ["mention": true]]
            isMentionNoti = true
        }
        
        APIManager().updateSettings(params: params) {
                        result in switch result {
                        case .success(_):
                            print("Setting API update success")
                            reloadGlobalSettings()
                        case.failure(let error):
                            DispatchQueue.main.async {
                                self.showErrorAlert("Oops!", msg: "Cannot update user's setting information \(error.localizedDescription)")
                            }
                        }
                    }
        
    }
    
    @IBAction func FollowSwitchPressed(_ sender: Any) {
        
        var params = ["notifications": ["follow": false]]
        
        if isFollowNoti {
            
            params = ["notifications": ["follow": false]]
            isFollowNoti = false
            
        } else {
            
            params = ["notifications": ["follow": true]]
            isFollowNoti = true
        }
        
        APIManager().updateSettings(params: params) {
                        result in switch result {
                        case .success(_):
                            print("Setting API update success")
                            reloadGlobalSettings()
                        case.failure(let error):
                            DispatchQueue.main.async {
                                self.showErrorAlert("Oops!", msg: "Cannot update user's setting information \(error.localizedDescription)")
                            }
                        }
                    }
        
    }
    
    @IBAction func MessageSwitchPressed(_ sender: Any) {
        
        var params = ["notifications": ["message": false]]
        
        if isMessageNoti {
            
            params = ["notifications": ["message": false]]
            isMessageNoti = false
    
        } else {
            
            params = ["notifications": ["message": true]]
            isMessageNoti = true
            
        }
        
        APIManager().updateSettings(params: params) {
                        result in switch result {
                        case .success(_):
                            print("Setting API update success")
                            reloadGlobalSettings()
                        case.failure(let error):
                            DispatchQueue.main.async {
                                self.showErrorAlert("Oops!", msg: "Cannot update user's setting information \(error.localizedDescription)")
                            }
                        }
                    }
        
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
        backButton.frame = back_frame
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
    
    func showErrorAlert(_ title: String, msg: String) {
        
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        
        
        present(alert, animated: true, completion: nil)
        
    }
    
}
