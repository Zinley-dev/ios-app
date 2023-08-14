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
    
    @IBOutlet weak var collectionLayout: UICollectionViewFlowLayout! {
        didSet {
            collectionLayout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        }
    }
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
        backButton.setTitleColor(UIColor.white, for: .normal)
        backButton.setTitle("", for: .normal)
        let backButtonBarButton = UIBarButtonItem(customView: backButton)
        
        self.navigationItem.leftBarButtonItem = backButtonBarButton
        
        return backButtonBarButton

    }()
    
    private lazy var _rightBarButton: UIBarButtonItem = {
            let rightItem =  UIBarButtonItem(
                title: "Add",
                style: .plain,
                target: self,
                action: #selector(InviteUsers)
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
        self.searchController?.searchBar.tintColor = .black
        self.searchController?.searchBar.searchTextField.textColor = .black
        self.searchController!.searchBar.searchTextField.attributedPlaceholder = NSAttributedString(string: "Search", attributes: [.foregroundColor: UIColor.lightGray])
        self.searchController!.searchBar.searchTextField.leftView?.tintColor = .darkGray

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
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(InviteUserVC.InviteToChannel), name: (NSNotification.Name(rawValue: "invite")), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(InviteUserVC.createChannel), name: (NSNotification.Name(rawValue: "create")), object: nil)
        
       
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
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        NotificationCenter.default.removeObserver(self, name: (NSNotification.Name(rawValue: "invite")), object: nil)
        NotificationCenter.default.removeObserver(self, name: (NSNotification.Name(rawValue: "create")), object: nil)
        
        
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
        self.selectedUserListView.register(HashtagCell.nib(), forCellWithReuseIdentifier: HashtagCell.cellReuseIdentifier())
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
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HashtagCell.cellReuseIdentifier(), for: indexPath) as! HashtagCell
        cell.hashTagLabel.text = selectedUsers[indexPath.row].nickname
        cell.hashTagLabel.font = FontManager.shared.roboto(.Regular, size: 12)
        cell.hashTagLabel.backgroundColor = .clear
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
        cell.theme = .light
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
            } else {
                selectedUsers.append(user)
                cell.selectUser(true)
            }

            // Update button and view based on number of selected users
            if selectedUsers.count > 0 {
                rightBarButton?.isEnabled = true
                selectedUserListHeight.constant = 40
                selectedUserListView.isHidden = false
            } else {
                rightBarButton?.isEnabled = false
                selectedUserListHeight.constant = 0
                selectedUserListView.isHidden = true
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
                delayItem.perform(after: 0.35) { [weak self] in
                    guard let self = self else { return }
                    self.searchUsers(keyword: searchText)
                }
            }
        }
    }

    
    func loadDefaultUsers(needChecked: Bool) {
        APIManager.shared.searchUsersForChat(keyword: "") { [weak self] result in
            guard let self = self else { return }

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
        APIManager.shared.searchUsersForChat(keyword: keyword) { [weak self] result in
            guard let self = self else { return }

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

           let slideVC = InviteView()
           
           slideVC.modalPresentationStyle = .custom
           slideVC.transitioningDelegate = self
           global_presetingRate = Double(0.35)
           global_cornerRadius = 35
           self.present(slideVC, animated: true, completion: nil)
           
        
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
           SBDGroupChannel.createChannel(with: channelParams) { [weak self] groupChannel, error in
               guard let self = self else { return }
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
                       self.checkForChannelInvitation(channelUrl: url, user_ids: ids)
                   }
               }

               // Get group channel's URL
               let channelUrl = groupChannel?.channelUrl
               // Create an instance of ChannelViewController
               let channelVC = ChannelViewController(channelUrl: channelUrl!, messageListParams: nil)
               // Push ChannelViewController onto the navigation stack
               //channelVC.shouldUnhide = true
               self.navigationController?.pushViewController(channelVC, animated: true)
               // Remove view controllers in the stack after it
               self.navigationController?.viewControllers.removeSubrange(1...4)
           }
       }
    }
    
    func checkForChannelInvitation(channelUrl: String, user_ids: [String]) {
        
        APIManager.shared.channelCheckForInviation(userIds: user_ids, channelUrl: channelUrl) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let apiResponse):
                // Check if the request was successful
                guard apiResponse.body?["message"] as? String == "success",
                    let data = apiResponse.body?["data"] as? [String: Any] else {
                        return
                }
                
                print(data)
                
               
            case .failure(let error):
                print(error)
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
        
        // Check if the channelUrl property is not nil
        guard let url = self.channelUrl else { return }
        
        inviteUsersToChannel(userIds: userIds, channel: channel, url: url)
    }

    func inviteUsersToChannel(userIds: [String], channel: SBDGroupChannel, url: String) {
        channel.inviteUserIds(userIds) { [weak self] error in
            guard let self = self else { return }
            
            // Check if the invitation was successful
            if let error = error {
                print(error.localizedDescription)
                self.showErrorAlert("Oops!", msg: error.localizedDescription)
                return
            }
            
            // Call checkForChannelInvitation function
            checkForChannelInvitation(channelUrl: url, user_ids: userIds)

            // Pop back to the fourth view controller in the navigation stack
            // Assuming you have a custom implementation for popBack function
            self.navigationController?.popBack(4)
        }
    }


    
    
    func shouldShowLoadingIndicator(){
        SBULoading.start()
        
    }
    
    func shouldDismissLoadingIndicator() {
        SBULoading.stop()
    }

    
    @objc func createChannel() {
        
        createNewChannel()
        
        
    }
    
    
    
    
    @objc func InviteToChannel() {
        
        let userIds = Array(self.selectedUsers).sbu_getUserIds()
        // Invite users to the group channel
        inviteUsers(userIds: userIds)
        
    }
    
  

}

