//
//  FistBumpListVC.swift
//  Stitchbox
//
//  Created by Khanh Duy Nguyen on 2/6/23.
//

import UIKit
import Alamofire
import AsyncDisplayKit
import RxSwift


class fistBumperVC: UIViewController, ControllerType {
    typealias ViewModelType = FistBumpViewModel
    
    let backButton: UIButton = UIButton(type: .custom)
    
    let group = DispatchGroup()
    
    @IBOutlet weak var contentView: UIView!
    var FistBumpList = [FistBumpUserModel]()
    var tableNode: ASTableNode!
    var viewModel = FistBumpViewModel()
    var currentPage = 1
    let disposeBag = DisposeBag()
    
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
        viewModel.input.fistBumperAccounts.subscribe{ FistBumpUsers in
            print(FistBumpUsers)
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

extension fistBumperVC {
    
    func setupButtons() {
        
        setupBackButton()
        
    }
    
    
    func setupBackButton() {
        
        // Do any additional setup after loading the view.
        backButton.setImage(UIImage.init(named: "back_icn_white")?.resize(targetSize: CGSize(width: 13, height: 23)), for: [])
        backButton.addTarget(self, action: #selector(onClickBack(_:)), for: .touchUpInside)
        backButton.frame = CGRect(x: -10, y: 0, width: 15, height: 25)
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

extension fistBumperVC {
    
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

extension fistBumperVC: ASTableDelegate {
    
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

extension fistBumperVC: ASTableDataSource {
    
    func tableNode(_ tableNode: ASTableNode, numberOfRowsInSection section: Int) -> Int {
        
        if self.FistBumpList.count == 0 {
            
            tableNode.view.setEmptyMessage("No FistBumped user!")
            
        } else {
            tableNode.view.restore()
        }
        
        return self.FistBumpList.count
        
        
    }
    
    func tableNode(_ tableNode: ASTableNode, nodeBlockForRowAt indexPath: IndexPath) -> ASCellNodeBlock {
        
        let user = self.FistBumpList[indexPath.row]
        
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
    
}

extension fistBumperVC {
    
    func retrieveNextPageWithCompletion( FistBump: @escaping () -> Void) {
        
        viewModel.getFistBumper(page: currentPage) { [self] in
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
extension fistBumperVC {
    
}
