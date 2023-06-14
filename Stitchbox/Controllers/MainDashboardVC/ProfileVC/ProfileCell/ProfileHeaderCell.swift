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
    @IBOutlet weak var fistBumpedView: UIView!
    @IBOutlet weak var discordView: UIView!
    @IBOutlet weak var editBtn: UIButton!
    @IBOutlet weak var FistBumpedBtn: UIButton!
    @IBOutlet weak var fistBumpedListBtn: UIButton!
    @IBOutlet weak var discordBtn: UIButton!
    @IBOutlet weak var usernameLbl: UILabel!
    @IBOutlet weak var numberOfFollowing: UILabel!
    @IBOutlet weak var numberOfFollowers: UILabel!
    @IBOutlet weak var numberOfFistBumps: UILabel!
    @IBOutlet weak var avatarImage: UIImageView!
    @IBOutlet weak var coverImage: UIImageView!
    @IBOutlet weak var discordLbl: UILabel!
    @IBOutlet weak var discordChecked: UIImageView!
    @IBOutlet weak var followerStack: UIStackView!
    @IBOutlet weak var followingStack: UIStackView!
    @IBOutlet weak var proImg: UIImageView!
    let kCONTENT_XIB_NAME = "ProfileView"
    
    var lastAvatarImgUrl: URL?
    var lastcoverImgUrl: URL?
   
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        
        editBtn.setTitle("", for: .normal)
        discordBtn.setTitle("", for: .normal)
        FistBumpedBtn.setTitle("", for: .normal)
        editProfileBtn.setTitleColor(.white, for: .normal)
        fistBumpedListBtn.setTitleColor(.white, for: .normal)
        
        editProfileBtn.tintColor = .white
        fistBumpedListBtn.tintColor = .white
    
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        avatarImage.layer.cornerRadius = avatarImage.bounds.height/2
       
    }
    
    func checkProImg() {
        
        if let passEligible = _AppCoreData.userDataSource.value?.passEligible {
            
            if passEligible {
                
                proImg.isHidden = false
                
            } else {
                
                checkPlan()
                
            }
            
        } else {
            
            checkPlan()
            
        }
        
    }

    
    func checkPlan() {
        
        IAPManager.shared.checkPermissions { result in
            if result == false {
                
                Dispatch.main.async {
                    
                    self.proImg.isHidden = true
                    
                }
                
            } else {
             
                Dispatch.main.async {
                
                    self.proImg.isHidden = false
                    
                }
  
            }
        }
        
        
    }


    
}
