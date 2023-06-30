//
//  ProfileHeaderCell.swift
//  Stitchbox
//
//  Created by Khoi Nguyen on 1/15/23.
//

import UIKit
import AlamofireImage
import Cache
import Alamofire

class ProfileHeaderCell: UICollectionViewCell {
    
    
    @IBOutlet weak var descriptionLbl: UILabel!
    @IBOutlet weak var editProfileBtn: UIButton!
   
    @IBOutlet weak var fistBumpedListBtn: UIButton!
    @IBOutlet weak var usernameLbl: UILabel!
    @IBOutlet weak var numberOfFollowing: UILabel!
    @IBOutlet weak var numberOfFollowers: UILabel!
    @IBOutlet weak var avatarImage: UIImageView!

    @IBOutlet weak var followerStack: UIStackView!
    @IBOutlet weak var followingStack: UIStackView!
   
    let kCONTENT_XIB_NAME = "ProfileView"
    
    var lastAvatarImgUrl: URL?
    var lastcoverImgUrl: URL?
   
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        
        
    
        editProfileBtn.setTitleColor(.white, for: .normal)
        fistBumpedListBtn.setTitleColor(.white, for: .normal)
        
        editProfileBtn.tintColor = .white
        fistBumpedListBtn.tintColor = .white
    
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        avatarImage.layer.cornerRadius = avatarImage.bounds.height/2
       
    }



    
}
