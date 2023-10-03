//
//  NotificationVC.swift
//  Stitchbox
//
//  Created by Khoi Nguyen on 1/27/23.
//

import UIKit
import FLAnimatedImage
import AsyncDisplayKit

class NotificationVC: UIViewController {
    
    deinit {
        print("NotificationVC is being deallocated.")
    }
    
    let backButton: UIButton = UIButton(type: .custom)
    
    @IBOutlet weak var contentView: UIView!

    var page = 1
    var refresh_request = false
    private var pullControl = UIRefreshControl()
    var tableNode: ASTableNode!
    var UserNotificationList = [UserNotificationModel]()
    var firstAnimated = true

    
    required init?(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
        self.tableNode = ASTableNode(style: .plain)
        self.wireDelegates()
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        setupButtons()
        
        contentView.addSubview(tableNode.view)
        
        self.tableNode.view.translatesAutoresizingMaskIntoConstraints = false
        self.tableNode.view.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 0).isActive = true
        self.tableNode.view.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 0).isActive = true
        self.tableNode.view.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: 0).isActive = true
        self.tableNode.view.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: 0).isActive = true
        
        self.applyStyle()
        self.tableNode.leadingScreensForBatching = 5
        self.tableNode.automaticallyRelayoutOnLayoutMarginsChanges = true
        self.tableNode.automaticallyAdjustsContentOffset = true
        
        
        pullControl.tintColor = .secondary
        pullControl.addTarget(self, action: #selector(refreshListData(_:)), for: .valueChanged)
        
        if UIDevice.current.hasNotch {
            pullControl.bounds = CGRect(x: pullControl.bounds.origin.x, y: -50, width: pullControl.bounds.size.width, height: pullControl.bounds.size.height)
        }
        
        if #available(iOS 10.0, *) {
            tableNode.view.refreshControl = pullControl
        } else {
            tableNode.view.addSubview(pullControl)
        }
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
    
}

extension NotificationVC {
    
    @objc private func refreshListData(_ sender: Any) {
        // self.pullControl.endRefreshing() // You can stop after API Call
        // Call API
        
        clearAllData()
        
    }
    
}

extension NotificationVC {
    
    func setupButtons() {
        
        setupBackButton()
        
    }
    
    
    func setupBackButton() {
        
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
        
        backButton.addTarget(self, action: #selector(onClickBack(_:)), for: .touchUpInside)
        backButton.setTitleColor(UIColor.white, for: .normal)
        backButton.setTitle("", for: .normal)
        let backButtonBarButton = UIBarButtonItem(customView: backButton)
        navigationItem.title = "Notifications"
        
        self.navigationItem.leftBarButtonItem = backButtonBarButton
        
        
        
    }
    
    
    func showErrorAlert(_ title: String, msg: String) {
        
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default)
        
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
        
    }
    
    
}

extension NotificationVC {
    
    @objc func onClickBack(_ sender: AnyObject) {
        if let navigationController = self.navigationController {
            navigationController.popViewController(animated: true)
        }
    }
    
}

extension NotificationVC {
    
    func applyStyle() {
        
        self.tableNode.view.separatorStyle = .none
        self.tableNode.view.separatorColor = UIColor.lightGray
        self.tableNode.view.isPagingEnabled = false
        self.tableNode.view.backgroundColor = .white
        self.tableNode.view.showsVerticalScrollIndicator = false
        
    }
    
    func wireDelegates() {
        
        self.tableNode.delegate = self
        self.tableNode.dataSource = self
        
    }
    
    
}

