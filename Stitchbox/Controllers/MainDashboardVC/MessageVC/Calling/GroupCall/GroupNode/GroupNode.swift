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
    
    var participant: Participant!
    
    var AvatarNode: ASNetworkImageNode!
    var nameNode: ASTextNode!
    var muteIcon: ASImageNode!
    var InfoNode: ASDisplayNode!

    var paragraphStyles = NSMutableParagraphStyle()
    
    
    // Initialize the participant node with the given participant
    init(with participant: Participant) {
        self.participant = participant
        self.AvatarNode = ASNetworkImageNode()
        self.InfoNode = ASDisplayNode()
        self.nameNode = ASTextNode()
        self.muteIcon = ASImageNode()
        super.init()

        // Set the background color and border of the node's view
        view.backgroundColor = .darkGray
        view.layer.borderWidth = 3
        
        
        // Determine the border color based on the current user's userID
        let borderColor: UIColor
        if let userUID = _AppCoreData.userDataSource.value?.userID, userUID != "" {
            borderColor = userUID == participant.user.userId ? UIColor.secondary : UIColor.white
        } else {
            borderColor = .white
        }
        view.borderColors = borderColor
        
       
        // Set the corner radius and mask of the node's viewchatBackGround
        view.layer.cornerRadius = 17
        view.layer.masksToBounds = true
        selectionStyle = .none
        automaticallyManagesSubnodes = true

        // Configure the avatar node
        AvatarNode.contentMode = .scaleAspectFill
        AvatarNode.shouldRenderProgressImages = true
        AvatarNode.url = URL(string: participant.user.profileURL!)
        AvatarNode.backgroundColor = .clear

        // Set the background color and alpha of the info node
        InfoNode.backgroundColor = .clear
       

        // Configure the mute icon node
        muteIcon.backgroundColor = .clear
        muteIcon.contentMode = .scaleAspectFit

        // Set the attributed text of the name node with the participant's nickname
        let nickname = participant.user.nickname!
        paragraphStyles.alignment = .center
        nameNode.backgroundColor = UIColor.clear
        nameNode.attributedText = NSAttributedString(
            string: nickname,
            attributes: [
                .font: FontManager.shared.roboto(.Bold, size: 13),
                .foregroundColor: UIColor.white,
                .paragraphStyle: paragraphStyles
            ]
        )


        // Set the image of the mute icon based on the participant's audio enabled status
        muteIcon.image = participant.isAudioEnabled ? UIImage(named: "btnAudioOff") : UIImage(named: "btnAudioOffSelected")

    }
    
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        
        let size =  constrainedSize.min.width - 22 - 15 - 15
        let mid = (constrainedSize.min.width - size) / 2
        
        AvatarNode.style.preferredSize = CGSize(width: size, height: size)
        AvatarNode.cornerRadius = size/2
        
        let avatarInsetSpec = ASInsetLayoutSpec(insets: UIEdgeInsets(top: 10, left: mid , bottom: .infinity, right: mid), child: AvatarNode)
        
        
        InfoNode.style.preferredSize = CGSize(width: constrainedSize.min.width, height: 35)

        // INFINITY is used to make the inset unbounded
        let insets = UIEdgeInsets(top: CGFloat.infinity, left: 0, bottom: 20, right: 0)
        let textInsetSpec = ASInsetLayoutSpec(insets: insets, child: InfoNode)
        
        //
        DispatchQueue.main.async {
            
            let estimated = UILabel()
            estimated.text = self.participant.user.nickname!
            estimated.font = FontManager.shared.roboto(.Bold, size: 13)

            let estimatedSize = estimated.textWidth()
            
            self.nameNode.frame = CGRect(x: constrainedSize.min.width / 2 - (estimatedSize/2), y: 20, width: estimatedSize, height: 20)
            self.muteIcon.frame = CGRect(x: constrainedSize.min.width / 2 + (estimatedSize/2) + 3, y: 17.5, width: 20, height: 20)
        }
        
        InfoNode.addSubnode(nameNode)
        InfoNode.addSubnode(muteIcon)
        
        return ASOverlayLayoutSpec(child: avatarInsetSpec, overlay: textInsetSpec)
        
    }

    

}
