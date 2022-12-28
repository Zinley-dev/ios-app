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

        view.backgroundColor = .clear
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.white.cgColor
        view.layer.cornerRadius = 10
        view.layer.masksToBounds = true
        selectionStyle = .none
        automaticallyManagesSubnodes = true

        AvatarNode.contentMode = .scaleAspectFit
        AvatarNode.shouldRenderProgressImages = true
        AvatarNode.url = URL(string: participant.user.profileURL!)
        AvatarNode.backgroundColor = .clear

        InfoNode.backgroundColor = .black
        InfoNode.alpha = 0.7

        muteIcon.backgroundColor = .clear
        muteIcon.contentMode = .scaleAspectFit

        let nickname = participant.user.nickname!
        nameNode.attributedText = NSAttributedString(string: participant.user.userId == _AppCoreData.userDataSource.value?.userID ? "\(nickname) (me)" : nickname, attributes: [.font: UIFont.systemFont(ofSize: 10), .foregroundColor: UIColor.white, .paragraphStyle: paragraphStyles])

        muteIcon.image = participant.isAudioEnabled ? UIImage(named: "btnAudioOff") : UIImage(named: "btnAudioOffSelected")
    }

    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        AvatarNode.style.preferredSize = constrainedSize.min
        InfoNode.style.preferredSize = CGSize(width: constrainedSize.min.width, height: 22)
        let insets = UIEdgeInsets(top: .infinity, left: 8, bottom: 8, right: 8)
        let textInsetSpec = ASInsetLayoutSpec(insets: insets, child: InfoNode)
        nameNode.frame = CGRect(x: 22, y: 6, width: constrainedSize.min.width, height: 20)
        muteIcon.frame = CGRect(x: 2, y: 2, width: 18, height: 18)
        InfoNode.addSubnode(nameNode)
        InfoNode.addSubnode(muteIcon)
        return ASOverlayLayoutSpec(child: AvatarNode, overlay: textInsetSpec)
    }

    
    
}
