//
//  ChallengerCardProfileHeaderCell.swift
//  Stitchbox
//
//  Created by Khoi Nguyen on 1/15/23.
//

import UIKit

class ChallengerCardProfileHeaderCell: UICollectionViewCell {
    
    @IBOutlet weak var startTime: UILabel!
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var fistBumpedLbl: UILabel!
    @IBOutlet weak var infoHeight: NSLayoutConstraint!
    @IBOutlet weak var badgeWidth: NSLayoutConstraint!
    @IBOutlet weak var userImgHeight: NSLayoutConstraint!
    @IBOutlet weak var userImgWidth: NSLayoutConstraint!
    @IBOutlet weak var userImgView: UIImageView!
    @IBOutlet weak var badgeImgView: UIImageView!
    @IBOutlet weak var infoLbl: UILabel!
    @IBOutlet weak var EditChallenge: UIButton!
    
    @IBOutlet weak var game1: UIButton!
    @IBOutlet weak var game2: UIButton!
    @IBOutlet weak var game3: UIButton!
    @IBOutlet weak var game4: UIButton!
    
    @IBOutlet weak var gameWidth: NSLayoutConstraint!
    @IBOutlet weak var gameHeight: NSLayoutConstraint!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        
        
        EditChallenge.setTitle("", for: .normal)
        game1.setTitle("", for: .normal)
        game2.setTitle("", for: .normal)
        game3.setTitle("", for: .normal)
        game4.setTitle("", for: .normal)
        
        
        
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let size = self.frame.width * (40/388)
        let cornerRadius = size/2
        
        gameWidth.constant = size
        gameHeight.constant = size
        
      
        game1.layer.cornerRadius = cornerRadius
        game2.layer.cornerRadius = cornerRadius
        game3.layer.cornerRadius = cornerRadius
        game4.layer.cornerRadius = cornerRadius
        
        badgeWidth.constant = self.frame.width * (131/388)
       
    }
    
}
