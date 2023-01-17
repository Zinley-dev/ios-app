//
//  SettingVC.swift
//  Stitchbox
//
//  Created by Khoi Nguyen on 1/16/23.
//

import UIKit

class SettingVC: UIViewController {

    
    let backButton: UIButton = UIButton(type: .custom)
    
    @IBOutlet weak var logOutBtn: UIButton!
    @IBOutlet weak var TermOfServiceBtn: UIButton!
    @IBOutlet weak var contactUsBtn: UIButton!
    @IBOutlet weak var blockAccountBtn: UIButton!
    @IBOutlet weak var accountActivityBtn: UIButton!
    @IBOutlet weak var securityBtn: UIButton!
    @IBOutlet weak var pushNotificationBtn: UIButton!
    @IBOutlet weak var findFriendsBtn: UIButton!
    @IBOutlet weak var referralBtn: UIButton!
    
    @IBOutlet weak var SoundSwitch: UISwitch!
    @IBOutlet weak var StreamingLinkSwitch: UISwitch!
    @IBOutlet weak var PrivateAccountSwitch: UISwitch!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupButtons()
        wireDelegate()
    }

    
    @IBAction func referralBtnPressed(_ sender: Any) {
        
        if let MRVC = UIStoryboard(name: "Dashboard", bundle: nil).instantiateViewController(withIdentifier: "MyReferralCodeVC") as? MyReferralCodeVC {
            self.navigationController?.pushViewController(MRVC, animated: true)
            
        }
    }
    
    @IBAction func findFriendsBtn(_ sender: Any) {
        
        if let FFVC = UIStoryboard(name: "Dashboard", bundle: nil).instantiateViewController(withIdentifier: "FindFriendsVC") as? FindFriendsVC {
            self.navigationController?.pushViewController(FFVC, animated: true)
            
        }
    }
    
    @IBAction func pushNotificationBtnPressed(_ sender: Any) {
        
        if let PNVC = UIStoryboard(name: "Dashboard", bundle: nil).instantiateViewController(withIdentifier: "PushNotificationVC") as? PushNotificationVC {
            self.navigationController?.pushViewController(PNVC, animated: true)
            
        }
        
    }
    
    @IBAction func securityBtnPressed(_ sender: Any) {
        
        
        
    }
    
    @IBAction func accountActivityBtnPressed(_ sender: Any) {
        
        
        
    }
    
    @IBAction func blockAccountBtnPressed(_ sender: Any) {
        
        
        
    }
    
    @IBAction func contactUsBtnPressed(_ sender: Any) {
        
        
        
    }
    
    
    @IBAction func termOfServiceBtnPressed(_ sender: Any) {
        
        
        
    }
    
    @IBAction func logoutBtnPressed(_ sender: Any) {
        
        
        
        
        
    }
    
    
    @IBAction func soundSwitchPressed(_ sender: Any) {
        
        
        
    }
    
    
    
    @IBAction func streamingLinkSwitchPressed(_ sender: Any) {
        
        
        
    }
    
    
    @IBAction func privateAccountSwitchPressed(_ sender: Any) {
        
        
        
    }
    
    
    
}


//setting up navigationCollection Bar
extension SettingVC: UINavigationBarDelegate, UINavigationControllerDelegate {
    
    func wireDelegate() {
        self.navigationController?.navigationBar.delegate = self
    }
    
    func position(for bar: UIBarPositioning) -> UIBarPosition {
        return .topAttached
    }
    
    
}


extension SettingVC {
    
    func setupButtons() {
        
        setupBackButton()
        emptyButtonLabel()
        
    }
    
    
    func setupBackButton() {
        
        
        // Do any additional setup after loading the view.
        backButton.setImage(UIImage.init(named: "back_icn_white")?.resize(targetSize: CGSize(width: 13, height: 23)), for: [])
        backButton.addTarget(self, action: #selector(onClickBack(_:)), for: .touchUpInside)
        backButton.frame = CGRect(x: -10, y: 0, width: 15, height: 25)
        backButton.setTitleColor(UIColor.white, for: .normal)
        backButton.setTitle("     Settings", for: .normal)
        backButton.sizeToFit()
        let backButtonBarButton = UIBarButtonItem(customView: backButton)
    
        self.navigationItem.leftBarButtonItem = backButtonBarButton
       
    }

    
    @objc func onClickBack(_ sender: AnyObject) {
        if let navigationController = self.navigationController {
            navigationController.popViewController(animated: true)
        }
    }
    
    
    func emptyButtonLabel() {
        
        
        logOutBtn.setTitle("", for: .normal)
        TermOfServiceBtn.setTitle("", for: .normal)
        contactUsBtn.setTitle("", for: .normal)
        blockAccountBtn.setTitle("", for: .normal)
        accountActivityBtn.setTitle("", for: .normal)
        securityBtn.setTitle("", for: .normal)
        pushNotificationBtn.setTitle("", for: .normal)
        
        findFriendsBtn.setTitle("", for: .normal)
        referralBtn.setTitle("", for: .normal)
        
    }
      
    
}
