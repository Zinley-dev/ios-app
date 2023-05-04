//
//  LOLProfileHeaderCell.swift
//  Stitchbox
//
//  Created by Khoi Nguyen on 4/14/23.
//

import UIKit

class LOLProfileHeaderCell: UICollectionViewCell {
    
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var level: UILabel!
    @IBOutlet weak var region: UILabel!
    @IBOutlet weak var rank: UILabel!
    
    
    @IBOutlet weak var iconImgView: UIImageView!
    @IBOutlet weak var rankImgView: UIImageView!
    
    
    
    
    @IBOutlet weak var liveGame: UIButton!
    @IBOutlet weak var refresh: UIButton!
    @IBOutlet weak var upgrade: UIButton!
    

    @IBOutlet weak var twentyGameStats: UILabel!
    @IBOutlet weak var soloStats: UILabel!
    @IBOutlet weak var allSeasonStats: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        
        
       
        
    }
    
    
}
