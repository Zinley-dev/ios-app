//
//  ChallengeCard.swift
//  Dual
//
//  Created by Khoi Nguyen on 10/29/21.
//

import UIKit

class ChallengeCard: UIView {

    @IBOutlet weak var startTime: UILabel!
    @IBOutlet weak var challengeCount: UILabel!
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var infoHeight: NSLayoutConstraint!
    @IBOutlet weak var badgeWidth: NSLayoutConstraint!
    @IBOutlet weak var userImgHeight: NSLayoutConstraint!
    @IBOutlet weak var userImgWidth: NSLayoutConstraint!
    @IBOutlet weak var userImgView: UIImageView!
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var infoLbl: UILabel!
    
    let kCONTENT_XIB_NAME = "ChallengeCard"
    
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
