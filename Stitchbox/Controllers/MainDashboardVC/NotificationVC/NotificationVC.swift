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
    @IBOutlet weak var loadingImage: FLAnimatedImageView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var loadingView: UIView!
 
    
    var page = 1
    var refresh_request = false
    private var pullControl = UIRefreshControl()
    var tableNode: ASTableNode!
    var UserNotificationList = [UserNotificationModel]()
    var firstAnimated = true
    lazy var delayItem = workItem()
    
    
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
        loadingView.isHidden = true

        
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
    
    @objc func clearAllData() {
        
        refresh_request = true
        page = 1
        updateData()
        
    }
    
    
    func updateData() {
        self.retrieveNextPageWithCompletion { (newNotis) in
            
            if newNotis.count > 0 {
                
                self.UserNotificationList.removeAll()
                self.tableNode.reloadData()
                
                self.insertNewRowsInTableNode(newNotis: newNotis)
                
            } else {
                
                self.refresh_request = false
                self.UserNotificationList.removeAll()
                self.tableNode.reloadData()
                
                if self.UserNotificationList.isEmpty == true {
                    
                    self.tableNode.view.setEmptyMessage("No active notification")
                    
                } else {
                    
                    self.tableNode.view.restore()
                    
                }
                
            }
            
            if self.pullControl.isRefreshing == true {
                self.pullControl.endRefreshing()
            }
            
            
        }
        
        
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
        
        if let RVC = UIStoryboard(name: "Dashboard", bundle: nil).instantiateViewController(withIdentifier: "SelectedPostVC") as? SelectedPostVC {
            
            let nav = UINavigationController(rootViewController: RVC)
            
            // Set the user ID, nickname, and onPresent properties of UPVC
            RVC.posts = [post]
            
            // Customize the navigation bar appearance
            nav.navigationBar.barTintColor = .background
            nav.navigationBar.tintColor = .white
            nav.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
            
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
                
                guard let data = apiResponse.body?["data"] as? [[String: Any]] else {
                    let item = [[String: Any]]()
                    DispatchQueue.main.async {
                        block(item)
                    }
                    return
                }
                
                if !data.isEmpty {
                    self.page += 1
                    print("Successfully retrieved \(data.count) notifications.")
                    let items = data
                    DispatchQueue.main.async {
                        block(items)
                    }
                } else {
                    
                    let item = [[String: Any]]()
                    DispatchQueue.main.async {
                        block(item)
                    }
                }
                
            case .failure(let error):
                print(error)
                let item = [[String: Any]]()
                DispatchQueue.main.async {
                    block(item)
                }
            }
        }
        
    }
    
    
    func insertNewRowsInTableNode(newNotis: [[String: Any]]) {
        
        guard newNotis.count > 0 else {
            hideAnimation()
            return
        }
        
        
        let section = 0
        var items = [UserNotificationModel]()
        var indexPaths: [IndexPath] = []
        let total = self.UserNotificationList.count + newNotis.count
        
        for row in self.UserNotificationList.count...total-1 {
            let path = IndexPath(row: row, section: section)
            indexPaths.append(path)
        }
        
        for i in newNotis {
            
            let item = UserNotificationModel(UserNotificationModel: i)
            items.append(item)
            
        }
        
        
        self.UserNotificationList.append(contentsOf: items)
        self.tableNode.insertRows(at: indexPaths, with: .none)
        hideAnimation()
        
    }
    
}


extension NotificationVC: ASTableDataSource {
    
    func tableNode(_ tableNode: ASTableNode, numberOfRowsInSection section: Int) -> Int {
        
        if self.UserNotificationList.count == 0 {
            
            tableNode.view.setEmptyMessage("No active notification")
            
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
    
    func hideAnimation() {
        
        if firstAnimated {
            
            firstAnimated = false
            
            UIView.animate(withDuration: 0.5) {
                
                Dispatch.main.async {
                    self.loadingView.alpha = 0
                }
                
            }
            
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                
                if self.loadingView.alpha == 0 {
                    
                    self.loadingView.isHidden = true
                    
                }
                
            }
            
            
        }
        
    }
    
}
