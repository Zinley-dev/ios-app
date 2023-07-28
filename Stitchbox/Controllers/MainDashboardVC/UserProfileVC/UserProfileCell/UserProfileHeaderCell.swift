//
//  UserProfileHeaderCell.swift
//  Stitchbox
//
//  Created by Khoi Nguyen on 1/25/23.
//

import UIKit

class UserProfileHeaderCell: UICollectionViewCell {
    
    @IBOutlet weak var descriptionLbl: UILabel!
    @IBOutlet weak var moreBtn: UIButton!
    @IBOutlet weak var messageBtn: UIButton!
    @IBOutlet weak var followersBtn: UIButton!
    @IBOutlet weak var usernameLbl: UILabel!
    @IBOutlet weak var numberOfFollowing: UILabel!
    @IBOutlet weak var numberOfFollowers: UILabel!
    @IBOutlet weak var avatarImage: UIImageView!
    //@IBOutlet weak var proImg: UIImageView!
    
    @IBOutlet weak var linkStackView: UIStackView!
    @IBOutlet weak var linkLbl: UILabel!
    
    let kCONTENT_XIB_NAME = "ProfileView"
    
    @IBOutlet weak var followerStack: UIStackView!
    @IBOutlet weak var followingStack: UIStackView!
    
    var lastAvatarImgUrl: URL?
    var lastcoverImgUrl: URL?
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    
        moreBtn.setTitle("", for: .normal)
       
        followersBtn.setTitleColor(.white, for: .normal)
        messageBtn.setTitleColor(.black, for: .normal)
        
        messageBtn.tintColor = .black
        followersBtn.tintColor = .white
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        avatarImage.layer.cornerRadius = avatarImage.bounds.height/2
      
    }
    
    
    
}
