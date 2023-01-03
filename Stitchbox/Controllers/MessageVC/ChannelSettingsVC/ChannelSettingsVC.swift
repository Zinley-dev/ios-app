//
//  ChannelSettingsVC.swift
//  Stitchbox
//
//  Created by Khoi Nguyen on 12/18/22.
//

import UIKit
import SendBirdUIKit
import SendBirdSDK
import Alamofire

class ChannelSettingsVC: UIViewController, UINavigationControllerDelegate  {
    
    @IBOutlet weak var notiSwitch: UISwitch!
    @IBOutlet weak var channelName: UILabel!
    @IBOutlet weak var avatarView: UIView!
    @IBOutlet weak var activeview1: UIView!
    @IBOutlet weak var activeview2: UIView!
    @IBOutlet weak var avatar1: ProfileImageView!
    @IBOutlet weak var avatar2: UIImageView!
    @IBOutlet weak var avatar3: UIImageView!
    @IBOutlet weak var viewImageView: UIView!
    @IBOutlet weak var notificationView: UIView!
    @IBOutlet weak var moderationView: UIView!
    @IBOutlet weak var membersView: UIView!
    @IBOutlet weak var searchView: UIView!
    @IBOutlet weak var leaveChannelView: UIView!
    @IBOutlet weak var memberCountLbl: UILabel!
    @IBOutlet weak var settingHeight: NSLayoutConstraint!
    @IBOutlet weak var imageBtn: UIButton!
    @IBOutlet weak var modBtn: UIButton!
    @IBOutlet weak var leaveBtn: UIButton!
    @IBOutlet weak var searchBtn: UIButton!
    @IBOutlet weak var membersBtn: UIButton!
    
    
    var channel: SBDGroupChannel?
    let backButton: UIButton = UIButton(type: .custom)
    let editButton: UIButton = UIButton(type: .custom)
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.channel?.refresh()
        setupBackButton()
        emptyLbl()
        setupDefaultLayout()
        
        NotificationCenter.default.addObserver(self, selector: #selector(ChannelSettingsVC.leaveChannel), name: (NSNotification.Name(rawValue: "leaveChannel")), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ChannelSettingsVC.changeName), name: (NSNotification.Name(rawValue: "changeName")), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ChannelSettingsVC.changeAvatar), name: (NSNotification.Name(rawValue: "changeAvatar")), object: nil)
        
 
    }
    
    
    @objc func leaveChannel() {
        
        
        self.channel?.leave(completionHandler: { (error) in
            if let error = error {
                Utils.showAlertController(error: error, viewController: self)
                print(error.localizedDescription, error.code)
                return
            }
            
            NotificationCenter.default.removeObserver(self, name: (NSNotification.Name(rawValue: "leaveChannel")), object: nil)
            self.navigationController?.popToRootViewController(animated: true)
            
        })
        
    }
    
    @objc func changeName() {
        
        
        
    }
    
    @objc func changeAvatar() {
        
      
    }
    
    
    func emptyLbl() {
        imageBtn.setTitle("", for: .normal)
        modBtn.setTitle("", for: .normal)
        leaveBtn.setTitle("", for: .normal)
        searchBtn.setTitle("", for: .normal)
        membersBtn.setTitle("", for: .normal)
    }
    
    
    func setupDefaultLayout() {
        
        if let channel = self.channel {
            
            memberCountLbl.text = channel.memberCount.description
            getChannelName(channel: channel)
            checkModeration(channel: channel)
            shouldAddEdit(channel: channel)
            checkNotification(channel: channel)
            updateActiveStatusAndAvatar(channel: channel)
            
        }
    
    }
    
    func getChannelName(channel: SBDGroupChannel) {
        
        if channel.name != "" && channel.name != "Group Channel" {
            channelName.text = channel.name
        } else {
            
            if let members = channel.members {
                let filteredMembers = members.compactMap { $0 as? SBDMember }.filter { $0.userId != SBDMain.getCurrentUser()?.userId }
                
                let names = filteredMembers.prefix(3).map { $0.nickname ?? "" }
                
                if channel.memberCount > 3 {
                    channelName.text = "\(names.joined(separator: ",")) and \(channel.memberCount - 3) users"
                } else {
                    channelName.text = names.joined(separator: ",")
                }
                
            }
            
        }
        
    }
    
    func checkModeration(channel: SBDGroupChannel) {
        
        if channel.myRole == .operator {
            moderationView.isHidden = false
            settingHeight.constant = 275
        } else {
            moderationView.isHidden = true
            settingHeight.constant = 205
        }
        
    }
    
