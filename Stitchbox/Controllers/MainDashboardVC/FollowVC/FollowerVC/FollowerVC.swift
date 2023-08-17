//
//  FollowerVC.swift
//  Stitchbox
//
//  Created by Khoi Nguyen on 1/24/23.
//

import UIKit
import Alamofire
import AsyncDisplayKit
import SendBirdUIKit

class FollowerVC: UIViewController {
    
    deinit {
        print("FollowerVC is being deallocated.")
    }
    
    //typealias ViewModelType = ProfileViewModel
    // MARK: - Properties
    private var currPage = 1
    //private var viewModel: ViewModelType! = ViewModelType()
    //private let disposeBag = DisposeBag()
    
    @IBOutlet weak var contentView: UIView!
    var requestedUserId: String?
    var inSearchMode = false
    var tableNode: ASTableNode!
    var searchUserList = [FollowModel]()
    var userList = [FollowModel]()
    
    
    var userId = ""
    
    var refresh_request = false
    private var pullControl = UIRefreshControl()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.tableNode = ASTableNode(style: .plain)
        self.wireDelegates()
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //must happen before setting up tablenode otherwise data is not enough to render
        setupTableNode()
        // Do any additional setup after loading the view.
        
        pullControl.tintColor = .secondary
        pullControl.addTarget(self, action: #selector(refreshListData(_:)), for: .valueChanged)
        
        
        if #available(iOS 10.0, *) {
            tableNode.view.refreshControl = pullControl
        } else {
            tableNode.view.addSubview(pullControl)
        }
        
        
    }
    
    
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let size = tableNode.view.visibleCells[0].frame.height
        let iconSize: CGFloat = 35.0
        
        let removeAction = UIContextualAction(
            style: .normal,
            title: ""
        ) { action, view, actionHandler in
            
            let userid = self.inSearchMode ? self.searchUserList[indexPath.row].userId : self.userList[indexPath.row].userId
            self.removeFollower(userUID: userid ?? "", row: indexPath.row)
            actionHandler(true)
        }
        
        let removeView = UIImageView(
            frame: CGRect(
                x: (size-iconSize)/2,
                y: (size-iconSize)/2,
                width: iconSize,
                height: iconSize
            ))
        //removeView.layer.borderColor = UIColor.white.cgColor
        removeView.layer.masksToBounds = true
        //removeView.layer.borderWidth = 1
        removeView.layer.cornerRadius = iconSize/2
        removeView.backgroundColor =  .clear
        removeView.image = SBUIconSet.iconRemove.resize(targetSize: CGSize(width: 22, height: 22)).withTintColor(.black)
        removeView.contentMode = .center
        
        removeAction.image = removeView.asImage()
        removeAction.backgroundColor = .white
       
        
        return UISwipeActionsConfiguration(actions: [removeAction])
        
        
    }
    
    func removeFollower(userUID: String, row: Int) {
        
        if userUID != "" {
            
            APIManager.shared.deleteFollower(params: ["FollowId": userUID]) { [weak self] result in
                guard let self = self else { return }
                
                switch result {
                case .success(_):
                    DispatchQueue.main.async { [weak self] in
                        guard let self = self else { return }
                        self.userList.remove(at: row)
                        self.tableNode.deleteRows(at: [IndexPath(row: row, section: 0)], with: .automatic)
                        showNote(text: "Remove followed!")
                    }
                    
                case .failure(_):
                    DispatchQueue.main.async { [weak self] in
                        guard let self = self else { return }
                        showNote(text: "Unable to remove follow!")
                    }
                    
                }
            }
            
        }
        
    }
    
}

extension FollowerVC {
    
    func setupTableNode() {
        
        contentView.addSubview(tableNode.view)
        
        self.tableNode.view.translatesAutoresizingMaskIntoConstraints = false
        self.tableNode.view.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 0).isActive = true
        self.tableNode.view.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 0).isActive = true
        self.tableNode.view.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: 0).isActive = true
        self.tableNode.view.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: 0).isActive = true
        
        
        
        self.applyStyle()
        self.tableNode.leadingScreensForBatching = 5
        
    }
    
    func applyStyle() {
        
        self.tableNode.view.separatorStyle = .none
        self.tableNode.view.separatorColor = UIColor.lightGray
        self.tableNode.view.isPagingEnabled = false
        self.tableNode.view.backgroundColor = UIColor.clear
        self.tableNode.view.showsVerticalScrollIndicator = false
        
    }
    
    func wireDelegates() {
        
        self.tableNode.delegate = self
        self.tableNode.dataSource = self
    }
    
}

extension FollowerVC: ASTableDelegate {
    
    func tableNode(_ tableNode: ASTableNode, constrainedSizeForRowAt indexPath: IndexPath) -> ASSizeRange {
        
        let width = UIScreen.main.bounds.size.width;
        
        let min = CGSize(width: width, height: 40);
        let max = CGSize(width: width, height: 1000);
        return ASSizeRangeMake(min, max);
        
    }
    
    
    func shouldBatchFetch(for tableNode: ASTableNode) -> Bool {
        
        return true
        
    }
    
