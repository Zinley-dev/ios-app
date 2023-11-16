//
//  PostHeader.swift
//  Stitchbox
//
//  Created by Khoi Nguyen on 10/2/21.
//

import UIKit
import AsyncDisplayKit

// MARK: - PostHeader Class
// This class represents a custom view to display the header of a post, including user details and settings.

class PostHeader: UIView {
    
    // MARK: - Outlets
    @IBOutlet weak var avatarImg: UIView!
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var postDate: UILabel!
    @IBOutlet weak var postTime: UILabel!
    @IBOutlet weak var settingBtn: UIButton!
    @IBOutlet var contentView: UIView!
    
    fileprivate var avatarNode = ASNetworkImageNode()

    // Constant for the XIB file name.
    let kCONTENT_XIB_NAME = "PostHeader"
    
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
    private func commonInit() {
        Bundle.main.loadNibNamed(kCONTENT_XIB_NAME, owner: self, options: nil)
        contentView.fixInView(self)

        configureAvatarNode()
    }

    // MARK: - Avatar Node Configuration
    private func configureAvatarNode() {
        avatarNode.frame = avatarImg.bounds
        avatarNode.contentMode = .scaleAspectFill
        avatarNode.cornerRadius = avatarImg.frame.height / 2
        avatarNode.clipsToBounds = true
        avatarImg.addSubview(avatarNode.view)
    }

    // MARK: - Function to Load Avatar
    func loadAvatarImage(from url: URL) {
        avatarNode.url = url
    }

    // MARK: - Layout Adjustments
    override func layoutSubviews() {
        super.layoutSubviews()
        avatarNode.frame = avatarImg.bounds
    }

    // MARK: - Function to Assign Post Information
    func setHeaderInfo(username: String, postDate: String, postTime: String, avatarURL: URL?) {
        self.username.text = username
        self.postDate.text = postDate
        self.postTime.text = postTime

        if let url = avatarURL {
            loadAvatarImage(from: url)
        }
    }
}
