//
//  CommentNode.swift
//  Stitchbox
//
//  Created by Khoi Nguyen on 2/22/23.
//

import UIKit
import AsyncDisplayKit
import Alamofire
import ActiveLabel


fileprivate let FontSize: CGFloat = 13
fileprivate let OrganizerImageSize: CGFloat = 30
fileprivate let HorizontalBuffer: CGFloat = 10


class CommentNode: ASCellNode {
    
    var replyUsername = ""
    var finalText: NSAttributedString!
    var replyUID = ""
    weak var post: CommentModel!
    var count = 0
    var userNameNode: ASTextNode!
    var CmtNode: ASTextNode!
    var replyToNode: ASTextNode!
    var timeNode: ASTextNode!
    var imageView: ASImageNode!
    var AvatarNode: ASNetworkImageNode!
    var textNode: ASTextNode!
    var loadReplyBtnNode: ASButtonNode!
    var replyBtnNode: ASButtonNode!
    var InfoNode: ASDisplayNode!
    let selectedColor = UIColor(red: 248/255, green: 189/255, blue: 91/255, alpha: 1.0)
    var replyBtn : ((ASCellNode) -> Void)?
    var reply : ((ASCellNode) -> Void)?
   
    
    var like : ((ASCellNode) -> Void)?
    
