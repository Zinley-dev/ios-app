//
//  AutocompeteViewController.swift
//  Dual
//
//  Created by Rui Sun on 8/18/21.
//

import UIKit

class AutocompeteViewController: UIViewController, UITableViewDelegate {
    
    lazy var delayItem = workItem()
    
    enum Mode {
        case user, hashtag
    }
    
    var userSearchcompletionHandler: ((String, String) -> Void)?
    var hashtagSearchcompletionHandler: ((String) -> Void)?
   

    
    var searchMode = Mode.user
    
    var searchUserList = [UserSearchModel]()
    var searchHashtagList = [HashtagsModel]()
   
    
    let tableView: UITableView = {
        let uitableView = UITableView()
        uitableView.separatorStyle = .none
        uitableView.register(CustomSearchCell.nib(), forCellReuseIdentifier: CustomSearchCell.cellReuseIdentifier())
        uitableView.backgroundColor = .clear
        uitableView.borderColors = .clear
        return uitableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.dataSource = self
        self.tableView.delegate = self
        
        view.addSubview(tableView)
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }
    
    
    func searchUsers(searchText: String) {
        print("searching: \(searchText)")
        
        delayItem.perform(after: 0.35) {
            
            
            APIManager.shared.searchUser(query: searchText) { result in
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

                        if self.searchUserList != newSearchList {
                            self.searchUserList = newSearchList
                            DispatchQueue.main.async {
                                self.tableView.reloadData()
                            }
                        }
                        
                    }
                    
                case .failure(let error):
                    
                    print(error)
                   
                }
            }
            
        }
        

    }
    
    
    func searchHashtags(searchText: String) {
        
        delayItem.perform(after: 0.35) {
            
            APIManager.shared.searchHashtag(query: searchText) { result in
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
                         
                         if self.searchHashtagList != newSearchList {
                             self.searchHashtagList = newSearchList
                             DispatchQueue.main.async {
                                 self.tableView.reloadData()
                             }
                         }
                         
                     }
                     
                 case .failure(let error):
                     
                     print(error)
                    
                 }
             }
            
        }
       
        
    }
    
    
    func search(text: String, with mode: Mode) {
        switch mode {
        case .user:
            searchUsers(searchText: text)
            self.searchMode = .user
        case .hashtag:
            searchHashtags(searchText: text)
            self.searchMode = .hashtag
        }
    }
    
    
    func clearTable() {
        self.searchUserList = [UserSearchModel]()
        self.searchHashtagList = [HashtagsModel]()
        DispatchQueue.main.async {
            self.tableView.reloadData()
            print("Got result from Search")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        clearTable()
    }
    
}

extension AutocompeteViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch self.searchMode {
        case .user:
            return self.searchUserList.count
        case .hashtag:
            return self.searchUserList.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: CustomSearchCell.cellReuseIdentifier(), for: indexPath) as? CustomSearchCell {
            
            cell.backgroundColor = .clear
            
            
            switch self.searchMode {
            case .user:
                cell.configureCell(type: "user", text: self.searchUserList[indexPath.row].user_nickname, url: self.searchUserList[indexPath.row].avatarUrl)
                
            case .hashtag:
                cell.configureCell(type: "hashtag", text: String(self.searchHashtagList[indexPath.row].keyword.dropFirst()), url: "")
        
            }
            
            return cell
            
        } else {
            return UITableViewCell()
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        print("autocompletevc: did select row")
        switch self.searchMode {
        case .user:
            (userSearchcompletionHandler)?((self.searchUserList[indexPath.row].user_nickname), (self.searchUserList[indexPath.row].userId))
        case .hashtag:
            (hashtagSearchcompletionHandler)?(self.searchHashtagList[indexPath.row].keyword)
        }
    }
}

