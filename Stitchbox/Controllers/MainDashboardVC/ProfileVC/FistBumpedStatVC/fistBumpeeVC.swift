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
import RxSwift


class fistBumpeeVC: UIViewController, ControllerType {
    typealias ViewModelType = FistBumpViewModel
    
    let backButton: UIButton = UIButton(type: .custom)
    
    let group = DispatchGroup()
    
    @IBOutlet weak var contentView: UIView!
    var FistBumpList = [FistBumpUserModel]()
    var tableNode: ASTableNode!
    var viewModel = FistBumpViewModel()
    var currentPage = 1
    let disposeBag = DisposeBag()
    var inSearchMode = false
    var searchUserList = [FistBumpUserModel]()
    
    required init?(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
        self.tableNode = ASTableNode(style: .plain)
        self.wireDelegates()
        
    }
    
    init(userID: String){
        super.init(nibName: nil, bundle: nil)
        viewModel = FistBumpViewModel(userID: userID)
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
    
    func bindUI(with viewModel: FistBumpViewModel) {
        
    }
    
    func bindAction(with viewModel: FistBumpViewModel) {
        viewModel.input.fistBumpeeAccounts.subscribe{ FistBumpUsers in
            self.insertNewRowsInTableNode(newUsers: FistBumpUsers)
        }.disposed(by: disposeBag)
        
        viewModel.output.successObservable.subscribe{
            result in
            DispatchQueue.main.async {
                switch result.element {
                case .fistbump(let message):
                    showNote(text: message)
                case .unfistbump(let message):
                    showNote(text: message)
                case .follow(let message):
                    showNote(text: message)
                case .unfollow(let message):
                    showNote(text: message)
                case .none:
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

extension fistBumpeeVC {
    
    func setupButtons() {
        
        setupBackButton()
        
    }
    
    
    func setupBackButton() {
        
        // Do any additional setup after loading the view.
        backButton.setImage(UIImage.init(named: "back_icn_white")?.resize(targetSize: CGSize(width: 13, height: 23)), for: [])
        backButton.addTarget(self, action: #selector(onClickBack(_:)), for: .touchUpInside)
        backButton.frame = back_frame
        backButton.setTitleColor(UIColor.white, for: .normal)
        backButton.setTitle("     FistBumped List", for: .normal)
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

extension fistBumpeeVC {
    
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

extension fistBumpeeVC: ASTableDelegate {
    
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

extension fistBumpeeVC: ASTableDataSource {
    
    func tableNode(_ tableNode: ASTableNode, numberOfRowsInSection section: Int) -> Int {
        
        if self.FistBumpList.count == 0 {
            
            tableNode.view.setEmptyMessage("No fist-bumped user!")
            
        } else {
            tableNode.view.restore()
        }
        
        return inSearchMode ? searchUserList.count : FistBumpList.count
        
        
    }
    
    func tableNode(_ tableNode: ASTableNode, nodeBlockForRowAt indexPath: IndexPath) -> ASCellNodeBlock {
        
        let user = inSearchMode ? searchUserList[indexPath.row] : FistBumpList[indexPath.row]
        
        return {
            
            let node = FistBumpNode(with: user)
            node.FollowAction = {
                self.viewModel.follow(userId: user.userID) {
                    node.user.isFollowing = true
                    // reload node from table
                    DispatchQueue.main.async {
                        self.tableNode.reloadRows(at: [indexPath], with: .none)
                    }
                }
            }
            node.UnfollowAction = {
                self.viewModel.unfollow(userId: user.userID) {
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
    
    func tableNode(_ tableNode: ASTableNode, didSelectRowAt indexPath: IndexPath) {
        
        let user = inSearchMode ? searchUserList[indexPath.row] : FistBumpList[indexPath.row]
        
        if let UPVC = UIStoryboard(name: "Dashboard", bundle: nil).instantiateViewController(withIdentifier: "UserProfileVC") as? UserProfileVC {
            //self.hidesBottomBarWhenPushed = true
            UPVC.userId = user.userID
            UPVC.nickname = user.userName
            self.navigationController?.pushViewController(UPVC, animated: true)
            
        }
        
    }
    
}

extension fistBumpeeVC {
    
    func retrieveNextPageWithCompletion( FistBump: @escaping () -> Void) {
        
        viewModel.getFistBumpee(page: currentPage) { [self] in
            currentPage += 1
            FistBump()
        }
        
    }
    
    
    func insertNewRowsInTableNode(newUsers: [FistBumpUserModel]) {
        
        guard newUsers.count > 0 else {
            return
        }
        
        let section = 0
        var indexPaths: [IndexPath] = []
        let total = FistBumpList.count + newUsers.count
        
        for row in FistBumpList.count ... total - 1 {
            let path = IndexPath(row: row, section: section)
            indexPaths.append(path)
        }
        FistBumpList.append(contentsOf: newUsers)
        DispatchQueue.main.async {
            self.tableNode.insertRows(at: indexPaths, with: .none)
        }
        
        
    }
    
    
}
