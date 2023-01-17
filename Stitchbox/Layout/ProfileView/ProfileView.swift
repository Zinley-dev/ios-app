//
//  forgetWithEmailView.swift
//  Dual
//
//  Created by Khoi Nguyen on 8/20/21.
//

import UIKit

class ProfileView: UIView {
    
    @IBOutlet weak var descriptionLbl: UILabel!
    @IBOutlet weak var moreBtn: UIButton!
    @IBOutlet weak var messageBtn: UIButton!
    @IBOutlet weak var followBtn: UIButton!
    @IBOutlet weak var followerBtn: UIButton!
    @IBOutlet weak var editProfileBtn: UIButton!
    @IBOutlet weak var viewerStack: UIStackView!
    @IBOutlet weak var ownerStack: UIStackView!
    @IBOutlet weak var fistBumpedView: UIView!
    @IBOutlet weak var discordView: UIView!
    @IBOutlet weak var FistBumpedBtn: UIButton!
    @IBOutlet weak var discordBtn: UIButton!
    @IBOutlet weak var usernameLbl: UILabel!
    @IBOutlet weak var numberOfFollowing: UILabel!
    @IBOutlet weak var numberOfFollowers: UILabel!
    @IBOutlet weak var avatarImage: UIImageView!
    @IBOutlet weak var coverImage: UIImageView!
    let kCONTENT_XIB_NAME = "ProfileView"
    
    @IBOutlet var contentView: UIView!
     
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    func commonInit() {
        Bundle.main.loadNibNamed(kCONTENT_XIB_NAME, owner: self, options: nil)
        contentView.fixInView(self)
    }

}
