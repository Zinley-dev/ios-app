//
//  ButtonViews.swift
//  Dual
//
//  Created by Khoi Nguyen on 10/2/21.
//

import UIKit

// MARK: - PostFooter Class
// This class represents a custom view for displaying the footer of a post,
// including elements like title, description, and an action button.

class PostFooter: UIView {
    
    // MARK: - Outlets
    @IBOutlet var contentView: UIView!
    @IBOutlet var titleLbl: UILabel!
    @IBOutlet var stitchBtn: UIButton!
    @IBOutlet var descriptionLbl: UILabel!

    // Constant for the XIB file name.
    let kCONTENT_XIB_NAME = "PostFooter"
    
    // MARK: - Initializers
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    // MARK: - Common Initialization
    func commonInit() {
        Bundle.main.loadNibNamed(kCONTENT_XIB_NAME, owner: self, options: nil)
        contentView.fixInView(self)
    }

    // MARK: - Function to Set Footer Information
    /// Sets the footer information for the post.
    func setFooterInfo(title: String, description: String) {
        titleLbl.text = title
        descriptionLbl.text = description
    }
}
