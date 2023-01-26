//
//  ProfileHeaderCell.swift
//  Stitchbox
//
//  Created by Khoi Nguyen on 1/15/23.
//

import UIKit

class ProfileHeaderCell: UICollectionViewCell {
    
    
    @IBOutlet weak var descriptionLbl: UILabel!
    @IBOutlet weak var editProfileBtn: UIButton!
    @IBOutlet weak var fistBumpedView: UIView!
    @IBOutlet weak var discordView: UIView!
    @IBOutlet weak var editBtn: UIButton!
    @IBOutlet weak var FistBumpedBtn: UIButton!
    @IBOutlet weak var followersBtn: UIButton!
    @IBOutlet weak var discordBtn: UIButton!
    @IBOutlet weak var usernameLbl: UILabel!
    @IBOutlet weak var numberOfFollowing: UILabel!
    @IBOutlet weak var numberOfFollowers: UILabel!
    @IBOutlet weak var avatarImage: UIImageView!
    @IBOutlet weak var coverImage: UIImageView!
    @IBOutlet weak var discordLbl: UILabel!
    let kCONTENT_XIB_NAME = "ProfileView"
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        
        editBtn.setTitle("", for: .normal)
        discordBtn.setTitle("", for: .normal)
        FistBumpedBtn.setTitle("", for: .normal)
        editProfileBtn.setTitleColor(.white, for: .normal)
        followersBtn.setTitleColor(.white, for: .normal)
        
        editProfileBtn.tintColor = .white
        followersBtn.tintColor = .white
    
    }
    

    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        avatarImage.layer.cornerRadius = avatarImage.bounds.height/2
        
        editProfileBtn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 15)
        followersBtn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 15)
    }
    
  
    func configure() {
       
        
    }
    
    
}
