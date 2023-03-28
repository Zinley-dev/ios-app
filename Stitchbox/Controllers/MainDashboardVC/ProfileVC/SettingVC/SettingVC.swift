//
//  SettingVC.swift
//  Stitchbox
//
//  Created by Khoi Nguyen on 1/16/23.
//

import UIKit
import SafariServices
import RxCocoa
import RxSwift
import ObjectMapper

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
    
    var isStreamLink = false
    var isSound = false
    var isPrivate = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupButtons()
       
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        loadSettings()
        
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
        
        if let SVC = UIStoryboard(name: "Dashboard", bundle: nil).instantiateViewController(withIdentifier: "SecurityVC") as? SecurityVC {
            self.navigationController?.pushViewController(SVC, animated: true)
            
        }
        
    }
    
    @IBAction func accountActivityBtnPressed(_ sender: Any) {
        
        if let AAVC = UIStoryboard(name: "Dashboard", bundle: nil).instantiateViewController(withIdentifier: "AccountActivityVC") as? AccountActivityVC {
            self.navigationController?.pushViewController(AAVC, animated: true)
            
        }
        
    }
    
    @IBAction func blockAccountBtnPressed(_ sender: Any) {
        
        if let BLVC = UIStoryboard(name: "Dashboard", bundle: nil).instantiateViewController(withIdentifier: "BlockedListVC") as? BlockedListVC {
            self.navigationController?.pushViewController(BLVC, animated: true)
            
        }
        
    }
    
    @IBAction func contactUsBtnPressed(_ sender: Any) {
        
        if let CUVC = UIStoryboard(name: "Dashboard", bundle: nil).instantiateViewController(withIdentifier: "ContactUsVC") as? ContactUsVC {
            self.navigationController?.pushViewController(CUVC, animated: true)
            
        }
        
    }
    
    
    @IBAction func termOfServiceBtnPressed(_ sender: Any) {
        
        guard let urls = URL(string: "https://stitchbox.gg") else {
            return //be safe
        }
        
        let vc = SFSafariViewController(url: urls)
        vc.modalPresentationStyle = .fullScreen
        
        self.present(vc, animated: true, completion: nil)
        
        
    }
    
    @IBAction func logOutBtnPressed(_ sender: Any) {
        
        _AppCoreData.signOut()
        sendbirdLogout()
        
        if let SNVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "StartNavVC") as? StartNavVC {
            
            SNVC.modalPresentationStyle = .fullScreen
            self.present(SNVC, animated: true)
        }
        
        
    }
    
    
    @IBAction func SoundSwitchPressed(_ sender: Any) {
        
        var params = ["autoPlaySound": false]
        
        if isSound {
            
            params = ["autoPlaySound": false]
            isSound = false
            globalIsSound = false
            shouldMute = true
        } else {
            
            params = ["autoPlaySound": true]
            isSound = true
            globalIsSound = true
            shouldMute = false
        }

        APIManager().updateSettings(params: params) {
                        result in switch result {
                        case .success(_):
                            print("Setting API update success")
                            
                        case.failure(let error):
                            DispatchQueue.main.async {
                                self.showErrorAlert("Oops!", msg: "Cannot update user's setting information \(error.localizedDescription)")
                            }
                        }
                    }
        
        
    }
    
    @IBAction func StreamingLinkSwitchPressed(_ sender: Any) {
        
        var params = ["allowStreamingLink": false]
        
        if isStreamLink {
            
            params = ["allowStreamingLink": false]
            isStreamLink = false
            
        } else {
            
            params = ["allowStreamingLink": true]
            isStreamLink = true
        }
        
        APIManager().updateSettings(params: params) {
                        result in switch result {
                        case .success(_):
                            print("Setting API update success")
                            
                        case.failure(let error):
                            DispatchQueue.main.async {
                                self.showErrorAlert("Oops!", msg: "Cannot update user's setting information \(error.localizedDescription)")
                            }
                        }
                    }
        
        
    }
    
    @IBAction func PrivateSwitchPressed(_ sender: Any) {
        
        var params = ["privateAccount": false]
        
        if isPrivate {
            
            params = ["privateAccount": false]
            isPrivate = false
            
        } else {
            
            params = ["privateAccount": true]
            isPrivate = true
            
        }

        
        APIManager().updateSettings(params: params) {
                        result in switch result {
                        case .success(_):
                            print("Setting API update success")
                            
                        case.failure(let error):
                            DispatchQueue.main.async {
                                self.showErrorAlert("Oops!", msg: "Cannot update user's setting information \(error.localizedDescription)")
                        }
                }
            }
        
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
        backButton.frame = back_frame
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

extension SettingVC {
    
    func loadSettings() {
        
        APIManager().getSettings { result in
            switch result {
            case .success(let apiResponse):
                
                guard let data = apiResponse.body else {
                        return
                }

                globalSetting =  Mapper<SettingModel>().map(JSONObject: data)
                
                DispatchQueue.main {
                    self.processDefaultData()
                }
                
            case .failure(let error):
            
                DispatchQueue.main {
                    self.showErrorAlert("Oops!", msg: "Unable to retrieve your setting \(error.localizedDescription)")
                    self.navigationController?.popViewController(animated: true)
                }
               
            }
        }
        
        
    }
    
    func processDefaultData() {
        
        if globalSetting != nil {
            if globalSetting.AutoPlaySound == true {
                self.SoundSwitch.setOn(true, animated: true)
                isSound = true
            } else {
                self.SoundSwitch.setOn(false, animated: true)
                isSound = false
            }
            
            if globalSetting.AllowStreamingLink == true {
                self.StreamingLinkSwitch.setOn(true, animated: true)
                isStreamLink = true
            } else {
                self.StreamingLinkSwitch.setOn(false, animated: true)
                isStreamLink = false
            }
            
            if globalSetting.PrivateAccount == true {
                self.PrivateAccountSwitch.setOn(true, animated: true)
                isPrivate = true
            } else {
                self.PrivateAccountSwitch.setOn(false, animated: true)
                isPrivate = false
            }
            
        }
        
    }

    func showErrorAlert(_ title: String, msg: String) {
        
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        
        
        present(alert, animated: true, completion: nil)
        
    }
    
}
