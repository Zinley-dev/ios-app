//
//  ResolutionVC.swift
//  Stitchbox
//
//  Created by Khoi Nguyen on 8/11/23.
//

import UIKit
import AsyncDisplayKit
import FLAnimatedImage
import ObjectMapper

class ResolutionVC: UIViewController {
    
    deinit {
        print("AccountActivityVC is being deallocated.")
    }
    
    let backButton: UIButton = UIButton(type: .custom)
    var issueLists = [VideoIssueModel]()
    
    @IBOutlet weak var contentView: UIView!
    
    @IBOutlet weak var alertHeight: NSLayoutConstraint!
    @IBOutlet weak var alertLbl: UILabel!
    var page = 1
    private var pullControl = UIRefreshControl()
    
    var refresh_request = false
    var tableNode: ASTableNode!
    var userLoginActivityList = [UserLoginActivityModel]()
    
    lazy var delayItem = workItem()
    
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
        
        pullControl.tintColor = UIColor.systemOrange
        pullControl.addTarget(self, action: #selector(refreshListData(_:)), for: .valueChanged)
        
        if UIDevice.current.hasNotch {
            pullControl.bounds = CGRect(x: pullControl.bounds.origin.x, y: -50, width: pullControl.bounds.size.width, height: pullControl.bounds.size.height)
        }
        
        if #available(iOS 10.0, *) {
            tableNode.view.refreshControl = pullControl
        } else {
            tableNode.view.addSubview(pullControl)
        }
        
        
    }
    
}

extension ResolutionVC {
    
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


extension ResolutionVC {
    
    @objc private func refreshListData(_ sender: Any) {
        // self.pullControl.endRefreshing() // You can stop after API Call
        // Call API
        
        clearAllData()
        
    }
    
    @objc func clearAllData() {
        
        refresh_request = true
        page = 1
        updateData()
        
    }
    
    
}

extension ResolutionVC {
    
    func setupButtons() {
        
        setupBackButton()
        
        
    }
    
    func setupBackButton() {
        
        backButton.frame = back_frame
        backButton.contentMode = .center
        
        if let backImage = UIImage(named: "back-black") {
            let imageSize = CGSize(width: 13, height: 23)
            let padding = UIEdgeInsets(top: (back_frame.height - imageSize.height) / 2,
                                       left: (back_frame.width - imageSize.width) / 2 - horizontalPadding,
                                       bottom: (back_frame.height - imageSize.height) / 2,
                                       right: (back_frame.width - imageSize.width) / 2 + horizontalPadding)
            backButton.imageEdgeInsets = padding
            backButton.setImage(backImage, for: [])
        }
        
        backButton.addTarget(self, action: #selector(onClickBack(_:)), for: .touchUpInside)
        backButton.setTitleColor(UIColor.white, for: .normal)
        navigationItem.title = "Resolution center"
        let backButtonBarButton = UIBarButtonItem(customView: backButton)
        
        self.navigationItem.leftBarButtonItem = backButtonBarButton
        
        
        
    }
    
    
    @objc func onClickBack(_ sender: AnyObject) {
        if let navigationController = self.navigationController {
            navigationController.popViewController(animated: true)
        }
    }
    
    
}

extension ResolutionVC: ASTableDelegate {
    
    func tableNode(_ tableNode: ASTableNode, constrainedSizeForRowAt indexPath: IndexPath) -> ASSizeRange {
        
        let width = UIScreen.main.bounds.size.width;
        
        let min = CGSize(width: width, height: 30);
        let max = CGSize(width: width, height: 500);
        return ASSizeRangeMake(min, max);
        
    }
    
    
    func shouldBatchFetch(for tableNode: ASTableNode) -> Bool {
        
        return true
        
    }
    
    func tableNode(_ tableNode: ASTableNode, willBeginBatchFetchWith context: ASBatchContext) {
        
        if refresh_request == false {
            
            self.retrieveNextPageWithCompletion { (newIssues) in
                
                self.insertNewRowsInTableNode(newIssues: newIssues)
                
                context.completeBatchFetching(true)
                
            }
            
        } else {
            
            context.completeBatchFetching(true)
            
        }
        
        
    }
    
