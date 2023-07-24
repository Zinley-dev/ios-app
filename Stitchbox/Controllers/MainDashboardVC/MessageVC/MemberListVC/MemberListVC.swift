//
//  MemberListVC.swift
//  Stitchbox
//
//  Created by Khoi Nguyen on 12/18/22.
//

import UIKit
import SendBirdUIKit
import SendBirdSDK

class MemberListVC: UIViewController, UINavigationControllerDelegate, UITableViewDelegate, UITableViewDataSource {
    
    
    @IBOutlet weak var tableView: UITableView!
    
    var joinedUserIds: [String] = []
    var userList: [SBUUser] = []
    var channel: SBDGroupChannel?

    let backButton: UIButton = UIButton(type: .custom)
    let addButton: UIButton = UIButton(type: .custom)
   
    var selectedIndexpath = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        
        channel?.refresh()
        setupBackButton()
        setupAddButton()
        setupTableView()
        getUsers()
        
        if self.channel?.myRole == .operator {
            
            
            NotificationCenter.default.addObserver(self, selector: #selector(MemberListVC.promoteUser), name: (NSNotification.Name(rawValue: "promoteUser")), object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(MemberListVC.dismissUser), name: (NSNotification.Name(rawValue: "dismissUser")), object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(MemberListVC.muteUser), name: (NSNotification.Name(rawValue: "muteUser")), object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(MemberListVC.banUser), name: (NSNotification.Name(rawValue: "banUser")), object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(MemberListVC.unMuteUser), name: (NSNotification.Name(rawValue: "unMuteUser")), object: nil)
            
        }
      
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
    
    func getUsers() {
        guard let members = channel?.members else { return }
        let filteredMembers = members.compactMap { $0 as? SBDMember }
        
        for member in filteredMembers {
            let addedUser = SBUUser(userId: member.userId, nickname: member.nickname, profileUrl: member.profileUrl)
            if member.userId == SBDMain.getCurrentUser()?.userId {
                userList.insert(addedUser, at: 0)
                    
            } else {
                userList.append(addedUser)
            }
        }

        tableView.reloadData()
    }


    
    func setupTableView() {
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.separatorStyle = .none
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.estimatedRowHeight = 44.0
        self.tableView.register(SBUUserCell.self, forCellReuseIdentifier: SBUUserCell.sbu_className)
        
        
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
        navigationItem.title = "Members"
      
        let backButtonBarButton = UIBarButtonItem(customView: backButton)

        self.navigationItem.leftBarButtonItem = backButtonBarButton
       
    }
    
    func setupAddButton() {
        
        addButton.setImage(UIImage.init(named: "4x_add"), for: [])
        addButton.addTarget(self, action: #selector(onInviteUser(_:)), for: .touchUpInside)
        addButton.frame = CGRect(x: -1, y: 0, width: 30, height: 30)
       
        let addButtonBarButton = UIBarButtonItem(customView: addButton)
    
        self.navigationItem.rightBarButtonItem = addButtonBarButton
        
        
    }
    
    
    @objc func onClickBack(_ sender: AnyObject) {
        if let navigationController = self.navigationController {
            
            if self.channel?.myRole == .operator {
                
                NotificationCenter.default.removeObserver(self, name: (NSNotification.Name(rawValue: "promoteUser")), object: nil)
                NotificationCenter.default.removeObserver(self, name: (NSNotification.Name(rawValue: "dismissUser")), object: nil)
                NotificationCenter.default.removeObserver(self, name: (NSNotification.Name(rawValue: "muteUser")), object: nil)
                NotificationCenter.default.removeObserver(self, name: (NSNotification.Name(rawValue: "banUser")), object: nil)
                NotificationCenter.default.removeObserver(self, name: (NSNotification.Name(rawValue: "unMuteUser")), object: nil)
              
            }
            
            
            navigationController.popViewController(animated: true)
        }
    }
    
    
    @objc func onInviteUser(_ sender: AnyObject) {
        guard let inviteUserVC = UIStoryboard(name: "Dashboard", bundle: nil).instantiateViewController(withIdentifier: "InviteUserVC") as? InviteUserVC else { return }
        guard let members = channel?.members else { return }
        // Add the user IDs of the members in the memberList array to the joinedUserIds array
        let filteredMembers = members.compactMap { $0 as? SBDMember }
        
        let joinedUserIds = filteredMembers.sbu_convertUserList().sbu_getUserIds()

        // Set the channelUrl and joinedUserIds properties of the invite user view controller
        inviteUserVC.channelUrl = self.channel?.channelUrl
        inviteUserVC.joinedUserIds = joinedUserIds
        inviteUserVC.channel = self.channel

        // Push the invite user view controller onto the navigation stack
        navigationController?.pushViewController(inviteUserVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if userList.isEmpty {
            tableView.setEmptyMessage("No member")
        } else {
            tableView.restore()
        }
        
        return userList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let user = userList[indexPath.row]

        guard let cell = tableView.dequeueReusableCell(withIdentifier: SBUUserCell.sbu_className, for: indexPath) as? SBUUserCell else {
            return UITableViewCell()
        }

        cell.configure(type: .channelMembers, user: user, operatorMode: self.channel?.myRole == .operator)
        cell.theme = .light
        cell.contentView.backgroundColor = self.view.backgroundColor
        cell.selectionStyle = .none
        cell.moreButton.addTarget(self, action: #selector(actionButtonPressed(sender:)), for: .touchUpInside)
        cell.moreButton.tag = indexPath.row
        cell.moreButton.setImage(user.userId == SBDMain.getCurrentUser()?.userId ? UIImage(named: "noMore") : UIImage(named: "more"), for: .normal)
        cell.theme.separateColor = .clear
    
        
        switch (self.channel?.getMember(user.userId)?.role, self.channel?.getMember(user.userId)?.isMuted) {
            case (.operator, false):
                cell.operatorLabel.text = "Operator"
            case (.operator, true):
                cell.operatorLabel.text = "Muted - Operator"
            case (_, true):
                cell.operatorLabel.text = "Muted"
            default:
                cell.operatorLabel.text = ""
        }
        
        cell.operatorLabel.isHidden = false

        return cell
    }

    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let user = userList[indexPath.row]
        
        if user.userId != _AppCoreData.userDataSource.value?.userID {
            presentUsers(userId: user.userId, username: user.nickname ?? "")
        }
        
        
    }
    
    
    func presentUsers(userId: String, username: String) {
        
        if let UPVC = UIStoryboard(name: "Dashboard", bundle: nil).instantiateViewController(withIdentifier: "UserProfileVC") as? UserProfileVC {
            
            let nav = UINavigationController(rootViewController: UPVC)

            // Set the user ID, nickname, and onPresent properties of UPVC
            UPVC.userId = userId
            UPVC.nickname = username
            UPVC.onPresent = true

            // Customize the navigation bar appearance
            nav.navigationBar.barTintColor = .white
            nav.navigationBar.tintColor = .black
            nav.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.black]

            nav.modalPresentationStyle = .fullScreen
            self.present(nav, animated: true, completion: nil)
        }
        
    }
    
    @objc func actionButtonPressed(sender: UIButton) {
        selectedIndexpath = sender.tag
        let user = userList[selectedIndexpath]

        let ModActionView = ModActionView()
        ModActionView.modalPresentationStyle = .custom
        ModActionView.transitioningDelegate = self
        ModActionView.isOperator = channel!.getMember(user.userId)?.role == .operator
        ModActionView.isMute = channel!.getMember(user.userId)?.isMuted

        //setting frame
        global_presetingRate = Double(0.25)
        global_cornerRadius = 40
        
        self.present(ModActionView, animated: true, completion: nil)
    }
    
    // objc

    @objc func promoteUser() {
        channel?.addOperators(withUserIds: [userList[selectedIndexpath].userId]) { error in
            guard error == nil else {
                // Handle error.
               
                self.presentErrorAlert(message: "Error code: \(error!.code), \(error!.localizedDescription)")
                return
            }
            // The members are successfully registered as operators of the channel.
            self.tableView.reloadRows(at: [IndexPath(row: self.selectedIndexpath, section: 0)], with: .automatic)
           
        }
        
    }

    
    @objc func dismissUser() {
        channel?.removeOperators(withUserIds: [userList[selectedIndexpath].userId]) { error in
            guard error == nil else {
                // Handle error.
                self.presentErrorAlert(message: "Error code: \(error!.code), \(error!.localizedDescription)")
                return
            }

            // The specified operators are removed.
            // You can notify the users of the role change through a prompt.
            self.tableView.reloadRows(at: [IndexPath(row: self.selectedIndexpath, section: 0)], with: .automatic)
        }
        
    }
    
    @objc func muteUser() {
        
        channel?.muteUser(withUserId: userList[selectedIndexpath].userId) { error in
            guard error == nil else {
                // Handle error.
                self.presentErrorAlert(message: "Error code: \(error!.code), \(error!.localizedDescription)")
                return
            }

            // The specified operators are removed.
            // You can notify the users of the role change through a prompt.
            self.tableView.reloadRows(at: [IndexPath(row: self.selectedIndexpath, section: 0)], with: .automatic)
        }
        
    }
    
    @objc func unMuteUser() {
        
        channel?.unmuteUser(withUserId: userList[selectedIndexpath].userId) { error in
            guard error == nil else {
                // Handle error.
                self.presentErrorAlert(message: "Error code: \(error!.code), \(error!.localizedDescription)")
                return
            }

            // The specified operators are removed.
            // You can notify the users of the role change through a prompt.
            self.tableView.reloadRows(at: [IndexPath(row: self.selectedIndexpath, section: 0)], with: .automatic)
        }
        
    }
    
    @objc func banUser() {
        
        channel?.banUser(withUserId: userList[selectedIndexpath].userId, seconds: 259200, description: "None")  { error in
            guard error == nil else {
                // Handle error.
                self.presentErrorAlert(message: "Error code: \(error!.code), \(error!.localizedDescription)")
                return
            }

            // The specified operators are removed.
            // You can notify the users of the role change through a prompt.
            self.userList.remove(at: self.selectedIndexpath)
            self.tableView.reloadData()
        }
        
        
    }
}

