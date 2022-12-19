//
//  GroupNode.swift
//  The Dual
//
//  Created by Khoi Nguyen on 6/3/21.
//

import Foundation

import UIKit
import AsyncDisplayKit
import Alamofire
import SendBirdCalls


class GroupNode: ASCellNode {
    
    weak var participant: Participant!
    
    var AvatarNode: ASNetworkImageNode!
    var nameNode: ASTextNode!
    var muteIcon: ASImageNode!
    var InfoNode: ASDisplayNode!

    var paragraphStyles = NSMutableParagraphStyle()
    
    
    init(with participant: Participant) {
        
        self.participant = participant
        self.AvatarNode = ASNetworkImageNode()
        self.InfoNode = ASDisplayNode()
        self.nameNode = ASTextNode()
        self.muteIcon = ASImageNode()
        super.init()
        
        
        //
        
        view.backgroundColor = UIColor.clear
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.white.cgColor
        view.layer.cornerRadius = 10
        view.layer.masksToBounds = true
        
        //
        
        self.selectionStyle = .none
        automaticallyManagesSubnodes = true
        
        AvatarNode.contentMode = .scaleAspectFit
        AvatarNode.shouldRenderProgressImages = true
        AvatarNode.url = URL.init(string: participant.user.profileURL!)
        AvatarNode.backgroundColor = UIColor.clear
       
        
        InfoNode.backgroundColor = UIColor.black
        InfoNode.alpha = 0.7
        
        muteIcon.backgroundColor = UIColor.clear
        muteIcon.contentMode = .scaleAspectFit
        //
        
        paragraphStyles.alignment = .left
        
        
        if let userUID = _AppCoreData.userDataSource.value?.userID, userUID != "" {
            
            if participant.user.userId == userUID {
                
                nameNode.attributedText = NSAttributedString(string: "\(participant.user.nickname!) (me)", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 10.0), NSAttributedString.Key.foregroundColor: UIColor.white, NSAttributedString.Key.paragraphStyle: paragraphStyles])
                
            } else {
                
                nameNode.attributedText = NSAttributedString(string: participant.user.nickname!, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 10.0), NSAttributedString.Key.foregroundColor: UIColor.white, NSAttributedString.Key.paragraphStyle: paragraphStyles])
                
            }
            
            
        }
        
        
        
        //btnAudioOff
        
        if participant.isAudioEnabled == true {
            
            muteIcon.image = UIImage(named: "btnAudioOff")
            
        } else {
            
            muteIcon.image = UIImage(named: "btnAudioOffSelected")
            
        }
        
        
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {

        
        AvatarNode.style.preferredSize = CGSize(width: constrainedSize.min.width, height: constrainedSize.min.height)
        InfoNode.style.preferredSize = CGSize(width: constrainedSize.min.width, height: 22)

        // INFINITY is used to make the inset unbounded
        let insets = UIEdgeInsets(top: CGFloat.infinity, left: 8, bottom: 8, right: 8)
        let textInsetSpec = ASInsetLayoutSpec(insets: insets, child: InfoNode)
        
        //
        
        nameNode.frame = CGRect(x: 22, y: 6, width: constrainedSize.min.width, height: 20)
        muteIcon.frame = CGRect(x: 2, y: 2, width: 18, height: 18)
        InfoNode.addSubnode(nameNode)
        InfoNode.addSubnode(muteIcon)
        

        return ASOverlayLayoutSpec(child: AvatarNode, overlay: textInsetSpec)
            
    }
    
    
}
