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
    @IBOutlet weak var linkStackView: UIStackView!
    @IBOutlet weak var linkLbl: UILabel!
    @IBOutlet weak var insightBtn: UIButton!
    @IBOutlet weak var usernameLbl: UILabel!
    @IBOutlet weak var numberOfFollowing: UILabel!
    @IBOutlet weak var numberOfFollowers: UILabel!
    @IBOutlet weak var numberOfStitches: UILabel!
    @IBOutlet weak var avatarImage: UIImageView!

    @IBOutlet weak var followerStack: UIStackView!
    @IBOutlet weak var followingStack: UIStackView!
   
    let kCONTENT_XIB_NAME = "ProfileView"
    
    var lastAvatarImgUrl: URL?
    var lastcoverImgUrl: URL?
   
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        editProfileBtn.setTitleColor(.white, for: .normal)
        insightBtn.setTitleColor(.black, for: .normal)
        
        editProfileBtn.tintColor = .white
        insightBtn.tintColor = .black
        
        insightBtn.backgroundColor = .normalButtonBackground
    
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        avatarImage.layer.cornerRadius = avatarImage.bounds.height/2
       
    }



    
}
