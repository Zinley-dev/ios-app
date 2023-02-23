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
    var cmtPage = 0
    @IBOutlet weak var totalCmtCount: UILabel!
    @IBOutlet weak var bView: UIView!
    //var currentItem: HighlightsModel!
    var hasSetPointOrigin = false
    var pointOrigin: CGPoint?
    
    //var lastDocumentSnapshot: DocumentSnapshot!
    //var query: Query!
    var reply_to_uid: String!
    var reply_to_cid: String!
    

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
        searchResultContainerView.backgroundColor = UIColor.black
        
        
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
//            self.updatePrevCmtTxt()
            
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

}

extension CommentVC {
    
    func textViewDidChange(_ textView: UITextView) {
        placeholderLabel.isHidden = !textView.text.isEmpty
        viewHeight.constant = textView.layer.frame.height + 25
        
        
        if let text = textView.text, text != "" {
            let curTxtLen = text.count
            print("pre: \(previousTxt), current: \(String(describing: textView.text))")
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
                print("User is looking for hashtag: \(hashtagToSearch)")
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
                print("User is looking for user: \(userToSearch)")
                let userToSearchTrimmed = String(userToSearch.dropFirst(1))

                if !userToSearchTrimmed.isEmpty {
                    self.searchResultContainerView.isHidden = false
                    self.autocompleteVC.search(text: userToSearchTrimmed, with: AutocompeteViewController.Mode.user)
                    isInAutocomplete = true

                }
                
            }
        } else {
             
            print("Just normal text")
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
        
        loadPinnedPost()
        
    }
    
    func loadPinnedPost() {
        
        wireDelegates()
        
    }
    
    
    
}

extension CommentVC {
    
    func wireDelegates() {
        
        self.tableNode.delegate = self
        self.tableNode.dataSource = self
        
        self.tableNode.reloadData()
        
        delay(1) {
            
            UIView.animate(withDuration: 0.5) {
                
                self.loadingView.alpha = 0
                
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
            searchResultContainerView.topAnchor.constraint(equalTo: view.topAnchor, constant: 10),
            searchResultContainerView.bottomAnchor.constraint(equalTo: cmtTxtView.topAnchor, constant: -22),
        ])
        searchResultContainerView.backgroundColor = UIColor.gray.withAlphaComponent(0.9)
        searchResultContainerView.isHidden = true
        
    }
    
    func setupTableNode() {
        
        self.tableNode = ASTableNode(style: .plain)
        self.applyStyle()
        self.tableNode.leadingScreensForBatching = 20
        self.tableNode.automaticallyRelayoutOnLayoutMarginsChanges = true
        self.tableNode.automaticallyAdjustsContentOffset = true
        
    }
    
    func setupPlaceholder() {
        
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
                tableNode.scrollToRow(at: IndexPath(row: indexPath.row, section: 0), at: .top, animated: true)
                
                let sheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
                
                
                let report = UIAlertAction(title: "Report", style: .default) { (alert) in
                    
                    /*
                    
                    let slideVC =  reportView()
                    
                    
                    slideVC.comment_id = self.CommentList[indexPath.row].Comment_id
                    slideVC.comment_report = true
                    slideVC.modalPresentationStyle = .custom
                    slideVC.transitioningDelegate = self
                    
                    
                    self.present(slideVC, animated: true, completion: nil)
                    */
                    
                }
                
                let copy = UIAlertAction(title: "Copy", style: .default) { (alert) in
                    
                    UIPasteboard.general.string = self.CommentList[indexPath.row].text
                    showNote(text: "Copied")
                    
                    
                }
                
                let pin = UIAlertAction(title: "Pin", style: .default) {  [self] (alert) in
                    
                    let item = CommentList[indexPath.row]
                    pinCmt(items: item, indexPath: indexPath.row)
                    
                    
                }
                
                let unPin = UIAlertAction(title: "Unpin", style: .default) { [self] (alert) in
                    
                   
                    let item = CommentList[indexPath.row]
                    unPinCmt(items: item, indexPath: indexPath.row)
                    
                }
                
                let delete = UIAlertAction(title: "Delete", style: .destructive) { [self] (alert) in
                    
                    let item = CommentList[indexPath.row]
                    removeComment(items: item, indexPath: indexPath.row)
                    
                }
                
                let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (alert) in
                    
                }
                
                
                if uid == self.post.userUID {
                    
                    if CommentList[indexPath.row].is_title == false {
                        
                        if CommentList[indexPath.row].isReply == false {
                            
                            if CommentList[indexPath.row].is_pinned == true {
                                
                                sheet.addAction(unPin)
                                
                            } else {
                                
                                sheet.addAction(pin)
                                
                            }
                            
                        }
                        
                    }
                    
                    
                    
                    if uid == CommentList[indexPath.row].comment_uid {
                              
                        if CommentList[indexPath.row].is_title == true {
                            
                            sheet.addAction(copy)
                            sheet.addAction(cancel)
                            
                        } else {
                            
                            sheet.addAction(copy)
                            sheet.addAction(delete)
                            sheet.addAction(cancel)
                            
                        }
                     
                        
                    } else {
                        
                        
                        sheet.addAction(copy)
                        sheet.addAction(report)
                        sheet.addAction(delete)
                        sheet.addAction(cancel)
                        
                    }
                    
                    
                } else {
                    
                    if uid == CommentList[indexPath.row].comment_uid {
                        
                        sheet.addAction(copy)
                        sheet.addAction(delete)
                        sheet.addAction(cancel)
                        
                    } else {
                        
                        sheet.addAction(copy)
                        sheet.addAction(report)
                        sheet.addAction(cancel)
                        
                        
                    }
                    
                }
                
                
               
