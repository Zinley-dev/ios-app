//
//  SelectedUserCollectioViewCell.swift
//  SendBird-iOS
//
//  Created by Jaesung Lee on 27/08/2019.
//  Copyright © 2019 SendBird. All rights reserved.
//

import UIKit
import SendBirdSDK
import SendBirdUIKit

class SelectedUserCollectionViewCell: UICollectionViewCell {
   
    @IBOutlet weak var nicknameLabel: UILabel!
    
    private var user: SBUUser!
    
    static func nib() -> UINib {
        return UINib(nibName: String(describing: self), bundle: Bundle(for: self))
    }
    
    static func cellReuseIdentifier() -> String {
        return String(describing: self)
    }
    
    func setModel(aUser: SBUUser) {
        self.user = aUser
        
        nicknameLabel.text = "Nickname"

    }
}
