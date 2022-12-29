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
    
    
    // Initialize the participant node with the given participant
    init(with participant: Participant) {
        self.participant = participant
        self.AvatarNode = ASNetworkImageNode()
        self.InfoNode = ASDisplayNode()
        self.nameNode = ASTextNode()
        self.muteIcon = ASImageNode()
        super.init()

        // Set the background color and border of the node's view
        view.backgroundColor = .chatBackGround
        view.layer.borderWidth = 3
        
        
        // Determine the border color based on the current user's userID
        let borderColor: UIColor
        if let userUID = _AppCoreData.userDataSource.value?.userID, userUID != "" {
            borderColor = userUID == participant.user.userId ? UIColor.secondary : UIColor.lightGray
        } else {
            borderColor = .lightGray
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
        nameNode.attributedText = NSAttributedString(string: nickname, attributes: [.font: UIFont.boldSystemFont(ofSize: 13), .foregroundColor: UIColor.white, .paragraphStyle: paragraphStyles])

        // Set the image of the mute icon based on the participant's audio enabled status
        muteIcon.image = participant.isAudioEnabled ? UIImage(named: "btnAudioOff") : UIImage(named: "btnAudioOffSelected")

    }
    
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
               
        muteIcon.style.preferredSize = CGSize(width: 20, height: 20)
        let nameAndMuteStack = ASStackLayoutSpec(direction: .horizontal, spacing: 3, justifyContent: .center, alignItems: .center, children: [nameNode, muteIcon])
                
        InfoNode.style.preferredSize = CGSize(width: constrainedSize.min.width, height: 22)
        let insets = UIEdgeInsets(top: .infinity, left: 0, bottom: 15, right: 0)
        let textInsetSpec = ASInsetLayoutSpec(insets: insets, child: nameAndMuteStack)
        
        let size =  constrainedSize.min.width - 22 - 15 - 15
        let mid = (constrainedSize.min.width - size) / 2
                                
        AvatarNode.style.preferredSize = CGSize(width: size, height: size)
        AvatarNode.cornerRadius = size/2 
                
        let avatarInsetSpec = ASInsetLayoutSpec(insets: UIEdgeInsets(top: 10, left: mid , bottom: .infinity, right: mid), child: AvatarNode)
        return ASOverlayLayoutSpec(child: avatarInsetSpec, overlay: textInsetSpec)
        
    }
    

}
