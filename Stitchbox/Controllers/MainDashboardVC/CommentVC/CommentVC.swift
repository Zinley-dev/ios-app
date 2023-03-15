//
//  CommentVC.swift
//  Stitchbox
//
//  Created by Khoi Nguyen on 2/4/23.
//

import UIKit
import Alamofire
import AsyncDisplayKit
import AlamofireImage
import Cache
import FLAnimatedImage

class CommentVC: UIViewController, UITextViewDelegate, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var loadingView: UIView!
    @IBOutlet weak var loadingImage: FLAnimatedImageView!
    @IBOutlet weak var sendBtnBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var commentBtn: UIButton!
    var isSending = false
    @IBOutlet weak var avatarBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var avatarView: UIImageView!
    var mention_list = [String]()
    var total = 0
    var isTitle = false
    var cmtPage = 1
    @IBOutlet weak var totalCmtCount: UILabel!
    @IBOutlet weak var bView: UIView!
    //var currentItem: HighlightsModel!
    var hasSetPointOrigin = false
    var pointOrigin: CGPoint?
    var editedComment: CommentModel?
    var editedIndexpath: IndexPath?
    //var lastDocumentSnapshot: DocumentSnapshot!
    //var query: Query!
    var reply_to_uid: String!
    var reply_to_cid: String!
    var reply_to_username: String!

    //var CmtQuery: Query!
    var prev_id: String!
    
    var root_id: String!
    var index: Int!
    
    @IBOutlet weak var tView: UIView!
    
    @IBOutlet weak var viewHeight: NSLayoutConstraint!
    @IBOutlet weak var textConstraint: NSLayoutConstraint!
    @IBOutlet weak var cmtTxtView: UITextView!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    var placeholderLabel : UILabel!
    var CommentList = [CommentModel]()
    var tableNode: ASTableNode!
    
    //
    var hashtag_arr = [String]()
    var mention_arr = [String]()
    
    var previousTxtLen = 0
    var previousTxt = ""
    var isInAutocomplete = false
    
    
    var uid_dict = [String: String]()
    
    var post: PostModel!


    let searchResultContainerView = UIView()
    
    lazy var autocompleteVC: AutocompeteViewController = {
        let vc = AutocompeteViewController()
        searchResultContainerView.backgroundColor = UIColor.background
        
        
        self.searchResultContainerView.addSubview(vc.view)
        vc.view.frame = searchResultContainerView.bounds
    
        
        vc.userSearchcompletionHandler = { newMention, userUID in
            if newMention.isEmpty {
                return
            }
            
            let newMentionWithAt = "@" + newMention
            
            self.mention_arr[self.mention_arr.count - 1] = newMentionWithAt
            
            let curCmtTxt = self.cmtTxtView.text ?? ""
            let lastAt = curCmtTxt.lastIndex(of: "@")!
            let finalText = curCmtTxt[..<lastAt] + newMentionWithAt + " "
            
            
            self.cmtTxtView.text = String(finalText)
            
            self.searchResultContainerView.isHidden = true
            vc.clearTable()
            self.isInAutocomplete = false
            
            self.uid_dict[newMention] = userUID
            
        }
        
        vc.hashtagSearchcompletionHandler = { newHashtag in
            
            if newHashtag.isEmpty {
                return
            }
            
            //already has pound sign
            let newHashtagWithPound = newHashtag
            
            self.hashtag_arr[self.hashtag_arr.count - 1] = newHashtagWithPound
            
            let curCmtTxt = self.cmtTxtView.text ?? ""
            let lastAt = curCmtTxt.lastIndex(of: "#")!
            let finalText = curCmtTxt[..<lastAt] + newHashtagWithPound + " "
            
            
            self.cmtTxtView.text = String(finalText)

            
            self.searchResultContainerView.isHidden = true
            vc.clearTable()
            self.isInAutocomplete = false
        }
        
        
        return vc
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(panGestureRecognizerAction))
        view.addGestureRecognizer(panGesture)
        
        setupTableNode()
        setupSearchController()
        setupPlaceholder()
        calculateToTalCmt()
        setupLongPressGesture()
        loadAvatar()
        loadCommentTitle()
        commentBtn.setTitle("", for: .normal)
        
        
        //
        
        NotificationCenter.default.addObserver(self, selector: #selector(CommentVC.pinRequest), name: (NSNotification.Name(rawValue: "pin_cmt")), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(CommentVC.unpinRequest), name: (NSNotification.Name(rawValue: "unpin_cmt")), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(CommentVC.reportRequest), name: (NSNotification.Name(rawValue: "report_cmt")), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(CommentVC.copyRequest), name: (NSNotification.Name(rawValue: "copy_cmt")), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(CommentVC.deleteRequest), name: (NSNotification.Name(rawValue: "delete_cmt")), object: nil)
        
        
        
        //
        
        Timer.scheduledTimer(timeInterval: 20, target: self, selector: #selector(CommentVC.calculateToTalCmt), userInfo: nil, repeats: true)
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardShow),
                                               name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardHide),
                                               name: UIResponder.keyboardWillHideNotification, object: nil)
        
        do {
            
            let path = Bundle.main.path(forResource: "fox2", ofType: "gif")!
            let gifData = try NSData(contentsOfFile: path) as Data
            let image = FLAnimatedImage(animatedGIFData: gifData)
            
            
            self.loadingImage.animatedImage = image
            
        } catch {
            print(error.localizedDescription)
        }
        
        loadingView.backgroundColor = self.view.backgroundColor
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)

        
        NotificationCenter.default.removeObserver(self, name: (NSNotification.Name(rawValue: "pin_cmt")), object: nil)
        NotificationCenter.default.removeObserver(self, name: (NSNotification.Name(rawValue: "unpin_cmt")), object: nil)
        NotificationCenter.default.removeObserver(self, name: (NSNotification.Name(rawValue: "report_cmt")), object: nil)
        NotificationCenter.default.removeObserver(self, name: (NSNotification.Name(rawValue: "copy_cmt")), object: nil)
        NotificationCenter.default.removeObserver(self, name: (NSNotification.Name(rawValue: "delete_cmt")), object: nil)
        
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        self.tableNode.frame = CGRect(x: 0, y: 0, width: self.tView.frame.width, height: self.tView.frame.height - 50)
        
    }
    
    override func viewDidLayoutSubviews() {
        if !hasSetPointOrigin {
            hasSetPointOrigin = true
            pointOrigin = self.view.frame.origin
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        self.view.endEditing(true)
        
        
    }
    
    @IBAction func sendCommentBtnPressed(_ sender: Any) {
        
        if let text = self.cmtTxtView.text, text != "", isSending == false {
            
            isSending = true
            
            self.sendCommentBtn()
            
        }
        
        
    }


}