    func shouldAddEdit(channel: SBDGroupChannel) {
        
        if channel.myRole == .operator {
            editButton.addTarget(self, action: #selector(onClickEdit(_:)), for: .touchUpInside)
            editButton.frame = CGRect(x: -1, y: 0, width: 15, height: 25)
            editButton.setTitle("Edit", for: .normal)
            editButton.setTitleColor(UIColor.white, for: .normal)
            editButton.sizeToFit()
            let editButtonBarButton = UIBarButtonItem(customView: editButton)
            
            self.navigationItem.rightBarButtonItem = editButtonBarButton
            
            
        } else {
            self.navigationItem.rightBarButtonItem = nil
        }
        
    }
    
    
    func checkNotification(channel: SBDGroupChannel) {
        
      
        if channel.myPushTriggerOption == .off {
            
            notiSwitch.setOn(false, animated: false)
            
        } else {
            
            notiSwitch.setOn(true, animated: false)
            
        }
        
    }
    
    func updateActiveStatusAndAvatar(channel: SBDGroupChannel) {
        let currentUserId = SBDMain.getCurrentUser()?.userId
        let filteredMembers = channel.members?.compactMap { $0 as? SBDMember }.filter { $0.userId != currentUserId }
        let hasActiveMember = filteredMembers?.contains(where: { $0.connectionStatus.rawValue == 1 }) ?? false

        if channel.memberCount == 2 {
            avatarView.isHidden = false
            activeview2.backgroundColor = hasActiveMember ? .green : .lightGray

            setAvatarImage(for: avatar2, withProfileUrl: filteredMembers?[0].profileUrl)
            setAvatarImage(for: avatar3, withProfileUrl: SBDMain.getCurrentUser()?.profileUrl)
        } else {
            avatarView.isHidden = true
            activeview1.backgroundColor = hasActiveMember ? .green : .lightGray

            if channel.memberCount > 2 && channel.memberCount < 5 {
                avatar1.users = filteredMembers!
                avatar1.makeCircularWithSpacing(spacing: 1)
            } else {
                avatar1.setImage(withCoverUrl: channel.coverUrl!)
            }
        }
    }

    func setAvatarImage(for imageView: UIImageView, withProfileUrl profileUrl: String?) {
        if let coverUrl = profileUrl {
            imageStorage.async.object(forKey: coverUrl) { result in
                if case .value(let image) = result {
                    DispatchQueue.main.async {
                        imageView.image = image
                    }
                } else {
                    AF.request(coverUrl).responseImage { response in
                        switch response.result {
                        case let .success(value):
                            imageView.image = value
                            try? imageStorage.setObject(value, forKey: coverUrl)
                        case let .failure(error):
                            print(error)
                        }
                    }
                }
            }
        } else {
            imageView.image = UIImage(named: "defaultuser")
        }
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
            NotificationCenter.default.removeObserver(self, name: (NSNotification.Name(rawValue: "leaveChannel")), object: nil)
            NotificationCenter.default.removeObserver(self, name: (NSNotification.Name(rawValue: "changeName")), object: nil)
            NotificationCenter.default.removeObserver(self, name: (NSNotification.Name(rawValue: "changeAvatar")), object: nil)
            navigationController.popViewController(animated: true)
        }
    }
    
    @objc func onClickEdit(_ sender: AnyObject) {
        
        let EditChannelDataModView = EditChannelDataModView()
        EditChannelDataModView.modalPresentationStyle = .custom
        EditChannelDataModView.transitioningDelegate = self
        
        global_presetingRate = Double(0.25)
        global_cornerRadius = 40
        self.present(EditChannelDataModView, animated: true, completion: nil)
        
    }
    
    
    func createLeftTitleItem(text: String) -> UIView {
        let titleLabel = UILabel()
        titleLabel.text = text
        titleLabel.font = UIFont.systemFont(ofSize: 18.0, weight: .bold)
        titleLabel.textColor = SBUTheme.componentTheme.titleColor
       
        return titleLabel
    }

    @IBAction func notiSwitchPressed(_ sender: Any) {
        
         if channel?.myPushTriggerOption == .off {
             
             channel?.setMyPushTriggerOption(.all) { error in
                 if let error = error {
                     Utils.showAlertController(error: error, viewController: self)
                     return
                 }
             }
             
         } else {
             
             channel?.setMyPushTriggerOption(.off) { error in
                 if let error = error {
                     Utils.showAlertController(error: error, viewController: self)
                     return
                 }
             }
             
             
         }
        
        
    }
    
    
    @IBAction func moderationChannelBtnPressed(_ sender: Any) {
        
        if let selected_channel = channel {
            
            if let MDVC = UIStoryboard(name: "Dashboard", bundle: nil).instantiateViewController(withIdentifier: "ModerationVC") as? ModerationVC {
                MDVC.channel = selected_channel
                self.navigationController?.pushViewController(MDVC, animated: true)
                
            }
            
        }
        
    }
    
    @IBAction func memberChannelBtnPressed(_ sender: Any) {
        
        if let selected_channel = channel {
            
            if let CCV = UIStoryboard(name: "Dashboard", bundle: nil).instantiateViewController(withIdentifier: "MemberListVC") as? MemberListVC {
                CCV.channel = selected_channel
                self.navigationController?.pushViewController(CCV, animated: true)
                
            }
            
        }
        
    }
    
    @IBAction func searchChannelBtnPressed(_ sender: Any) {
        
        
    }
    
    @IBAction func leaveChannelBtnPressed(_ sender: Any) {
        
        
        let LeaveView = LeaveView()
        LeaveView.modalPresentationStyle = .custom
        LeaveView.transitioningDelegate = self
        
        global_presetingRate = Double(0.30)
        global_cornerRadius = 45
        self.present(LeaveView, animated: true, completion: nil)
        
        
    }
}
