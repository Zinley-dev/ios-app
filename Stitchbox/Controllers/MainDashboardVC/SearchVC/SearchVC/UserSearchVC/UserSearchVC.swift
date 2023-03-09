//
//  UserSearchVC.swift
//  Stitchbox
//
//  Created by Khoi Nguyen on 3/6/23.
//

import UIKit
import Alamofire
import AsyncDisplayKit
import FLAnimatedImage

class UserSearchVC: UIViewController {
    
    struct SearchRecord {
        let keyWord: String
        let timeStamp: Double
        let items: [UserSearchModel]
    }
    
    let EXPIRE_TIME = 20.0 //s
    var searchHist = [SearchRecord]()

    var tableNode: ASTableNode!
    var searchUserList = [UserSearchModel]()
    @IBOutlet weak var contentview: UIView!
    
    required init?(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
        self.tableNode = ASTableNode(style: .plain)
        self.wireDelegates()
  
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        contentview.addSubview(tableNode.view)
        self.applyStyle()

        self.tableNode.automaticallyRelayoutOnLayoutMarginsChanges = true
        self.tableNode.automaticallyAdjustsContentOffset = true
        
    }
    
    override func viewWillLayoutSubviews() {
        
        super.viewWillLayoutSubviews()
        self.tableNode.frame = contentview.bounds
       
    }

}

extension UserSearchVC {
    
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

extension UserSearchVC: ASTableDelegate {

    func tableNode(_ tableNode: ASTableNode, constrainedSizeForRowAt indexPath: IndexPath) -> ASSizeRange {
        
        let width = UIScreen.main.bounds.size.width;
        
        let min = CGSize(width: width, height: 40);
        let max = CGSize(width: width, height: 1000);
        return ASSizeRangeMake(min, max);
           
    }
    
    
    func shouldBatchFetch(for tableNode: ASTableNode) -> Bool {
        return false
    }
    
    func tableNode(_ tableNode: ASTableNode, didSelectRowAt indexPath: IndexPath) {
        
        let item = searchUserList[indexPath.row]
        saveRecentUser(userId: item.userId)
        if let UPVC = UIStoryboard(name: "Dashboard", bundle: nil).instantiateViewController(withIdentifier: "UserProfileVC") as? UserProfileVC {
            UPVC.userId = item.userId
            UPVC.nickname = item.user_nickname
        
            self.navigationController?.pushViewController(UPVC, animated: true)
            
        }
        
    }
}

extension UserSearchVC: ASTableDataSource {
    
    func tableNode(_ tableNode: ASTableNode, numberOfRowsInSection section: Int) -> Int {
        return self.searchUserList.count
    }
    
    func tableNode(_ tableNode: ASTableNode, nodeBlockForRowAt indexPath: IndexPath) -> ASCellNodeBlock {
        guard self.searchUserList.count > indexPath.row else { return { ASCellNode() } }
        let user = self.searchUserList[indexPath.row]
        
        let cellNodeBlock = { () -> ASCellNode in
            let cellNode = UserSearchNode(with: user)
            return cellNode
        }
        
        return cellNodeBlock
    }
    
    func searchUsers(for searchText: String) {
    
        //check local result first
        if checkLocalRecords(searchText: searchText){
            return
        }
        
        print(searchText)
        
        APIManager().searchUser(query: searchText) { result in
            switch result {
            case .success(let apiResponse):
                
                guard let data = apiResponse.body?["data"] as? [[String: Any]] else {
                    return
                }
                
                if !data.isEmpty {
                    
                    var newSearchList = [UserSearchModel]()
                    
                    for item in data {
                        newSearchList.append(UserSearchModel(UserSearchModel: item))
                    }
                    
                    let newSearchRecord = SearchRecord(keyWord: searchText, timeStamp: Date().timeIntervalSince1970, items: newSearchList)
                    self.searchHist.append(newSearchRecord)
                    
                    if self.searchUserList != newSearchList {
                        self.searchUserList = newSearchList
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
    
    func checkLocalRecords(searchText: String) -> Bool {
       
        for (i, record) in searchHist.enumerated() {
            if record.keyWord == searchText {
                print("time: \(Date().timeIntervalSince1970 - record.timeStamp)")
                if Date().timeIntervalSince1970 - record.timeStamp <= EXPIRE_TIME {
                    let retrievedSearchList = record.items
                    
                    if self.searchUserList != retrievedSearchList {
                        self.searchUserList = retrievedSearchList
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

extension UserSearchVC {
    
    func saveRecentUser(userId: String) {
        
        APIManager().addRecent(query: userId, type: "user") { result in
            switch result {
            case .success(let apiResponse):
                
                print(apiResponse)
                
            case .failure(let error):
                
                print(error)
               
            }
        }
        
    }
    
    
    func saveRecentText(text: String) {
        
        APIManager().addRecent(query: text, type: "text") { result in
            switch result {
            case .success(let apiResponse):
                
                print(apiResponse)
                
            case .failure(let error):
                
                print(error)
               
            }
        }
        
    }
    
}
