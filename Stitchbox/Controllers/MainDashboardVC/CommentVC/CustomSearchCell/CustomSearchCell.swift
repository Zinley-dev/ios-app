//
//  customSearchCell.swift
//  Dual
//
//  Created by Khoi Nguyen on 8/19/21.
//

import UIKit
import AsyncDisplayKit

class CustomSearchCell: UITableViewCell {

    @IBOutlet weak var postCount: UILabel!
    @IBOutlet weak var textLbl: UILabel!
    @IBOutlet weak var ImageView: UIImageView!
    @IBOutlet weak var hashtagLbl: UILabel!
    
    var AvatarNode: ASNetworkImageNode!
    
    static func nib() -> UINib {
        return UINib(nibName: String(describing: self), bundle: Bundle(for: self))
    }
    
    static func cellReuseIdentifier() -> String {
        return String(describing: self)
    }
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    func configureCell(type: String, text: String, url: String) {
        
        textLbl.text = text
 
        
        if type == "user" {
        
            hashtagLbl.isHidden = true
            ImageView?.isHidden = false
            postCount.isHidden = true
            //
            
            let imageNode = ASNetworkImageNode()
            imageNode.cornerRadius = ImageView.frame.width / 2
            
            imageNode.clipsToBounds =  true
            
            
            if url != "" {
                
                imageNode.url = URL.init(string: url)
                
            } else {
                
                imageNode.image = UIImage.init(named: "defaultuser")
                
            }
        
            imageNode.contentMode = .scaleAspectFill
            imageNode.shouldRenderProgressImages = true
    
            imageNode.frame = ImageView.layer.bounds
            ImageView.image = nil
            
            
            ImageView.addSubnode(imageNode)
            
        } else if type == "hashtag" {
            
            hashtagLbl.isHidden = false
            ImageView?.isHidden = true
            postCount.isHidden = false
            
            loadHashTagCount(hashtag: "#\(text)")
            
        }
        
    }
    
    
    func loadHashTagCount(hashtag: String) {
        
        let paragraphStyles = NSMutableParagraphStyle()
        paragraphStyles.alignment = .left
        self.postCount.text = "0 post"
        
    }
    
    
    
}
