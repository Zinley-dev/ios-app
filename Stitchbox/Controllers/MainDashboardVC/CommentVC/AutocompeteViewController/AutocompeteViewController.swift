//
//  AutocompeteViewController.swift
//  Dual
//
//  Created by Rui Sun on 8/18/21.
//

import UIKit

class AutocompeteViewController: UIViewController, UITableViewDelegate {
    
    enum Mode {
        case user, hashtag, highlight, keyword
    }
    
    var userSearchcompletionHandler: ((String, String) -> Void)?
    var hashtagSearchcompletionHandler: ((String) -> Void)?
    var highlightSearchcompletionHandler: ((String) -> Void)?
    var keywordSearchcompletionHandler: ((String) -> Void)?

    
    var searchMode = Mode.user
    
    var searchUserList = [SearchUser]()
    //var searchHashtagList = [HashtagsModelFromAlgolia]()
    //var searchHighlightList = [HighlightsModel]()
    //var searchKeywordList = [KeywordModelFromAlgolia]()
    
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
        /*
        AlgoliaSearch.instance.searchUsers(searchText: searchText) { userSearchResult in
            print("finish search")
            print(userSearchResult.count)
            if userSearchResult != self.searchUserList {
                self.searchUserList = userSearchResult
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                    print("***RUI***: Got result and reload table")
                }
                
            }
            
        } */
        
    }
    
    
    func searchHashtags(searchText: String) {
       
        
    }
    
    func searchHighlights(searchText: String) {
       
    }
    
    func searchKeywords(searchText: String) {
       
    }
    
    func search(text: String, with mode: Mode) {
        switch mode {
        case .user:
            searchUsers(searchText: text)
            self.searchMode = .user
        case .hashtag:
            searchHashtags(searchText: text)
            self.searchMode = .hashtag
        case .highlight:
            searchHighlights(searchText: text)
            self.searchMode = .highlight
        case .keyword:
            searchKeywords(searchText: text)
            self.searchMode = .keyword
        }
    }
    
    
    func clearTable() {
        self.searchUserList = [SearchUser]()
        //self.searchHashtagList = [HashtagsModelFromAlgolia]()
        //self.searchHighlightList = [HighlightsModel]()
        DispatchQueue.main.async {
            self.tableView.reloadData()
            print("Got result from Search")
        }
        //        self.tableView.reloadData()
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
        case .highlight:
            return self.searchUserList.count
        case .keyword:
            return self.searchUserList.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: CustomSearchCell.cellReuseIdentifier(), for: indexPath) as? CustomSearchCell {
            
            cell.backgroundColor = .clear
            
            
            switch self.searchMode {
            case .user:
                cell.configureCell(type: "user", text: self.searchUserList[indexPath.row].username, url: self.searchUserList[indexPath.row].avatar)
                
            case .hashtag:
                cell.configureCell(type: "user", text: self.searchUserList[indexPath.row].username, url: self.searchUserList[indexPath.row].avatar)
                
            case .highlight:
                cell.configureCell(type: "user", text: self.searchUserList[indexPath.row].username, url: self.searchUserList[indexPath.row].avatar)
            case .keyword:
                cell.configureCell(type: "user", text: self.searchUserList[indexPath.row].username, url: self.searchUserList[indexPath.row].avatar)
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
            (userSearchcompletionHandler)?((self.searchUserList[indexPath.row].username), (self.searchUserList[indexPath.row].userID))
        case .hashtag:
            (userSearchcompletionHandler)?((self.searchUserList[indexPath.row].username), (self.searchUserList[indexPath.row].userID))
        case .highlight: //todo: what to display/search?
            (userSearchcompletionHandler)?((self.searchUserList[indexPath.row].username), (self.searchUserList[indexPath.row].userID))
        case .keyword:
            (userSearchcompletionHandler)?((self.searchUserList[indexPath.row].username), (self.searchUserList[indexPath.row].userID))
        }
    }
}

