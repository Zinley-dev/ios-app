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
    @IBOutlet weak var loadingImage: FLAnimatedImageView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var loadingView: UIView!
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
        
        
        pullControl.tintColor = UIColor.systemOrange
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
        
        do {
            
            let path = Bundle.main.path(forResource: "fox2", ofType: "gif")!
            let gifData = try NSData(contentsOfFile: path) as Data
            let image = FLAnimatedImage(animatedGIFData: gifData)
            
            
            self.loadingImage.animatedImage = image
            
        } catch {
            print(error.localizedDescription)
        }
        
        loadingView.backgroundColor = self.view.backgroundColor
        
        
        delay(1.0) {
            
            UIView.animate(withDuration: 0.5) {
                
                self.loadingView.alpha = 0
                
            }
            
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                
                if self.loadingView.alpha == 0 {
                    
                    self.loadingView.isHidden = true
                    
                }
                
            }
            
        }
        
    }
    

}

extension LoginActivityVC {
    
    func setupButtons() {
        
        setupBackButton()
       
    }
    
    func setupBackButton() {
        
        
        // Do any additional setup after loading the view.
        backButton.setImage(UIImage.init(named: "back_icn_white")?.resize(targetSize: CGSize(width: 13, height: 23)), for: [])
        backButton.addTarget(self, action: #selector(onClickBack(_:)), for: .touchUpInside)
        backButton.frame = back_frame
        backButton.setTitleColor(UIColor.white, for: .normal)
        backButton.setTitle("     Login Activity", for: .normal)
        backButton.sizeToFit()
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
    
    
    func updateData() {
        self.retrieveNextPageWithCompletion { (newActivities) in
                
            if newActivities.count > 0 {
                        
                self.insertNewRowsInTableNode(newActivities: newActivities)
                
            } else {
              
                self.refresh_request = false
                self.userLoginActivityList.removeAll()
                self.tableNode.reloadData()
                
                if self.userLoginActivityList.isEmpty == true {
                    
                    self.tableNode.view.setEmptyMessage("No active notification")
                    
                } else {
                    
                    self.tableNode.view.restore()
                    
                }
                
            }
            
            if self.pullControl.isRefreshing == true {
                self.pullControl.endRefreshing()
            }
            
            self.delayItem.perform(after: 0.75) {
                
                self.tableNode.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
                    
            }
              
          
        }
        
        
    }
    

}

extension LoginActivityVC {
    
    func applyStyle() {
        
        self.tableNode.view.separatorStyle = .none
        self.tableNode.view.separatorColor = UIColor.lightGray
        self.tableNode.view.isPagingEnabled = false
        self.tableNode.view.backgroundColor = .background
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
        
            APIManager().getLoginActivity(page: page) { result in
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
                        print("Successfully retrieved \(data.count) activities.")
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
     
    func insertNewRowsInTableNode(newActivities: [[String: Any]]) {
        // Check if there are new posts to insert
        guard !newActivities.isEmpty else { return }
        
        // Check if a refresh request has been made
        if refresh_request {
            refresh_request = false
            
            // Delete existing rows if there are any
            let numExistingItems = userLoginActivityList.count
            if numExistingItems > 0 {
                let deleteIndexPaths = (0..<numExistingItems).map { IndexPath(row: $0, section: 0) }
                userLoginActivityList.removeAll()
                tableNode.deleteRows(at: deleteIndexPaths, with: .automatic)
            }
        }

        // Calculate the range of new rows
        let startIndex = userLoginActivityList.count
        let endIndex = startIndex + newActivities.count
        
        // Create an array of PostModel objects
        let newItems = newActivities.compactMap { UserLoginActivityModel(userLoginActivity: $0) }
        
        // Append the new items to the existing array
        userLoginActivityList.append(contentsOf: newItems)
        
        // Create an array of index paths for the new rows
        let insertIndexPaths = (startIndex..<endIndex).map { IndexPath(row: $0, section: 0) }
        
        // Insert the new rows
        tableNode.insertRows(at: insertIndexPaths, with: .automatic)
       
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
