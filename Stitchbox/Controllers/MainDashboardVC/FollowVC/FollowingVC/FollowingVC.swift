//
//  FollowingVC.swift
//  Stitchbox
//
//  Created by Khoi Nguyen on 1/24/23.
//

import UIKit
import Alamofire
import AsyncDisplayKit
import SendBirdUIKit

class FollowingVC: UIViewController {

    @IBOutlet weak var contentView: UIView!
    
    var tableNode: ASTableNode!
    var userList = [UserActionModel]()
    
    
    required init?(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
        self.tableNode = ASTableNode(style: .plain)
        self.wireDelegates()
  
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

}

extension FollowingVC {
    
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
    
extension FollowingVC: ASTableDelegate {

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
            
        
            
    }
    
    func tableNode(_ tableNode: ASTableNode, didSelectRowAt indexPath: IndexPath) {
        
        
     
        
    }
           
}
    
extension FollowingVC: ASTableDataSource {
        
    func tableNode(_ tableNode: ASTableNode, numberOfRowsInSection section: Int) -> Int {
            
            
        if self.userList.count == 0 {
            
            tableNode.view.setEmptyMessage("No follower")
            
        } else {
            tableNode.view.restore()
        }
        
        return self.userList.count
            
            
    }
        
    func tableNode(_ tableNode: ASTableNode, nodeBlockForRowAt indexPath: IndexPath) -> ASCellNodeBlock {
            
        let user = userList[indexPath.row]
            
        return {
            var node: FollowNode!
            
            node = FollowNode(with: user)
            node.neverShowPlaceholders = true
            node.debugName = "Node \(indexPath.row)"
            
            return node
        }
            
    }
        

            
}
    
extension FollowingVC {
    
    func retrieveNextPageWithCompletion( block: @escaping ([AnyObject]) -> Void) {
        
       
                
    }
    

    func insertNewRowsInTableNode(newUsers: [AnyObject]) {
        
        guard newUsers.count > 0 else {
            return
        }
        
        
        
    }
    
    
}
