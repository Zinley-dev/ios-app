//
//  UserSearchNode.swift
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

class UserSearchNode: ASCellNode {
    
    deinit {
        print("UserSearchNode is being deallocated.")
    }
    
    var user: UserSearchModel!

    var userNameNode: ASTextNode!
    var gameNode: ASDisplayNode!
    var nameNode: ASTextNode!
    var imageNode: ASNetworkImageNode!
    
    var gameListView: GameListView!
    
    init(with user: UserSearchModel) {
        
        self.user = user
        self.userNameNode = ASTextNode()
        self.imageNode = ASNetworkImageNode()
        self.nameNode = ASTextNode()
        self.gameNode = ASDisplayNode()
        super.init()
        
        self.backgroundColor = UIColor.clear
        
        self.selectionStyle = .none
        imageNode.cornerRadius = OrganizerImageSize/2
        imageNode.clipsToBounds = true
        userNameNode.isLayerBacked = true
        imageNode.shouldRenderProgressImages = true
        imageNode.isLayerBacked = true

   
        userNameNode.backgroundColor = UIColor.clear
        nameNode.backgroundColor = UIColor.clear
        
        automaticallyManagesSubnodes = true
        
        
        DispatchQueue.main.async {
            
            self.gameListView = GameListView()
            self.gameNode.view.addSubview(self.gameListView)
            
            self.gameListView.translatesAutoresizingMaskIntoConstraints = false
            self.gameListView.topAnchor.constraint(equalTo: self.gameNode.view.topAnchor, constant: 0).isActive = true
            self.gameListView.bottomAnchor.constraint(equalTo: self.gameNode.view.bottomAnchor, constant: 0).isActive = true
            self.gameListView.leadingAnchor.constraint(equalTo: self.gameNode.view.leadingAnchor, constant: 0).isActive = true
            self.gameListView.trailingAnchor.constraint(equalTo: self.gameNode.view.trailingAnchor, constant: 0).isActive = true
            
            self.loadGameIfNeed()
            
        }
         
        
        DispatchQueue.main.async {
            
            let paragraphStyles = NSMutableParagraphStyle()
            paragraphStyles.alignment = .left
            self.userNameNode.attributedText = NSAttributedString(string: user.user_nickname ?? "@", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: FontSize + 1), NSAttributedString.Key.foregroundColor: UIColor.black, NSAttributedString.Key.paragraphStyle: paragraphStyles])
            
            if user.user_name == "" {
                
                self.nameNode.attributedText = NSAttributedString(string: "None", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: FontSize + 1), NSAttributedString.Key.foregroundColor: UIColor.black, NSAttributedString.Key.paragraphStyle: paragraphStyles])
                
            } else {
                
                self.nameNode.attributedText = NSAttributedString(string: user.user_name ?? "@", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: FontSize + 1), NSAttributedString.Key.foregroundColor: UIColor.black, NSAttributedString.Key.paragraphStyle: paragraphStyles])
                
                
            }
            
            
            if user.avatarUrl != "" {
                
                self.imageNode.url = URL(string: user.avatarUrl)
                self.cacheUrlIfNeed(url: user.avatarUrl)
                
            } else {
                
                self.imageNode.image = UIImage.init(named: "defaultuser")
                
            }

          
        }
        
    }
    
    func cacheUrlIfNeed(url: String) {
        
        
        imageStorage.async.object(forKey: url) { result in
            if case .value(_) = result {
                
        
               
            } else {
                
                
             AF.request(url).responseImage { response in
                    
                    
                    switch response.result {
                    case let .success(value):
                     
                        try? imageStorage.setObject(value, forKey: url, expiry: .seconds(3000))
                        
                    case let .failure(error):
                        print(error)
                    }
                    
                    
                    
                }
                
            }
            
        }
        
    }
    
    func loadGameIfNeed() {
        guard let game = user.gameList else {
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
                gameViews[i]!.loadGame(url: URL(string: gameInfo.cover) ?? empty)
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
        
        headerSubStack.children = [userNameNode, nameNode]
      
  
        let headerStack = ASStackLayoutSpec.horizontal()
      
        
        headerStack.spacing = 10
        headerStack.justifyContent = ASStackLayoutJustifyContent.start
        headerStack.alignItems = .center
        headerStack.children = [imageNode, headerSubStack, gameNode]
        
        return ASInsetLayoutSpec(insets: UIEdgeInsets(top: 16.0, left: 16, bottom: 16, right: 16), child: headerStack)
            
    }
    
    
    
}
