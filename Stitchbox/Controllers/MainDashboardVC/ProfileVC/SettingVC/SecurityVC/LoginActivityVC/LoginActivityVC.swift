//
//  LoginActivityVC.swift
//  Stitchbox
//
//  Created by Khoi Nguyen on 1/18/23.
//

import UIKit
import FLAnimatedImage
import AsyncDisplayKit

class LoginActivityVC: UIViewController {
    
    let backButton: UIButton = UIButton(type: .custom)
    
    var page = 1
    @IBOutlet weak var contentView: UIView!
    private var pullControl = UIRefreshControl()
    
    var refresh_request = false
    var tableNode: ASTableNode!
    var userLoginActivityList = [UserLoginActivityModel]()
    
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

    
}

extension LoginActivityVC {
    
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
        navigationItem.title = "Login Activity"
        let backButtonBarButton = UIBarButtonItem(customView: backButton)
        
        self.navigationItem.leftBarButtonItem = backButtonBarButton
        
        
        
    }
    
    
    @objc func onClickBack(_ sender: AnyObject) {
        if let navigationController = self.navigationController {
            navigationController.popViewController(animated: true)
        }
    }
    
    func showErrorAlert(_ title: String, msg: String) {
        
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default)
        
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
        
    }
    
    
}



extension LoginActivityVC {
    
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
    
}

extension LoginActivityVC {
    
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

extension LoginActivityVC {
    
    func tableNode(_ tableNode: ASTableNode, didSelectRowAt indexPath: IndexPath) {
        
        let item = userLoginActivityList[indexPath.row]
        
        if let LIVC = UIStoryboard(name: "Dashboard", bundle: nil).instantiateViewController(withIdentifier: "LogInfomationVC") as? LogInfomationVC {
            
            LIVC.item = item
            self.navigationController?.pushViewController(LIVC, animated: true)
            
        }
    
    }
    
}


extension LoginActivityVC: ASTableDelegate {
    
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
            
            self.retrieveNextPageWithCompletion { (newActivities) in
                
                self.insertNewRowsInTableNode(newActivities: newActivities)
                
                context.completeBatchFetching(true)
                
            }
            
        } else {
            
            context.completeBatchFetching(true)
            
        }
    }

}


extension LoginActivityVC {
    
    func retrieveNextPageWithCompletion(block: @escaping ([[String: Any]]) -> Void) {
        
        APIManager.shared.getLoginActivity(page: page) { [weak self] result in
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

    func insertNewRowsInTableNode(newActivities: [[String: Any]]) {
        guard newActivities.count > 0 else { return }
        
        if refresh_request {
            clearExistingPosts()
            refresh_request = false
        }

        let items = newActivities.compactMap { UserLoginActivityModel(userLoginActivity: $0) }.filter { !self.userLoginActivityList.contains($0) }
        self.userLoginActivityList.append(contentsOf: items)
        
        if !items.isEmpty {
            let indexPaths = generateIndexPaths(for: items)
            tableNode.insertRows(at: indexPaths, with: .automatic)
        }
    }

    private func clearExistingPosts() {
        userLoginActivityList.removeAll()
        tableNode.reloadData()
    }

    private func generateIndexPaths(for items: [UserLoginActivityModel]) -> [IndexPath] {
        let startIndex = self.userLoginActivityList.count - items.count
        return (startIndex..<self.userLoginActivityList.count).map { IndexPath(row: $0, section: 0) }
    }

    func updateData() {
        self.retrieveNextPageWithCompletion { [weak self] (newNotis) in
            guard let self = self else { return }

            if self.pullControl.isRefreshing {
                self.pullControl.endRefreshing()
            }
            
            if newNotis.isEmpty {
                self.refresh_request = false
                self.userLoginActivityList.removeAll()
                self.tableNode.reloadData()
                if self.userLoginActivityList.isEmpty {
                    self.tableNode.view.setEmptyMessage("No active activity!")
                } else {
                    self.tableNode.view.restore()
                }
            } else {
                self.insertNewRowsInTableNode(newActivities: newNotis)
            }
        }
    }
    
}


extension LoginActivityVC: ASTableDataSource {
    
    func tableNode(_ tableNode: ASTableNode, numberOfRowsInSection section: Int) -> Int {
        
        if self.userLoginActivityList.count == 0 {
            
            tableNode.view.setEmptyMessage("No activity found")
            
        } else {
            tableNode.view.restore()
        }
        
        return self.userLoginActivityList.count
        
    }
    
    func tableNode(_ tableNode: ASTableNode, nodeBlockForRowAt indexPath: IndexPath) -> ASCellNodeBlock {
        
        let activity = self.userLoginActivityList[indexPath.row]
        
        return {
            
            let node = LoginActivityNode(with: activity)
            node.neverShowPlaceholders = true
            node.debugName = "Node \(indexPath.row)"
            
            return node
        }
        
    }
    
}
