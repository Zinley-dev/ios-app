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
    @IBOutlet weak var infoHeight: NSLayoutConstraint!
    @IBOutlet weak var badgeWidth: NSLayoutConstraint!
    @IBOutlet weak var userImgHeight: NSLayoutConstraint!
    @IBOutlet weak var userImgWidth: NSLayoutConstraint!
    @IBOutlet weak var userImgView: UIImageView!
    @IBOutlet weak var infoLbl: UILabel!
    @IBOutlet weak var EditChallenge: UIButton!
    
    @IBOutlet weak var game1: UIButton!
    @IBOutlet weak var game2: UIButton!
    @IBOutlet weak var game3: UIButton!
    @IBOutlet weak var game4: UIButton!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        
        EditChallenge.setTitle("", for: .normal)
        game1.setTitle("", for: .normal)
        game2.setTitle("", for: .normal)
        game3.setTitle("", for: .normal)
        game4.setTitle("", for: .normal)
        
        
    }
    
  
    func configure() {
       
        
    }
    
}