extension NotificationVC {
    
    
    func tableNode(_ tableNode: ASTableNode, didSelectRowAt indexPath: IndexPath) {
        
        let notification = UserNotificationList[indexPath.row]
        
        if notification._isRead == false {
            UserNotificationList[indexPath.row]._isRead = true
            tableNode.reloadRows(at: [IndexPath(row: indexPath.row, section: 0)], with: .automatic)
            setRead(notiId: notification.notiId)
        }
        
        
        if let template = notification.template {
            
            switch template {
                
            case "NEW_COMMENT":
                if let post = notification.post {
                    openComment(commentId: notification.commentId, rootComment: notification.rootComment, replyToComment: notification.replyToComment, type: template, post: post)
                } else {
                    self.showErrorAlert("Oops!", msg: "This content is not available")
                }
                
            case "REPLY_COMMENT":
                if let post = notification.post {
                    openComment(commentId: notification.commentId, rootComment: notification.rootComment, replyToComment: notification.replyToComment, type: template, post: post)
                } else {
                    self.showErrorAlert("Oops!", msg: "This content is not available")
                }
                
            case "NEW_FOLLOW_1":
                
                if let userId = notification.userId, let username = notification.username {
                    openUser(userId: userId, username: username)
                } else {
                    showErrorAlert("Oops!", msg: "Can't open this notification content")
                }
                
            case "NEW_FOLLOW_2":
                openFollow()
            case "NEW_TAG":
                if let post = notification.post {
                    openComment(commentId: notification.commentId, rootComment: notification.rootComment, replyToComment: notification.replyToComment, type: template, post: post)
                } else {
                    self.showErrorAlert("Oops!", msg: "This content is not available")
                }
            case "MENTION_IN_COMMENT":
                if let post = notification.post {
                    openComment(commentId: notification.commentId, rootComment: notification.rootComment, replyToComment: notification.replyToComment, type: template, post: post)
                } else {
                    self.showErrorAlert("Oops!", msg: "This content is not available")
                }
            case "NEW_POST":
                openPost(post: notification.post)
            case "LIKE_COMMENT":
                if let userId = notification.userId, let username = notification.username {
                    openUser(userId: userId, username: username)
                } else {
                    showErrorAlert("Oops!", msg: "Can't open this notification content")
                }
            case "LIKE_POST":
                if let userId = notification.userId, let username = notification.username {
                    openUser(userId: userId, username: username)
                } else {
                    showErrorAlert("Oops!", msg: "Can't open this notification content")
                }
            case "NEW_STITCH":
                moveToStichDashboard()
            case  "APPROVED_STITCH":
                moveToStichDashboard()
            case "DENIED_STITCH":
                moveToStichDashboard()
                
            default:
                print(notification.template)
                
            }
            
        }
        
    }
    
}

extension NotificationVC {
    
    
    func moveToStichDashboard() {
        
        if let PVC = UIStoryboard(name: "Dashboard", bundle: nil).instantiateViewController(withIdentifier: "StitchDashboardVC") as? StitchDashboardVC {
            
            self.navigationController?.pushViewController(PVC, animated: true)
            
        }
      
        
    }
    
    func openPost(post: PostModel) {
        
        if let RVC = UIStoryboard(name: "Dashboard", bundle: nil).instantiateViewController(withIdentifier: "SelectedParentVC") as? SelectedParentVC {
            
            let nav = UINavigationController(rootViewController: RVC)
            
            // Set the user ID, nickname, and onPresent properties of UPVC
            RVC.posts = [post]
            RVC.startIndex = 0
            
            nav.modalPresentationStyle = .fullScreen
            self.present(nav, animated: true, completion: nil)
            
        }
        
        
    }
    
    func openComment(commentId: String, rootComment: String, replyToComment: String, type: String, post: PostModel) {
        
        print(commentId, rootComment, replyToComment, type)
        
        let slideVC = CommentNotificationVC()
        
        slideVC.commentId = commentId
        slideVC.reply_to_cid = replyToComment
        slideVC.root_id = rootComment
        slideVC.type = type
        slideVC.post = post
        
        global_presetingRate = Double(0.75)
        global_cornerRadius = 35
        
        slideVC.modalPresentationStyle = .custom
        slideVC.transitioningDelegate = self
        
        self.present(slideVC, animated: true, completion: nil)
        
        
    }
    
    func openUser(userId: String, username: String) {
        
        if let UPVC = UIStoryboard(name: "Dashboard", bundle: nil).instantiateViewController(withIdentifier: "UserProfileVC") as? UserProfileVC {
            
            UPVC.userId = userId
            UPVC.nickname = username
            self.navigationController?.pushViewController(UPVC, animated: true)
            
        }
        
        
    }
    
    func openFollow() {
        
        if let MFVC = UIStoryboard(name: "Dashboard", bundle: nil).instantiateViewController(withIdentifier: "MainFollowVC") as? MainFollowVC {
            MFVC.showFollowerFirst = true
            MFVC.userId = _AppCoreData.userDataSource.value?.userID ?? ""
            MFVC.followerCount = 0
            MFVC.followingCount = 0
            
            self.navigationController?.pushViewController(MFVC, animated: true)
            
        }
        
        
    }
    
    
    func setRead(notiId: String) {
        
        
        APIManager.shared.readNotification(noti: notiId) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let apiResponse):
                
