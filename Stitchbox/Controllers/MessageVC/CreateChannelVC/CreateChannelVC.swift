//
//  CreateChannelVC.swift
//  Stitchbox
//
//  Created by Khoi Nguyen on 12/16/22.
//

import UIKit
import SendBirdUIKit
import SendBirdSDK

class CreateChannelVC: UIViewController, UISearchBarDelegate, UINavigationControllerDelegate, UITableViewDelegate, UITableViewDataSource, UICollectionViewDataSource, UICollectionViewDelegate {
    
    var userListQuery: SBDApplicationUserListQuery?
    
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
        titleView.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 50)
        titleView.text = "New Message"
        titleView.textAlignment = .center
        titleView.textColor = UIColor.white
        
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
        self.searchController?.searchBar.delegate = self
        self.searchController?.obscuresBackgroundDuringPresentation = false
        
        self.searchController?.searchBar.searchBarStyle = .minimal
        
        self.navigationItem.searchController = self.searchController
        self.navigationItem.hidesSearchBarWhenScrolling = false
        self.searchController?.searchBar.tintColor = UIColor.white
        self.searchController?.searchBar.searchTextField.textColor = UIColor.white
        self.searchController!.searchBar.searchTextField.attributedPlaceholder =  NSAttributedString.init(string: "Search", attributes: [NSAttributedString.Key.foregroundColor:UIColor.lightGray])
        self.searchController!.searchBar.searchTextField.leftView?.tintColor = UIColor.lightGray
        
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
        
        if self.selectedUsers.count == 0 {
            self.rightBarButton?.isEnabled = false
        }
        else {
            self.rightBarButton?.isEnabled = true
        }
        
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
    
    func setupStyles() {

        self.leftBarButton?.tintColor = SBUTheme.userListTheme.leftBarButtonTintColor
        self.rightBarButton?.tintColor = self.selectedUsers.isEmpty
            ? SBUTheme.userListTheme.rightBarButtonTintColor
            : SBUTheme.userListTheme.rightBarButtonSelectedTintColor

    }
    
    @objc func onClickBack() {
        if let navigationController = self.navigationController,
            navigationController.viewControllers.count > 1 {
            navigationController.popViewController(animated: true)
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    
    // collectionView setup
    
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
    
    // tableView setup
    
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
            
            if indexPath.row < searchUserList.count {
                
                user = searchUserList[indexPath.row]
                
            }
          
            
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
        if searchText.count > 0 {
           
            let filteredUsers = userList.filter { ($0.nickname?.contains(searchText))!}
            
            if filteredUsers.count != 0 {
                
                searchUserList = filteredUsers
                self.tableView.reloadData()
                
            } else {
                
                if searchText != "" {
                    
                    //self.searchUsers(searchText: searchText)
                    
                }
            }
        }
    }
    
    
    func hideForSelectedUser(channelUrl: String, user_list: [String], channel: SBDGroupChannel) {
        
     
    }
    
    
    func checkIfHidden(uid: String, channelUrl: String, channel: SBDGroupChannel) {
        
       
    }
    
    func acceptInviation(channelUrl: String, user_id: String) {

        
    }
    
    
    
    func sendAdminMessage(channelUrl: String, message: String) {
        
        
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

        
   
    }

}
