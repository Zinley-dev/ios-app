//
//  PreferenceVC.swift
//  Stitchbox
//
//  Created by Khoi Nguyen on 6/16/23.
//

import UIKit
import Cache
import Alamofire
import AlamofireImage
import AsyncDisplayKit

class PreferenceVC: UIViewController, UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var continueBtn: UIButton!
    
    @IBOutlet weak var contentView: UIView!
    
    var itemList = [GameList]()
    var selected_itemList = [GameList]()
    var SelectedIndex: IndexPath!
    var collectionNode: ASCollectionNode!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        
        let flowLayout = UICollectionViewFlowLayout()
        self.collectionNode = ASCollectionNode(collectionViewLayout: flowLayout)
        
        loadAddGame()
        

        contentView.addSubview(collectionNode.view)
      
        self.collectionNode.view.translatesAutoresizingMaskIntoConstraints = false
        self.collectionNode.view.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 0).isActive = true
        self.collectionNode.view.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 16).isActive = true
        self.collectionNode.view.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -16).isActive = true
        self.collectionNode.view.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: 0).isActive = true
        
        self.collectionNode.allowsMultipleSelection = true
        self.collectionNode.delegate = self
        self.collectionNode.dataSource = self
        
        applyStyle()
        
        
    }
    
    
    func applyStyle() {
        
        self.collectionNode.view.isPagingEnabled = false
        self.collectionNode.view.backgroundColor = UIColor.clear
        self.collectionNode.view.showsVerticalScrollIndicator = false
        self.collectionNode.view.allowsSelection = true
        self.collectionNode.view.contentInsetAdjustmentBehavior = .never
        
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        
        return 20
        
    }
    
    func loadAddGame() {
        
        
        for item in global_suppport_game_list {
            if item.name != "Steam" {
                itemList.append(item)
            }
        }
    
        self.collectionNode.reloadData()
        
    }
    
    
    // func show error alert
    
    func showErrorAlert(_ title: String, msg: String) {
        
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        
        
        present(alert, animated: true, completion: nil)
        
    }
    
    @IBAction func ContinueBtnPressed(_ sender: Any) {
        
        if !selected_itemList.isEmpty {
            presentSwiftLoader()
            var items = [String]()
            
            for item in selected_itemList {
                items.append(item._id)
            }
            
            APIManager.shared.updateFavoriteContent(contents: items) { [weak self] result in
                guard let self = self else { return }
                
                switch result {
                case .success(_):
                    
                    Dispatch.main.async {
                        SwiftLoader.hide()
                        RedirectionHelper.redirectToDashboard()
                    }
                    
                case .failure(let error):
                   
                    SwiftLoader.hide()
                    self.showErrorAlert("Oops!", msg: "\(error.localizedDescription)")
                    
                }
            }
            
            
        } else {
            
            self.showErrorAlert("Oops!", msg: "Please select your favorite games so we can deliver the right content for you.")
            
            
        }
   
        
    }



}


extension PreferenceVC: ASCollectionDelegate {
   
    func collectionNode(_ collectionNode: ASCollectionNode, constrainedSizeForItemAt indexPath: IndexPath) -> ASSizeRange {
        
        let min = CGSize(width: contentView.frame.width/2 - 30, height: 57);
        let max = CGSize(width: contentView.frame.width/2 - 30, height: 57);
        return ASSizeRangeMake(min, max);
       
    }
    
    func shouldBatchFetch(for collectionNode: ASCollectionNode) -> Bool {
        
        return false
    }
    

}


extension PreferenceVC: ASCollectionDataSource {
    
   
    func numberOfSections(in collectionNode: ASCollectionNode) -> Int {
        
        
        return 1
        
        

    }
    
    func collectionNode(_ collectionNode: ASCollectionNode, numberOfItemsInSection section: Int) -> Int {
        
        return itemList.count
      
    }
 
    func collectionNode(_ collectionNode: ASCollectionNode, nodeBlockForItemAt indexPath: IndexPath) -> ASCellNodeBlock {
        
        let category = self.itemList[indexPath.row]
       
        return {
            
            let node = PreferenceNode(with: category)
            node.neverShowPlaceholders = true
            node.debugName = "Node \(indexPath.row)"
            
            
           
            return node
        }
        
    }
    

   
    
    func collectionNode(_ collectionNode: ASCollectionNode, didSelectItemAt indexPath: IndexPath) {
        
        if let node = collectionNode.nodeForItem(at: indexPath as IndexPath) as? PreferenceNode {
            
            if node.isSelected == true {
                
                node.layer.cornerRadius = 10
                node.layer.borderWidth = 4
                node.layer.borderColor = UIColor.secondary.cgColor
                
            }
            
            let item = itemList[indexPath.row]
            selected_itemList.append(item)
            
        }
    
    }
    
    func collectionNode(_ collectionNode: ASCollectionNode, didDeselectItemAt indexPath: IndexPath) {
        
        if let node = collectionNode.nodeForItem(at: indexPath as IndexPath) as? PreferenceNode {
            
            node.layer.borderColor = UIColor.clear.cgColor
            
            let item = itemList[indexPath.row]
            
            var count = 0
            for x in selected_itemList {
     
                if x.name == item.name {
                    
                    selected_itemList.remove(at: count)
                    
                }
                
                count += 1
                
            }
            
        }
    }

}
