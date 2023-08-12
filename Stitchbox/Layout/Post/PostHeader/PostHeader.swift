//
//  ButtonViews.swift
//  Dual
//
//  Created by Khoi Nguyen on 10/2/21.
//

import UIKit

class PostHeader: UIView {

    
    @IBOutlet weak var stitchLbl: UILabel!
    @IBOutlet weak var createStitchStack: UIStackView!
    @IBOutlet weak var createStitchView: UIView!
    @IBOutlet weak var usernameLbl: UILabel!
    @IBOutlet var stichBtn: UIButton!
    @IBOutlet var contentView: UIView!
    @IBOutlet var followBtn: UIButton!
    @IBOutlet weak var restView: UIView!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var shareBtn: UIButton!
    @IBOutlet weak var commentBtn: UIButton!
    @IBOutlet weak var commentCountLbl: UILabel!
    @IBOutlet weak var likeBtn: UIButton!
    @IBOutlet weak var likeCountLbl: UILabel!
    @IBOutlet weak var shareCountLbl: UILabel!
    @IBOutlet weak var saveBtn: UIButton!
    @IBOutlet weak var saveCountLbl: UILabel!
    
    @IBOutlet weak var contentLbl: UILabel!

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
