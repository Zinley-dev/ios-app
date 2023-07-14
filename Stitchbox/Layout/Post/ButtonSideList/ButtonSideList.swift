//
//  ButtonViews.swift
//  Dual
//
//  Created by Khoi Nguyen on 10/2/21.
//

import UIKit

class ButtonSideList: UIView {
    
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var viewStitchBtn: UIButton!
    @IBOutlet weak var stitchCount: UILabel!
   
    

    let kCONTENT_XIB_NAME = "ButtonSideList"
    
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