extension CommentVC {
    
    func textViewDidChange(_ textView: UITextView) {
        placeholderLabel.isHidden = !textView.text.isEmpty
        viewHeight.constant = textView.layer.frame.height + 25
        
        
        if let text = textView.text, text != "" {
            let curTxtLen = text.count
         
            if curTxtLen < previousTxtLen && !isInAutocomplete {
                handleDeletion()
            } else {
                checkCurrenText(text: text)
            }
        } else {
            
            uid_dict.removeAll()
            self.searchResultContainerView.isHidden = true
        }
       
    }
    
    func handleDeletion() {
        
        var txtBefore: String
        var targetTxt: String
            if let lastSpace = previousTxt.lastIndex(of: " ") {
                txtBefore = String(previousTxt[..<lastSpace])
                targetTxt = String(previousTxt[previousTxt.index(after: lastSpace)...])
                
            } else {
                txtBefore = ""
                targetTxt = previousTxt
            }
            print("target txt: " + targetTxt)
            if let firstOfTarget = targetTxt.first {
                print("first charactor: " + String(firstOfTarget))
                switch firstOfTarget {
                case "@":
                    print("delete @")
                    self.mention_arr.removeObject(targetTxt)
                    self.previousTxtLen = txtBefore.count
                    self.previousTxt = txtBefore
                    uid_dict[String(targetTxt.dropFirst())] = nil
                    self.cmtTxtView.text = txtBefore
                    print("target: " + targetTxt)
                case "#":
                    print("delete #")
                default:
                    print("normal delete")
                    updatePrevCmtTxt()
                    return
                }
            }
        
        updatePrevCmtTxt()
        
    }
    
    
    
func checkCurrenText(text: String) {
    
    if hashtag_arr != text.findMHashtagText() {
        hashtag_arr = text.findMHashtagText()
        if !hashtag_arr.isEmpty {
            let hashtagToSearch = hashtag_arr[hashtag_arr.count - 1]
            let hashtagToSearchTrimmed = String(hashtagToSearch.dropFirst(1))
           
            if !hashtagToSearchTrimmed.isEmpty {
                self.searchResultContainerView.isHidden = false
                self.autocompleteVC.search(text: hashtagToSearchTrimmed, with: AutocompeteViewController.Mode.hashtag)
                isInAutocomplete = true
            }
        }
        
    } else if mention_arr != text.findMentiontagText() {
        mention_arr = text.findMentiontagText()
        if !mention_arr.isEmpty {
            let userToSearch = mention_arr[mention_arr.count - 1]
            let userToSearchTrimmed = String(userToSearch.dropFirst(1))
            
            if !userToSearchTrimmed.isEmpty {
                self.searchResultContainerView.isHidden = false
                self.autocompleteVC.search(text: userToSearchTrimmed, with: AutocompeteViewController.Mode.user)
                isInAutocomplete = true

            }
            
        }
    } else {

        self.searchResultContainerView.isHidden = true
        
    }
    self.updatePrevCmtTxt()
    
    print("Done")
    
}
    
    func updatePrevCmtTxt() {
        self.previousTxtLen = self.cmtTxtView.text.count
        self.previousTxt = self.cmtTxtView.text
    }
    
}

extension CommentVC {
    
