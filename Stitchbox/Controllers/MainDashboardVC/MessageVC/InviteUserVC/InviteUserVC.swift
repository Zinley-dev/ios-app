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
import ObjectMapper

class InviteUserVC: UIViewController, UISearchBarDelegate, UINavigationControllerDelegate, UITableViewDelegate, UITableViewDataSource, UICollectionViewDataSource, UICollectionViewDelegate {
    
   
    var userListQuery: SBDApplicationUserListQuery?
    var query: SBDBannedUserListQuery?
    
    var inSearchMode = false

    var channelUrl: String?
    var channel: SBDGroupChannel?
    
    
    // to override search task
    lazy var delayItem = workItem()
    
    @IBOutlet weak var selectedUserListView: UICollectionView!
    @IBOutlet weak var selectedUserListHeight: NSLayoutConstraint!
    @IBOutlet weak var tableView: UITableView!
    
    
    //
    var joinedUserIds: [String] = []
    var bannedList: [String] = []
    //
    var searchController: UISearchController?
    var userList: [SBUUser] = []
    var searchUserList: [SBUUser] = []
    var uid_list = [String]()
    var selectedUsers: [SBUUser] = []
    //

    var createButtonItem: UIBarButtonItem?
    var cancelButtonItem: UIBarButtonItem?
    
    //private lazy var titleView: UIView? = _titleView
    private lazy var leftBarButton: UIBarButtonItem? = _leftBarButton
    private lazy var rightBarButton: UIBarButtonItem? = _rightBarButton
   
    /*
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
    }() */
    
    private lazy var _leftBarButton: UIBarButtonItem = {
        
        let leftButton = UIButton(type: .custom)
        
        leftButton.setImage(UIImage.init(named: "back_icn_white")?.resize(targetSize: CGSize(width: 13, height: 23)), for: [])
        leftButton.addTarget(self, action: #selector(onClickBack), for: .touchUpInside)
        leftButton.frame = back_frame
        leftButton.setTitleColor(UIColor.white, for: .normal)
        leftButton.setTitle("", for: .normal)
        leftButton.sizeToFit()
        
        let backButtonBarButton = UIBarButtonItem(customView: leftButton)
        return backButtonBarButton
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
        self.navigationItem.leftBarButtonItem = self.leftBarButton
        self.navigationItem.rightBarButtonItem = self.rightBarButton
        navigationItem.title = "Add members"
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
        
        
        if self.channel?.myRole == .operator {
            
            self.loadBanUsers {
                self.loadDefaultUsers(needChecked: true)
            }
            
        } else {
            self.loadDefaultUsers(needChecked: false)
        }
        
        
       
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
    
    func loadBanUsers(completed: @escaping DownloadComplete) {
        
        guard let channel = self.channel else { return }
        self.query = channel.createBannedUserListQuery()
        self.query?.loadNextPage { [weak self] users, error in
            guard error == nil, let users = users, let self = self else {
                // Handle error.
                Utils.showAlertController(error: error!, viewController: self!)
                return
            }
            // A list of banned users is successfully retrieved.
            let sbuUsers = users.map { SBUUser(user: $0) }
            self.bannedList += sbuUsers.sbu_getUserIds()
            
            completed()
          
        }
        
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
            if searchText != "", filteredUsers.isEmpty {
                delayItem.perform(after: 0.35) {
                    self.searchUsers(keyword: searchText)
                }
            }
        }
    }

    
    func loadDefaultUsers(needChecked: Bool) {
        APIManager().searchUsersForChat(keyword: "") { result in
            switch result {
            case .success(let apiResponse):
                guard let data = apiResponse.body?["data"] as? [[String: Any]] else {
                    return
                }
                
                let newUserList = data.compactMap { user -> SBUUser? in
                    do {
                        let preloadUser =  Mapper<SearchUser>().map(JSONObject: user)
                        let user = SBUUser(userId: preloadUser?.userID ?? "", nickname: preloadUser?.username ?? "", profileUrl: preloadUser?.avatar ?? "")
                        
                        if needChecked {
                            
                            if !self.joinedUserIds.contains(user.userId), !self.bannedList.contains(user.userId) {
                                return user
                            }
                            
                        } else {
                            
                            if !self.joinedUserIds.contains(user.userId) {
                                return user
                            }
                            
                        }
                        
                    } catch {
                        print("Can't catch user")
                    }
                    
                    return nil
                }

                self.userList = newUserList
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }

            case .failure(let error):
                print(error)
            }
        }
    }

