//
//  ButtonViews.swift
//  Dual
//
//  Created by Khoi Nguyen on 10/2/21.
//

import UIKit

class HandlePendingView: UIView {
    
    @IBOutlet var contentView: UIView!
    @IBOutlet var declineBtn: UIView!
    @IBOutlet var approveBtn: UIView!
   
    let kCONTENT_XIB_NAME = "HandlePendingView"
    
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
