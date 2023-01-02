//
//  MemberListVC.swift
//  Stitchbox
//
//  Created by Khoi Nguyen on 12/18/22.
//

import UIKit
import SendBirdUIKit

class MemberListVC: UIViewController, UISearchBarDelegate, UINavigationControllerDelegate, UITableViewDelegate, UITableViewDataSource {
    
    
    @IBOutlet weak var tableView: UITableView!
    
    var joinedUserIds: [String] = []
    var userList: [SBUUser] = []
    var channel: SBDGroupChannel?

    let backButton: UIButton = UIButton(type: .custom)
    let addButton: UIButton = UIButton(type: .custom)
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        
        channel?.refresh()
        setupBackButton()
        setupAddButton()
        setupTableView()
        getUsers()
      
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
        
        // Do any additional setup after loading the view.
        backButton.setImage(UIImage.init(named: "back_icn_white")?.resize(targetSize: CGSize(width: 13, height: 23)), for: [])
        backButton.addTarget(self, action: #selector(onClickBack(_:)), for: .touchUpInside)
        backButton.frame = CGRect(x: -10, y: 0, width: 15, height: 25)
        backButton.setTitleColor(UIColor.white, for: .normal)
        backButton.setTitle("     Members", for: .normal)
        backButton.sizeToFit()
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

        // Push the invite user view controller onto the navigation stack
        navigationController?.pushViewController(inviteUserVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
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
        cell.moreButton.addTarget(self, action: #selector(whichButtonPressed(sender:)), for: .touchUpInside)
        cell.moreButton.tag = indexPath.row
        cell.moreButton.setImage(user.userId == SBDMain.getCurrentUser()?.userId ? UIImage(named: "noMore") : UIImage(named: "more"), for: .normal)
        cell.theme.separateColor = .clear

        if self.channel?.getMember(user.userId)?.role == .operator {
            cell.operatorLabel.text = "Operator"
        } else {
            cell.operatorLabel.text = ""
        }

        cell.operatorLabel.isHidden = false

        return cell
    }

    
    @objc func whichButtonPressed(sender: UIButton) {
        print(sender.tag)

    }
    

}