    func searchUsers(keyword: String) {
        APIManager().searchUsersForChat(keyword: keyword) { result in
            switch result {
            case .success(let apiResponse):
                guard let data = apiResponse.body?["data"] as? [[String: Any]] else {
                    return
                }
                
                let newUserList = data.compactMap { user -> SBUUser? in
                        let preloadUser = Mapper<SearchUser>().map(JSONObject: user)
                        let user = SBUUser(userId: preloadUser?.userID ?? "", nickname: preloadUser?.username ?? "", profileUrl: preloadUser?.avatar ?? "")
                        if !self.joinedUserIds.contains(user.userId), !self.bannedList.contains(user.userId) {
                            return user
                        }
                    
                    return nil
                }

                self.searchUserList = newUserList
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }

            case .failure(let error):
                print(error)
            }
        }
    }

    
    @objc func InviteUsers() {
       // Check if the userUID property is not an empty string
       if let userUID = _AppCoreData.userDataSource.value?.userID, userUID != "" {
           // Check if there are any selected users
           if selectedUsers.count == 0 {
               return
           }

           // Check if the joinedUserIds array has exactly 2 elements
           if joinedUserIds.count == 2 {
               createNewChannel()
           } else {
               // Get an array of user IDs from the selectedUsers array
               let userIds = Array(self.selectedUsers).sbu_getUserIds()
               // Invite users to the group channel
               inviteUsers(userIds: userIds)
           }
       }
    }

    
    func createNewChannel() {
       if let userUID = _AppCoreData.userDataSource.value?.userID, userUID != "" {
           if selectedUsers.count == 0 {
               return
           }

           // Create an instance of SBDGroupChannelParams
           let channelParams = SBDGroupChannelParams()

           // Set isDistinct property to true
           channelParams.isDistinct = true

           // Add user IDs of selected users and joinedUserIds to channelParams
           let userIds = selectedUsers.map { $0.userId } + joinedUserIds
           channelParams.addUserIds(userIds)

           // Set operatorUserIds property to current user's UID
           channelParams.operatorUserIds = [userUID]

           // Create a new group channel or invite users to existing group channel
           SBDGroupChannel.createChannel(with: channelParams) { groupChannel, error in
               guard error == nil else {
                   self.showErrorAlert("Oops!", msg: error!.localizedDescription)
                   return
               }

               // Check if channelUrl is not nil
               if let url = self.channelUrl {
                   // Get list of user IDs in the group channel
                   if let loadList = groupChannel?.members?.sbu_getUserIds() {
                       // Filter out current user's UID
                       let ids = loadList.filter { $0 != userUID }
                       // Call checkForChannelInvitation function
                       checkForChannelInvitation(channelUrl: url, user_ids: ids)
                   }
               }

               // Get group channel's URL
               let channelUrl = groupChannel?.channelUrl
               // Create an instance of ChannelViewController
               let channelVC = ChannelViewController(channelUrl: channelUrl!, messageListParams: nil)
               // Push ChannelViewController onto the navigation stack
               self.navigationController?.pushViewController(channelVC, animated: true)
               // Remove view controllers in the stack after it
               self.navigationController?.viewControllers.removeSubrange(1...4)
           }
       }
    }

    
    func showErrorAlert(_ title: String, msg: String) {
                                                                                                                                           
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        
                                                                                       
        present(alert, animated: true, completion: nil)
        
    }
    
    
    func inviteUsers(userIds: [String]) {
       // Get a reference to the group channel
       guard let channel = self.channel else { return }

       // Invite users to the group channel
       channel.inviteUserIds(userIds) { [weak self] error in
           guard let self = self else { return }

           // Check if the invitation was successful
           if let error = error {
               print(error.localizedDescription)
               showErrorAlert("Oops!", msg: error.localizedDescription)
               return
           }

           
           // Check if the channelUrl property is not nil
           if let url = self.channelUrl {
               // Call checkForChannelInvitation function
               checkForChannelInvitation(channelUrl: url, user_ids: userIds)
           }

           // Pop back to the fourth view controller in the navigation stack
           self.navigationController?.popBack(4)
       }
    }

    
    
    func shouldShowLoadingIndicator(){
        SBULoading.start()
        
    }
    
    func shouldDismissLoadingIndicator() {
        SBULoading.stop()
    }

    
  

}

