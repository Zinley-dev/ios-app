//
//  HashtagSearchVC.swift
//  Stitchbox
//
//  Created by Khoi Nguyen on 3/6/23.
//

import UIKit
import AsyncDisplayKit


class HashtagSearchVC: UIViewController {

    struct SearchRecord {
        let keyWord: String
        let timeStamp: Double
        let items: [HashtagsModel]
    }
    
    let EXPIRE_TIME = 20.0 //s
    var searchHist = [SearchRecord]()
    
    @IBOutlet weak var contentview: UIView!
    
    var tableNode: ASTableNode!
    var searchHashtagList = [HashtagsModel]()
    var prev_keyword = ""
    
    required init?(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
        self.tableNode = ASTableNode(style: .plain)
        self.wireDelegates()
  
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear

        // Do any additional setup after loading the view.
        
        view.addSubview(tableNode.view)
        self.applyStyle()

        self.tableNode.automaticallyRelayoutOnLayoutMarginsChanges = true
        self.tableNode.automaticallyAdjustsContentOffset = true

        
//        self.contentView.addGestureRecognizer(tapGesture)
    }
    
    override func viewWillLayoutSubviews() {
        
        super.viewWillLayoutSubviews()
        self.tableNode.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height - 235)
       
    }
    
    

}

extension HashtagSearchVC {
    
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
    
    func searchHashtags(searchText: String) {
        
        if prev_keyword == "" || prev_keyword != searchText {
            
            prev_keyword = searchText
            
            //check local result first
            if checkLocalRecords(searchText: searchText){
                return
            }
            
            APIManager.shared.searchHashtag(query: searchText) { [weak self] result in
                guard let self = self else { return }

                switch result {
                case .success(let apiResponse):
                    
                    guard let data = apiResponse.body?["data"] as? [[String: Any]] else {
                        return
                    }
                    
                    if !data.isEmpty {
                        
                        var newSearchList = [HashtagsModel]()
                        
                        for item in data {
                            newSearchList.append(HashtagsModel(type: "hashtag", hashtagModel: item))
                        }
                        
                        let newSearchRecord = SearchRecord(keyWord: searchText, timeStamp: Date().timeIntervalSince1970, items: newSearchList)
                        self.searchHist.append(newSearchRecord)
                        
                        if self.searchHashtagList != newSearchList {
                            self.searchHashtagList = newSearchList
                            DispatchQueue.main.async {
                                self.tableNode.reloadData()
                            }
                        }
                        
                    }
                    
                case .failure(let error):
                    
                    print(error)
                   
                }
            }
            
            
        }
        
        
    }
    
    func checkLocalRecords(searchText: String) -> Bool {
       
        for (i, record) in searchHist.enumerated() {
            if record.keyWord == searchText {
                print("time: \(Date().timeIntervalSince1970 - record.timeStamp)")
                if Date().timeIntervalSince1970 - record.timeStamp <= EXPIRE_TIME {
                    let retrievedSearchList = record.items
                    
                    if self.searchHashtagList != retrievedSearchList {
                        self.searchHashtagList = retrievedSearchList
                        DispatchQueue.main.async {
                            self.tableNode.reloadData(completion: nil)
                        }
                    }
                    return true
                } else {

                    searchHist.remove(at: i)
                }
            }
        }

        return false
    }
    
}

extension HashtagSearchVC: ASTableDelegate {

    func tableNode(_ tableNode: ASTableNode, constrainedSizeForRowAt indexPath: IndexPath) -> ASSizeRange {
        
        let width = UIScreen.main.bounds.size.width;
        
        let min = CGSize(width: width, height: 30);
        let max = CGSize(width: width, height: 1000);
        return ASSizeRangeMake(min, max);
           
    }
    
    
    func shouldBatchFetch(for tableNode: ASTableNode) -> Bool {
        
        return false
        
    }
   
}

extension HashtagSearchVC: ASTableDataSource {
    
    func tableNode(_ tableNode: ASTableNode, numberOfRowsInSection section: Int) -> Int {
        
        return self.searchHashtagList.count

    }
    
    func tableNode(_ tableNode: ASTableNode, nodeBlockForRowAt indexPath: IndexPath) -> ASCellNodeBlock {
        
        let hashtag = self.searchHashtagList[indexPath.row]
       
        return {
            
            let node = HashTagSearchNode(with: hashtag)
            node.neverShowPlaceholders = true
            node.debugName = "Node \(indexPath.row)"
            
            return node
        }
        
    }
    
    func tableNode(_ tableNode: ASTableNode, didSelectRowAt indexPath: IndexPath) {
        
        let selectedHashtag = searchHashtagList[indexPath.row]
        
        if let PLWHVC = UIStoryboard(name: "Dashboard", bundle: nil).instantiateViewController(withIdentifier: "PostListWithHashtagVC") as? PostListWithHashtagVC {
            
            PLWHVC.hidesBottomBarWhenPushed = true
            hideMiddleBtn(vc: self)
            PLWHVC.searchHashtag = selectedHashtag.keyword
            self.navigationController?.pushViewController(PLWHVC, animated: true)
            
        }
        
        
    }
    
        
}

