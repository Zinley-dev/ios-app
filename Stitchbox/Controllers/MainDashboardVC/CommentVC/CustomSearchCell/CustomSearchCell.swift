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
            
            
            imageNode.contentMode = .scaleAspectFit
            imageNode.shouldRenderProgressImages = true
            imageNode.url = URL.init(string: url)
            imageNode.frame = ImageView.layer.bounds
            ImageView.image = nil
            
            
            ImageView.addSubnode(imageNode)
            
        } else if type == "hashtag" {
            
            hashtagLbl.isHidden = false
            ImageView?.isHidden = true
            postCount.isHidden = false
            
            loadHashTagCount(hashtag: "#\(text)")
            
        }
        
        else if type == "highlight" {
            
            hashtagLbl.isHidden = true
            ImageView?.isHidden = true
            postCount.isHidden = false
            
//            loadHashTagCount(hashtag: "#\(text)")
            
        }
        
        else if type == "keyword" {
            
            hashtagLbl.isHidden = true
            ImageView?.isHidden = true
            postCount.isHidden = true
                        
        }
        
    }
    
    
    func loadHashTagCount(hashtag: String) {
        
        let paragraphStyles = NSMutableParagraphStyle()
        paragraphStyles.alignment = .left
        
        /*
        DataService.instance.mainFireStoreRef.collection("Highlights").whereField("h_status", isEqualTo: "Ready").whereField("hashtag_list", arrayContains: hashtag).getDocuments { querySnapshot, error in
                     
            guard querySnapshot != nil else {
                print("Error fetching snapshots: \(error!)")
                return
            }
            
            if querySnapshot?.isEmpty == true {
                
                
                self.postCount.text = "0 post"
                
            } else {
                
                if let cnt = querySnapshot?.count {
                 
                    self.postCount.text = "\(formatPoints(num: Double(cnt))) posts"
                    
                }
                
            }
                
            
        } */
        
    }
    
    
    
}