    func loadCommentTitle() {
        
        APIManager().getTitleComment(postId: post.id) { result in
            switch result {
            case .success(let apiResponse):
              
                guard let data = apiResponse.body?["data"] as? [[String: Any]] else {
                    self.loadPinnedPost()
                    return
                }
                
                if !data.isEmpty {
                    for each in data {
                        let item = CommentModel(postKey: each["_id"] as! String, Comment_model: each)
                        self.CommentList.insert(item, at: 0)
                    }
                    self.loadPinnedPost()
                } else {
                    
                    self.loadPinnedPost()
                }
            case .failure(let error):
                print(error)
                self.loadPinnedPost()
          }
      }
        
    }
    
    func loadPinnedPost() {
        
        APIManager().getPinComment(postId: post.id) { result in
            switch result {
            case .success(let apiResponse):
                
                guard let data = apiResponse.body?["data"] as? [[String: Any]] else {
                    self.wireDelegates()
                    return
                }
                
                if !data.isEmpty {
                    for each in data {
                        let item = CommentModel(postKey: each["_id"] as! String, Comment_model: each)
                        self.CommentList.append(item)
                    }
                    self.wireDelegates()
                } else {
                    
                    self.wireDelegates()
                }
            case .failure(let error):
                print(error)
                self.wireDelegates()
          }
      }
        
    }
    
    
    
}

extension CommentVC {
    
    func wireDelegates() {
        
        self.tableNode.delegate = self
        self.tableNode.dataSource = self
        
        DispatchQueue.main.async {
            self.tableNode.reloadData()
        }
        delay(0.5) {
            
            UIView.animate(withDuration: 0.5) {
                
                DispatchQueue.main.async {
                    self.loadingView.alpha = 0
                }
            
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                
                if self.loadingView.alpha == 0 {
                    
                    self.loadingView.isHidden = true
                    
                }
                
            }
          
            
        }
       
    }
    
}

extension CommentVC {
    
    func setupSearchController() {
        
        searchResultContainerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(searchResultContainerView)
        NSLayoutConstraint.activate([
            searchResultContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            searchResultContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
            searchResultContainerView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0),
            searchResultContainerView.bottomAnchor.constraint(equalTo: cmtTxtView.topAnchor, constant: -22),
        ])
        searchResultContainerView.backgroundColor = UIColor.gray.withAlphaComponent(0.9)
        searchResultContainerView.isHidden = true
        
    }
    
    func setupTableNode() {
        
       
        self.tableNode = ASTableNode(style: .plain)
        tView.addSubview(tableNode.view)
        self.applyStyle()
        self.tableNode.leadingScreensForBatching = 20
        self.tableNode.automaticallyRelayoutOnLayoutMarginsChanges = true
        self.tableNode.automaticallyAdjustsContentOffset = true
        self.tableNode.view.backgroundColor = self.view.backgroundColor
        
    }
    
    func setupPlaceholder() {
        
        cmtTxtView.delegate = self
        placeholderLabel = UILabel()
        placeholderLabel.text = "Add comment..."
        placeholderLabel.font = UIFont.systemFont(ofSize: (cmtTxtView.font?.pointSize)!)
        placeholderLabel.sizeToFit()
        cmtTxtView.addSubview(placeholderLabel)
        
        placeholderLabel.frame = CGRect(x: 5, y: (cmtTxtView.font?.pointSize)! / 2 - 5, width: 200, height: 30)
        placeholderLabel.textColor = UIColor.white
        placeholderLabel.isHidden = !cmtTxtView.text.isEmpty
        
    }
    
    func applyStyle() {
        
        self.tableNode.view.separatorStyle = .none
        self.tableNode.view.separatorColor = UIColor.lightGray
        self.tableNode.view.isPagingEnabled = false
        self.tableNode.view.backgroundColor = UIColor.clear
        self.tableNode.view.showsVerticalScrollIndicator = false
        
        
        
    }
    
    func showErrorAlert(_ title: String, msg: String) {
                                                                                                                                           
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        
                                                                                       
        present(alert, animated: true, completion: nil)
        
    }
    
  
    func loadAvatar() {
        guard let userDataSource = _AppCoreData.userDataSource.value else {
            return
        }
        let avatarUrl = userDataSource.avatarURL

        imageStorage.async.object(forKey: avatarUrl) { result in
            if case .value(let image) = result {
                // Return the image from cache
                DispatchQueue.main.async {
                    self.avatarView.image = image
                }
                return
            }

            // Image not found in cache or storage, fetch from network
            AF.request(avatarUrl).validate().responseImage { response in
                switch response.result {
                case .success(let image):
                    self.avatarView.image = image
                    try? imageStorage.setObject(image, forKey: avatarUrl)
                case .failure(let error):
                    print(error)
                }
            }
        }
    }

    
}

extension CommentVC {
    
