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
    @IBOutlet weak var followBtn: UIButton!
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
    func setHeaderInfo(username: String, postTime: Date, avatarURL: String?) {
        self.username.text = username

        // DateFormatter for the date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM d, yyyy" // format: May 15, 2023
        let date = dateFormatter.string(from: postTime)
        
        // DateFormatter for the time
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm" // format: 17:40
        let time = timeFormatter.string(from: postTime)
        
        // Now you can use 'date' and 'time' as needed
        // For example, setting them to some labels
        self.postDate.text = date
        self.postTime.text = time

        // Load the avatar image using avatarURL if available
        if let avatarURL = avatarURL, let url = URL(string: avatarURL) {
            // Load the image from the URL
            loadAvatarImage(from: url)
        } else {
            avatarNode.image = UIImage(named: "defaultuser")
        }
    }

}
