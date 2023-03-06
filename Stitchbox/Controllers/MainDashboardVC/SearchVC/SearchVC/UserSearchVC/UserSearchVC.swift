//
//  UserSearchVC.swift
//  Stitchbox
//
//  Created by Khoi Nguyen on 3/6/23.
//

import UIKit
import Alamofire
import AsyncDisplayKit
import FLAnimatedImage

class UserSearchVC: UIViewController {

    var tableNode: ASTableNode!
    var searchUserList = [UserSearchModel]()
    @IBOutlet weak var contentview: UIView!
    
    required init?(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
        self.tableNode = ASTableNode(style: .plain)
        self.wireDelegates()
  
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        contentview.addSubview(tableNode.view)
        self.applyStyle()

        self.tableNode.automaticallyRelayoutOnLayoutMarginsChanges = true
        self.tableNode.automaticallyAdjustsContentOffset = true
        
    }
    
    override func viewWillLayoutSubviews() {
        
        super.viewWillLayoutSubviews()
        self.tableNode.frame = contentview.bounds
       
    }
    
    func searchUsers(searchText: String) {
        
        
    }
    


}

extension UserSearchVC {
    
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

extension UserSearchVC: ASTableDelegate {

    func tableNode(_ tableNode: ASTableNode, constrainedSizeForRowAt indexPath: IndexPath) -> ASSizeRange {
        
        let width = UIScreen.main.bounds.size.width;
        
        let min = CGSize(width: width, height: 40);
        let max = CGSize(width: width, height: 1000);
        return ASSizeRangeMake(min, max);
           
    }
    
    
    func shouldBatchFetch(for tableNode: ASTableNode) -> Bool {
        return false
    }
    
    func tableNode(_ tableNode: ASTableNode, didSelectRowAt indexPath: IndexPath) {
        
        
    }
}

extension UserSearchVC: ASTableDataSource {
    
    func tableNode(_ tableNode: ASTableNode, numberOfRowsInSection section: Int) -> Int {
        return self.searchUserList.count
    }
    
    func tableNode(_ tableNode: ASTableNode, nodeBlockForRowAt indexPath: IndexPath) -> ASCellNodeBlock {
        guard self.searchUserList.count > indexPath.row else { return { ASCellNode() } }
        let user = self.searchUserList[indexPath.row]
        
        let cellNodeBlock = { () -> ASCellNode in
            let cellNode = UserSearchNode(with: user)
            return cellNode
        }
        
        return cellNodeBlock
    }
    
        
}
