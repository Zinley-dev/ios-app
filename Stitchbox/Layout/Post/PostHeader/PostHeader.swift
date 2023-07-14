//
//  ButtonViews.swift
//  Dual
//
//  Created by Khoi Nguyen on 10/2/21.
//

import UIKit

class PostHeader: UIView {

    @IBOutlet weak var createStitchStack: UIStackView!
    @IBOutlet weak var createStitchView: UIView!
    @IBOutlet weak var usernameLbl: UILabel!
    @IBOutlet var stichBtn: UIButton!
    @IBOutlet var contentView: UIView!
    @IBOutlet var followBtn: UIButton!

    let kCONTENT_XIB_NAME = "PostHeader"
    
    
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

        createStitchView.layer.cornerRadius = 5  // set as per your requirement.
        createStitchView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMaxXMaxYCorner]  // Top right corner, Bottom right corner respectively
        createStitchView.clipsToBounds = true

    
    }

}
