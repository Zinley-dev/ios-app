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
    
    var searchController: UISearchController?
    var userList: [SBUUser] = []
    var searchUserList: [SBUUser] = []
    var uid_list = [String]()
    var selectedUsers: [SBUUser] = []
    var createButtonItem: UIBarButtonItem?
    var cancelButtonItem: UIBarButtonItem?
    
    private lazy var titleView: UIView? = _titleView
    private lazy var leftBarButton: UIBarButtonItem? = _leftBarButton
    private lazy var rightBarButton: UIBarButtonItem? = _rightBarButton
    
    private lazy var _titleView: UILabel = {
        var titleView = UILabel()
        titleView.backgroundColor = UIColor.clear
        titleView.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 55)
        titleView.text = ""
        titleView.textAlignment = .center
        titleView.textColor = UIColor.white
        
        return titleView
    }()
    
    private lazy var _leftBarButton: UIBarButtonItem = {
        
        
        let leftButton = UIButton(type: .custom)
        
        leftButton.setImage(UIImage.init(named: "back_icn_white")?.resize(targetSize: CGSize(width: 13, height: 23)), for: [])
        leftButton.addTarget(self, action: #selector(onClickBack), for: .touchUpInside)
        leftButton.frame = back_frame
        leftButton.setTitleColor(UIColor.white, for: .normal)
        leftButton.setTitle("     New message", for: .normal)
        leftButton.sizeToFit()
        
        let backButtonBarButton = UIBarButtonItem(customView: leftButton)
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


    // setup initial view
    func setupNavigationView() {
        self.navigationItem.leftBarButtonItem = self.leftBarButton
        self.navigationItem.rightBarButtonItem = self.rightBarButton
        self.navigationItem.titleView = self.titleView
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
        layout.itemSize = CGSize(width: 120, height: 30)
        selectedUserListView.collectionViewLayout = layout
        selectedUserListView.contentInset = UIEdgeInsets(top: 0, left: 14, bottom: 0, right: 14)
        selectedUserListView.delegate = self
        selectedUserListView.dataSource = self
        selectedUserListView.register(SelectedUserCollectionViewCell.nib(), forCellWithReuseIdentifier: SelectedUserCollectionViewCell.cellReuseIdentifier())
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
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SelectedUserCollectionViewCell.cellReuseIdentifier(), for: indexPath) as! SelectedUserCollectionViewCell
        cell.nicknameLabel.text = selectedUsers[indexPath.row].nickname
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
        APIManager().searchUsersForChat(keyword: keyword) { result in
            switch result {
            case .success(let apiResponse):
                guard let data = apiResponse.body?["data"] as? [[String: Any]] else {
                    return
                }

                var newUserList = [SBUUser]()
                for user in data {
                    let preloadUser =  Mapper<SendBirdUser>().map(JSONObject: user)
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
        APIManager().searchUsersForChat(keyword: "") { result in
            switch result {
            case .success(let apiResponse):
                guard let data = apiResponse.body?["data"] as? [[String: Any]] else {
                    return
                }

                var newUserList = [SBUUser]()
                for user in data {
                    let preloadUser =  Mapper<SendBirdUser>().map(JSONObject: user)
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
        channelParams.isDistinct = true
        channelParams.addUserIds(selectedUsers.map { $0.userId })
        if selectedUsers.count > 1 {
            channelParams.operatorUserIds = [userUID]
        }

        SBDGroupChannel.createChannel(with: channelParams) { groupChannel, error in
            guard error == nil, let channelUrl = groupChannel?.channelUrl else {
                self.showErrorAlert("Oops!", msg: error?.localizedDescription ?? "Failed to create channel")
                return
            }

            let userIDs = self.selectedUsers.map { $0.userId }
            checkForChannelInvitation(channelUrl: channelUrl, user_ids: userIDs)

            let channelVC = ChannelViewController(channelUrl: channelUrl, messageListParams: nil)
            self.navigationController?.pushViewController(channelVC, animated: true)
            self.navigationController?.viewControllers.remove(at: 1)
        }
    }


}
