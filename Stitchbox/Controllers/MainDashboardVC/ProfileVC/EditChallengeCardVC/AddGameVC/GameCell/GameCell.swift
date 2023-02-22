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
    
    @IBOutlet weak var gameLbl: UILabel!
    @IBOutlet weak var gameImage: UIImageView!

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
        self.info = Information
    
        if let game = global_suppport_game_list.first(where: { $0._id == info.gameId }) {
            print(game.name)
            gameLbl.text = game.name
            gameImage.load(url: URL(string: game.cover)!, str: game.cover)
        }

    }

}
