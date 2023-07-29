//
//  AddOperatorMemberVC.swift
//  Stitchbox
//
//  Created by Khoi Nguyen on 1/3/23.
//

import UIKit
import SendBirdSDK
import SendBirdUIKit

class AddOperatorMemberVC: UIViewController, UISearchBarDelegate, UINavigationControllerDelegate, UITableViewDelegate, UITableViewDataSource, UICollectionViewDataSource, UICollectionViewDelegate {
    
    deinit {
        print("AddOperatorMemberVC is being deallocated.")
    }
    
    var channel: SBDGroupChannel?
    var joinedUserIds: [String] = []
    var inSearchMode = false

    var channelUrl: String?
 
    // to override search task
    lazy var delayItem = workItem()
    
    @IBOutlet weak var selectedUserListView: UICollectionView!
    @IBOutlet weak var selectedUserListHeight: NSLayoutConstraint!
    @IBOutlet weak var tableView: UITableView!
    
    //
    var searchController: UISearchController?
    var userList: [SBUUser] = []
    var searchUserList: [SBUUser] = []
    var uid_list = [String]()
    var selectedUsers: [SBUUser] = []
    //

    var createButtonItem: UIBarButtonItem?
    var cancelButtonItem: UIBarButtonItem?
    
    private lazy var titleView: UIView? = _titleView
    private lazy var leftBarButton: UIBarButtonItem? = _leftBarButton
    private lazy var rightBarButton: UIBarButtonItem? = _rightBarButton
   
