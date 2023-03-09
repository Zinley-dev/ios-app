//
//  ButtonViews.swift
//  Dual
//
//  Created by Khoi Nguyen on 10/2/21.
//

import UIKit

class GameListView: UIView {
    
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var game1: UIImageView!
    @IBOutlet weak var game2: UIImageView!
    @IBOutlet weak var game3: UIImageView!
    @IBOutlet weak var game4: UIImageView!

    let kCONTENT_XIB_NAME = "GameListView"
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    func commonInit() {
        
        
        Bundle.main.loadNibNamed(kCONTENT_XIB_NAME, owner: self, options: nil)
        contentView.fixInView(self)

    
    }

}
