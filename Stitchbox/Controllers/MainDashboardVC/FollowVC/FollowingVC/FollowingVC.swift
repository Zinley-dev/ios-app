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
import RxSwift

class FollowingVC: UIViewController {

    @IBOutlet weak var contentView: UIView!
    
    
    
    typealias ViewModelType = ProfileViewModel
    // MARK: - Properties
    private var currPage = 1
    private var viewModel: ViewModelType! = ViewModelType()
    private let disposeBag = DisposeBag()
    var inSearchMode = false
    var tableNode: ASTableNode!
    var searchUserList = [FollowerModel]()
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
        viewModel.output.followingListObservable.subscribe(onNext: { list in
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
            
        print("getFollowing......")
        asContext = context
        self.viewModel.getFollowing(page: currPage)
            
    }
    
    func tableNode(_ tableNode: ASTableNode, didSelectRowAt indexPath: IndexPath) {
        
        
     
        
    }
           
}
    
extension FollowingVC: ASTableDataSource {
        
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
            
        let user = inSearchMode ? searchUserList[indexPath.row] : userList[indexPath.row]
        
        return {
            var node: FollowNode!
            user.action = "Following"
            node = FollowNode(with: user)
            node.neverShowPlaceholders = true
            node.debugName = "Node \(indexPath.row)"
            node.followAction = { item in
                print("Pressed Id= \(item.user.userId) Name= \(item.user.username)")
                self.viewModel.unfollow(userId: item.user.userId ?? "")
                
            }
            return node
        }
            
    }
        

            
}

extension FollowingVC {
    func addVCAsChildVC(childViewController: UIViewController) {
        
        addChild(childViewController)
        contentView.addSubview(childViewController.view)
        
        childViewController.view.frame = contentView.bounds
        childViewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        childViewController.didMove(toParent: self)
        
        
    }
}