                print(apiResponse)
                
                
            case .failure(let error):
                print(error)
                
            }
        }
        
    }
    
    
}


extension NotificationVC: ASTableDelegate {
    
    func tableNode(_ tableNode: ASTableNode, constrainedSizeForRowAt indexPath: IndexPath) -> ASSizeRange {
        
        let width = UIScreen.main.bounds.size.width;
        
        let min = CGSize(width: width, height: 30);
        let max = CGSize(width: width, height: 1000);
        return ASSizeRangeMake(min, max);
        
    }
    
    
    func shouldBatchFetch(for tableNode: ASTableNode) -> Bool {
        
        return true
        
    }
    
    func tableNode(_ tableNode: ASTableNode, willBeginBatchFetchWith context: ASBatchContext) {
        
        if refresh_request == false {
            
            self.retrieveNextPageWithCompletion { [weak self] (newNotis) in
                guard let self = self else { return }
                self.insertNewRowsInTableNode(newNotis: newNotis)
                
                context.completeBatchFetching(true)
                
            }
            
        } else {
            
            context.completeBatchFetching(true)
            
        }
        
        
    }
    
    
}


extension NotificationVC {
    
    func retrieveNextPageWithCompletion(block: @escaping ([[String: Any]]) -> Void) {
        
        APIManager.shared.getNotifications(page: page) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let apiResponse):
                if let data = apiResponse.body?["data"] as? [[String: Any]], !data.isEmpty {
                    print("Successfully retrieved \(data.count) posts.")
                    self.page += 1
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

    func insertNewRowsInTableNode(newNotis: [[String: Any]]) {
        guard newNotis.count > 0 else { return }
        
        if refresh_request {
            clearExistingPosts()
            refresh_request = false
        }

        let items = newNotis.compactMap { UserNotificationModel(UserNotificationModel: $0) }.filter { !self.UserNotificationList.contains($0) }
        self.UserNotificationList.append(contentsOf: items)
        
        if !items.isEmpty {
            let indexPaths = generateIndexPaths(for: items)
            tableNode.insertRows(at: indexPaths, with: .automatic)
        }
    }

    private func clearExistingPosts() {
        UserNotificationList.removeAll()
        tableNode.reloadData()
    }

    private func generateIndexPaths(for items: [UserNotificationModel]) -> [IndexPath] {
        let startIndex = self.UserNotificationList.count - items.count
        return (startIndex..<self.UserNotificationList.count).map { IndexPath(row: $0, section: 0) }
    }

    func updateData() {
        self.retrieveNextPageWithCompletion { [weak self] (newNotis) in
            guard let self = self else { return }

            if self.pullControl.isRefreshing {
                self.pullControl.endRefreshing()
            }
            
            if newNotis.isEmpty {
                self.refresh_request = false
                self.UserNotificationList.removeAll()
                self.tableNode.reloadData()
                if self.UserNotificationList.isEmpty {
                    self.tableNode.view.setEmptyMessage("No active notification!")
                } else {
                    self.tableNode.view.restore()
                }
            } else {
                self.insertNewRowsInTableNode(newNotis: newNotis)
            }
        }
    }

    @objc func clearAllData() {
      
        refresh_request = true
        page = 1
        updateData()
    }
    
}


extension NotificationVC: ASTableDataSource {
    
    func tableNode(_ tableNode: ASTableNode, numberOfRowsInSection section: Int) -> Int {
        
        if self.UserNotificationList.count == 0 {
            
            tableNode.view.setEmptyMessage("No active notification!")
            
        } else {
            tableNode.view.restore()
        }
        
        return self.UserNotificationList.count
        
    }
    
    func tableNode(_ tableNode: ASTableNode, nodeBlockForRowAt indexPath: IndexPath) -> ASCellNodeBlock {
        
        let notification = self.UserNotificationList[indexPath.row]
        
        return {
            
            let node = NotificationNode(with: notification)
            node.neverShowPlaceholders = true
            node.debugName = "Node \(indexPath.row)"
            
            return node
        }
        
    }

    
}