    func tableNode(_ tableNode: ASTableNode, willBeginBatchFetchWith context: ASBatchContext) {
        
        if refresh_request == false {
            
            self.retrieveNextPageWithCompletion { [weak self] (newFollowers) in
                guard let self = self else { return }
                self.insertNewRowsInTableNode(newFollowers: newFollowers)
                
                context.completeBatchFetching(true)
                
            }
            
        } else {
            
            context.completeBatchFetching(true)
            
        }
        
        
    }
    
    func tableNode(_ tableNode: ASTableNode, didSelectRowAt indexPath: IndexPath) {
        
        let user = inSearchMode ? searchUserList[indexPath.row] : userList[indexPath.row]
        
        if user.userId != _AppCoreData.userDataSource.value?.userID {
            
            if let UPVC = UIStoryboard(name: "Dashboard", bundle: nil).instantiateViewController(withIdentifier: "UserProfileVC") as? UserProfileVC {
                //self.hidesBottomBarWhenPushed = true
                UPVC.userId = user.userId
                UPVC.nickname = user.username
                self.navigationController?.pushViewController(UPVC, animated: true)
                
            }
            
        }
        
        
    }
    
}

extension FollowerVC: ASTableDataSource {
    
    func tableNode(_ tableNode: ASTableNode, numberOfRowsInSection section: Int) -> Int {
        
        
        let array = inSearchMode ? searchUserList : userList
        
        
        if array.count == 0 {
            
            tableNode.view.setEmptyMessage("No follower")
            
        } else {
            tableNode.view.restore()
        }
        
        return array.count
        
    }
    
    func tableNode(_ tableNode: ASTableNode, nodeBlockForRowAt indexPath: IndexPath) -> ASCellNodeBlock {
        //let array = inSearchMode ? searchChannelList : channels
        let user = inSearchMode ? searchUserList[indexPath.row] : userList[indexPath.row]
        
        user.loadFromMode = "follower"
        user.loadFromUserId = self.userId
        
        return {
            var node: FollowNode!
            node = FollowNode(with: user)
            node.neverShowPlaceholders = true
            node.debugName = "Node \(indexPath.row)"
            
            
            return node
        }
        
    }
    
    
}


extension FollowerVC {
    
    
    func retrieveNextPageWithCompletion(block: @escaping ([[String: Any]]) -> Void) {
        
        APIManager.shared.getFollowers(userId: userId, page: currPage) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let apiResponse):
                if let data = apiResponse.body?["data"] as? [[String: Any]], !data.isEmpty {
                    print("Successfully retrieved \(data.count) posts.")
                    self.currPage += 1
                    DispatchQueue.main.async {
                        block(data)
                    }
                } else {
                    self.completeWithEmptyData(block)
                }
            case .failure(let error):
                print(error)
                self.completeWithEmptyData(block)
            }
        }
    }

    private func completeWithEmptyData(_ block: @escaping ([[String: Any]]) -> Void) {
        DispatchQueue.main.async {
            block([])
        }
    }

    func insertNewRowsInTableNode(newFollowers: [[String: Any]]) {
        guard newFollowers.count > 0 else { return }
        
        if refresh_request {
            clearExistingPosts()
            refresh_request = false
        }

        let items = newFollowers.compactMap { FollowModel(JSON: $0) }.filter { !self.userList.contains($0) }
        self.userList.append(contentsOf: items)
        
        if !items.isEmpty {
            let indexPaths = generateIndexPaths(for: items)
            tableNode.insertRows(at: indexPaths, with: .automatic)
        }
    }

    private func clearExistingPosts() {
        userList.removeAll()
        tableNode.reloadData()
    }

    private func generateIndexPaths(for items: [FollowModel]) -> [IndexPath] {
        let startIndex = self.userList.count - items.count
        return (startIndex..<self.userList.count).map { IndexPath(row: $0, section: 0) }
    }
    
    
}




extension FollowerVC {
    
    @objc private func refreshListData(_ sender: Any) {
        // self.pullControl.endRefreshing() // You can stop after API Call
        // Call API
        
        clearAllData()
        
    }
    
    @objc func clearAllData() {
        
        refresh_request = true
        currPage = 1
        updateData()
        
    }
    
    func updateData() {
        self.retrieveNextPageWithCompletion { [weak self] (newFollowers) in
            guard let self = self else { return }

            if self.pullControl.isRefreshing {
                self.pullControl.endRefreshing()
            }
            
            if newFollowers.isEmpty {
                self.refresh_request = false
                self.userList.removeAll()
                self.tableNode.reloadData()
                if self.userList.isEmpty {
                    self.tableNode.view.setEmptyMessage("No follower!")
                } else {
                    self.tableNode.view.restore()
                }
            } else {
                self.insertNewRowsInTableNode(newFollowers: newFollowers)
            }
        }
    }

    
}
