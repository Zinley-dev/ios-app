//
//  BlockedListVC.swift
//  Stitchbox
//
//  Created by Khoi Nguyen on 1/17/23.
//

import UIKit
import Alamofire
import AsyncDisplayKit
import RxSwift


class BlockedListVC: UIViewController, ControllerType {
    typealias ViewModelType = BlockAccountsViewModel
    
    let backButton: UIButton = UIButton(type: .custom)
    
    let group = DispatchGroup()
    
    @IBOutlet weak var contentView: UIView!
    var BlockList = [BlockUserModel]()
    var tableNode: ASTableNode!
    
    let viewModel = BlockAccountsViewModel()
    var currentPage = 1
    let disposeBag = DisposeBag()
    
    required init?(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
        self.tableNode = ASTableNode(style: .plain)
        self.wireDelegates()
        
    }
    
    override func viewDidLoad() {
        bindUI(with: viewModel)
        bindAction(with: viewModel)
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        setupButtons()
        setupTableNode()
        
    }
    
    func bindUI(with viewModel: BlockAccountsViewModel) {
        
    }
    
    func bindAction(with viewModel: BlockAccountsViewModel) {
        viewModel.input.blockAccounts.subscribe{ blockUsers in
            self.insertNewRowsInTableNode(newUsers: blockUsers)
        }.disposed(by: disposeBag)
        
        viewModel.output.successObservable.subscribe{
            result in
            DispatchQueue.main.async {
                switch result.element{
                case .unblock(let message):
                    showNote(text: message)
                case .unfollow(let message):
                    showNote(text: message)
                case .follow(let message):
                    showNote(text: message)
                default:
                    break
                }
            }
        }.disposed(by: disposeBag)
        
        viewModel.output.errorsObservable.subscribe{ (error) in
            DispatchQueue.main.async {
                showNote(text: error)
            }
        }.disposed(by: disposeBag)
    }
    
}

extension BlockedListVC {
    
    func setupButtons() {
        
        setupBackButton()
        
    }
    
    
    func setupBackButton() {
        
        // Do any additional setup after loading the view.
        backButton.setImage(UIImage.init(named: "back_icn_white")?.resize(targetSize: CGSize(width: 13, height: 23)), for: [])
        backButton.addTarget(self, action: #selector(onClickBack(_:)), for: .touchUpInside)
        backButton.frame = back_frame
        backButton.setTitleColor(UIColor.white, for: .normal)
        backButton.setTitle("     Blocked List", for: .normal)
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

extension BlockedListVC {
    
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

extension BlockedListVC: ASTableDelegate {
    
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
        self.retrieveNextPageWithCompletion {
            
            context.completeBatchFetching(true)
            
        }
        
    }
    
    
}

extension BlockedListVC: ASTableDataSource {
    
    func tableNode(_ tableNode: ASTableNode, numberOfRowsInSection section: Int) -> Int {
        
        if self.BlockList.count == 0 {
            
            tableNode.view.setEmptyMessage("No blocked user!")
            
        } else {
            tableNode.view.restore()
        }
        
        return self.BlockList.count
        
        
    }
    
    func tableNode(_ tableNode: ASTableNode, nodeBlockForRowAt indexPath: IndexPath) -> ASCellNodeBlock {
        
        let user = self.BlockList[indexPath.row]
        
        return {
            
            let node = BlockNode(with: user)
            node.UnBlockAction = {
                self.viewModel.unblock(blockId: user.blockId) {
                    node.user.isBlock = false
                    node.user.isFollowing = false
                    // reload node from table
                    DispatchQueue.main.async {
                        self.tableNode.reloadRows(at: [indexPath], with: .none)
                        
                    }
                }
            }
            node.FollowAction = {
                self.viewModel.follow(userId: user.userId) {
                    node.user.isBlock = false
                    node.user.isFollowing = true
                    // reload node from table
                    DispatchQueue.main.async {
                        self.tableNode.reloadRows(at: [indexPath], with: .none)
                    }
                }
            }
            node.UnfollowAction = {
                self.viewModel.unfollow(userId: user.userId) {
                    node.user.isBlock = false
                    node.user.isFollowing = false
                    // reload node from table
                    DispatchQueue.main.async {
                        self.tableNode.reloadRows(at: [indexPath], with: .none)
                    }
                }
            }
            node.neverShowPlaceholders = true
            node.debugName = "Node \(indexPath.row)"
            
            return node
        }
        
    }
    
}

extension BlockedListVC {
    
    func retrieveNextPageWithCompletion( block: @escaping () -> Void) {
        
        viewModel.getBlocks(page: currentPage) { [self] in
            currentPage += 1
            block()
        }
        
    }
    
    
    func insertNewRowsInTableNode(newUsers: [BlockUserModel]) {
        
        guard newUsers.count > 0 else {
            return
        }
        
        let section = 0
        var indexPaths: [IndexPath] = []
        let total = BlockList.count + newUsers.count
        
        for row in BlockList.count ... total - 1 {
            let path = IndexPath(row: row, section: section)
            indexPaths.append(path)
        }
        BlockList.append(contentsOf: newUsers)
        DispatchQueue.main.async {
            self.tableNode.insertRows(at: indexPaths, with: .none)
        }
        
        
    }
    
    
}