    func setupLongPressGesture() {
        let longPressGesture:UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(self.handleLongPress))
        longPressGesture.minimumPressDuration = 0.5 // 0.5 second press
        longPressGesture.delegate = self
        self.tableNode.view.addGestureRecognizer(longPressGesture)
    }
    
    @objc func handleLongPress(_ gestureRecognizer: UILongPressGestureRecognizer){
        if gestureRecognizer.state == .began {
            let touchPoint = gestureRecognizer.location(in: self.tableNode.view)
            if let indexPath = self.tableNode.indexPathForRow(at: touchPoint) {
                
                guard let userDataSource = _AppCoreData.userDataSource.value, let userUID = userDataSource.userID, userUID != "" else {
                    print("Can't get userUID")
                    return
                }
                
                let uid = userUID
                let selectedCmt = CommentList[indexPath.row]
                
                
                let commentSettings = CommentSettings()
                commentSettings.modalPresentationStyle = .custom
                commentSettings.transitioningDelegate = self
                
                global_presetingRate = Double(0.35)
                global_cornerRadius = 45
                
                if uid == self.post.owner?.id {
                    commentSettings.isPostOwner = true
    
                } else {
                    commentSettings.isPostOwner = false
                }
                
                if uid == selectedCmt.owner_uid {
                    commentSettings.isCommentOwner = true
                } else {
                    commentSettings.isCommentOwner = false
                }
               
                editedComment = selectedCmt
                editedIndexpath = indexPath
                
                self.present(commentSettings, animated: true, completion: nil)
            
            }
        }
    }
    
}

extension CommentVC: ASTableDelegate, ASTableDataSource {
    
    func tableNode(_ tableNode: ASTableNode, constrainedSizeForRowAt indexPath: IndexPath) -> ASSizeRange {
        
        let width = UIScreen.main.bounds.size.width;
        
        let min = CGSize(width: width, height: 50);
        let max = CGSize(width: width, height: 1000);
        return ASSizeRangeMake(min, max);
        
    }
    
    func shouldBatchFetch(for tableNode: ASTableNode) -> Bool {
        
        return true
        
    }
    
    func tableNode(_ tableNode: ASTableNode, willBeginBatchFetchWith context: ASBatchContext) {
        
        self.retrieveNextPageWithCompletion { (newPosts) in
            
            self.insertNewRowsInTableNode(newPosts: newPosts)
            
        
      
            context.completeBatchFetching(true)
            
            
        }
        
    }
    
    
    func tableNode(_ tableNode: ASTableNode, numberOfRowsInSection section: Int) -> Int {
    
        
        return self.CommentList.count
        
    }
    
    func tableNode(_ tableNode: ASTableNode, nodeBlockForRowAt indexPath: IndexPath) -> ASCellNodeBlock {
        let comment = self.CommentList[indexPath.row]
        
        return makeCommentNodeBlock(with: comment, indexPath: indexPath)
    }

    private func makeCommentNodeBlock(with comment: CommentModel, indexPath: IndexPath) -> ASCellNodeBlock {
        let nodeBlock: ASCellNodeBlock = {
            let node = CommentNode(with: comment)
            node.neverShowPlaceholders = true
            node.debugName = "Node \(indexPath.row)"
            
            node.replyBtn = { (node) in
            
                self.handleReply(for: comment, indexPath: indexPath)
            }
            
            
            node.reply = { (nodes) in
                
                self.handleReplyBtn(for: comment, commentNode: node, indexPath: indexPath)
            }
            

            return node
        }
        
        return nodeBlock
    }


    private func handleReplyBtn(for comment: CommentModel, commentNode: CommentNode?, indexPath: IndexPath) {
        
        if self.prev_id != nil {
            
            if self.prev_id != self.CommentList[indexPath.row].comment_id {
                
                //self.CmtQuery = nil
                self.prev_id = self.CommentList[indexPath.row].comment_id
                
            }
            
            
        } else {
            
            self.prev_id = self.CommentList[indexPath.row].comment_id
            
        }
        

        if comment.root_id != "", comment.has_reply == true {
            
            let newIndex = self.findIndexForRootCmt(post: comment)
            let newPost = self.CommentList[newIndex]
                       
            var newDict = ["createdAt": Date(), "content": comment.text!, "isReply": true, "postId": comment.post_id!, "parentId": comment.root_id!, "hasReply": false, "ownerId": comment.owner_uid!] as [String : Any]
            newDict["owner"] = ["_id": comment.comment_uid, "avatar": comment.comment_avatarUrl, "username": comment.comment_username, "name": comment.comment_name]
            
            
            newDict["replyTo"] = ["_id": comment.reply_to_cid!, "owner": ["username": comment.reply_to_username!, "_id": comment.reply_to!]]
            
            if comment.updatedAt != nil {
                
                newDict.updateValue(comment.updatedAt!, forKey: "updatedAt")
                
            } else {
                
                newDict.updateValue(Date(), forKey: "updatedAt")
                
            }
            
            if comment.last_modified != nil {
                
                newDict.updateValue(comment.last_modified!, forKey: "last_modified")
                
            } else {
                
                newDict.updateValue(Date(), forKey: "last_modified")
                
            }
            
            if comment.is_title == true {
                
                newDict.updateValue(true, forKey: "isTitle")
                
            } else {
                
                newDict.updateValue(false, forKey: "isTitle")
                
            }
        
            let elem = CommentModel(postKey: comment.comment_id, Comment_model: newDict)
            self.CommentList[indexPath.row] = elem
            
            self.tableNode.reloadRows(at: [IndexPath(row: indexPath.row, section: 0)], with: .automatic)
            
            self.loadReplied(item: newPost, indexex: indexPath.row, root_index: newIndex)
            
            
        } else {
            
            var newDict = ["createdAt": Date(), "content": comment.text!, "isReply": false, "postId": comment.post_id!, "hasReply": false, "ownerId": comment.owner_uid!] as [String : Any]
            newDict["owner"] = ["_id": comment.comment_uid, "avatar": comment.comment_avatarUrl, "username": comment.comment_username, "name": comment.comment_name]
            
        
            if comment.updatedAt != nil {
                
                newDict.updateValue(comment.updatedAt!, forKey: "updatedAt")
                
            } else {
                
                newDict.updateValue(Date(), forKey: "updatedAt")
                
            }
            
            if comment.last_modified != nil {
                
                newDict.updateValue(comment.last_modified!, forKey: "last_modified")
                
            } else {
                
                newDict.updateValue(Date(), forKey: "last_modified")
                
            }
            
            if comment.is_title == true {
                
                newDict.updateValue(true, forKey: "is_title")
                
            } else {
                
                newDict.updateValue(false, forKey: "is_title")
                
            }
        
            let elem = CommentModel(postKey: comment.comment_id, Comment_model: newDict)
            self.CommentList[indexPath.row] = elem
            
            self.tableNode.reloadRows(at: [IndexPath(row: indexPath.row, section: 0)], with: .automatic)
            
            self.loadReplied(item: comment, indexex: indexPath.row, root_index: indexPath.row)
            
        }
        
    }


