//
//  ButtonViews.swift
//  Dual
//
//  Created by Khoi Nguyen on 10/2/21.
//

import UIKit

class ButtonSideList: UIView {
    
    @IBOutlet var contentView: UIView!
    
    @IBOutlet weak var shareBtn: UIButton!
    @IBOutlet weak var commentBtn: UIButton!
    @IBOutlet weak var commentCountLbl: UILabel!
    @IBOutlet weak var hostLbl: UILabel!
    @IBOutlet weak var likeBtn: UIButton!
    @IBOutlet weak var likeCountLbl: UILabel!
    @IBOutlet weak var streamlinkBtn: UIButton!
    @IBOutlet weak var soundBtn: UIButton!
 
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet var streamView: UIView!

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