                self.present(sheet, animated: true, completion: nil)
                
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
        let post = self.CommentList[indexPath.row]
        
        return makeCommentNodeBlock(with: post, indexPath: indexPath)
    }

    private func makeCommentNodeBlock(with post: CommentModel, indexPath: IndexPath) -> ASCellNodeBlock {
        let nodeBlock: ASCellNodeBlock = {
            let node = CommentNode(with: post)
            node.neverShowPlaceholders = true
            node.debugName = "Node \(indexPath.row)"
            
            node.replyBtn = { (node) in
            
                self.handleReply(for: post, indexPath: indexPath)
            }
            
            
            node.reply = { (nodes) in
                
                self.handleReplyBtn(for: post, commentNode: node, indexPath: indexPath)
            }
            

            return node
        }
        
        return nodeBlock
    }


    private func handleReplyBtn(for post: CommentModel, commentNode: CommentNode?, indexPath: IndexPath) {
        guard commentNode != nil else {
            return
        }

        // Update previous comment id
        if self.prev_id != post.comment_id {
            self.prev_id = post.comment_id
        }

        let isRootComment = post.root_id == "nil"
        let hasReply = post.has_reply

        // Prepare data for the new comment
        var newDict: [String: Any] = [
            "Comment_uid": post.comment_uid!,
            "createdAt": post.createdAt!,
            "text": post.text!,
            "isReply": !isRootComment,
            "post_id": post.post_id!,
            "root_id": isRootComment ? post.comment_id! : post.root_id!,
            "has_reply": false,
            "reply_to": post.reply_to!,
            "is_title": post.is_title ?? false,
            "owner_uid": post.owner_uid!
        ]

        if let updatedAt = post.updatedAt {
            newDict["updatedAt"] = updatedAt
        } else {
            newDict["updatedAt"] = Date()
        }

        if let lastModified = post.last_modified {
            newDict["last_modified"] = lastModified
        } else {
            newDict["last_modified"] = Date()
        }

        // Update comment list with the new comment
        let newComment = CommentModel(postKey: post.comment_id, Comment_model: newDict)
        self.CommentList[indexPath.row] = newComment

        // Update the corresponding row in the table view
        let indexPaths = [indexPath]
        let animation: UITableView.RowAnimation = .automatic

        self.tableNode.performBatchUpdates({
            if hasReply! {
                // Update existing reply
                let newIndex = self.findIndexForRootCmt(post: post)
                let newPost = self.CommentList[newIndex]

                self.loadReplied(item: newPost, indexex: indexPath.row, root_index: newIndex)
            } else {
                // Create new reply
                self.loadReplied(item: post, indexex: indexPath.row, root_index: indexPath.row)
            }

            self.tableNode.reloadRows(at: indexPaths, with: animation)
        }, completion: nil)
    }


    private func handleReply(for post: CommentModel, indexPath: IndexPath) {
        // Handle reply submitted
        // ...
        
        self.ReplyBtn(item: post)
    }

    
}

extension CommentVC {
    