    func tableNode(_ tableNode: ASTableNode, didSelectRowAt indexPath: IndexPath) {
        
        let issue = issueLists[indexPath.row]
        
        if let RDVC = UIStoryboard(name: "Dashboard", bundle: nil).instantiateViewController(withIdentifier: "ResolutionDetailVC") as? ResolutionDetailVC {
            
            RDVC.detailIssue = issue
            self.navigationController?.pushViewController(RDVC, animated: true)

        }
        
    }
    
    
}


extension ResolutionVC {
    
    func retrieveNextPageWithCompletion(block: @escaping ([[String: Any]]) -> Void) {
        
        APIManager.shared.getModeration { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let apiResponse):
        
                if let data = apiResponse.body?["data"] as? [[String: Any]], !data.isEmpty {
                    print("Successfully retrieved \(data.count) posts.")
                    
                    DispatchQueue.main.async {
                        self.alertLbl.isHidden = false
                        self.alertHeight.constant = 100
                        block(data)
                    }
                } else {
                    self.completeWithEmptyData(block)
                }
            case .failure(let error):
                print(error)
                self.completeWithEmptyData(block)
            }
        }
        
    }

    private func completeWithEmptyData(_ block: @escaping ([[String: Any]]) -> Void) {
        DispatchQueue.main.async {
            self.alertLbl.isHidden = true
            self.alertHeight.constant = 0
            block([])
        }
    }

    func insertNewRowsInTableNode(newIssues: [[String: Any]]) {
        guard newIssues.count > 0 else { return }
        
        if refresh_request {
            clearExistingPosts()
            refresh_request = false
        }

        let items = newIssues.compactMap { VideoIssueModel(JSON: $0) }.filter { !self.issueLists.contains($0) }

        self.issueLists.append(contentsOf: items)
        
        if !items.isEmpty {
            let indexPaths = generateIndexPaths(for: items)
            tableNode.insertRows(at: indexPaths, with: .automatic)
        }
    }

    private func clearExistingPosts() {
        let deleteIndexPaths = issueLists.enumerated().map { IndexPath(row: $0.offset, section: 0) }
        issueLists.removeAll()
        tableNode.deleteRows(at: deleteIndexPaths, with: .automatic)
    }

    private func generateIndexPaths(for items: [VideoIssueModel]) -> [IndexPath] {
        let startIndex = self.issueLists.count - items.count
        return (startIndex..<self.issueLists.count).map { IndexPath(row: $0, section: 0) }
    }

    func updateData() {
        self.retrieveNextPageWithCompletion { [weak self] (newIssues) in
            guard let self = self else { return }

            if self.pullControl.isRefreshing {
                self.pullControl.endRefreshing()
            }
            
            if newIssues.isEmpty {
                self.refresh_request = false
                self.issueLists.removeAll()
                self.tableNode.reloadData()
                if self.issueLists.isEmpty {
                    self.tableNode.view.setEmptyMessage("No issue found!")
                } else {
                    self.tableNode.view.restore()
                }
            } else {
                self.insertNewRowsInTableNode(newIssues: newIssues)
            }
        }
    }
    
}


extension ResolutionVC: ASTableDataSource {
    
    func tableNode(_ tableNode: ASTableNode, numberOfRowsInSection section: Int) -> Int {
        
        if self.issueLists.count == 0 {
            
            tableNode.view.setEmptyMessage("No issue found!")
            
        } else {
            tableNode.view.restore()
        }
        
        return self.issueLists.count
        
    }
    
    func tableNode(_ tableNode: ASTableNode, nodeBlockForRowAt indexPath: IndexPath) -> ASCellNodeBlock {
        
        let newIssues = self.issueLists[indexPath.row]
        
        return {
            
            let node = VideoIssueNode(with: newIssues)
            node.neverShowPlaceholders = true
            node.debugName = "Node \(indexPath.row)"
            
            return node
        }
        
    }
    
}
