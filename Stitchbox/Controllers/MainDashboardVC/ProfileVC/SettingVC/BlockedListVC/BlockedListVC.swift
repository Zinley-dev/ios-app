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
    
    @IBOutlet weak var contentView: UIView!
    var BlockList = [BlockUserModel]()
    var tableNode: ASTableNode!
    
    let viewModel = BlockAccountsViewModel()
    let disposeBag = DisposeBag()
    
    required init?(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
        self.tableNode = ASTableNode(style: .plain)
        self.wireDelegates()
        
    }
    
    override func viewDidLoad() {
        bindUI(with: viewModel)
        bindAction(with: viewModel)
        viewModel.getAPISetting()
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        setupButtons()
        setupTableNode()
        
    }
    
    func bindUI(with viewModel: BlockAccountsViewModel) {
        
    }
    
    func bindAction(with viewModel: BlockAccountsViewModel) {
        viewModel.input.blockAccounts.subscribe{ blockUsers in
            self.BlockList = blockUsers.element ?? [BlockUserModel]()
            print(self.BlockList)
            DispatchQueue.main.async {
                self.tableNode.reloadData()
            }
            
        }.disposed(by: disposeBag)
        
        
        viewModel.output.successObservable.subscribe{
            result in
            DispatchQueue.main.async {
                showNote(text: result)
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
        backButton.frame = CGRect(x: -10, y: 0, width: 15, height: 25)
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
        
        self.retrieveNextPageWithCompletion { (newUsers) in
            
            self.insertNewRowsInTableNode(newUsers: newUsers)
            
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
            node.neverShowPlaceholders = true
            node.debugName = "Node \(indexPath.row)"
            
            return node
        }
        
    }
    
}

extension BlockedListVC {
    
    func retrieveNextPageWithCompletion( block: @escaping ([AnyObject]) -> Void) {
        
        DispatchQueue.main.async {
            
        }
        
    }
    
    
    func insertNewRowsInTableNode(newUsers: [AnyObject]) {
        
        guard newUsers.count > 0 else {
            return
        }
        
        
    }
    
    
}