    func retrieveNextPageWithCompletion( block: @escaping ([[String: Any]]) -> Void) {
        
        APIManager().getComment(postId: post.id, page: cmtPage) { result in
                switch result {
                case .success(let apiResponse):
                    guard apiResponse.body?["message"] as? String == "success",
                          let data = apiResponse.body?["data"] as? [[String: Any]] else {
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
            let inputItem = CommentModel(postKey: item["postId"] as! String, Comment_model: item)
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
            let item = CommentModel(postKey: i["postId"] as! String, Comment_model: i)
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
            
            if let uid = CommentList[cIndex].comment_uid {
                //getuserName(uid: uid)
                
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
            
            
            tableNode.scrollToRow(at: IndexPath(row: cIndex, section: 0), at: .top, animated: true)
            
        }
        
    }
    
    func findIndexForRootCmt(post: CommentModel) -> Int {
        var indexMap = [String: Int]()
        for (index, comment) in CommentList.enumerated() {
            indexMap[comment.comment_id] = index
        }
        if let rootIndex = indexMap[post.root_id] {
            return rootIndex
        }
        return -1
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
        
        if let item_id = item.comment_id {
            
            /*
            let db = DataService.instance.mainFireStoreRef
            
         
            if item.lastCmtSnapshot == nil {
                
              
                CmtQuery = db.collection("Comments").whereField("isReply", isEqualTo: true).whereField("is_title", isEqualTo: false).whereField("cmt_status", isEqualTo: "valid").whereField("root_id", isEqualTo: item_id).order(by: "timeStamp", descending: false).limit(to: 5)
                
                
            } else {
                
                CmtQuery = db.collection("Comments").whereField("isReply", isEqualTo: true).whereField("is_title", isEqualTo: false).whereField("cmt_status", isEqualTo: "valid").whereField("root_id", isEqualTo: item_id).order(by: "timeStamp", descending: false).limit(to: 5).start(afterDocument: item.lastCmtSnapshot)
            }
       
            CmtQuery.getDocuments {  querySnapshot, error in
                guard let snapshot = querySnapshot else {
                    print("Error fetching snapshots: \(error!)")
                    return
                }
                
                guard snapshot.count > 0 else {
                    return
                }
                
                
                var actualPost = [QueryDocumentSnapshot]()
                
                for item in snapshot.documents {
                    
                    let check = CommentModel(postKey: item.documentID, Comment_model: item.data())
                    
                    
                    if self.checkduplicateLoading(post: check) == false {
                                        
                        actualPost.append(item)
                        
                    }
                    
                    
                }
                
                if actualPost.isEmpty != true {
                    
                    
                    let section = 0
                    var indexPaths: [IndexPath] = []

                    var last = 0
                    var start = indexex + 1
                    
                    
                    
                    for row in start...actualPost.count + start - 1 {
                        
                        let path = IndexPath(row: row, section: section)
                        indexPaths.append(path)
                        
                        last = row
                        
                    }
                    
                    
                    
                    for item in actualPost {
                        
                        var updatedItem = item.data()
                        
                        if item == actualPost.last {
                            
                            
                            updatedItem.updateValue(true, forKey: "has_reply")
                            
                        }
                        
                        
                        let items = CommentModel(postKey: item.documentID, Comment_model: updatedItem)
         
                        self.CommentList.insert(items, at: start)
                        
                        
                        if item == snapshot.documents.last {
                            
                            self.CommentList[start].lastCmtSnapshot = actualPost.last
                            
                        }
                        
                        start += 1
                        
                    }
                    
                    self.tableNode.insertRows(at: indexPaths,with: .none)
                    
                    self.CommentList[root_index].lastCmtSnapshot = actualPost.last
                    
                    
                    var updatePath: [IndexPath] = []
                    
                    for row in indexex + 1 ... self.CommentList.count - 1 {
                        let path = IndexPath(row: row, section: 0)
                        updatePath.append(path)
                    }
                    
                    
                    self.tableNode.reloadRows(at: updatePath, with: .automatic)
                    
                    
                    self.tableNode.scrollToRow(at: IndexPath(row: last, section: 0), at: .bottom, animated: true)
                    
                        
                    
                }
            
                
            }
            
             */
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
        
        /*
        let db = DataService.instance.mainFireStoreRef.collection("Comments")
        
        if items.Comment_id != "nil" {
            
            db.document(items.Comment_id).updateData(["is_pinned": true, "update_timestamp": FieldValue.serverTimestamp()]) { (err) in
                if err != nil {
                    
                    self.showErrorAlert("Ops!", msg: err!.localizedDescription)
                    
                } else {
                    
                    
                    self.CommentList[indexPath]._is_pinned = true
                    self.tableNode.reloadRows(at: [IndexPath(row: indexPath, section: 0)], with: .automatic)
                    
                    
                }
            }
            
        } else {
            
            self.showErrorAlert("Ops !", msg: "Unable to pin this comment right now, please try again.")
            
            
        } */
    }
    
    
    func unPinCmt(items: CommentModel, indexPath: Int) {
        
        /*
        let db = DataService.instance.mainFireStoreRef.collection("Comments")
        
        if items.Comment_id != "nil" {
            
            db.document(items.Comment_id).updateData(["is_pinned": false, "update_timestamp": FieldValue.serverTimestamp()]) { (err) in
                if err != nil {
                    
                    self.showErrorAlert("Ops!", msg: err!.localizedDescription)
                    
                } else {
                    
                    self.CommentList[indexPath]._is_pinned = false
                    self.tableNode.reloadRows(at: [IndexPath(row: indexPath, section: 0)], with: .automatic)
                    
                }
            }
            
        } else {
            
            self.showErrorAlert("Ops !", msg: "Unable to unpin this comment right now, please try again.")
            
            
        }
        */
        
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
