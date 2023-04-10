//
//  HashtagVC.swift
//  Stitchbox
//
//  Created by Khoi Nguyen on 1/23/23.
//

import UIKit
import AsyncDisplayKit

class HashtagVC: UIViewController {


    @IBOutlet weak var hashtagTxtField: UITextField!
    @IBOutlet weak var contentView: UIView!
    
    
    let backButton: UIButton = UIButton(type: .custom)
    var completionHandler: ((String) -> Void)?
    var tableNode: ASTableNode!
    
    var isVerified = false
    var previousSearchText = ""
    var searchHashtagList = [HashtagsModel]()
    
    struct SearchRecord {
        let keyWord: String
        let timeStamp: Double
        let items: [HashtagsModel]
    }
    
    let EXPIRE_TIME = 20.0 //s
    var searchHist = [SearchRecord]()
    var text: String?
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
        setupView()
        
        delay(0.1) {
            self.hashtagTxtField.addUnderLine()
        }
        
    }
    
    override func viewWillLayoutSubviews() {
        
        super.viewWillLayoutSubviews()
        self.tableNode.frame = contentView.bounds
       
    }
  
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        self.view.endEditing(true)
    }
    
}

extension HashtagVC {
    
    func setupButtons() {
        
        setupBackButton()
        createDisableAddBtn()
    
    }
    
    func setupBackButton() {
    
        backButton.frame = back_frame
        backButton.contentMode = .center

        if let backImage = UIImage(named: "back_icn_white") {
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
        navigationItem.title = "Add Hashtags"
        
        let backButtonBarButton = UIBarButtonItem(customView: backButton)

        self.navigationItem.leftBarButtonItem = backButtonBarButton


        
    }
    
    
    func createDisableAddBtn() {
        
        isVerified = false
        
        let createButton = UIButton(type: .custom)
        createButton.semanticContentAttribute = .forceRightToLeft
        //createButton.addTarget(self, action: #selector(onClickAdd(_:)), for: .touchUpInside)
        createButton.setTitle("Add", for: .normal)
        createButton.setTitleColor(.lightGray, for: .normal)
        createButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        createButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 2, bottom: 0, right: -2)
        createButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: -2, bottom: 0, right: 2)
        createButton.frame = CGRect(x: 0, y: 0, width: 80, height: 30)
        createButton.backgroundColor = .disableButtonBackground
        createButton.cornerRadius = 15
        let customView = UIView(frame: CGRect(x: 0, y: 0, width: 80, height: 30))
        customView.addSubview(createButton)
        createButton.center = customView.center
        let createBarButton = UIBarButtonItem(customView: customView)

        let fixedSpace = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        fixedSpace.width = 2
      
        self.navigationItem.rightBarButtonItem = createBarButton
         
    }
    
    func createAddAddBtn() {
        
        isVerified = true
        
        let createButton = UIButton(type: .custom)
        createButton.semanticContentAttribute = .forceRightToLeft
        createButton.addTarget(self, action: #selector(onClickAdd(_:)), for: .touchUpInside)
        createButton.setTitle("Add", for: .normal)
        createButton.setTitleColor(.white, for: .normal)
        createButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        createButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 2, bottom: 0, right: -2)
        createButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: -2, bottom: 0, right: 2)
        createButton.frame = CGRect(x: 0, y: 0, width: 80, height: 30)
        createButton.backgroundColor = .primary
        createButton.cornerRadius = 15
        let customView = UIView(frame: CGRect(x: 0, y: 0, width: 80, height: 30))
        customView.addSubview(createButton)
        createButton.center = customView.center
        let createBarButton = UIBarButtonItem(customView: customView)

        let fixedSpace = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        fixedSpace.width = 2
      
        self.navigationItem.rightBarButtonItem = createBarButton
         
    }
    
    func setupView() {
        
        if text != nil {
            
            if let currentText = text {
                hashtagTxtField.text = "\(currentText)#"
            }
            
        } else {
            hashtagTxtField.text = "#"
        }
        
        contentView.backgroundColor = UIColor.clear
        contentView.addSubview(tableNode.view)
        self.applyStyle()
        //self.tableNode.leadingScreensForBatching = 5
        self.tableNode.automaticallyRelayoutOnLayoutMarginsChanges = true
        self.tableNode.automaticallyAdjustsContentOffset = true
                
        //improve later
        
        self.contentView.addSubview(tableNode.view)
      
       
        
        
        hashtagTxtField.delegate = self
        
        //hashtagTxtField.becomeFirstResponder()
        
    }
    
   

    
}

