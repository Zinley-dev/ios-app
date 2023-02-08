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
    var inSearchMode = false
    var tableNode: ASTableNode!
    var searchUserList = [FollowerModel]()
    var userList = [FollowerModel]()
    var followingList = [FollowerModel]()
    var asContext: ASBatchContext!
    
    required init?(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
        self.tableNode = ASTableNode(style: .plain)
        self.wireDelegates()
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //must happen before setting up tablenode otherwise data is not enough to render
        bindingUI()
        setupTableNode()
        // Do any additional setup after loading the view.
        
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
        viewModel.output.allFollowingListObservable.subscribe(onNext: {
            list in
            print("All Following: ",list)
            self.followingList = list
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
//        self.viewModel.getAllFollowing() //get all following
        self.viewModel.getFollowers(page: currPage)
        
    }
    
    func tableNode(_ tableNode: ASTableNode, didSelectRowAt indexPath: IndexPath) {
        
    }
    
}

extension FollowerVC: ASTableDataSource {
    
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
        //let array = inSearchMode ? searchChannelList : channels
        let user = inSearchMode ? searchUserList[indexPath.row] : userList[indexPath.row]
        
        return {
            var node: FollowNode!
            // if user in the following list, this should be a following node.
            let isFollowing = !self.followingList.contains{$0.userId == user.userId}
            print("-------------")
            print(self.followingList)
            print(user)
            print("-------------")
            if isFollowing {
                
            }
            user.action = isFollowing ? "Follower" : "Following"
            node = FollowNode(with: user)
            node.followAction = {
                item in
                if isFollowing {self.follow(item: item) }
                else { self.unfollow(item: item)}
            }
            
            
            node.neverShowPlaceholders = true
            node.debugName = "Node \(indexPath.row)"
            
            return node
        }
        
    }
    
}

extension FollowerVC {
    
    func follow(item: FollowNode) {
        self.viewModel.insertfollow(userId: item.user.userId ?? "")
        item.followAction = unfollow
        item.followBtnNode.backgroundColor = UIColor.primary
        item.followBtnNode.setTitle("Unfollow", with: UIFont(name: "Avenir-Medium", size: 13)!, with: UIColor.white, for: .normal)
        
    }
    func unfollow(item: FollowNode) {
        self.viewModel.unfollow(userId: item.user.userId ?? "")
        item.followAction = follow
        item.followBtnNode.backgroundColor = UIColor.white
        item.followBtnNode.setTitle("+ Follow", with: UIFont(name: "Avenir-Medium", size: 13)!, with: UIColor.primary, for: .normal)
    }
    
    
}

