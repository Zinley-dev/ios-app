//
//  UserProfileHeaderCell.swift
//  Stitchbox
//
//  Created by Khoi Nguyen on 1/25/23.
//

import UIKit

class UserProfileHeaderCell: UICollectionViewCell {
    
    @IBOutlet weak var descriptionLbl: UILabel!
    @IBOutlet weak var fistBumpedView: UIView!
    @IBOutlet weak var discordView: UIView!
    @IBOutlet weak var FistBumpedBtn: UIButton!
    @IBOutlet weak var discordBtn: UIButton!
    @IBOutlet weak var usernameLbl: UILabel!
    @IBOutlet weak var numberOfFollowing: UILabel!
    @IBOutlet weak var numberOfFollowers: UILabel!
    @IBOutlet weak var avatarImage: UIImageView!
    @IBOutlet weak var coverImage: UIImageView!
    
    @IBOutlet weak var followersBtn: UIButton!
    @IBOutlet weak var messageBtn: UIButton!
    @IBOutlet weak var moreBtn: UIButton!
    
    let kCONTENT_XIB_NAME = "ProfileView"
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        discordBtn.setTitle("", for: .normal)
        FistBumpedBtn.setTitle("", for: .normal)
        moreBtn.setTitle("", for: .normal)
       
        followersBtn.setTitleColor(.white, for: .normal)
        messageBtn.setTitleColor(.primary, for: .normal)
        
        messageBtn.tintColor = .white
        followersBtn.tintColor = .white
    
    }
    

    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        avatarImage.layer.cornerRadius = avatarImage.bounds.height/2
        
       
        followersBtn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 15)
        messageBtn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 15)
        
    }
    
  
    func configure() {
       
        
    }
    
}