    private func handleReply(for comment: CommentModel, indexPath: IndexPath) {
        // Handle reply submitted
        // ...
        
        self.ReplyBtn(item: comment)
    }

    
}

extension CommentVC {
    
    func retrieveNextPageWithCompletion( block: @escaping ([[String: Any]]) -> Void) {
       
        APIManager().getComment(postId: post.id, page: cmtPage) { result in
                switch result {
                case .success(let apiResponse):
                    
                    guard let data = apiResponse.body?["data"] as? [[String: Any]] else {
                        let item = [[String: Any]]()
                        DispatchQueue.main.async {
                            block(item)
                        }
                        return
                    }
                    if !data.isEmpty {
                        print("Successfully retrieved \(data.count) comments.")
                        let items = data
                        self.cmtPage += 1
                    
                        DispatchQueue.main.async {
                            block(items)
                        }
                    } else {
                        
                        let item = [[String: Any]]()
                        DispatchQueue.main.async {
                            block(item)
                        }
                    }
                case .failure(let error):
                    print(error)
                    let item = [[String: Any]]()
                    DispatchQueue.main.async {
                        block(item)
                }
            }
        }
    
    }
    
    func insertNewRowsInTableNode(newPosts: [[String: Any]]) {
        guard newPosts.count > 0 else {
            return
        }
        
        let section = 0
        
        var actualPost = [[String: Any]]()
        
        for item in newPosts {
            let inputItem = CommentModel(postKey: item["_id"] as! String, Comment_model: item)
            if checkDuplicateLoading(post: inputItem) == false {
                actualPost.append(item)
            }
        }
        
        guard actualPost.count > 0 else {
            return
        }
        
        var items = [CommentModel]()
        var indexPaths = [IndexPath]()
        let total = self.CommentList.count + actualPost.count
        
        for row in self.CommentList.count...total-1 {
            let path = IndexPath(row: row, section: section)
            indexPaths.append(path)
        }
        
        for i in actualPost {
            let item = CommentModel(postKey: i["_id"] as! String, Comment_model: i)
            items.append(item)
        }
        
        self.CommentList.append(contentsOf: items)
        self.tableNode.insertRows(at: indexPaths, with: .none)
        
    }


    func checkDuplicateLoading(post: CommentModel) -> Bool {
        return CommentList.contains { $0.comment_id == post.comment_id }
    }
    
    
}

extension CommentVC {
    
    func ReplyBtn(item: CommentModel){
        
        let cIndex = findCommentIndex(item: item)
        
        if cIndex != -1 {
            
            cmtTxtView.becomeFirstResponder()
            
            if CommentList[cIndex].comment_uid != "" {
                
                let paragraphStyles = NSMutableParagraphStyle()
                paragraphStyles.alignment = .left
            
                if let username = CommentList[cIndex].comment_username {
                    
                
                    self.placeholderLabel.text = "Reply to @\(username)"
                    
                    
                }
                
            } else{
                placeholderLabel.text = "Reply to @Undefined"
            }
            
            if CommentList[cIndex].isReply == false {
                root_id = CommentList[cIndex].comment_id
                index = cIndex
            } else {
                root_id = CommentList[cIndex].root_id
                index = cIndex
            }
            
            
            reply_to_uid =  CommentList[cIndex].comment_uid
            reply_to_cid =  CommentList[cIndex].comment_id
            reply_to_username = CommentList[cIndex].comment_username
            
            tableNode.scrollToRow(at: IndexPath(row: cIndex, section: 0), at: .top, animated: true)
            
        }
        
    }
    
