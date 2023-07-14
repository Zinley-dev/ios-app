//
//  ButtonViews.swift
//  Dual
//
//  Created by Khoi Nguyen on 10/2/21.
//

import UIKit

class SelectPostCollectionView: UIView {
    
    @IBOutlet var contentView: UIView!
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var hideBtn: UIView!

    let kCONTENT_XIB_NAME = "SelectPostCollectionView"
    
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
