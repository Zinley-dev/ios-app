//
//  OperatorMemberVC.swift
//  Stitchbox
//
//  Created by Khoi Nguyen on 1/3/23.
//

import UIKit
import SendBirdUIKit
import SendBirdSDK

class OperatorMemberVC: UIViewController, UINavigationControllerDelegate, UITableViewDelegate, UITableViewDataSource {

    
    var channel: SBDGroupChannel?
    let backButton: UIButton = UIButton(type: .custom)
    
    
    @IBOutlet weak var tableView: UITableView!
    
    var joinedUserIds: [String] = []
    var userList: [SBUUser] = []
    

    let addButton: UIButton = UIButton(type: .custom)
   
    var selectedIndexpath = 0
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        channel?.refresh()
        setupBackButton()
        setupAddButton()
        setupTableView()
        getUsers()
        
        NotificationCenter.default.addObserver(self, selector: #selector(OperatorMemberVC.dismissUser), name: (NSNotification.Name(rawValue: "Operate-dismissUser")), object: nil)
        
    
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let navigationBarAppearance = UINavigationBarAppearance()
        navigationBarAppearance.configureWithOpaqueBackground()
        navigationBarAppearance.backgroundColor = .background
        navigationBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        navigationBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]

        self.navigationController?.navigationBar.standardAppearance = navigationBarAppearance
        self.navigationController?.navigationBar.scrollEdgeAppearance = navigationBarAppearance
        
    }
    
    func getUsers() {
        guard let members = channel?.members else { return }
        let filteredMembers = members.compactMap { $0 as? SBDMember }
        
        for member in filteredMembers {
            let addedUser = SBUUser(userId: member.userId, nickname: member.nickname, profileUrl: member.profileUrl)
            
            if self.channel?.getMember(addedUser.userId)?.role == .operator {
                
                if member.userId == SBDMain.getCurrentUser()?.userId {
                    userList.insert(addedUser, at: 0)
                        
                } else {
                    userList.append(addedUser)
                }
                
                
                
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
        navigationItem.title = "Operators"
      
        let backButtonBarButton = UIBarButtonItem(customView: backButton)

        self.navigationItem.leftBarButtonItem = backButtonBarButton


        
    }

    
    func setupAddButton() {
        
        addButton.setImage(UIImage.init(named: "4x_add"), for: [])
        addButton.addTarget(self, action: #selector(onPromoteUsers(_:)), for: .touchUpInside)
        addButton.frame = CGRect(x: -1, y: 0, width: 30, height: 30)
       
        let addButtonBarButton = UIBarButtonItem(customView: addButton)
    
        self.navigationItem.rightBarButtonItem = addButtonBarButton
        
        
    }
    
    
    @objc func onPromoteUsers(_ sender: AnyObject) {
        if let selected_channel = channel {
            if let AOMVC = UIStoryboard(name: "Dashboard", bundle: nil).instantiateViewController(withIdentifier: "AddOperatorMemberVC") as? AddOperatorMemberVC {
                AOMVC.channel = selected_channel
                self.navigationController?.pushViewController(AOMVC, animated: true)
                
            }
        }
    }
    
    
    @objc func onClickBack(_ sender: AnyObject) {
        if let navigationController = self.navigationController {
            NotificationCenter.default.removeObserver(self, name: (NSNotification.Name(rawValue: "Operate-dismissUser")), object: nil)
            navigationController.popViewController(animated: true)
        }
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if userList.isEmpty {
            tableView.setEmptyMessage("No operator")
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
        cell.theme = .dark
        cell.contentView.backgroundColor = self.view.backgroundColor
        cell.selectionStyle = .none
        cell.moreButton.addTarget(self, action: #selector(actionButtonPressed(sender:)), for: .touchUpInside)
        cell.moreButton.tag = indexPath.row
        cell.moreButton.setImage(user.userId == SBDMain.getCurrentUser()?.userId ? UIImage(named: "noMore") : UIImage(named: "more"), for: .normal)
        cell.theme.separateColor = .clear


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
            nav.navigationBar.barTintColor = .background
            nav.navigationBar.tintColor = .white
            nav.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]

            nav.modalPresentationStyle = .fullScreen
            self.present(nav, animated: true, completion: nil)
        }
        
    }

    
    @objc func actionButtonPressed(sender: UIButton) {
       
        selectedIndexpath = sender.tag
       
        let DismissOperatorModView = DismissOperatorModView()
        DismissOperatorModView.modalPresentationStyle = .custom
        DismissOperatorModView.transitioningDelegate = self
    
        //setting frame
        global_presetingRate = Double(0.15)
        global_cornerRadius = 30
        
        self.present(DismissOperatorModView, animated: true, completion: nil)
 
    }
    
    
    @objc func dismissUser() {
        
        channel?.removeOperators(withUserIds: [userList[selectedIndexpath].userId]) { error in
            guard error == nil else {
                // Handle error.
               
                self.presentErrorAlert(message: "Error code: \(error!.code), \(error!.localizedDescription)")
                return
            }
            // The members are successfully registered as operators of the channel.
            self.userList.remove(at: self.selectedIndexpath)
            self.tableView.reloadData()
           
        }
        
    }
    

  

}