    func findIndexForRootCmt(post: CommentModel) -> Int {
        index = 0
        
        
        for item in CommentList {
            
            
            if item.comment_id == post.root_id
            {
                return index
                
            } else {
                
                index += 1
            }
            
        }
        
        return index
    }

    
    func findCommentIndex(item: CommentModel) -> Int {
        if let index = self.CommentList.firstIndex(where: { $0.comment_uid == item.comment_uid && $0.comment_id == item.comment_id }) {
            return index
        }
        return -1
    }
    
}

extension CommentVC {
    
    func loadReplied(item: CommentModel, indexex: Int, root_index: Int) {
        guard let commentId = item.comment_id else {
            // If the comment ID is nil, return early
            return
        }
        
        if self.CommentList[root_index].lastCmtSnapshot == nil {
            self.CommentList[root_index].lastCmtSnapshot = 1
        }
        
        APIManager().getReply(for: commentId, page: self.CommentList[root_index].lastCmtSnapshot) { result in
            switch result {
            case .success(let apiResponse):
               
                guard let replyData = apiResponse.body?["data"] as? [[String:Any]],
                      !replyData.isEmpty else {
                    // If the API response is not successful or the reply data is empty, return early
                    return
                }
                
                // Filter out any reply data that has already been loaded
                var newReplyData = replyData.filter { reply in
                    let cmtId = reply["_id"] as! String
                    let newReplyModel = CommentModel(postKey: cmtId, Comment_model: reply)
                    return !self.checkDuplicateLoading(post: newReplyModel)
                }
                
                guard !newReplyData.isEmpty else {
                    // If there is no new reply data to load, return early
                    return
                }
                
                let section = 0
                var indexPaths: [IndexPath] = []

                var last = 0
                var start = indexex + 1
                
                
                
                for row in start...newReplyData.count + start - 1 {
                    
                    let path = IndexPath(row: row, section: section)
                    indexPaths.append(path)
                    
                    last = row
                    
                }
                
                newReplyData[newReplyData.count - 1].updateValue(true, forKey: "hasReply")
                
                for item in newReplyData {
                    
        
                    let items = CommentModel(postKey: item["_id"] as! String, Comment_model: item)
     
                    self.CommentList.insert(items, at: start)
                    
                    start += 1
                    
                }
                
                DispatchQueue.main.async {
                    self.tableNode.insertRows(at: indexPaths,with: .none)
                    
                    self.CommentList[root_index].lastCmtSnapshot += 1
                    
                    
                    var updatePath: [IndexPath] = []
                    
                    for row in indexex + 1 ... self.CommentList.count - 1 {
                        let path = IndexPath(row: row, section: 0)
                        updatePath.append(path)
                    }
                    
                    
                    self.tableNode.reloadRows(at: updatePath, with: .automatic)
                    
                    
                    self.tableNode.scrollToRow(at: IndexPath(row: last, section: 0), at: .bottom, animated: true)
                }
                
                
                
            case .failure(let error):
                print("CmtCount: \(error)")
            }
        }
    }

    
    func sendCommentBtn() {
        // Check condition here

        guard let commentText = cmtTxtView.text, !commentText.isEmpty else {
            return
        }
        
        guard let userDataSource = _AppCoreData.userDataSource.value, let userUID = userDataSource.userID, userUID != "" else {
            print("Can't get userUID")
            return
        }

        // Append values to mention_list array
        uid_dict.values.forEach {
            if !mention_list.contains($0) {
                mention_list.append($0)
            }
        }

        var data = ["content": commentText, "postId": post.id] as [String : Any]

        if let replyToCID = reply_to_cid {
            data.updateValue(replyToCID, forKey: "replyTo")
        }
        
        if let root = root_id {
            data.updateValue(root, forKey: "parentId")
        }
        
        if !mention_list.isEmpty {
            data.updateValue(mention_list, forKey: "mention")
        }

        // Call the API to create a comment
        APIManager().createComment(params: data) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let apiResponse):
                guard apiResponse.body?["message"] as? String == "success", let returnData = apiResponse.body?["data"] as? [String: Any] else {
                    return
                }
                
                guard let id = returnData["InsertedID"] as? String else {
                    return
                }
                
                var isReply: Bool?
            
                if self.root_id != nil {
                    isReply = true
                } else {
                    isReply = false
                }
                
                var update = ["ownerId": self.post.owner?.id ?? "", "isReply": isReply!, "hasReply": false, "createdAt": Date(), "updatedAt": Date(), "last_modified": Date(), "isPined": false]
                
                update["owner"] = ["_id": userUID, "avatar": userDataSource.avatarURL, "username": userDataSource.userName, "name": userDataSource.name]
                
                if self.reply_to_cid != nil {
                    
                    data["replyTo"] = ["_id": self.reply_to_cid!, "owner": ["username": self.reply_to_username!, "_id": self.reply_to_cid!]]
    
                }
                
              
                data.merge(dict: update)
                
                // Insert the comment into the CommentList array and the corresponding row into tableNode
                let item = CommentModel(postKey: id, Comment_model: data)
                let start: Int
                
                
                
