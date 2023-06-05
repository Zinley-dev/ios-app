//
//  CreateChannelVC.swift
//  Stitchbox
//
//  Created by Khoi Nguyen on 12/16/22.
//

import UIKit
import SendBirdUIKit
import SendBirdSDK
import ObjectMapper

class CreateChannelVC: UIViewController, UISearchBarDelegate, UINavigationControllerDelegate, UITableViewDelegate, UITableViewDataSource, UICollectionViewDataSource, UICollectionViewDelegate {
    
    var userListQuery: SBDApplicationUserListQuery?
    
    // to override search task
    lazy var delayItem = workItem()
    var inSearchMode = false
    
    @IBOutlet weak var selectedUserListView: UICollectionView!
    @IBOutlet weak var selectedUserListHeight: NSLayoutConstraint!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var collectionLayout: UICollectionViewFlowLayout! {
        didSet {
            collectionLayout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        }
    }
    
    var searchController: UISearchController?
    var userList: [SBUUser] = []
    var searchUserList: [SBUUser] = []
    var uid_list = [String]()
    var selectedUsers: [SBUUser] = []
    var createButtonItem: UIBarButtonItem?
    var cancelButtonItem: UIBarButtonItem?
    
    private lazy var leftBarButton: UIBarButtonItem? = _leftBarButton
    private lazy var rightBarButton: UIBarButtonItem? = _rightBarButton
    
    
    private lazy var _leftBarButton: UIBarButtonItem = {
        
        
        let backButton = UIButton(type: .custom)
        
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
        
        backButton.addTarget(self, action: #selector(onClickBack), for: .touchUpInside)
        backButton.setTitleColor(UIColor.white, for: .normal)
        backButton.setTitle("", for: .normal)
        let backButtonBarButton = UIBarButtonItem(customView: backButton)
        
        self.navigationItem.leftBarButtonItem = backButtonBarButton
        
        return backButtonBarButton
    }()
    
    private lazy var _rightBarButton: UIBarButtonItem = {
            let rightItem =  UIBarButtonItem(
                title: "Create",
                style: .plain,
                target: self,
                action: #selector(createChannel)
            )
        rightItem.setTitleTextAttributes([.font : SBUFontSet.button2], for: .normal)
        return rightItem
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupNavigationView()
        setupSearchController()
        setuptableView()
        setupCollectionView()
        setupScrollView()
        setupStyles()
        
        //
        loadDefaultUsers()
        
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

    // setup initial view
    func setupNavigationView() {
        self.navigationItem.leftBarButtonItem = self.leftBarButton
        self.navigationItem.rightBarButtonItem = self.rightBarButton
        navigationItem.title = "New Message"
        self.navigationItem.largeTitleDisplayMode = .never
    }
    
    
    func setupSearchController() {
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
    }

    
    
    func setuptableView() {
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.separatorStyle = .none
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.estimatedRowHeight = 44.0
        self.tableView.register(SBUUserCell.self, forCellReuseIdentifier: SBUUserCell.sbu_className)
    }
    
    func setupCollectionView() {
        self.rightBarButton?.isEnabled = self.selectedUsers.count > 0
    }

    
    func setupScrollView() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        //layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        layout.itemSize = CGSize(width: 120, height: 30)
        selectedUserListView.collectionViewLayout = layout
        selectedUserListView.contentInset = UIEdgeInsets(top: 0, left: 14, bottom: 0, right: 14)
        selectedUserListView.delegate = self
        selectedUserListView.dataSource = self
        selectedUserListView.register(HashtagCell.nib(), forCellWithReuseIdentifier: HashtagCell.cellReuseIdentifier())
        selectedUserListHeight.constant = 0
        selectedUserListView.isHidden = true
        selectedUserListView.showsHorizontalScrollIndicator = false
        selectedUserListView.showsVerticalScrollIndicator = false
    }
    
    func setupStyles() {

        self.leftBarButton?.tintColor = UIColor.white
        self.rightBarButton?.tintColor = self.selectedUsers.isEmpty
            ? SBUTheme.userListTheme.rightBarButtonTintColor
            : UIColor.white

    }
    
    @objc func onClickBack() {
        if let navigationController = self.navigationController {
            if let viewController = navigationController.viewControllers.first(where: { $0 is MainMessageVC }) {
                navigationController.popToViewController(viewController, animated: true)
            } else {
                navigationController.popViewController(animated: true)
            }
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }

    
    
    // collectionView setup
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.selectedUsers.count
    }
     
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HashtagCell.cellReuseIdentifier(), for: indexPath) as! HashtagCell
        cell.hashTagLabel.text = selectedUsers[indexPath.row].nickname
        cell.hashTagLabel.font = UIFont.systemFont(ofSize: 12)
        cell.hashTagLabel.backgroundColor = .clear
        cell.backgroundColor = .primary
        return cell
    }


    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.selectedUsers.remove(at: indexPath.row)
        self.rightBarButton?.isEnabled = !self.selectedUsers.isEmpty
        setupStyles()
        collectionView.reloadData()
        self.tableView.reloadData()
        self.selectedUserListHeight.constant = self.selectedUsers.isEmpty ? 0 : self.selectedUserListView.bounds.height
        self.selectedUserListView.isHidden = self.selectedUsers.isEmpty
    }

    
    // tableView setup
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return inSearchMode ? searchUserList.count : userList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let user: SBUUser = inSearchMode ? searchUserList[indexPath.row] : userList[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: SBUUserCell.sbu_className, for: indexPath) as? SBUUserCell
        cell?.configure(
            type: .createChannel,
            user: user,
            isChecked: self.selectedUsers.contains(user)
        )
        cell?.theme = .dark
        cell?.contentView.backgroundColor = self.view.backgroundColor
        cell?.selectionStyle = .none
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
    
    
    // searchBar setup

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
        guard !searchText.isEmpty else {
            searchUserList.removeAll()
            tableView.reloadData()
            return
        }

        let filteredUsers = userList.filter {
            guard let nickname = $0.nickname else { return false }
            return nickname.range(of: searchText, options: .caseInsensitive) != nil
        }
        searchUserList = filteredUsers.isEmpty ? [] : filteredUsers
        tableView.reloadData()

        if filteredUsers.isEmpty {
            delayItem.perform(after: 0.35) {
                self.searchUsers(keyword: searchText)
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

                var newUserList = [SBUUser]()
                for user in data {
                    let preloadUser =  Mapper<SearchUser>().map(JSONObject: user)
                    let user = SBUUser(userId: preloadUser?.userID ?? "", nickname: preloadUser?.username ?? "", profileUrl: preloadUser?.avatar ?? "")
                    if !self.searchUserList.contains(where: { $0.userId == user.userId }) {
                        newUserList.append(user)
                    }
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
    
    
    func loadDefaultUsers() {
        APIManager.shared.searchUsersForChat(keyword: "") { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .success(let apiResponse):
                guard let data = apiResponse.body?["data"] as? [[String: Any]] else {
                    return
                }

                var newUserList = [SBUUser]()
                for user in data {
                   
                    let preloadUser =  Mapper<SearchUser>().map(JSONObject: user)
                    let user = SBUUser(userId: preloadUser?.userID ?? "", nickname: preloadUser?.username ?? "", profileUrl: preloadUser?.avatar ?? "")
                    if !self.userList.contains(where: { $0.userId == user.userId }) {
                        newUserList.append(user)
                    }
                   
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

    
    func shouldShowLoadingIndicator(){
        SBULoading.start()
        
    }
    
    func shouldDismissLoadingIndicator() {
        SBULoading.stop()
    }
    
    func showErrorAlert(_ title: String, msg: String) {
                                                                                                                                           
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        
                                                                                       
        present(alert, animated: true, completion: nil)
        
    }
    
    @objc func createChannel() {
        guard let userUID = _AppCoreData.userDataSource.value?.userID, !userUID.isEmpty, !selectedUsers.isEmpty else { return }
        
        let channelParams = SBDGroupChannelParams()

        
        channelParams.addUserIds(selectedUsers.map { $0.userId })
        if selectedUsers.count > 1 {
            channelParams.isDistinct = false
        } else {
            channelParams.isDistinct = true
        }
        
        channelParams.addUserId(userUID)
        channelParams.operatorUserIds = [userUID]
        
        SBDGroupChannel.createChannel(with: channelParams) { groupChannel, error in
            guard error == nil, let channelUrl = groupChannel?.channelUrl else {
                self.showErrorAlert("Oops!", msg: error?.localizedDescription ?? "Failed to create channel")
                return
            }

            let userIDs = self.selectedUsers.map { $0.userId }
            checkForChannelInvitation(channelUrl: channelUrl, user_ids: userIDs)

            let channelVC = ChannelViewController(channelUrl: channelUrl, messageListParams: nil)
            channelVC.shouldUnhide = true
            self.navigationController?.pushViewController(channelVC, animated: true)
            self.navigationController?.viewControllers.remove(at: 1)
        }
    }


}