    init(with post: CommentModel) {
        
        self.post = post
        self.userNameNode = ASTextNode()
        self.CmtNode = ASTextNode()
        self.AvatarNode = ASNetworkImageNode()
        self.loadReplyBtnNode = ASButtonNode()
        self.InfoNode = ASDisplayNode()
        self.imageView = ASImageNode()
        self.textNode = ASTextNode()
        self.timeNode = ASTextNode()
        self.replyBtnNode = ASButtonNode()
        self.replyToNode = ASTextNode()
        
        super.init()
        
        
        self.backgroundColor = UIColor(red: 43, green: 43, blue: 43)
        self.replyBtnNode.setTitle("Reply", with: UIFont(name:"Roboto-Medium",size: FontSize)!, with: UIColor.lightGray, for: .normal)
        self.replyBtnNode.addTarget(self, action: #selector(CommentNode.replyBtnPressed), forControlEvents: .touchUpInside)
        self.selectionStyle = .none
        AvatarNode.contentMode = .scaleAspectFill
        AvatarNode.cornerRadius = OrganizerImageSize/2
        AvatarNode.clipsToBounds = true
        CmtNode.truncationMode = .byTruncatingTail
       
        let paragraphStyles = NSMutableParagraphStyle()
        paragraphStyles.alignment = .left
        
        AvatarNode.shouldRenderProgressImages = true
        
        
        
        let textAttributes: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: FontSize, weight: .light),NSAttributedString.Key.foregroundColor: UIColor.white]
        
        
        let timeAttributes: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: FontSize, weight: .light),NSAttributedString.Key.foregroundColor: UIColor.lightGray]
        
        if self.post.reply_to != "" {
           
            if let username = self.post.reply_to_username as? String {
                                
               let username = "\(username)"
                self.replyUsername = username
               
                if self.post.createdAt != nil {
                    
                    var date: Date?
            
                    let user = NSMutableAttributedString()
              
                    let username = NSAttributedString(string: "\(username): ", attributes: textAttributes)
                    let text = NSAttributedString(string: self.post.text, attributes: textAttributes)
                    var time: NSAttributedString?
                    
                    
                    
                    
                    if self.post.is_title == true {
                    
                        if self.post.createdAt == self.post.last_modified {
                            
                            time = NSAttributedString(string: "\(timeAgoSinceDate(self.post.createdAt, numericDates: true))", attributes: timeAttributes)
                            
                        } else {
                            
                            time = NSAttributedString(string: "Edited \(timeAgoSinceDate(self.post.last_modified, numericDates: true))", attributes: timeAttributes)
                        }
                        
                    } else {
                        
                        time = NSAttributedString(string: "\(timeAgoSinceDate(self.post.createdAt, numericDates: true))", attributes: timeAttributes)
                    }
                      
                    user.append(username)
                    user.append(text)
                    
                    
                    
                    self.timeNode.attributedText = time
                    self.CmtNode.attributedText = user
                    
                    
                } else {
                                               
                    
                    let user = NSMutableAttributedString()
              
                    let username = NSAttributedString(string: "\(username): ", attributes: textAttributes)
                    
                    let text = NSAttributedString(string: self.post.text, attributes: textAttributes)
                   
                    let time = NSAttributedString(string: "Just now", attributes: timeAttributes)
                    
                    user.append(username)
                    user.append(text)
                    
                    
                    self.timeNode.attributedText = time
                    self.CmtNode.attributedText = user
                   
                    
                }
                
                                  
                
            }
           
          
        } else {
            
            
            if self.post.createdAt != nil {
                
                
                var date: Date?
                           
                
                let user = NSMutableAttributedString()
                
                let text = NSAttributedString(string: self.post.text, attributes: textAttributes)
              
                var time: NSAttributedString?
                
                if self.post.is_title == true {
                    
                    
                    if self.post.createdAt == self.post.last_modified {
                        
                
                        time = NSAttributedString(string: "\(timeAgoSinceDate(self.post.createdAt, numericDates: true))", attributes: timeAttributes)
                        
                    } else {
                        
                        time = NSAttributedString(string: "Edited \(timeAgoSinceDate(self.post.last_modified, numericDates: true))", attributes: timeAttributes)
                    }
                    
                } else {
                    
                    time = NSAttributedString(string: "\(timeAgoSinceDate(self.post.createdAt, numericDates: true))", attributes: timeAttributes)
                    
                }
                
               
                
                user.append(text)
                
                
                
                timeNode.attributedText = time
                CmtNode.attributedText = user
               
                
            } else {
                
                
                let user = NSMutableAttributedString()
             
                let text = NSAttributedString(string: self.post.text, attributes: textAttributes)
               
                let time = NSAttributedString(string: "Just now", attributes: timeAttributes)
                
                user.append(text)
                
                
                timeNode.attributedText = time
                CmtNode.attributedText = user
               
                
            }
            
        }
        
        
        InfoNode.backgroundColor = UIColor.clear
        
        loadReplyBtnNode.backgroundColor = UIColor.clear
        CmtNode.backgroundColor = UIColor.clear
        replyToNode.backgroundColor = UIColor.clear
        userNameNode.backgroundColor = UIColor.clear
        
        imageView.contentMode = .scaleAspectFit
        imageView.frame = CGRect(x: 5.2, y: 2, width: 20, height: 20)
    
        
    
        textNode.isLayerBacked = true
    
        textNode.backgroundColor = UIColor.clear
        imageView.backgroundColor = UIColor.clear
        imageView.contentMode = .scaleAspectFit
                                                     
        textNode.frame = CGRect(x: 0, y: 30, width: 30, height: 20)
       
        
        let button = ASButtonNode()
        button.frame = CGRect(x: 0, y: 0, width: 30, height: 60)
        button.backgroundColor = UIColor.clear
        
        
        InfoNode.addSubnode(imageView)
        InfoNode.addSubnode(textNode)
        InfoNode.addSubnode(button)
   
        button.addTarget(self, action: #selector(CommentNode.LikedBtnPressed), forControlEvents: .touchUpInside)
        loadReplyBtnNode.addTarget(self, action: #selector(CommentNode.repliedBtnPressed), forControlEvents: .touchUpInside)
        
        
        loadInfo(uid: self.post.comment_uid)
        
        
        if self.post.has_reply == true, self.post.IsNoti == false {
            
            loadCmtCount(id: self.post.comment_id)
            
        }
        
        
        checkLikeCmt(id: self.post.comment_id)
        
        
        //
        
        
        automaticallyManagesSubnodes = true
        
        // add Button
        
        //userNameNode
        userNameNode.addTarget(self, action: #selector(CommentNode.usernameBtnPressed), forControlEvents: .touchUpInside)
        AvatarNode.addTarget(self, action: #selector(CommentNode.usernameBtnPressed), forControlEvents: .touchUpInside)
        
         
        
    }
    
    @objc func replyToBtnPressed() {
        
        if let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "UserProfileVC") as? UserProfileVC {
            
            if let vc = UIViewController.currentViewController() {
            
                
                 
            }
            
            
        }
        
    }
    
    @objc func usernameBtnPressed() {
        
        
        if let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "UserProfileVC") as? UserProfileVC {
            
            if let vc = UIViewController.currentViewController() {
            
                
                 
            }
            
            
        }
        
    }
    
    
    @objc func LikedBtnPressed(sender: AnyObject!) {
  
        /*
        let db = DataService.instance.mainFireStoreRef
        
        db.collection("Comments_Like").document(post.Comment_id + Auth.auth().currentUser!.uid).getDocument {  querySnapshot, error in
            
            guard let snapshot = querySnapshot else {
               
                print("Error fetching snapshots: \(error!)")
                return
            }
            
            if snapshot.exists {
                
                self.unlikePerform(id: snapshot.documentID)
                
            } else {
                
                self.updateLikeActivtyLog()
                self.imageView.image = UIImage(named: "heart-fill")
                self.likePerform()
                
            }
            
        } */
        
    }
    
    func updateLikeActivtyLog() {
        
   
        
        
        
    }
    
    func unlikePerform(id: String) {
        
        /*
        let db = DataService.instance.mainFireStoreRef.collection("Comments_Like")
              
        db.document(id).delete { (err) in
            
            if err != nil {
                print(err!.localizedDescription)
            }
            
            self.imageView.image = UIImage(named: "Icon ionic-ios-heart-empty")
            
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .center
            
            let LikeAttributes: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: UIFont(name:"Roboto-Medium",size: FontSize)!, NSAttributedString.Key.foregroundColor: UIColor.lightGray, NSAttributedString.Key.paragraphStyle: paragraphStyle]
            
            
            
            self.count -= 1
            let like = NSMutableAttributedString(string: "\(formatPoints(num: Double(self.count)))", attributes: LikeAttributes)
            self.textNode.attributedText = like
            
        }
        */
        
        
    }
    
    func likePerform() {
        /*
        SwiftPublicIP.getPublicIP(url: PublicIPAPIURLs.ipv4.icanhazip.rawValue) {  (string, error) in
            if let error = error {
                
                print(error.localizedDescription)
                
            } else if let string = string {
                
                DispatchQueue.main.async {
                    
                    let device = UIDevice().type.rawValue
                    
                    var data = [String:Any]()
                    
                    data = ["like_uid": Auth.auth().currentUser!.uid, "timeStamp": FieldValue.serverTimestamp(), "Device": device, "cmt_status": "valid", "Mux_playbackID": self.post.Mux_playbackID!, "Update_timestamp": FieldValue.serverTimestamp(), "cmt_id": self.post.Comment_id!, "query": string] as [String : Any]
                    
                    
        
                    let db = DataService.instance.mainFireStoreRef.collection("Comments_Like").document(self.post.Comment_id + Auth.auth().currentUser!.uid)
                    
                    db.setData(data) { errors in
                        if errors != nil {
                            
                            print(errors!.localizedDescription)
                            return
                            
                        }
                        
                        self.imageView.image = UIImage(named: "heart-fill")
                        
                        let paragraphStyle = NSMutableParagraphStyle()
                        paragraphStyle.alignment = .center
                        
                        let LikeAttributes: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: UIFont(name:"Roboto-Medium",size: FontSize)!, NSAttributedString.Key.foregroundColor: self.selectedColor, NSAttributedString.Key.paragraphStyle: paragraphStyle]
                        
                       
                        
                        self.count += 1
                        let like = NSMutableAttributedString(string: "\(formatPoints(num: Double(self.count)))", attributes: LikeAttributes)
                        self.textNode.attributedText = like
                    }
                    
            
                    }
                    
                }
                
            }
        */
    }
 
    
    func checkLikeCmt(id: String) {
        
        /*
        let db = DataService.instance.mainFireStoreRef
        
        
        db.collection("Comments_Like").whereField("cmt_id", isEqualTo: id).getDocuments {  querySnapshot, error in
            
            guard let snapshot = querySnapshot else {
               
                print("Error fetching snapshots: \(error!)")
                return
            }
            
            if snapshot.isEmpty != true {
                
                db.collection("Comments_Like").document(self.post.Comment_id + Auth.auth().currentUser!.uid).getDocument {  querySnapshot, error in
                    
                    guard let snapshots = querySnapshot else {
                       
                        print("Error fetching snapshots: \(error!)")
                        return
                    }
                    
                    if snapshots.exists {
                        
                        self.imageView.image = UIImage(named: "heart-fill")
                        
                        let paragraphStyle = NSMutableParagraphStyle()
                        paragraphStyle.alignment = .center
                        
                        let LikeAttributes: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: UIFont(name:"Roboto-Medium",size: FontSize)!, NSAttributedString.Key.foregroundColor: self.selectedColor, NSAttributedString.Key.paragraphStyle: paragraphStyle]
                      
                        
                        self.count = snapshot.count
                        let like = NSMutableAttributedString(string: "\(formatPoints(num: Double(snapshot.count)))", attributes: LikeAttributes)
                        self.textNode.attributedText = like
                        
                        
                    } else {
                        
                        self.imageView.image = UIImage(named: "Icon ionic-ios-heart-empty")
                        
                        let paragraphStyle = NSMutableParagraphStyle()
                        paragraphStyle.alignment = .center
                        
                        let LikeAttributes: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: UIFont(name:"Roboto-Medium",size: FontSize)!, NSAttributedString.Key.foregroundColor: UIColor.lightGray, NSAttributedString.Key.paragraphStyle: paragraphStyle]
                        self.count = snapshot.count
                        let like = NSMutableAttributedString(string: "\(formatPoints(num: Double(snapshot.count)))", attributes: LikeAttributes)
                        self.textNode.attributedText = like
                        
                    }
                    
                    
                }
                      
               
            } else {
                
                let paragraphStyle = NSMutableParagraphStyle()
                paragraphStyle.alignment = .center
                
                let LikeAttributes: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: UIFont(name:"Roboto-Medium",size: FontSize)!, NSAttributedString.Key.foregroundColor: UIColor.lightGray, NSAttributedString.Key.paragraphStyle: paragraphStyle]
                let like = NSMutableAttributedString(string: "", attributes: LikeAttributes)
                self.textNode.attributedText = like
                self.count = snapshot.count
                self.imageView.image = UIImage(named: "Icon ionic-ios-heart-empty")
                
                
                UIView.animate(withDuration: 0, delay: 0, options: .curveEaseOut, animations:  {
                    self.view.layoutIfNeeded()
                }, completion: { (completed) in
                    
                })
                
                
            }
            
            
        }
        */
        
    }
    
    

    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        
        
        let headerSubStack = ASStackLayoutSpec.vertical()
        
        
        AvatarNode.style.preferredSize = CGSize(width: OrganizerImageSize, height: OrganizerImageSize)
        InfoNode.style.preferredSize = CGSize(width: 30.0, height: 60.0)
        
        headerSubStack.style.flexShrink = 16.0
        headerSubStack.style.flexGrow = 16.0
        headerSubStack.spacing = 8.0
        
        let horizontalSubStack = ASStackLayoutSpec.horizontal()
        horizontalSubStack.spacing = 10
        horizontalSubStack.justifyContent = ASStackLayoutJustifyContent.start
        horizontalSubStack.children = [timeNode, replyBtnNode]
        //replyBtnNode
     
        
        
        if self.post.has_reply == true, self.post.IsNoti == false {
            
            headerSubStack.children = [userNameNode, CmtNode, horizontalSubStack, loadReplyBtnNode]
            
            
        } else {
            
            headerSubStack.children = [userNameNode, CmtNode, horizontalSubStack]
            
        }
      
  
        let headerStack = ASStackLayoutSpec.horizontal()
      
        
        headerStack.spacing = 10
        headerStack.justifyContent = ASStackLayoutJustifyContent.start
        
        headerStack.children = [AvatarNode, headerSubStack, InfoNode]
        
        //addActiveLabelToCmtNode()
     
        if self.post.isReply == true {
            
            return ASInsetLayoutSpec(insets: UIEdgeInsets(top: 16.0, left: 40, bottom: 16, right: 20), child: headerStack)
            
        } else {
            
            return ASInsetLayoutSpec(insets: UIEdgeInsets(top: 16.0, left: 16, bottom: 16, right: 20), child: headerStack)
            
        }
        
       
        
    }
    
    func addReplyUIDBtn(label: ActiveLabel) {
        
        DispatchQueue.main.async {
            
            self.replyToNode.attributedText = NSAttributedString(string: "\(self.replyUsername): ", attributes: [NSAttributedString.Key.font: UIFont(name:"Roboto-Light",size: FontSize)!,NSAttributedString.Key.foregroundColor: UIColor.white])
            let size = self.replyToNode.attributedText?.size()
            
            let userButton = ASButtonNode()
            userButton.backgroundColor = UIColor.clear
            userButton.frame = CGRect(x: 0, y: 0, width: size!.width, height: size!.height)
            self.CmtNode.view.addSubnode(userButton)
            
            userButton.addTarget(self, action: #selector(CommentNode.replyToBtnPressed), forControlEvents: .touchUpInside)
            
        
        }
        
        
    }
    
    
    @objc func replyBtnPressed(sender: AnyObject!) {
  
        replyBtn?(self)
  
        
    }
    
    
    override func layout() {
        addActiveLabelToCmtNode()
    }
    
    
    func addActiveLabelToCmtNode() {
        
        DispatchQueue.main.async {
            
            self.CmtNode.view.isUserInteractionEnabled = true
            
            
            let label =  ActiveLabel()
            
            //
            self.CmtNode.view.addSubview(label)
            
            label.translatesAutoresizingMaskIntoConstraints = false
            label.topAnchor.constraint(equalTo: self.CmtNode.view.topAnchor, constant: 0).isActive = true
            label.leadingAnchor.constraint(equalTo: self.CmtNode.view.leadingAnchor, constant: 0).isActive = true
            label.trailingAnchor.constraint(equalTo: self.CmtNode.view.trailingAnchor, constant: 0).isActive = true
            label.bottomAnchor.constraint(equalTo: self.CmtNode.view.bottomAnchor, constant: 0).isActive = true
            
                    
            label.customize { label in
                
               
                label.numberOfLines = Int(self.CmtNode.lineCount)
                label.enabledTypes = [.mention, .hashtag, .url]
                
                label.attributedText = self.CmtNode.attributedText
                //label.attributedText = textAttributes
            
                label.hashtagColor = UIColor(red: 85.0/255, green: 172.0/255, blue: 238.0/255, alpha: 1)
                label.mentionColor = self.selectedColor
                label.URLColor = UIColor(red: 135/255, green: 206/255, blue: 250/255, alpha: 1)
                
                if self.post.reply_to != "" {
                    self.addReplyUIDBtn(label: label)
                }
                
                
                label.handleMentionTap {  mention in
                    print(mention)
                    self.checkIfUserValidAndPresentVC(username: mention)
                }
                
                label.handleHashtagTap { hashtag in
                          
                    var selectedHashtag = hashtag
                    selectedHashtag.insert("#", at: selectedHashtag.startIndex)
                    
                    
                }
                
                label.handleURLTap { string in
                    
                    
                    
                    let url = string.absoluteString
                    
                    if url.contains("https://dualteam.page.link/") {
                              
                        guard let components = URLComponents(url: string, resolvingAgainstBaseURL: false),let queryItems = components.queryItems else {
                            
                            return
                            
                        }
                        
                        for queryItem in queryItems {
                            
                            if queryItem.name == "p" {
                                
                                if let id = queryItem.value {
                                    
                                    /*
                                    let db = DataService.instance.mainFireStoreRef
                                    
                                    
                                    db.collection("Highlights").document(id).getDocument {  (snap, err) in
                                        
                                        if err != nil {
                                            
                                            print(err!.localizedDescription)
                                            return
                                        }
                                        
                                        
                                        if snap?.exists != false {
                                            
                                            if let status = snap!.data()!["h_status"] as? String, let owner_uid = snap!.data()!["userUID"] as? String, let mode = snap!.data()!["mode"] as? String {
                                                
                                                if status == "Ready", !global_block_list.contains(owner_uid) {
                                                    
                                                    if mode != "Only me" {
                                                        
                                                        if mode == "Followers"  {
                                                            
                                                            if global_following_list.contains(owner_uid) ||  owner_uid == Auth.auth().currentUser?.uid {
                                                                
                                                                let i = HighlightsModel(postKey: snap!.documentID, Highlight_model: snap!.data()!)
                                                                self.presentViewController(id: id, items: [i])
                                                                
                                                            } else {
                                                                
                                                                if let vc = UIViewController.currentViewController() {
                                                                    
                                                                    if vc is notificationVC {
                                                                        
                                                                        if let update = vc as? notificationVC {
                                                                            update.showErrorAlert("Oops!", msg: "This video can't be viewed now.")
                                                                        }
                                                                        
                                                                    } else if vc is CommentNotificationVC {
                                                                        
                                                                        if let update = vc as? CommentNotificationVC {
                                                                            update.showErrorAlert("Oops!", msg: "This video can't be viewed now.")
                                                                        }
                                                                        
                                                                    }
                                                                                                              
                                                                     
                                                                }
                                                                
                                                            }
                                                            
                                                        } else if mode == "Public" {
                                                            
                                                            let i = HighlightsModel(postKey: snap!.documentID, Highlight_model: snap!.data()!)
                                                            self.presentViewController(id: id, items: [i])
                                                            
                                                        }
                                                        
                                                    } else{
                                                        
                                                        if owner_uid == Auth.auth().currentUser?.uid {
                                                            
                                                            let i = HighlightsModel(postKey: snap!.documentID, Highlight_model: snap!.data()!)
                                                            self.presentViewController(id: id, items: [i])
                                                            
                                                            
                                                        } else {
                                                            
                                                            if let vc = UIViewController.currentViewController() {
                                                                
                                                                if vc is notificationVC {
                                                                    
                                                                    if let update = vc as? notificationVC {
                                                                        update.showErrorAlert("Oops!", msg: "This video can't be viewed now.")
                                                                    }
                                                                    
                                                                } else if vc is CommentNotificationVC {
                                                                    
                                                                    if let update = vc as? CommentNotificationVC {
                                                                        update.showErrorAlert("Oops!", msg: "This video can't be viewed now.")
                                                                    }
                                                                    
                                                                }
                                                                                                          
                                                                 
                                                            }
                                                            
                                                        }
                                                        
                                                        
                                                    }
                                                    
                                                }
                                                
                                            }
                                            
                                        }

                                        
                                    } */
                                   
                                    
                                }
                
                            } else if queryItem.name == "up" {
                                
                                if let id = queryItem.value {
                                    
                                    self.moveToUserProfileVC(uid: id)
                                    
                                }
                                
                             
                            }
                            
                            
                        }
                        
                        
                    } else {
                        
                        guard let requestUrl = URL(string: url) else {
                            return
                        }

                        if UIApplication.shared.canOpenURL(requestUrl) {
                             UIApplication.shared.open(requestUrl, options: [:], completionHandler: nil)
                        }
                    }
                    
                    
                }
                
                
                
            }
            
        }
            
    }
    
    func moveToUserProfileVC(uid: String) {
        
        
        if let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "UserProfileVC") as? UserProfileVC {
            
            controller.modalPresentationStyle = .fullScreen
            
            if let vc = UIViewController.currentViewController() {
                
               
                 
            }
            
            
        }
        
    }
    
    func presentViewController(id: String, items: [PostModel]) {
        
        /*
        if let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "UserHighlightFeedVC") as? UserHighlightFeedVC {
            
            controller.modalPresentationStyle = .fullScreen
            
            
            controller.video_list = items
            controller.userid = items[0].userUID
            controller.startIndex = 0
            
            if let vc = UIViewController.currentViewController() {
                 
               
                vc.present(controller, animated: true, completion: nil)
                 
            }
            
        }
        */
        
        
        
    }
    
    func loadCmtCount(id: String) {
        
        /*
        if self.post.has_reply == true, self.post.root_id != "nil" {
      
            if self.post.lastCmtSnapshot != nil{
                
                let db = DataService.instance.mainFireStoreRef
                
                db.collection("Comments").whereField("isReply", isEqualTo: true).whereField("root_id", isEqualTo: self.post.root_id!).whereField("cmt_status", isEqualTo: "valid").order(by: "timeStamp", descending: false).start(afterDocument: self.post.lastCmtSnapshot).getDocuments {  querySnapshot, error in
                    
                    guard let snapshot = querySnapshot else {
                       
                        print("Error fetching snapshots: \(error!)")
                        return
                    }
                    
                    if snapshot.isEmpty != true {
                        
                        self.loadReplyBtnNode.setTitle("Show more (\(snapshot.count))", with: UIFont(name:"Roboto-Light",size: FontSize)!, with: UIColor.lightGray, for: .normal)
                        self.loadReplyBtnNode.contentHorizontalAlignment = .left
                        
                        
                    }
                    
                    
                }
                
                
            }
            
            
        } else {
            
            
            DataService.init().mainFireStoreRef.collection("Comments").whereField("root_id", isEqualTo: id).whereField("cmt_status", isEqualTo: "valid").getDocuments {   querySnapshot, error in
                    guard let snapshot = querySnapshot else {
                        print("Error fetching snapshots: \(error!)")
                        return
                    }
                
                
                if snapshot.isEmpty != true {
                    
                    self.loadReplyBtnNode.setTitle("Replied (\(snapshot.count))", with: UIFont(name:"Roboto-Light",size: FontSize)!, with: UIColor.lightGray, for: .normal)
                    self.loadReplyBtnNode.contentHorizontalAlignment = .left
                    
                    
                }
                
            }
            
            
        }
         */
        
        
    }
    
    func loadInfo(uid: String ) {
        
 /*
        if uid == Auth.auth().currentUser?.uid {
            
            if global_avatar_url != "", global_username != "" {
                
                AvatarNode.url = URL(string: global_avatar_url)
                
                let paragraphStyles = NSMutableParagraphStyle()
                paragraphStyles.alignment = .left
                
               
                
                if self.post.Comment_uid == self.post.owner_uid {
                    
                    if self.post.is_pinned == true {
                        
                        userNameNode.attributedText = NSAttributedString(string: "\(global_username) - author (pinned)", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: FontSize + 1, weight: .medium), NSAttributedString.Key.foregroundColor: UIColor.lightGray])
                        
                        
                        
                    } else {
                        
                        userNameNode.attributedText = NSAttributedString(string: "\(global_username) - author", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: FontSize + 1, weight: .medium), NSAttributedString.Key.foregroundColor: UIColor.lightGray])
                        
                    }
                    
                 
                    
                } else {
                    
                    if self.post.is_pinned == true {
                        
                        userNameNode.attributedText = NSAttributedString(string: "\(global_username) (pinned)", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: FontSize + 1, weight: .medium), NSAttributedString.Key.foregroundColor: UIColor.lightGray])
                        
                    } else {
                        
                        userNameNode.attributedText = NSAttributedString(string: "\(global_username)", attributes: [NSAttributedString.Key.font: UIFont(name:"Roboto-Medium",size: FontSize + 1)!, NSAttributedString.Key.foregroundColor: UIColor.lightGray])
                        
                    }
                    
                  
                }
                
                
            } else {
                
                progressInfo(uid: uid)
                
            }
            
            
            
        } else {
            
            
            progressInfo(uid: uid)
            
        }
        */
        
        
    }
    
    func progressInfo(uid: String) {
        
        /*
        DataService.init().mainFireStoreRef.collection("Users").document(uid).getDocument { querySnapshot, error in
            guard let snapshot = querySnapshot else {
                print("Error fetching snapshots: \(error!)")
                return
            }
            
            if snapshot.exists {
                
                if let item = snapshot.data() {
                    
                    let paragraphStyles = NSMutableParagraphStyle()
                    paragraphStyles.alignment = .left
                
                    if let username = item["username"] as? String {
                        
                        if self.post.Comment_uid == self.post.owner_uid {
                            
                            
                            if self.post.is_pinned == true {
                                
                                self.userNameNode.attributedText = NSAttributedString(string: "\(username) - author (pinned)", attributes: [NSAttributedString.Key.font: UIFont(name:"Roboto-Medium",size: FontSize + 1)!, NSAttributedString.Key.foregroundColor: UIColor.lightGray])
                                
                            } else {
                                
                                self.userNameNode.attributedText = NSAttributedString(string: "\(username) - author", attributes: [NSAttributedString.Key.font: UIFont(name:"Roboto-Medium",size: FontSize + 1)!, NSAttributedString.Key.foregroundColor: UIColor.lightGray])
                                
                            }
                            
                            
                        } else {
                            
                            if self.post.is_pinned == true {
                                
                                self.userNameNode.attributedText = NSAttributedString(string: "\(username) (pinned)", attributes: [NSAttributedString.Key.font: UIFont(name:"Roboto-Medium",size: FontSize + 1)!, NSAttributedString.Key.foregroundColor: UIColor.lightGray])
                                
                                
                            } else {
                                
                                self.userNameNode.attributedText = NSAttributedString(string: "\(username)", attributes: [NSAttributedString.Key.font: UIFont(name:"Roboto-Medium",size: FontSize + 1)!, NSAttributedString.Key.foregroundColor: UIColor.lightGray])
                                
                                
                            }
                            
                            
                            
                        }
                        
                        
                        
                        if let avatarUrl = snapshot.data()!["avatarUrl"] as? String {
                            
                            self.AvatarNode.url = URL(string: avatarUrl)
                            
                        }
                        
                        
                    }
                    
                    
                }
                
                
                
            }
            ∫
   
        }
        
        */
    }
    
    @objc func repliedBtnPressed(sender: AnyObject!) {
  
        reply?(self)
  
    }
    
    func checkIfUserValidAndPresentVC(username: String) {
       /*
        DataService.instance.mainFireStoreRef.collection("Users").whereField("username", isEqualTo: username).whereField("is_suspend", isEqualTo: false).getDocuments { (snap, err) in
   
            if err != nil {
                
                print(err!.localizedDescription)
               
                return
            }
        
            if snap?.isEmpty != true {
                
                for item in snap!.documents {
                    
                    if let userId = item.data()["userUID"] as? String {
                        
                        
                        if !global_block_list.contains(userId) {
                            
                           
                            
                            if let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "UserProfileVC") as? UserProfileVC {
                                
                                if let vc = UIViewController.currentViewController() {
                
                                    controller.uid = userId
                                    controller.modalPresentationStyle = .fullScreen
                                    
                                  
                                    vc.present(controller, animated: true, completion: nil)
                                     
                                }
                                
                                
                            }
                            
                        }
                        
                    }
                    
                }
                
            }
            
        }
        */
        
    }
    
 
    
}
