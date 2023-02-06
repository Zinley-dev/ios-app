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

class CommentVC: UIViewController {
    
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

    
    //private var pullControl = UIRefreshControl()
    
    //
    let searchResultContainerView = UIView()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
    }
    

}