                if let index = self.index {
                    start = index + 1
                    self.CommentList.insert(item, at: start)
                    
                    DispatchQueue.main.async {
                        self.tableNode.insertRows(at: [IndexPath(row: start, section: 0)], with: .none)
                        self.tableNode.scrollToRow(at: IndexPath(row: index, section: 0), at: .top, animated: true)
                    }
                   
                } else {
                    if self.CommentList.isEmpty || !self.CommentList[0].is_title {
                        start = 0
                    } else {
                        start = 1
                    }
                    
                    self.CommentList.insert(item, at: start)
                    
                    DispatchQueue.main.async {
                        self.tableNode.insertRows(at: [IndexPath(row: start, section: 0)], with: .none)
                        self.tableNode.scrollToRow(at: IndexPath(row: start, section: 0), at: .top, animated: true)
                    }
                    
                }
                
                // Reload rows in tableNode
                let updatePath = (start ..< self.CommentList.count).map { IndexPath(row: $0, section: 0) }
                DispatchQueue.main.async {
                    self.tableNode.reloadRows(at: updatePath, with: .automatic)
                }
                

                // Update UI elements
                self.calculateToTalCmt()

                self.root_id = nil
                self.reply_to_uid = nil
                self.reply_to_cid = nil
                self.reply_to_username = nil
                self.index = nil
                self.isSending = false
                
                // Clear arrays and UI elements
                self.uid_dict.removeAll()
                self.mention_list.removeAll()
                self.hashtag_arr.removeAll()
                self.mention_arr.removeAll()
                
                DispatchQueue.main.async {
                    showNote(text: "Comment sent!")
                    self.searchResultContainerView.isHidden = true
                    self.cmtTxtView.text = ""
                    self.placeholderLabel.isHidden = !self.cmtTxtView.text.isEmpty
                    self.cmtTxtView.resignFirstResponder()
                }
                
            
            case .failure(let error):
                print(error)
                DispatchQueue.main.async {
                    self.showErrorAlert("Oops!", msg: error.localizedDescription)
                }
            }
        }
    }
    
}

extension CommentVC {
    
    @objc func handleKeyboardShow(notification: Notification) {
        
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
                let keyboardHeight = keyboardSize.height
                bottomConstraint.constant = -keyboardHeight
              
                viewHeight.constant = cmtTxtView.layer.frame.height + 25
                avatarBottomConstraint.constant = 11
                sendBtnBottomConstraint.constant = 11
                textConstraint.constant = 8
                bView.isHidden = false
               
            
            UIView.animate(withDuration: 0, delay: 0, options: .curveEaseOut, animations:  {
                self.view.layoutIfNeeded()
            }, completion: { (completed) in
                
            })
        }
        
        
    }
    
    @objc func handleKeyboardHide(notification: Notification) {
        
        bottomConstraint.constant = 0
       
        textConstraint.constant = 30
        avatarBottomConstraint.constant = 30
        sendBtnBottomConstraint.constant = 30
        bView.isHidden = true
        
        if cmtTxtView.text.isEmpty == true {
            placeholderLabel.text = "Add comment..."
            viewHeight.constant = 75
            
            
            root_id = nil
            reply_to_uid = nil
            reply_to_cid = nil
            reply_to_username = nil
            index = nil
            
            // remove all
            uid_dict.removeAll()
            mention_list.removeAll()
            hashtag_arr.removeAll()
            mention_arr.removeAll()
            
            //
            self.searchResultContainerView.isHidden = true
                
 
        } else{
            viewHeight.constant = cmtTxtView.layer.frame.height + 41
        }
        
        
        UIView.animate(withDuration: 0, delay: 0, options: .curveEaseOut, animations:  {
            self.view.layoutIfNeeded()
        }, completion: { (completed) in
            
        })
        
    }
    
}

extension CommentVC {
    
    @objc func calculateToTalCmt() {
        
        APIManager().countComment(post: post.id) { result in
            switch result {
            case .success(let apiResponse):
                
                guard apiResponse.body?["message"] as? String == "success",
                      let commentsCountFromQuery = apiResponse.body?["comments"] as? Int  else {
                        return
                }
                
                if commentsCountFromQuery == 0  {
                    
                    DispatchQueue.main.async {
                        self.totalCmtCount.text = "No Comment"
                    }
                   
                } else {
                    
                    DispatchQueue.main.async {
                        self.totalCmtCount.text = "\(commentsCountFromQuery) Comments"
                    }
                  
                }
                    
            case .failure(let error):
                print("CmtCount: \(error)")
            }
        }
        
    
    }
    
    @objc func panGestureRecognizerAction(sender: UIPanGestureRecognizer) {
        let translation = sender.translation(in: view)
        
        // Not allowing the user to drag the view upward
        guard translation.y >= 0 else { return }
        
        // setting x as 0 because we don't want users to move the frame side ways!! Only want straight up or down
        view.frame.origin = CGPoint(x: 0, y: self.pointOrigin!.y + translation.y)
        
        if sender.state == .ended {
            let dragVelocity = sender.velocity(in: view)
            if dragVelocity.y >= 1300 {
                self.dismiss(animated: true, completion: nil)
            } else {
                // Set back to original position of the view controller
                UIView.animate(withDuration: 0.3) {
                    self.view.frame.origin = self.pointOrigin ?? CGPoint(x: 0, y: 400)
                }
            }
        }
    }
    
}

