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
    
    deinit {
        print("SettingVC is being deallocated.")
    }
    
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
    @IBOutlet weak var proBtn: UIButton!
    
    @IBOutlet weak var SoundSwitch: UISwitch!
    @IBOutlet weak var StitchSwitch: UISwitch!
    @IBOutlet weak var PublicStitchSwitch: UISwitch!
    @IBOutlet weak var ClearSwitch: UISwitch!
    @IBOutlet weak var proView: UIView!
    
    
    @IBOutlet weak var mainViewHeight: NSLayoutConstraint!
    @IBOutlet weak var accountViewHeight: NSLayoutConstraint!
    
    var isStitch = false
    var isPublicStitch = false
    var isSound = false
    var isPrivate = false
    var isClearMode = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupButtons()
        setupNavBar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        loadSettings()
        checkAccountStatus()
        setupNavBar()
    }
    
    func setupNavBar() {
        
        let navigationBarAppearance = UINavigationBarAppearance()
        navigationBarAppearance.configureWithOpaqueBackground()
        navigationBarAppearance.backgroundColor = .white
        navigationBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.black]
        navigationBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.black]
        
        self.navigationController?.navigationBar.standardAppearance = navigationBarAppearance
        self.navigationController?.navigationBar.scrollEdgeAppearance = navigationBarAppearance
        
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
        
        guard let urls = URL(string: "https://stitchbox.net/term-of-use") else {
            return //be safe
        }
        
        let vc = SFSafariViewController(url: urls)
        vc.modalPresentationStyle = .fullScreen
        
        self.present(vc, animated: true, completion: nil)
        
        
    }
    
    @IBAction func logOutBtnPressed(_ sender: Any) {
        
        presentSwiftLoader()
        sendbirdLogout()
        IAPManager.shared.signout()
        removeAllUserDefaults()
        
        delay(1) { [weak self] in
        guard let self = self else { return }
            
        _AppCoreData.signOut()
            
            
            
        if let SNVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "StartViewController") as? StartViewController {
                
                
            let nav = UINavigationController(rootViewController: SNVC)

            // Customize the navigation bar appearance
            nav.navigationBar.barTintColor = .background
            nav.navigationBar.tintColor = .white
            nav.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]

            nav.modalPresentationStyle = .fullScreen
            self.present(nav, animated: true, completion: nil)
                
            }
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
        
        APIManager.shared.updateSettings(params: params) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(_):
                print("Setting API update success")
                reloadGlobalSettings()
                
            case.failure(let error):
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    self.showErrorAlert("Oops!", msg: "Cannot update user's setting information \(error.localizedDescription)")
                }
            }
        }
        
        
    }
    
    @IBAction func StitchSwitchPressed(_ sender: Any) {
        
        var params = ["allowStitch": false]
        
        if isStitch {
            
            params = ["allowStitch": false]
            isStitch = false
            
        } else {
            
            params = ["allowStitch": true]
            isStitch = true
        }
        
        APIManager.shared.updateSettings(params: params) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(_):
                print("Setting API update success")
                reloadGlobalSettings()
                
            case.failure(let error):
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    self.showErrorAlert("Oops!", msg: "Cannot update user's setting information \(error.localizedDescription)")
                }
            }
        }
        
        
    }
    
    
    @IBAction func ClearSwitchPressed(_ sender: Any) {
        
        var params = ["clearMode": false]
        
        if isClearMode {
            
            params = ["clearMode": false]
            isClearMode = false
            globalClear = false
            
        } else {
            
            params = ["clearMode": true]
            isClearMode = true
            globalClear = true
        }
        
        APIManager.shared.updateSettings(params: params) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(_):
                print("Setting API update success")
                reloadGlobalSettings()
                
            case.failure(let error):
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    self.showErrorAlert("Oops!", msg: "Cannot update user's setting information \(error.localizedDescription)")
                }
            }
        }
        
        
    }
    
    @IBAction func PublicStitchSwitchPressed(_ sender: Any) {
        
        var params = ["publicStitch": false]
        
        if isPublicStitch {
            
            params = ["publicStitch": false]
            isPublicStitch = false
            
        } else {
            
            params = ["publicStitch": true]
            isPublicStitch = true
        }
        
        APIManager.shared.updateSettings(params: params) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(_):
                print("Setting API update success")
                reloadGlobalSettings()
                
            case.failure(let error):
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    self.showErrorAlert("Oops!", msg: "Cannot update user's setting information \(error.localizedDescription)")
                }
            }
        }
        
        
    }
    
    @IBAction func proAccountBtnPressed(_ sender: Any) {
        
        if let SVC = UIStoryboard(name: "Dashboard", bundle: nil).instantiateViewController(withIdentifier: "SubcriptionVC") as? SubcriptionVC {
            
            let nav = UINavigationController(rootViewController: SVC)
            
            // Customize the navigation bar appearance
            nav.navigationBar.barTintColor = .background
            nav.navigationBar.tintColor = .white
            nav.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
            
            nav.modalPresentationStyle = .fullScreen
            self.present(nav, animated: true, completion: nil)
        }
        
    }
    
    
}


