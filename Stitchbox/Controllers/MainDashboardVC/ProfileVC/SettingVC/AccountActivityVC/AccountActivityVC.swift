//
//  AccountActivityVC.swift
//  Stitchbox
//
//  Created by Khoi Nguyen on 1/17/23.
//

import UIKit
import AsyncDisplayKit
import FLAnimatedImage

class AccountActivityVC: UIViewController {

    let backButton: UIButton = UIButton(type: .custom)
    
    
    var tableNode: ASTableNode!
    var UserActivityList = [UserActivityModel]()
    var item: UserActivityModel!
    
    @IBOutlet weak var contentView: UIView!
    
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

extension AccountActivityVC {
    
    func setupTableNode() {
        
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
        
    }
    
    func applyStyle() {
        
        self.tableNode.view.separatorStyle = .none
        self.tableNode.view.separatorColor = UIColor.lightGray
        self.tableNode.view.isPagingEnabled = false
        self.tableNode.view.backgroundColor = UIColor.clear
        self.tableNode.view.showsVerticalScrollIndicator = false
        
        //
     
        
    }
    
    func wireDelegates() {
        
        self.tableNode.delegate = self
        self.tableNode.dataSource = self
        
        //
    }
    
    
}

extension AccountActivityVC {
    
    func setupButtons() {
        
        setupBackButton()
       
        
    }
    
    
    func setupBackButton() {
        
        
        // Do any additional setup after loading the view.
        backButton.setImage(UIImage.init(named: "back_icn_white")?.resize(targetSize: CGSize(width: 13, height: 23)), for: [])
        backButton.addTarget(self, action: #selector(onClickBack(_:)), for: .touchUpInside)
        backButton.frame = back_frame
        backButton.setTitleColor(UIColor.white, for: .normal)
        backButton.setTitle("     Account Activity", for: .normal)
        backButton.sizeToFit()
        let backButtonBarButton = UIBarButtonItem(customView: backButton)
    
        self.navigationItem.leftBarButtonItem = backButtonBarButton
       
    }

    
    @objc func onClickBack(_ sender: AnyObject) {
        if let navigationController = self.navigationController {
            navigationController.popViewController(animated: true)
        }
    }
    
    
}

extension AccountActivityVC: ASTableDelegate {

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
        
        self.retrieveNextPageWithCompletion { (newUsers) in
            
            self.insertNewRowsInTableNode(newUsers: newUsers)
            
            context.completeBatchFetching(true)
            
        }
        
    }
       
    
}

extension AccountActivityVC: ASTableDataSource {
    
    func tableNode(_ tableNode: ASTableNode, numberOfRowsInSection section: Int) -> Int {
        
        
        if self.UserActivityList.count == 0 {
            
            tableNode.view.setEmptyMessage("No activity")
            
        } else {
            tableNode.view.restore()
        }
        
        return self.UserActivityList.count
        
        
    }
    
    func tableNode(_ tableNode: ASTableNode, nodeBlockForRowAt indexPath: IndexPath) -> ASCellNodeBlock {
        
        let activity = self.UserActivityList[indexPath.row]
       
        return {
            
            let node = AccountActivityNode(with: activity)
            node.neverShowPlaceholders = true
            node.debugName = "Node \(indexPath.row)"
            
            return node
        }
        
    }
    
    
    func tableNode(_ tableNode: ASTableNode, didSelectRowAt indexPath: IndexPath) {
          
        
        let activity = UserActivityList[indexPath.row]
        
        
    }
    

        
}


extension AccountActivityVC {
    
    func retrieveNextPageWithCompletion( block: @escaping ([AnyObject]) -> Void) {
        
        DispatchQueue.main.async {
            //block(items!)
        }
                
    }
    
    
    
    func insertNewRowsInTableNode(newUsers: [AnyObject]) {
        
        guard newUsers.count > 0 else {
            return
        }
        
        
        
    }
    
    
}
