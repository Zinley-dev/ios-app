//
//  RecentNode.swift
//  Stitchbox
//
//  Created by Khoi Nguyen on 3/6/23.
//

import UIKit
import AsyncDisplayKit
import Alamofire


fileprivate let OrganizerImageSize: CGFloat = 40
fileprivate let HorizontalBuffer: CGFloat = 10
fileprivate let FontSize: CGFloat = 13


class RecentNode: ASCellNode {
    
    deinit {
        print("RecentNode is being deallocated.")
    }
    
    weak var item: RecentModel!

    var upperNameNode: ASTextNode!
    var belowNameNode: ASTextNode!
    var imageNode: ASNetworkImageNode!
    var gameListView: GameListView!
    var gameNode: ASDisplayNode!
    
    init(with item: RecentModel) {
        
        self.item = item
        self.upperNameNode = ASTextNode()
        self.imageNode = ASNetworkImageNode()
        self.belowNameNode = ASTextNode()
        self.gameNode = ASDisplayNode()
        super.init()
        
        self.backgroundColor = UIColor.clear
        
        self.selectionStyle = .none
        upperNameNode.isLayerBacked = true
        

   
        upperNameNode.backgroundColor = UIColor.clear
        belowNameNode.backgroundColor = UIColor.clear
        
        automaticallyManagesSubnodes = true
         
        
        if item.type == "game" {
            
            //imageNode.cornerRadius = OrganizerImageSize/2
            imageNode.clipsToBounds = true
            imageNode.shouldRenderProgressImages = true
            imageNode.isLayerBacked = true
            
            DispatchQueue.main.async {
                
                let paragraphStyles = NSMutableParagraphStyle()
                paragraphStyles.alignment = .left
                self.upperNameNode.attributedText = NSAttributedString(string: item.game_name ?? "@", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: FontSize + 1), NSAttributedString.Key.foregroundColor: UIColor.white, NSAttributedString.Key.paragraphStyle: paragraphStyles])
                
                self.belowNameNode.attributedText = NSAttributedString(string: item.game_shortName ?? "@", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: FontSize + 1), NSAttributedString.Key.foregroundColor: UIColor.white, NSAttributedString.Key.paragraphStyle: paragraphStyles])

                
                if item.coverUrl != "" {
                    
                    self.imageNode.url = URL(string: item.coverUrl)
                } else {
                    
                    self.imageNode.image = UIImage.init(named: "search")
                    
                }
                
                
                self.imageNode.contentMode = .scaleAspectFit
                self.imageNode.backgroundColor = .clear
                
            }
        } else if item.type == "user" {
            
            imageNode.cornerRadius = OrganizerImageSize/2
            imageNode.clipsToBounds = true
            imageNode.shouldRenderProgressImages = true
            imageNode.isLayerBacked = true
            
            DispatchQueue.main.async {
                     
                self.gameListView = GameListView()
                self.gameNode.view.addSubview(self.gameListView)
                
                self.gameListView.translatesAutoresizingMaskIntoConstraints = false
                self.gameListView.topAnchor.constraint(equalTo: self.gameNode.view.topAnchor, constant: 0).isActive = true
                self.gameListView.bottomAnchor.constraint(equalTo: self.gameNode.view.bottomAnchor, constant: 0).isActive = true
                self.gameListView.leadingAnchor.constraint(equalTo: self.gameNode.view.leadingAnchor, constant: 0).isActive = true
                self.gameListView.trailingAnchor.constraint(equalTo: self.gameNode.view.trailingAnchor, constant: 0).isActive = true
                

                let paragraphStyles = NSMutableParagraphStyle()
                paragraphStyles.alignment = .left
                self.upperNameNode.attributedText = NSAttributedString(string: item.user_nickname ?? "@", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: FontSize + 1), NSAttributedString.Key.foregroundColor: UIColor.white, NSAttributedString.Key.paragraphStyle: paragraphStyles])
                
                self.belowNameNode.attributedText = NSAttributedString(string: item.user_name ?? "@", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: FontSize + 1), NSAttributedString.Key.foregroundColor: UIColor.white, NSAttributedString.Key.paragraphStyle: paragraphStyles])

                if item.avatarUrl != "" {
                    
                    self.imageNode.url = URL(string: item.avatarUrl)
                } else {
                    
                    self.imageNode.image = UIImage.init(named: "defaultuser")
                    
                }
    
                
                self.loadGameIfNeed()
            }
            

        } else if item.type == "text" {
            
            DispatchQueue.main.async {
                let paragraphStyles = NSMutableParagraphStyle()
                paragraphStyles.alignment = .left
                self.upperNameNode.attributedText = NSAttributedString(string: item.text ?? "@", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: FontSize + 1), NSAttributedString.Key.foregroundColor: UIColor.white, NSAttributedString.Key.paragraphStyle: paragraphStyles])

                self.imageNode.image = UIImage.init(named: "search")
                self.imageNode.contentMode = .scaleAspectFit
            }
            
        }

        
    }
    
    func loadGameIfNeed() {
        guard let game = item.gameList else {
            gameListView.game1.isHidden = true
            gameListView.game2.isHidden = true
            gameListView.game3.isHidden = true
            gameListView.game4.isHidden = true
            return
        }
        
        let empty = URL(string: emptyimage)!
        let gameViews = [gameListView.game1, gameListView.game2, gameListView.game3, gameListView.game4]
        
        for i in 0..<game.count {
            guard i < gameViews.count else { break }
            gameViews[i]!.isHidden = false
            
            if let gameInfo = global_suppport_game_list.first(where: { $0._id == game[i]["gameId"] as! String }) {
                gameViews[i]!.load(url: URL(string: gameInfo.cover) ?? empty, str: gameInfo.cover)
            }
        }
        
        for i in game.count..<gameViews.count {
            gameViews[i]!.isHidden = true
        }
    }

    
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        
        
        let headerSubStack = ASStackLayoutSpec.vertical()
        
        
        imageNode.style.preferredSize = CGSize(width: OrganizerImageSize, height: OrganizerImageSize)
        gameNode.style.preferredSize = CGSize(width: 150, height: 50)
        
        headerSubStack.style.flexShrink = 16.0
        headerSubStack.style.flexGrow = 16.0
        headerSubStack.spacing = 7.0
        
        if item.type == "text" {
            headerSubStack.children = [upperNameNode]
            imageNode.style.preferredSize = CGSize(width: OrganizerImageSize, height: OrganizerImageSize - 10)
        } else {
            headerSubStack.children = [upperNameNode, belowNameNode]
            imageNode.style.preferredSize = CGSize(width: OrganizerImageSize, height: OrganizerImageSize)
        }
        
        let headerStack = ASStackLayoutSpec.horizontal()
      
        
        headerStack.spacing = 10
        headerStack.justifyContent = ASStackLayoutJustifyContent.start
        headerStack.alignItems = .center
        
        if item.type == "user" {
            
            if let games = item.gameList, !games.isEmpty {
                
                headerStack.children = [imageNode, headerSubStack, gameNode]
                
            } else {
                headerStack.children = [imageNode, headerSubStack]
            }
            
        } else {
            headerStack.children = [imageNode, headerSubStack]
        }
        
      
        return ASInsetLayoutSpec(insets: UIEdgeInsets(top: 16.0, left: 16, bottom: 16, right: 16), child: headerStack)
            
    }
    
    
    
}