extension CommentVC {
    
    func pinCmt(items: CommentModel, indexPath: Int) {
        
        APIManager().pinComment(commentId: items.comment_id) { result in
            switch result {
            case .success(let apiResponse):
                guard apiResponse.body?["message"] as? String == "success" else {
                    
                    DispatchQueue.main.async {
                        self.showErrorAlert("Ops !", msg: "Unable to pin this comment right now, please try again.")
                    }
                    return
                }
                
                
                DispatchQueue.main.async {
                    
                    self.CommentList[indexPath]._is_pinned = true
                    self.tableNode.reloadRows(at: [IndexPath(row: indexPath, section: 0)], with: .automatic)
                
                }
                
               
            case .failure(let error):
                print(error)
                
                DispatchQueue.main.async {
                    self.showErrorAlert("Ops !", msg: "Unable to pin this comment right now, please try again.")
                }
            }
        }
        
    }
    
    
    func unPinCmt(items: CommentModel, indexPath: Int) {
        
        APIManager().unpinComment(commentId: items.comment_id) { result in
            switch result {
            case .success(let apiResponse):
                guard apiResponse.body?["message"] as? String == "success" else {
                    
                    DispatchQueue.main.async {
                        self.showErrorAlert("Ops !", msg: "Unable to unpin this comment right now, please try again.")
                    }
                    return
                }
                
                
                DispatchQueue.main.async {
                    
                    self.CommentList[indexPath]._is_pinned = false
                    self.tableNode.reloadRows(at: [IndexPath(row: indexPath, section: 0)], with: .automatic)
                
                }
                
               
            case .failure(let error):
                print(error)
                
                DispatchQueue.main.async {
                    self.showErrorAlert("Ops !", msg: "Unable to unpin this comment right now, please try again.")
                }
            }
        }
    
    }
    
    
    func removeComment(items: CommentModel, indexPath: Int) {
        
        APIManager().deleteComment(commentId: items.comment_id) { result in
            switch result {
            case .success(let apiResponse):
                guard apiResponse.body?["message"] as? String == "success" else {
                    
                    DispatchQueue.main.async {
                        self.showErrorAlert("Ops !", msg: "Unable to remove this comment right now, please try again.")
                    }
                    return
                }
                
                
                DispatchQueue.main.async {
                    
                    self.CommentList.remove(at: indexPath)
                    self.tableNode.deleteRows(at: [IndexPath(item: indexPath, section: 0)], with: .automatic)
                    
                    if items.root_id == "nil" {
                        
                        self.removeIndexOfChildComment(from: items, start: indexPath)
                        
                    }
                    
                    showNote(text: "Comment deleted!")
                    self.calculateToTalCmt()
                    
                    
                }
                
               
            case .failure(let error):
                print(error)
                
                DispatchQueue.main.async {
                    self.showErrorAlert("Ops !", msg: "Unable to remove this comment right now, please try again.")
                }
            }
        }
    }
    
    
    func removeIndexOfChildComment(from: CommentModel, start: Int) {
        var indexPaths: [IndexPath] = []
        let rootId = from.comment_id
        
        for (index, item) in CommentList.enumerated() {
            if item.root_id == rootId {
                indexPaths.append(IndexPath(row: index, section: 0))
            }
        }
        
        CommentList.removeSubrange(start..<start+indexPaths.count)
        tableNode.deleteRows(at: indexPaths, with: .automatic)
    }
    

    
}

extension CommentVC {
    
    @objc func pinRequest() {
        
        if let cmt = editedComment, let index = editedIndexpath?.row {
            pinCmt(items: cmt, indexPath: index)
        }
    
    }
    
    @objc func unpinRequest() {
        
        if let cmt = editedComment, let index = editedIndexpath?.row {
            unPinCmt(items: cmt, indexPath: index)
        }
       
    }
    
    @objc func copyRequest() {
        
        if let index = editedIndexpath?.row {
            UIPasteboard.general.string = self.CommentList[index].text
            showNote(text: "Copied successfully")
        }
        
        
        
    }
    
    @objc func deleteRequest() {
        
        if let cmt = editedComment, let index = editedIndexpath?.row {
            removeComment(items: cmt, indexPath: index)
        }
       
    }
    
    @objc func reportRequest() {
        
        if let index = editedIndexpath?.row {
            
            let slideVC =  reportView()
            
            slideVC.comment_id = self.CommentList[index].comment_id
            slideVC.comment_report = true
            slideVC.modalPresentationStyle = .custom
            slideVC.transitioningDelegate = self
            global_presetingRate = Double(0.75)
            global_cornerRadius = 35
            
            delay(0.1) {
                self.present(slideVC, animated: true, completion: nil)
            }
            
        }
    
    }
    
}
