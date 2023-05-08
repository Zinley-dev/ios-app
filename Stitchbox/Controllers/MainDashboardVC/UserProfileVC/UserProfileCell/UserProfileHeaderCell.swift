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
    @IBOutlet weak var fistBumpedView: UIView!
    @IBOutlet weak var discordView: UIView!
    @IBOutlet weak var messageBtn: UIButton!
    @IBOutlet weak var FistBumpedBtn: UIButton!
    @IBOutlet weak var followersBtn: UIButton!
    @IBOutlet weak var discordBtn: UIButton!
    @IBOutlet weak var usernameLbl: UILabel!
    @IBOutlet weak var numberOfFollowing: UILabel!
    @IBOutlet weak var numberOfFollowers: UILabel!
    @IBOutlet weak var numberOfFistBumps: UILabel!
    @IBOutlet weak var avatarImage: UIImageView!
    @IBOutlet weak var coverImage: UIImageView!
    @IBOutlet weak var fistBumpImage: UIImageView!
    @IBOutlet weak var discordLbl: UILabel!
    @IBOutlet weak var discordChecked: UIImageView!
    
    let kCONTENT_XIB_NAME = "ProfileView"
    
    @IBOutlet weak var followerStack: UIStackView!
    @IBOutlet weak var followingStack: UIStackView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        discordBtn.setTitle("", for: .normal)
        FistBumpedBtn.setTitle("", for: .normal)
        moreBtn.setTitle("", for: .normal)
       
        followersBtn.setTitleColor(.white, for: .normal)
        messageBtn.setTitleColor(.primary, for: .normal)
        
        messageBtn.tintColor = .primary
        followersBtn.tintColor = .white
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        avatarImage.layer.cornerRadius = avatarImage.bounds.height/2
        
        //followersBtn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 15)
        //messageBtn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 15)
        
        
    }
    
}
