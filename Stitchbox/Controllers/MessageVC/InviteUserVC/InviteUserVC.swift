//
//  InviteUserVC.swift
//  Stitchbox
//
//  Created by Khoi Nguyen on 12/18/22.
//

import UIKit
import SendBirdUIKit
import SendBirdSDK
import Alamofire


class InviteUserVC: UIViewController, UISearchBarDelegate, UINavigationControllerDelegate, UITableViewDelegate, UITableViewDataSource, UICollectionViewDataSource, UICollectionViewDelegate {
    
   // var searchUserListAgo  = [UserModelFromAlgolia]()
    
    var userListQuery: SBDApplicationUserListQuery?
    
    var inSearchMode = false

    var channelUrl: String?
    var channel: SBDGroupChannel?
    
    @IBOutlet weak var selectedUserListView: UICollectionView!
    @IBOutlet weak var selectedUserListHeight: NSLayoutConstraint!
    @IBOutlet weak var tableView: UITableView!
    
    
    //
    var joinedUserIds: [String] = []
    
    //
    var searchController: UISearchController?
    var userList: [SBUUser] = []
    var searchUserList: [SBUUser] = []
    var uid_list = [String]()
    var selectedUsers: [SBUUser] = []
    //
    
    lazy var delayItem = workItem()
    
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
        titleView.text = "Add members"
        titleView.textAlignment = .center
        return titleView
    }()
    
    private lazy var _leftBarButton: UIBarButtonItem = {
        return UIBarButtonItem(
            image: SBUIconSet.iconBack.resize(targetSize: CGSize(width: 25.0, height: 25.0)),
            style: .plain,
            target: self,
            action: #selector(onClickBack)
        )
    }()
    
    private lazy var _rightBarButton: UIBarButtonItem = {
            let rightItem =  UIBarButtonItem(
                title: "Add",
                style: .plain,
                target: self,
                action: #selector(InviteUsers)
            )
        rightItem.setTitleTextAttributes([.font : SBUFontSet.button2], for: .normal)
        return rightItem
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
        self.navigationItem.leftBarButtonItem = self.leftBarButton
        self.navigationItem.rightBarButtonItem = self.rightBarButton
        self.navigationItem.titleView = self.titleView
        
        self.navigationItem.largeTitleDisplayMode = .never
        
        
        self.searchController = UISearchController(searchResultsController: nil)
        self.searchController?.searchBar.delegate = self
        self.searchController?.searchBar.placeholder = "Search"
        self.searchController?.obscuresBackgroundDuringPresentation = false
        
        self.searchController?.searchBar.searchBarStyle = .minimal
        
        self.navigationItem.searchController = self.searchController
        self.navigationItem.hidesSearchBarWhenScrolling = false
        self.searchController?.searchBar.tintColor = UIColor.white
       
        
        // tableView
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.separatorStyle = .none
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.estimatedRowHeight = 44.0
        
        
        self.tableView.register(SBUUserCell.self, forCellReuseIdentifier: SBUUserCell.sbu_className)
        
       
        self.setupScrollView()
        
        if self.selectedUsers.count == 0 {
            self.rightBarButton?.isEnabled = false
        }
        else {
            self.rightBarButton?.isEnabled = true
        }
        
        
        if self.channelUrl != nil {
            
            loadChannel(channelUrl: self.channelUrl!)
            
        }
        
       
        // Styles
        self.setupStyles()
        
       
    }
    
    
    func acceptInviation(channelUrl: String, user_id: String) {
        
        

        
    }
    
    func loadChannel(channelUrl: String?) {
        guard let channelUrl = channelUrl else { return }
        
        SBUMain.connectIfNeeded { [weak self] user, error in
            guard let self = self else { return }
            if let error = error {
                print(error.localizedDescription)
            }
         
            SBDGroupChannel.getWithUrl(channelUrl) { [weak self] channel, error in
                guard let self = self else { return }
                if let error = error {
                    print(error.localizedDescription)
                    return
                }
                
                self.channel = channel
            }
        }
    }
    
    func setupStyles() {

        self.leftBarButton?.tintColor = SBUTheme.userListTheme.leftBarButtonTintColor
        self.rightBarButton?.tintColor = self.selectedUsers.isEmpty
            ? SBUTheme.userListTheme.rightBarButtonTintColor
            : SBUTheme.userListTheme.rightBarButtonSelectedTintColor

    }
    

    func setupScrollView() {
        self.selectedUserListView.contentInset = UIEdgeInsets.init(top: 0, left: 14, bottom: 0, right: 14)
        self.selectedUserListView.delegate = self
        self.selectedUserListView.dataSource = self
        self.selectedUserListView.register(SelectedUserCollectionViewCell.nib(), forCellWithReuseIdentifier: SelectedUserCollectionViewCell.cellReuseIdentifier())
        self.selectedUserListHeight.constant = 0
        self.selectedUserListView.isHidden = true
        
        self.selectedUserListView.showsHorizontalScrollIndicator = false
        self.selectedUserListView.showsVerticalScrollIndicator = false
        
        if let layout = self.selectedUserListView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = .horizontal
            layout.itemSize = CGSize(width: 120, height: 30)
        }
    }
        
    @objc func onClickBack() {
        if let navigationController = self.navigationController,
            navigationController.viewControllers.count > 1 {
            navigationController.popViewController(animated: true)
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    
    func loadUserListNextPage(_ refresh: Bool) {
        if refresh {
            self.userListQuery = nil
        }
        
        if self.userListQuery == nil {
            self.userListQuery = SBDMain.createApplicationUserListQuery()
            self.userListQuery?.limit = 20
        }
        
        if self.userListQuery?.hasNext == false {
            return
        }
        
        self.userListQuery?.loadNextPage(completionHandler: { (users, error) in
            if error != nil {
                
                return
            }
            
            DispatchQueue.main.async { [self] in
                
                let filteredUsers = users?.filter { joinedUserIds.contains($0.userId) == false }
                guard let users = filteredUsers?.sbu_convertUserList() else { return }
                self.userList += users
                
                self.shouldDismissLoadingIndicator()
                self.tableView.reloadData()
                
            }
        })
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.selectedUsers.count
    }
     
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = (collectionView.dequeueReusableCell(withReuseIdentifier: SelectedUserCollectionViewCell.cellReuseIdentifier(), for: indexPath)) as! SelectedUserCollectionViewCell
        
        
        cell.nicknameLabel.text = selectedUsers[indexPath.row].nickname
        
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        self.selectedUsers.remove(at: indexPath.row)
        
        
        if self.selectedUsers.count == 0 {
            self.rightBarButton?.isEnabled = false
        }
        else {
            self.rightBarButton?.isEnabled = true
        }
        
        setupStyles()
        
        DispatchQueue.main.async {
            if self.selectedUsers.count == 0 {
                self.selectedUserListHeight.constant = 0
                self.selectedUserListView.isHidden = true
            }
            collectionView.reloadData()
            self.tableView.reloadData()
        }
        
    }
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if inSearchMode {
            
            return self.searchUserList.count
           
        } else {
            
            return self.userList.count
                   
        }
       
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        var user: SBUUser?
        
        if inSearchMode {
            
            user = searchUserList[indexPath.row]
            
        } else {
            
            user = userList[indexPath.row]
                   
        }
        
        
        var cell: UITableViewCell? = nil
        cell = tableView.dequeueReusableCell(withIdentifier: SBUUserCell.sbu_className)

        cell?.selectionStyle = .none

        if let defaultCell = cell as? SBUUserCell {
            defaultCell.configure(
                type: .createChannel,
                user: user!,
                isChecked: self.selectedUsers.contains(user!)
            )
        }
        
        return cell ?? UITableViewCell()
        
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        
        var user: SBUUser?
        
        if inSearchMode {
            
            user = searchUserList[indexPath.row]
            searchController?.searchBar.text = ""
            
        } else {
            
            user = userList[indexPath.row]
            
        }
        
        if inSearchMode {
            
            if let user = self.searchUserList[exists: indexPath.row] {
                if self.selectedUsers.contains(user) {
                    self.selectedUsers.removeObject(user)
                } else {
                    if !self.userList.contains(user) {
                        self.userList.insert(user, at: 0)
                    }
                    self.selectedUsers.append(user)
                }
            }
            
        } else {
            
            if let user = self.userList[exists: indexPath.row] {
                if self.selectedUsers.contains(user) {
                    self.selectedUsers.removeObject(user)
                } else {
                    self.selectedUsers.append(user)
                }
            }
            
        }
        
        
        
       
        if self.selectedUsers.count == 0 {
            self.rightBarButton?.isEnabled = false
        }
        else {
            self.rightBarButton?.isEnabled = true
        }
        
        DispatchQueue.main.async {
            if self.selectedUsers.count > 0 {
                self.selectedUserListHeight.constant = 40
                self.selectedUserListView.isHidden = false
            }
            else {
                self.selectedUserListHeight.constant = 0
                self.selectedUserListView.isHidden = true
            }
            
            if let defaultCell = self.tableView.cellForRow(at: indexPath) as? SBUUserCell {
                defaultCell.selectUser(self.selectedUsers.contains(user!))
            }
            
            self.setupStyles()
            
            self.selectedUserListView.reloadData()
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
           
            let filteredUsers = userList.filter { ($0.nickname?.contains(searchText))!}
            
            if filteredUsers.count != 0 {
                
                searchUserList = filteredUsers
                self.tableView.reloadData()
                
            } else {
                
                if searchText != "" {
                    
                    self.searchUsers(searchText: searchText)
                    
                }
    
            }
        }
    }

    
    func searchUsers(searchText: String) {
        
    }

    
   @objc func InviteUsers() {
       
       
       if let userUID = _AppCoreData.userDataSource.value?.userID, userUID != "" {
           
           if selectedUsers.count != 0 {
               
               
               if joinedUserIds.count == 2 {
                   
                   let channelParams = SBDGroupChannelParams()
                   channelParams.isDistinct = true
                   for item in selectedUsers {
                       channelParams.addUserId(item.userId)
                   }
                   
                   var user_list = [String]()
                   
                   for item in joinedUserIds {
                       
                       channelParams.addUserId(item)
                             
                   }
                   
                   for userId in channelParams.userIds()! {
                       
                       if userId != userUID, !user_list.contains(userId) {
                           
                           user_list.append(userId)
                           
                       }
                       
                   }
                   
                   
                   channelParams.operatorUserIds = [userUID]
                   
                   
                   self.shouldDismissLoadingIndicator()
                   
                   
                   SBDGroupChannel.createChannel(with: channelParams) { groupChannel, error in
                       guard error == nil else {
                           // Handle error.
                           self.showErrorAlert("Oops!", msg: error!.localizedDescription)
                           return
                       }
                       
                       if let url = groupChannel?.channelUrl {
                           
                           self.hideForSelectedUser(channelUrl: url, user_list: user_list, channel: groupChannel!)
                           
                       }

                       
                       // A group channel of the specified users is successfully created.
                       // Through the "groupChannel" parameter of the callback method,
                       // you can get the group channel's data from the result object that Sendbird server has passed to the callback method.
                       let channelUrl = groupChannel?.channelUrl
                       
                       //selected_channelUrl = channelUrl
                       
                       let channelVC = ChannelViewController(
                           channelUrl: channelUrl!,
                           messageListParams: nil
                       )
                       
                   
                       self.navigationController?.pushViewController(channelVC, animated: true)
                       self.navigationController?.viewControllers.removeSubrange(1...4)
                       
                       //NotificationCenter.default.post(name: (NSNotification.Name(rawValue: "showChannelVC")), object: nil)
                      
                   }
                   
                   
               } else {
                   
                   let userIds = Array(self.selectedUsers).sbu_getUserIds()
                   self.inviteUsers(userIds: userIds)
                   
                   var user_list = [String]()
                   
                   for user in selectedUsers {
                       
                       
                       if !user_list.contains(user.userId) {
                           
                           user_list.append(user.userId)
                           
                           
                       }
                       
                   }
                   
                   if let url = self.channel?.channelUrl {
                       
                       hideForSelectedUser(channelUrl: url, user_list: user_list, channel: self.channel!)
                       
                   } else {
                       print("Can't get channelurl")
                   }
                   
                  
                   
               }
                       
           }
           
           
       }
    
        
    
    }
    
    
    func hideForSelectedUser(channelUrl: String, user_list: [String], channel: SBDGroupChannel) {
        
        
        
    }
    
    func hideChannel2(channelUrl: String, user_id: String) {
           
        
    }
    
    func showErrorAlert(_ title: String, msg: String) {
                                                                                                                                           
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        
                                                                                       
        present(alert, animated: true, completion: nil)
        
    }
    
    
    func inviteUsers(userIds: [String]) {
        
        self.channel?.inviteUserIds(userIds, completionHandler: { [weak self] error in
            guard let self = self else { return }
            
           // self.shouldDismissLoadingIndicator()
            
            if let error = error {
                print(error.localizedDescription)
            }
            
            
            self.navigationController?.popBack(4)
            
        })

    }
    
    
    func shouldShowLoadingIndicator(){
        SBULoading.start()
        
    }
    
    func shouldDismissLoadingIndicator() {
        SBULoading.stop()
    }

  

}

