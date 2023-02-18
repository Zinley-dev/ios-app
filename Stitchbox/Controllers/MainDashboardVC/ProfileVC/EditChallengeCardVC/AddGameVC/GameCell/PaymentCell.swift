//
//  PaymentCell.swift
//  uEAT
//
//  Created by Khoi Nguyen on 11/5/19.
//  Copyright © 2019 Khoi Nguyen. All rights reserved.
//

import UIKit

class GameCell: UITableViewCell {
    
    
    var info: Game!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()

        contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8))
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureCell(_ Information: Game) {
           
 
        
        
        
    }

}
