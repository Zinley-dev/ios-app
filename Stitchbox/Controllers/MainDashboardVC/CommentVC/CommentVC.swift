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
    //var CommentList = [CommentModel]()
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
                
                DispatchQueue.main.async { // Make sure you're on the main thread here
                    
                    
                    self.avatarView.image = image
                    
                    //try? imageStorage.setObject(image, forKey: url)
                    
                }
                
            } else {
                
                
             AF.request(avatarUrl).responseImage { response in
                    
                    
                    switch response.result {
                    case let .success(value):
                        self.avatarView.image = value
                        try? imageStorage.setObject(value, forKey: avatarUrl)
                    case let .failure(error):
                        print(error)
                    }
                    
                    
                    
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
           
        return {
            let node = CommentNode(with: post)
            node.neverShowPlaceholders = true
            node.debugName = "Node \(indexPath.row)"
            
            node.replyBtn = { (node) in
            
                self.ReplyBtn(item: post)
                  
            }
            
            node.reply = { (nodes) in
                
                if self.prev_id != nil {
                    
                    if self.prev_id != self.CommentList[indexPath.row].Comment_id {
                        
                        self.CmtQuery = nil
                        self.prev_id = self.CommentList[indexPath.row].Comment_id
                        
                    }
                    
                    
                } else {
                    
                    self.prev_id = self.CommentList[indexPath.row].Comment_id
                    
                }
                
  
                if post.root_id != "nil", post.has_reply == true {
                    
                    let newIndex = self.findIndexForRootCmt(post: post)
                    let newPost = self.CommentList[newIndex]
                               
                    
                    //post.update_timestamp!
                
                    var newDict = ["Comment_uid": post.Comment_uid!, "timeStamp": post.timeStamp!, "text": post.text!, "cmt_status": "valid", "isReply": true, "Mux_playbackID": post.Mux_playbackID!, "root_id": post.root_id!, "has_reply": false, "reply_to": post.reply_to!, "owner_uid": post.owner_uid!] as [String : Any]
                    
                    if post.update_timestamp != nil {
                        
                        newDict.updateValue(post.update_timestamp!, forKey: "update_timestamp")
                        
                    } else {
                        
                        newDict.updateValue(FieldValue.serverTimestamp(), forKey: "update_timestamp")
                        
                    }
                    
                    if post.last_modified != nil {
                        
                        newDict.updateValue(post.last_modified!, forKey: "last_modified")
                        
                    } else {
                        
                        newDict.updateValue(FieldValue.serverTimestamp(), forKey: "last_modified")
                        
                    }
                    
                    if post.is_title == true {
                        
                        newDict.updateValue(true, forKey: "is_title")
                        
                    } else {
                        
                        newDict.updateValue(false, forKey: "is_title")
                        
                    }
                
                    let elem = CommentModel(postKey: post.Comment_id, Comment_model: newDict)
                    self.CommentList[indexPath.row] = elem
                    
                    self.tableNode.reloadRows(at: [IndexPath(row: indexPath.row, section: 0)], with: .automatic)
                    
                    self.loadReplied(item: newPost, indexex: indexPath.row, root_index: newIndex)
                    
                    
                } else {
                    
                    
                    
                    var newDict = ["Comment_uid": post.Comment_uid!, "timeStamp": post.timeStamp!, "text": post.text!, "cmt_status": "valid", "isReply": false, "Mux_playbackID": post.Mux_playbackID!, "root_id": "nil", "has_reply": false, "reply_to": post.reply_to!, "is_title": false, "owner_uid": post.owner_uid!] as [String : Any]
                    
                    
                    if post.update_timestamp != nil {
                        
                        newDict.updateValue(post.update_timestamp!, forKey: "update_timestamp")
                        
                    } else {
                        
                        newDict.updateValue(FieldValue.serverTimestamp(), forKey: "update_timestamp")
                        
                    }
                    
                    if post.last_modified != nil {
                        
                        newDict.updateValue(post.last_modified!, forKey: "last_modified")
                        
                    } else {
                        
                        newDict.updateValue(FieldValue.serverTimestamp(), forKey: "last_modified")
                        
                    }
                    
                    if post.is_title == true {
                        
                        newDict.updateValue(true, forKey: "is_title")
                        
                    } else {
                        
                        newDict.updateValue(false, forKey: "is_title")
                        
                    }
                
                    let elem = CommentModel(postKey: post.Comment_id, Comment_model: newDict)
                    self.CommentList[indexPath.row] = elem
                    
                    self.tableNode.reloadRows(at: [IndexPath(row: indexPath.row, section: 0)], with: .automatic)
                    
                    self.loadReplied(item: post, indexex: indexPath.row, root_index: indexPath.row)
                    
                }
                
                
                
                
            }
            
            return node
        }
        
    }
    
    
}

extension CommentVC {
    
    func ReplyBtn(item: CommentModel){
        
        
        let cIndex = findCommentIndex(item: item)
        
        
        if cIndex != -1 {
            
            cmtTxtView.becomeFirstResponder()
            
            if let uid = CommentList[cIndex].Comment_uid {
                getuserName(uid: uid)
            } else{
                placeholderLabel.text = "Reply to @Undefined"
            }
            
            if CommentList[cIndex].isReply == false {
                root_id = CommentList[cIndex].Comment_id
                index = cIndex
            } else {
                root_id = CommentList[cIndex].root_id
                index = cIndex
            }
            
            
            reply_to_uid =  CommentList[cIndex].Comment_uid
            reply_to_cid =  CommentList[cIndex].Comment_id
            
            
            tableNode.scrollToRow(at: IndexPath(row: cIndex, section: 0), at: .top, animated: true)
            
        }
        
    }
    
    func findIndexForRootCmt(post: CommentModel) -> Int {
        
        index = 0
        
        
        for item in CommentList {
            
            
            if item.Comment_id == post.root_id
            {
                return index
                
            } else {
                
                index += 1
            }
            
        }
        
        return index
        
    }
    
}

extension CommentVC {
    
    func loadReplied(item: CommentModel, indexex: Int, root_index: Int) {
        
        if let item_id = item.Comment_id {
            
            
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
