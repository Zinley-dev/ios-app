//
//  PreferenceNode.swift
//  Stitchbox
//
//  Created by Khoi Nguyen on 6/16/23.
//

import Foundation
import UIKit
import AsyncDisplayKit
import Alamofire
import ActiveLabel
import SendBirdSDK
import AVFoundation
import AVKit
import Cache

class PreferenceNode: ASCellNode {
    
    weak var category: GameList!
    
    
    var infoView: ASDisplayNode!

    var desc = ""
    
    var AddViews: AddView!
    
   
    init(with category: GameList) {
        
        self.category = category
        self.infoView = ASDisplayNode()
        
        
        super.init()
        
        self.backgroundColor = UIColor.white
        self.infoView.backgroundColor = UIColor.clear
    
        
        automaticallyManagesSubnodes = true
        
        DispatchQueue.main.async {
            
            self.AddViews = AddView()
            
            self.infoView.view.addSubview(self.AddViews)
           
            self.AddViews.translatesAutoresizingMaskIntoConstraints = false
            self.AddViews.topAnchor.constraint(equalTo: self.infoView.view.topAnchor, constant: 0).isActive = true
            self.AddViews.bottomAnchor.constraint(equalTo: self.infoView.view.bottomAnchor, constant: 0).isActive = true
            self.AddViews.leadingAnchor.constraint(equalTo: self.infoView.view.leadingAnchor, constant: 0).isActive = true
            self.AddViews.trailingAnchor.constraint(equalTo: self.infoView.view.trailingAnchor, constant: 0).isActive = true
            
            self.layer.cornerRadius = 20
           
      
            self.configureCell(info: category)
            
        }
        
    }
    
    func configureCell(info: GameList) {
       
        let estimatedWidth = info.name.width(withConstrainedHeight: 27, font: UIFont.systemFont(ofSize: 15))
        
        self.AddViews.name.text = info.name
    
        if let imgUrl =  URL.init(string: info.cover) {
            
            imageStorage.async.object(forKey: info.cover) { result in
                if case .value(let image) = result {
                    
                    DispatchQueue.main.async {
                        self.AddViews.imageView.image = image
                    }
                   
                   
                } else {
                    
                    AF.request(imgUrl).responseImage { response in
                                          
                       switch response.result {
                        case let .success(value):
                           
                          
                           DispatchQueue.main.async {
                               self.AddViews.imageView.image = value
                           }
                           
                           try? imageStorage.setObject(value, forKey: info.cover, expiry: .date(Date().addingTimeInterval(2 * 3600)))
                                              
                               case let .failure(error):
                                   print(error)
                            }
                                          
                      }
                    
                }
            }
            
            
        }
        
      
    }
  
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        
        infoView.style.preferredSize = CGSize(width: constrainedSize.max.width , height: constrainedSize.max.height)
       
        
        return ASInsetLayoutSpec(insets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0), child: infoView)
       
            
    }

    
}