extension SettingVC {
    
    func setupButtons() {
        
        setupBackButton()
        emptyButtonLabel()
        
    }
    
    
    func setupBackButton() {
        
        backButton.frame = back_frame
        backButton.contentMode = .center
        
        if let backImage = UIImage(named: "back-black") {
            let imageSize = CGSize(width: 13, height: 23)
            let padding = UIEdgeInsets(top: (back_frame.height - imageSize.height) / 2,
                                       left: (back_frame.width - imageSize.width) / 2 - horizontalPadding,
                                       bottom: (back_frame.height - imageSize.height) / 2,
                                       right: (back_frame.width - imageSize.width) / 2 + horizontalPadding)
            backButton.imageEdgeInsets = padding
            backButton.setImage(backImage, for: [])
        }
        
        backButton.addTarget(self, action: #selector(onClickBack(_:)), for: .touchUpInside)
        backButton.setTitleColor(UIColor.white, for: .normal)
        navigationItem.title = "Settings"
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
        proBtn.setTitle("", for: .normal)
        
        findFriendsBtn.setTitle("", for: .normal)
        referralBtn.setTitle("", for: .normal)
        
    }
    
    
}

extension SettingVC {
    
    func loadSettings() {
        
        DispatchQueue.main {
            self.processDefaultData()
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
            
            if globalSetting.AllowStitch == true {
                self.StitchSwitch.setOn(true, animated: true)
                isStitch = true
            } else {
                self.StitchSwitch.setOn(false, animated: true)
                isStitch = false
            }
            
            if globalSetting.PublicStitch == true {
                self.PublicStitchSwitch.setOn(true, animated: true)
                isStitch = true
            } else {
                self.PublicStitchSwitch.setOn(false, animated: true)
                isStitch = false
            }
            
            if globalSetting.ClearMode == true {
                self.ClearSwitch.setOn(true, animated: true)
                isStitch = true
            } else {
                self.ClearSwitch.setOn(false, animated: true)
                isStitch = false
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

extension SettingVC {
    
    func checkAccountStatus() {
        
        if let passEligible = _AppCoreData.userDataSource.value?.passEligible {
            
            if passEligible {
                
                self.setupLayoutForPro()
                
            } else {
                
                checkPlan()
                
            }
            
        } else {
            
            checkPlan()
            
        }
        
    }
    
    func checkPlan() {
        
        IAPManager.shared.checkPermissions { result in
            if result == false {
                
                Dispatch.main.async {
                    
                    self.setupLayoutForNonPro()
                    
                    
                }
                
            } else {
             
                Dispatch.main.async {
                
                    self.setupLayoutForPro()
                    
                }
  
            }
        }
        
    }

    func setupLayoutForPro() {
        
        mainViewHeight.constant = 950
        accountViewHeight.constant = 400
        proView.isHidden = true
        
    }
    
    func setupLayoutForNonPro() {
        
        mainViewHeight.constant = 1000
        accountViewHeight.constant = 450
        proView.isHidden = false
        
    }
    
}
