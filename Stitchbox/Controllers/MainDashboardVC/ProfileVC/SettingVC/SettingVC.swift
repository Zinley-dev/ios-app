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

class SettingVC: UIViewController, ControllerType {
    
    typealias ViewModelType = SettingViewModel
    
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
    
    let viewModel = SettingViewModel()
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        bindUI(with: viewModel)
        bindAction(with: viewModel)
        viewModel.getAPISetting()
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupButtons()
       
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.tabBarController?.tabBar.isHidden = true
        self.tabBarController?.tabBar.frame = .zero
        
        
        if self.tabBarController is DashboardTabBarController {
            let tbctrl = self.tabBarController as! DashboardTabBarController
            tbctrl.button.isHidden = true
        }
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        viewModel.action.submitChange.on(.next(Void()))
    }
    func bindUI(with viewModel: SettingViewModel) {
        
        (SoundSwitch.rx.isOn <-> viewModel.input.autoPlaySound).disposed(by: disposeBag)
        (StreamingLinkSwitch.rx.isOn <-> viewModel.input.allowDiscordLink).disposed(by: disposeBag)
        (PrivateAccountSwitch.rx.isOn <-> viewModel.input.privateAccount).disposed(by: disposeBag)
    }
    
    func bindAction(with viewModel: SettingViewModel) {}

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
