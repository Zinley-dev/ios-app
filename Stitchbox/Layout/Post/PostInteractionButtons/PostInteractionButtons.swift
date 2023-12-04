//
//  ButtonViews.swift
//  Dual
//
//  Created by Khoi Nguyen on 10/2/21.
//

import UIKit

// MARK: - PostInteractionButtons Class
// This class represents a custom view for displaying interaction buttons on a post,
// including share, comment, like, and save buttons along with their respective counts.

class PostInteractionButtons: UIView {
    
    // MARK: - Outlets
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var likeStackView: UIStackView!
    @IBOutlet weak var playListStackView: UIStackView!
    @IBOutlet weak var commentStackView: UIStackView!
    @IBOutlet weak var saveStackView: UIStackView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var playListBtn: UIButton!
    @IBOutlet weak var commentBtn: UIButton!
    @IBOutlet weak var commentCountLbl: UILabel!
    @IBOutlet weak var likeBtn: UIButton!
    @IBOutlet weak var likeCountLbl: UILabel!
    @IBOutlet weak var playListCountLbl: UILabel!
    @IBOutlet weak var saveBtn: UIButton!
    @IBOutlet weak var saveCountLbl: UILabel!

    // Constant for the XIB file name.
    let kCONTENT_XIB_NAME = "PostInteractionButtons"
    
    // MARK: - Initializers
    // Initializer for creating the view from code.
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    // Required initializer for creating the view from a storyboard or XIB.
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    // MARK: - Common Initialization
    // Common setup code for the view, called from both initializers.
    func commonInit() {
        // Load the interface from the XIB file and attach it to this view.
        Bundle.main.loadNibNamed(kCONTENT_XIB_NAME, owner: self, options: nil)
        contentView.fixInView(self) // Helper method to fit the content view in this view's bounds.

        // Further customization and setup for buttons and labels can be done here.
        setupImage()
    }
    
    
}

// MARK: - UI Updates

extension PostInteractionButtons {

    /// Sets up images for various buttons.
    /// This method asynchronously updates the images for playlist, save, and comment buttons.
    func setupImage() {
        DispatchQueue.main.async { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.playListBtn.setImage(playListImage, for: .normal)
            strongSelf.saveBtn.setImage(unsaveImage, for: .normal)
            strongSelf.commentBtn.setImage(cmtImage, for: .normal)
        }
    }
    
    /// Updates the information labels for likes, comments, saves, and playlist count.
    /// - Parameters:
    ///   - likeCount: Number of likes.
    ///   - cmtCount: Number of comments.
    ///   - saveCount: Number of saves.
    ///   - playlistCount: Number of playlist additions.
    func fillInformation(likeCount: Int, cmtCount: Int, saveCount: Int, totalOnChain: Int, positionOnChain: Int) {
        DispatchQueue.main.async { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.likeCountLbl.text = "\(formatPoints(num: Double(likeCount)))"
            strongSelf.saveCountLbl.text = "\(formatPoints(num: Double(saveCount)))"
            strongSelf.commentCountLbl.text = "\(formatPoints(num: Double(cmtCount)))"
            strongSelf.playListCountLbl.text = "\(formatPoints(num: Double(positionOnChain)))/\(formatPoints(num: Double(totalOnChain)))"
        }
    }
    
    /// Sets the like button's image.
    /// - Parameter image: The image to be set for the like button.
    func setLikeImage(image: UIImage) {
        DispatchQueue.main.async { [weak self] in
            self?.likeBtn.setImage(image, for: .normal)
        }
    }
    
    /// Sets the save button's image.
    /// - Parameter image: The image to be set for the save button.
    func setSaveImage(image: UIImage) {
        DispatchQueue.main.async { [weak self] in
            self?.saveBtn.setImage(image, for: .normal)
        }
    }

    /// Sets the save count label's text.
    /// - Parameter saveCount: The number to display for save count.
    func setSaveCount(saveCount: Int) {
        DispatchQueue.main.async { [weak self] in
            self?.saveCountLbl.text = "\(formatPoints(num: Double(saveCount)))"
        }
    }

    /// Sets the like count label's text.
    /// - Parameter likeCount: The number to display for like count.
    func setLikeCount(likeCount: Int) {
        DispatchQueue.main.async { [weak self] in
            self?.likeCountLbl.text = "\(formatPoints(num: Double(likeCount)))"
        }
    }

    /// Sets the comment count label's text.
    /// - Parameter cmtCount: The number to display for comment count.
    func setCmtCount(cmtCount: Int) {
        DispatchQueue.main.async { [weak self] in
            self?.commentCountLbl.text = "\(formatPoints(num: Double(cmtCount)))"
        }
    }
}
