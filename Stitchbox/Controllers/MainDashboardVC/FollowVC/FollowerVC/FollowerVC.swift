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
import RxSwift

class FollowerVC: UIViewController {
    
    typealias ViewModelType = ProfileViewModel
    // MARK: - Properties
    private var currPage = 1
    private var viewModel: ViewModelType! = ViewModelType()
    private let disposeBag = DisposeBag()
    
    @IBOutlet weak var contentView: UIView!
    
    var tableNode: ASTableNode!
    var userList = [FollowerModel]()
    var asContext: ASBatchContext!
    
    required init?(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
        self.tableNode = ASTableNode(style: .plain)
        self.wireDelegates()
  
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableNode()
        // Do any additional setup after loading the view.
        bindingUI()
    }
    
    func bindingUI() {
        viewModel.output.followerListObservable.subscribe(onNext: { list in
            guard self.asContext != nil else  {
                return
            }

            guard list.count > 0 else {
                self.asContext.completeBatchFetching(true)
                return
            }

            let lastItemAt = self.userList.count
            let section = 0
            self.currPage += 1
            self.userList.append(contentsOf: list)
            
            var paths: [IndexPath] = []
            for row in lastItemAt...self.userList.count - 1 {
                let path = IndexPath(row: row, section: section)
                paths.append(path)
            }
            DispatchQueue.main.async {
                self.tableNode.insertRows(at: paths, with: .none)
                self.asContext.completeBatchFetching(true)
            }
            
        })
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
        print("getFollowers......")
        asContext = context
        self.viewModel.getFollowers(page: currPage)
    }
    
    func tableNode(_ tableNode: ASTableNode, didSelectRowAt indexPath: IndexPath) {
        
    }
           
}
    
extension FollowerVC: ASTableDataSource {
        
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
            node.followAction = { item in
                print("Pressed Id= \(item.user.userId) Name= \(item.user.username)")
//                if (item.user.status == "") {
//
//                }
            }
            
            return node
        }
            
    }
        

            
}
    
extension FollowerVC {
    
    func retrieveNextPageWithCompletion( block: @escaping ([AnyObject]) -> Void) {
        
    }
    

    func insertNewRowsInTableNode(newUsers: [AnyObject]) {
        
        guard newUsers.count > 0 else {
            return
        }
        
    }
    
    
}