    private lazy var _titleView: SBUNavigationTitleView = {
        var titleView: SBUNavigationTitleView
        if #available(iOS 11, *) {
            titleView = SBUNavigationTitleView()
        } else {
            titleView = SBUNavigationTitleView(
                frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 50)
            )
        }
        titleView.text = ""
        titleView.textAlignment = .center
        return titleView
    }()
    
    
    private lazy var _leftBarButton: UIBarButtonItem = {
        
        let backButton = UIButton(type: .custom)
        
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
        
        backButton.addTarget(self, action: #selector(onClickBack), for: .touchUpInside)
        let backButtonBarButton = UIBarButtonItem(customView: backButton)
        
        self.navigationItem.leftBarButtonItem = backButtonBarButton
        
        return backButtonBarButton
    }()
    
    private lazy var _rightBarButton: UIBarButtonItem = {
            let rightItem =  UIBarButtonItem(
                title: "Promote",
                style: .plain,
                target: self,
                action: #selector(PromoteUsers)
            )
        rightItem.setTitleTextAttributes([
            .font : SBUFontSet.button2,
            .foregroundColor: UIColor.black
        ], for: .normal)
        return rightItem
    }()
    
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        channel?.refresh()
        // Do any additional setup after loading the view.
        self.navigationItem.leftBarButtonItem = self.leftBarButton
        self.navigationItem.rightBarButtonItem = self.rightBarButton
        self.navigationItem.titleView = self.titleView
        self.navigationItem.largeTitleDisplayMode = .never

        self.searchController = UISearchController(searchResultsController: nil)
        self.searchController?.obscuresBackgroundDuringPresentation = false
        self.searchController?.searchBar.delegate = self
        self.searchController?.searchBar.searchBarStyle = .minimal
        self.navigationItem.searchController = self.searchController
        self.navigationItem.hidesSearchBarWhenScrolling = false
        self.searchController?.searchBar.tintColor = .white
        self.searchController?.searchBar.searchTextField.textColor = .white
        self.searchController!.searchBar.searchTextField.attributedPlaceholder = NSAttributedString(string: "Search", attributes: [.foregroundColor: UIColor.lightGray])
        self.searchController!.searchBar.searchTextField.leftView?.tintColor = .lightGray

        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.separatorStyle = .none
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.estimatedRowHeight = 44.0
        self.tableView.register(SBUUserCell.self, forCellReuseIdentifier: SBUUserCell.sbu_className)

        self.setupScrollView()
        self.rightBarButton?.isEnabled = self.selectedUsers.count > 0
        
        
        self.setupStyles()
        self.getUsers()
        
        
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
            
            if self.channel?.getMember(addedUser.userId)?.role != .operator {
                
                if member.userId == SBDMain.getCurrentUser()?.userId {
                    userList.insert(addedUser, at: 0)
                        
                } else {
                    userList.append(addedUser)
                }
                
                
                
            }
                
        }

        tableView.reloadData()
    }
    
    func setupStyles() {

        self.leftBarButton?.tintColor = UIColor.white
        self.rightBarButton?.tintColor = UIColor.white

    }
    

    func setupScrollView() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 120, height: 30)
        self.selectedUserListView.collectionViewLayout = layout
        self.selectedUserListView.contentInset = UIEdgeInsets(top: 0, left: 14, bottom: 0, right: 14)
        self.selectedUserListView.register(SelectedUserCollectionViewCell.nib(), forCellWithReuseIdentifier: SelectedUserCollectionViewCell.cellReuseIdentifier())
        self.selectedUserListView.isHidden = true
        self.selectedUserListView.showsHorizontalScrollIndicator = false
        self.selectedUserListView.showsVerticalScrollIndicator = false
        self.selectedUserListView.delegate = self
        self.selectedUserListView.dataSource = self
        self.selectedUserListHeight.constant = 0
    }

        
    @objc func onClickBack() {
        if let viewControllers = self.navigationController?.viewControllers, viewControllers.count > 1 {
            self.navigationController?.popViewController(animated: true)
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.selectedUsers.count
    }
     
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SelectedUserCollectionViewCell.cellReuseIdentifier(), for: indexPath) as! SelectedUserCollectionViewCell
        cell.nicknameLabel.text = selectedUsers[indexPath.row].nickname
        cell.nicknameLabel.font = FontManager.shared.roboto(.Regular, size: 12)
        cell.nicknameLabel.backgroundColor = .clear
        cell.backgroundColor = hashtagPurple
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.selectedUsers.remove(at: indexPath.row)
        self.rightBarButton?.isEnabled = !self.selectedUsers.isEmpty
        self.setupStyles()
        if self.selectedUsers.isEmpty {
            self.selectedUserListHeight.constant = 0
            self.selectedUserListView.isHidden = true
        }
        collectionView.reloadData()
        self.tableView.reloadData()
    }

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return inSearchMode ? searchUserList.count : userList.count
    }

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SBUUserCell.sbu_className) as! SBUUserCell
        cell.selectionStyle = .none
        let user = inSearchMode ? searchUserList[indexPath.row] : userList[indexPath.row]
        cell.configure(type: .createChannel, user: user, isChecked: selectedUsers.contains(user))
        cell.theme.backgroundColor = UIColor.clear
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let user = inSearchMode ? searchUserList[indexPath.row] : userList[indexPath.row]
        if let cell = tableView.cellForRow(at: indexPath) as? SBUUserCell {
            if selectedUsers.contains(user) {
                selectedUsers.removeObject(user)
                cell.selectUser(false)
                if searchUserList.contains(user) {
                    searchUserList.removeObject(user)
                }
                rightBarButton?.isEnabled = false
                selectedUserListHeight.constant = 0
                selectedUserListView.isHidden = true
            } else {
                selectedUsers.append(user)
                cell.selectUser(true)
                rightBarButton?.isEnabled = true
                selectedUserListHeight.constant = 40
                selectedUserListView.isHidden = false
            }
            setupStyles()
            selectedUserListView.reloadData()
        }
    }

    
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchUserList.removeAll()
        inSearchMode = false
        self.tableView.reloadData()
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchUserList = userList
        inSearchMode = true
        self.tableView.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.count > 0 {
            let filteredUsers = userList.filter {
                guard let nickname = $0.nickname else { return false }
                return nickname.range(of: searchText, options: .caseInsensitive) != nil
            }
            searchUserList = filteredUsers.isEmpty ? [] : filteredUsers
            tableView.reloadData()
            
        }
    }


    func showErrorAlert(_ title: String, msg: String) {
                                                                                                                                           
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        
                                                                                       
        present(alert, animated: true, completion: nil)
        
    }

    
    @objc func PromoteUsers() {
       // Check if the userUID property is not an empty string
        if let userUID = _AppCoreData.userDataSource.value?.userID, userUID != "", !self.selectedUsers.isEmpty {
           // Check if there are any selected users
          
            
            channel?.addOperators(withUserIds: self.selectedUsers.sbu_getUserIds()) { error in
                if let error = error {
                    Utils.showAlertController(error: error, viewController: self)
                    return
                }
                
                let channelUrl = self.channel?.channelUrl
                // Create an instance of ChannelViewController
                let channelVC = ChannelViewController(channelUrl: channelUrl!, messageListParams: nil)
                // Push ChannelViewController onto the navigation stack
                self.navigationController?.pushViewController(channelVC, animated: true)
                // Remove view controllers in the stack after it
                self.navigationController?.viewControllers.removeSubrange(1...5)
                
            }   
           
       }
    }
   
    
}
