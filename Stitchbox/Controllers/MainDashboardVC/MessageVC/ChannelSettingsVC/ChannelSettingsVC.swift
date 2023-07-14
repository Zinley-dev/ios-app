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
import PixelSDK
import Photos

class ChannelSettingsVC: UIViewController, UINavigationControllerDelegate  {
    
    deinit {
        print("ChannelSettingsVC is being deallocated.")
    }
    
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
    let container = ContainerController(modes: [.library, .photo])

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
        container.editControllerDelegate = self
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let navigationBarAppearance = UINavigationBarAppearance()
        navigationBarAppearance.configureWithOpaqueBackground()
        navigationBarAppearance.backgroundColor = .background
        navigationBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        navigationBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]

        self.navigationController?.navigationBar.standardAppearance = navigationBarAppearance
        self.navigationController?.navigationBar.scrollEdgeAppearance = navigationBarAppearance
        
        navigationItem.title = "Settings"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.changeTabBar(hidden: true)
        self.tabBarController?.tabBar.isTranslucent = true
    }


    func changeTabBar(hidden: Bool) {
        guard let tabBar = self.tabBarController?.tabBar else {
            return
        }

        tabBar.isHidden = hidden
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
        
        delay(0.25) { [self] in
            getNewName()
        }
        
    }
    
    func getNewName() {
        
        showInputDialog(subtitle: "You can add your new group name here",
                        actionTitle: "Change",
                        cancelTitle: "Cancel",
                        inputPlaceholder: "Group name (Max 15 characters)",
                        inputKeyboardType: .default, actionHandler:
                                { (input:String?) in
                                    
                                    
                if let newName = input {
                    
                    let param = SBDGroupChannelParams()
                    param.name = newName
                    
                    self.channel?.update(with: param, completionHandler: { updatedChannel, error in
                        if let error = error {
                            Utils.showAlertController(error: error, viewController: self)
                            print(error.localizedDescription, error.code)
                            return
                        }
                        
                        self.channel?.refresh()
                        self.getChannelName(channel: updatedChannel!)
                        
                    })
                }
                                        
        })
    }
    
    @objc func changeAvatar() {
        
        delay(0.25) { [self] in
            changeAvatarRequest()
        }
      
    }
    
    func changeAvatarRequest() {
        
        
        // Include only Image from the users photo library
        container.libraryController.fetchPredicate = NSPredicate(format: "mediaType == %d", PHAssetMediaType.image.rawValue)
        // Include only Image from the users drafts
        container.libraryController.draftMediaTypes = [.image]
        
        
        let nav = UINavigationController(rootViewController: container)
        nav.modalPresentationStyle = .fullScreen
        
        self.present(nav, animated: true, completion: nil)
        
        
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
        
            if channel.coverUrl != nil, !(channel.coverUrl?.contains("sendbird"))!{
                
                avatarView.isHidden = true
                activeview1.backgroundColor = hasActiveMember ? .green : .lightGray
                
                avatar1.setImage(withCoverUrl: channel.coverUrl!)
                
            } else {
                
                avatarView.isHidden = false
                activeview2.backgroundColor = hasActiveMember ? .green : .lightGray

                setAvatarImage(for: avatar2, withProfileUrl: filteredMembers?[0].profileUrl)
                setAvatarImage(for: avatar3, withProfileUrl: SBDMain.getCurrentUser()?.profileUrl)
                
            }
            
        } else {
            avatarView.isHidden = true
            activeview1.backgroundColor = hasActiveMember ? .green : .lightGray
            
            if channel.coverUrl != nil, !(channel.coverUrl?.contains("sendbird"))! {
                
                avatar1.setImage(withCoverUrl: channel.coverUrl!)
                
            } else {
                
                if channel.memberCount > 2 && channel.memberCount < 5 {
                    avatar1.users = filteredMembers!
                    avatar1.makeCircularWithSpacing(spacing: 1)
                } else {
                    avatar1.setImage(withCoverUrl: channel.coverUrl!)
                }
                
            }

            
        }
    }

    func setAvatarImage(for imageView: UIImageView, withProfileUrl profileUrl: String?) {
        
        if profileUrl != "" {
            
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
            
        } else {
            
            imageView.image = UIImage(named: "defaultuser")
            
        }
        
    }

    
    func setupBackButton() {
    
        backButton.frame = back_frame
        backButton.contentMode = .center

        if let backImage = UIImage(named: "back_icn_white") {
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

extension ChannelSettingsVC: EditControllerDelegate {
    
    func editController(_ editController: EditController, didLoadEditing session: PixelSDKSession) {
        // Called after the EditController's view did load.
        
        print("Did load here")
    }
    
    func editController(_ editController: EditController, didFinishEditing session: PixelSDKSession) {
        // Called when the Next button in the EditController is pressed.
        // Use this time to either dismiss the UINavigationController, or push a new controller on.
        
        if let image = session.image {
            
            
            ImageExporter.shared.export(image: image, completion: { (error, uiImage) in
                    if let error = error {
                        self.showErrorAlert("Oops!", msg: "Unable to export image: \(error)")
                        return
                    }
                
                if !self.avatarView.isHidden {
                    self.avatarView.isHidden = true
                }

                self.avatar1.setImage(withImage: uiImage!)
                processUpdateAvatar(channel: self.channel!, image: uiImage!)
                
            })
            
            
        }
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
    
    
    func editController(_ editController: EditController, didCancelEditing session: PixelSDKSession?) {
        // Called when the back button in the EditController is pressed.
        
        print("Did cancel load here")
        
    }
    
    func showErrorAlert(_ title: String, msg: String) {
                                                                                
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        
        present(alert, animated: true, completion: nil)
        
    }
    
}