extension HashtagVC {
        
    @objc func onClickBack(_ sender: AnyObject) {
        if let navigationController = self.navigationController {
            navigationController.popViewController(animated: true)
        }
    }
    
    @objc func onClickAdd(_ sender: AnyObject) {
        
        var updateText = ""
        if let text = self.hashtagTxtField.text {
            updateText = self.hashtagTxtField.text!
            if text.last == "#" {
                updateText.removeLast()
            }
            
            completionHandler?(updateText)
        }
        
        if let navigationController = self.navigationController {
            navigationController.popViewController(animated: true)
        }
        
        
    }
    
}

extension HashtagVC {
    
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

extension HashtagVC: UITextFieldDelegate {
    func textFieldDidChangeSelection(_ textField: UITextField) {
        guard let text = textField.text, !text.isEmpty else {
            createDisableAddBtn()
            return
        }
        
        if text == previousSearchText {
            return
        }
        
        previousSearchText = text
        
        if text.last != " " && text.last != "#" {
            let searchText = String(getCurrentSearchHashTag(text: text).dropFirst(1))
            
            delayItem.perform(after: 0.35) {
                self.searchHashTags(searchText: searchText)
            }
           
        } else {
            searchHashtagList = []
            tableNode.reloadData(completion: nil)
        }
        
        if text.findMHashtagText().isEmpty {
            createDisableAddBtn()
        } else {
            createAddAddBtn()
        }
    }

}


extension HashtagVC: ASTableDelegate {

    func tableNode(_ tableNode: ASTableNode, constrainedSizeForRowAt indexPath: IndexPath) -> ASSizeRange {
        
        let width = tableNode.view.bounds.size.width;

        
        let min = CGSize(width: width, height: 30);
        let max = CGSize(width: width, height: 1000);
        return ASSizeRangeMake(min, max);
           
    }
    
    
    func shouldBatchFetch(for tableNode: ASTableNode) -> Bool {
        
        return false
        
    }
    
    
}

extension HashtagVC: ASTableDataSource {
    
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
        tableNode.deselectRow(at: indexPath, animated: true)
        let hashtagsStr = self.hashtagTxtField.text!
        let endOfSentence = hashtagsStr.lastIndex(of: "#")!
        
        let newhashtagsText = hashtagsStr[..<endOfSentence] + (self.searchHashtagList[indexPath.row].keyword) + "#"
        
        self.hashtagTxtField.text = newhashtagsText
        
        self.searchHashtagList = [HashtagsModel]()
        self.tableNode.reloadData(completion: nil)
    }
    
        
}

extension HashtagVC {
    
    func getCurrentSearchHashTag(text: String) -> String {
        let mentionText = text.findMHashtagText()
        print("getCurrentSearchHashTag\nMentionText: \(mentionText)")
        
        
        if !text.findMHashtagText().isEmpty {
            
            let res = text.findMHashtagText()[text.findMHashtagText().count - 1]
            
            print("findMentionText: \(res)")
            
            return res
            
        } else {
            return ""
        }
        
        
    }
    
    func checkLocalRecords(searchText: String) -> Bool {
       
        for (i, record) in searchHist.enumerated() {
            if record.keyWord == searchText {
                print("time: \(Date().timeIntervalSince1970 - record.timeStamp)")
                if Date().timeIntervalSince1970 - record.timeStamp <= EXPIRE_TIME {
                    let retrievedSearchHashtagList = record.items
                    
                    if self.searchHashtagList != retrievedSearchHashtagList {
                        self.searchHashtagList = retrievedSearchHashtagList
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
    
    func searchHashTags(searchText: String) {
        if searchText.isEmpty {
            return
        }
        //check local result first
        if checkLocalRecords(searchText: searchText){
            return
        }
        
        APIManager().searchHashtag(query: searchText) { result in
            switch result {
            case .success(let apiResponse):
                
                print(apiResponse)
                
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


