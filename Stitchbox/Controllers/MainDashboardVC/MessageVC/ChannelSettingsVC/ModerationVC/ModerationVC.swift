//
//  ModerationVC.swift
//  Stitchbox
//
//  Created by Khoi Nguyen on 1/2/23.
//

import UIKit
import SendBirdSDK
import SendBirdUIKit

class ModerationVC: UIViewController {
    
    deinit {
        print("ModerationVC is being deallocated.")
    }
    
    @IBOutlet weak var banBtn: UIButton!
    @IBOutlet weak var mutedBtn: UIButton!
    @IBOutlet weak var operatorBtn: UIButton!
    
    @IBOutlet weak var freezeIcon: UIImageView!
    @IBOutlet weak var bannedIcon: UIImageView!
    @IBOutlet weak var mutedIcon: UIImageView!
    @IBOutlet weak var operatorIcon: UIImageView!
    @IBOutlet weak var switchBtn: UISwitch!
    var channel: SBDGroupChannel?
    
    let backButton: UIButton = UIButton(type: .custom)
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        freezeIcon.image = SBUIconSet.iconFreeze.withTintColor(UIColor.black)
        bannedIcon.image = SBUIconSet.iconBan.withTintColor(UIColor.black)
        mutedIcon.image = SBUIconSet.iconMute.withTintColor(UIColor.black)
        operatorIcon.image = SBUIconSet.iconOperator.withTintColor(UIColor.black)
        
        
        //
        self.channel?.refresh()
        setupBackButton()
        emptyLbl()
        checkFrozen()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let navigationBarAppearance = UINavigationBarAppearance()
        navigationBarAppearance.configureWithOpaqueBackground()
        navigationBarAppearance.backgroundColor = .white
        navigationBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.black]
        navigationBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.black]

        self.navigationController?.navigationBar.standardAppearance = navigationBarAppearance
        self.navigationController?.navigationBar.scrollEdgeAppearance = navigationBarAppearance
        
    }
    
    func emptyLbl() {
        
        banBtn.setTitle("", for: .normal)
        mutedBtn.setTitle("", for: .normal)
        operatorBtn.setTitle("", for: .normal)
        
        
    }
    
    func checkFrozen() {
        
        if channel?.isFrozen == true {
            
            switchBtn.setOn(true, animated: false)
            
        } else {
            
            switchBtn.setOn(false, animated: false)
            
        }
        
        
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
        navigationItem.title = "Moderators"
        
        let backButtonBarButton = UIBarButtonItem(customView: backButton)

        self.navigationItem.leftBarButtonItem = backButtonBarButton


        
    }

    
    
    @objc func onClickBack(_ sender: AnyObject) {
        if let navigationController = self.navigationController {
            navigationController.popViewController(animated: true)
        }
    }
    
    
    @IBAction func operatorBtnPressed(_ sender: Any) {
        
        if let selected_channel = channel {
            
            if let OMVC = UIStoryboard(name: "Dashboard", bundle: nil).instantiateViewController(withIdentifier: "OperatorMemberVC") as? OperatorMemberVC {
                OMVC.channel = selected_channel
                self.navigationController?.pushViewController(OMVC, animated: true)
                
            }
            
        }
        
    }
    
    
    
    @IBAction func muteBtnPressed(_ sender: Any) {
        
        if let selected_channel = channel {
            
            if let MMVC = UIStoryboard(name: "Dashboard", bundle: nil).instantiateViewController(withIdentifier: "MutedMemberVC") as? MutedMemberVC {
                MMVC.channel = selected_channel
                self.navigationController?.pushViewController(MMVC, animated: true)
                
            }
            
        }
        
    }
    
    @IBAction func banBtnPressed(_ sender: Any) {
        
        if let selected_channel = channel {
            
            if let BMVC = UIStoryboard(name: "Dashboard", bundle: nil).instantiateViewController(withIdentifier: "BannedMemberVC") as? BannedMemberVC {
                BMVC.channel = selected_channel
                self.navigationController?.pushViewController(BMVC, animated: true)
                
            }
            
        }
        
        
    }
    
    @IBAction func switchBtnPressed(_ sender: Any) {
        
        if channel?.isFrozen == true {
            
            channel?.unfreeze() { error in
                if let error = error {
                    self.switchBtn.setOn(true, animated: true)
                    Utils.showAlertController(error: error, viewController: self)
                    return
                }
            }
            
        } else {
            
            
            channel?.freeze() { error in
                if let error = error {
                    self.switchBtn.setOn(false, animated: true)
                    Utils.showAlertController(error: error, viewController: self)
                    return
                }
            }
            
        }
        
    }
    

}
