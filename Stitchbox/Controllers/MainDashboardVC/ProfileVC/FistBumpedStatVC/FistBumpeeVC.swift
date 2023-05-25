//
//  fistBumpeeVC.swift
//  Stitchbox
//
//  Created by Khanh Duy Nguyen on 2/6/23.
//

import Foundation
import UIKit
import Alamofire
import AsyncDisplayKit

class FistBumpeeVC: UIViewController {
    
    let backButton: UIButton = UIButton(type: .custom)
    
    let group = DispatchGroup()
    
    @IBOutlet weak var contentView: UIView!
    var fistBumpList = [FistBumpUserModel]()
    var tableNode: ASTableNode!
    var currPage = 1
    var inSearchMode = false
    var searchUserList = [FistBumpUserModel]()
    
    required init?(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
        self.tableNode = ASTableNode(style: .plain)
        self.wireDelegates()
        
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        setupButtons()
        setupTableNode()
        
    }

}

extension FistBumpeeVC {
    
    func setupButtons() {
        
        setupBackButton()
        
    }
    
    func setupBackButton() {
    
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

        backButton.addTarget(self, action: #selector(onClickBack(_:)), for: .touchUpInside)
        backButton.setTitleColor(UIColor.white, for: .normal)
        navigationItem.title = "FistBumped List"
        let backButtonBarButton = UIBarButtonItem(customView: backButton)

        self.navigationItem.leftBarButtonItem = backButtonBarButton
        
    }

    
    @objc func onClickBack(_ sender: AnyObject) {
        if let navigationController = self.navigationController {
            navigationController.popViewController(animated: true)
        }
    }
    
    
}

extension FistBumpeeVC {
    
    func setupTableNode() {
        
        contentView.addSubview(tableNode.view)
        
        self.tableNode.view.translatesAutoresizingMaskIntoConstraints = false
        self.tableNode.view.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 0).isActive = true
        self.tableNode.view.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 0).isActive = true
        self.tableNode.view.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: 0).isActive = true
        self.tableNode.view.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: 0).isActive = true
        
        self.applyStyle()
        self.tableNode.leadingScreensForBatching = 1.0
        self.tableNode.automaticallyRelayoutOnLayoutMarginsChanges = true
        self.tableNode.automaticallyAdjustsContentOffset = true
        
        
    }
    
    
    func applyStyle() {
        
        self.tableNode.view.separatorStyle = .none
        self.tableNode.view.separatorColor = UIColor.lightGray
        self.tableNode.view.isPagingEnabled = true
        self.tableNode.view.backgroundColor = UIColor.clear
        self.tableNode.view.showsVerticalScrollIndicator = false
        
        
    }
    
    func wireDelegates() {
        
        self.tableNode.delegate = self
        self.tableNode.dataSource = self
        
        //
    }
    
}

extension FistBumpeeVC: ASTableDelegate {
    
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
        print("batchfetching start")
        self.retrieveNextPageWithCompletion { (newFollowees) in
            
            self.insertNewRowsInTableNode(newFistBumpees: newFollowees)
            
            context.completeBatchFetching(true)
            
        }
        
    }
    
    
}

extension FistBumpeeVC: ASTableDataSource {
    
    func tableNode(_ tableNode: ASTableNode, numberOfRowsInSection section: Int) -> Int {
        
        if self.fistBumpList.count == 0 {
            
            tableNode.view.setEmptyMessage("No fistbumpees!")
            
        } else {
            tableNode.view.restore()
        }
        
        return inSearchMode ? searchUserList.count : fistBumpList.count
        
        
    }
    
    func tableNode(_ tableNode: ASTableNode, nodeBlockForRowAt indexPath: IndexPath) -> ASCellNodeBlock {
        
        let user = inSearchMode ? searchUserList[indexPath.row] : fistBumpList[indexPath.row]
        
        return {
            
            let node = FistBumpNode(with: user)
            node.neverShowPlaceholders = true
            node.debugName = "Node \(indexPath.row)"
            
            return node
        }
        
    }
    
    func tableNode(_ tableNode: ASTableNode, didSelectRowAt indexPath: IndexPath) {
        
        let user = inSearchMode ? searchUserList[indexPath.row] : fistBumpList[indexPath.row]
        
        if let UPVC = UIStoryboard(name: "Dashboard", bundle: nil).instantiateViewController(withIdentifier: "UserProfileVC") as? UserProfileVC {
            //self.hidesBottomBarWhenPushed = true
            UPVC.userId = user.userID
            UPVC.nickname = user.userName
            self.navigationController?.pushViewController(UPVC, animated: true)
            
        }
        
    }
    
}

extension FistBumpeeVC {
    
    func retrieveNextPageWithCompletion(block: @escaping ([[String: Any]]) -> Void) {
        
            APIManager().getFistBumpee(page: currPage) { result in
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
                        self.currPage += 1
                        print("Successfully retrieved \(data.count) fistBumpees.")
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
    
    func insertNewRowsInTableNode(newFistBumpees: [[String: Any]]) {
        
        guard newFistBumpees.count > 0 else {
            return
        }
        
        let section = 0
        var items = [FistBumpUserModel]()
        var indexPaths: [IndexPath] = []
        let total = self.fistBumpList.count + newFistBumpees.count
        
        for row in self.fistBumpList.count...total-1 {
            let path = IndexPath(row: row, section: section)
            indexPaths.append(path)
        }
        
        for i in newFistBumpees {

            let item = FistBumpUserModel(JSON: i)
            items.append(item!)
          
        }
        
    
        self.fistBumpList.append(contentsOf: items)
        self.tableNode.insertRows(at: indexPaths, with: .none)
        
    }
 
    
}
