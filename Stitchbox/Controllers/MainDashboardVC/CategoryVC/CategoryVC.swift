//
//  CategoryVC.swift
//  Stitchbox
//
//  Created by Khoi Nguyen on 8/25/23.
//

import UIKit
import AsyncDisplayKit

class CategoryVC: UIViewController, ASCollectionDelegate {
    
    deinit {
        print("CategoryVC is being deallocated.")
    }
    
    @IBOutlet weak var contentView: UIView!

    var collectionNode: ASCollectionNode!
    var categoryList = [CategoryModel]()
    var selectedList = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.minimumInteritemSpacing = 0
        flowLayout.minimumLineSpacing = 0
        flowLayout.scrollDirection = .vertical
        self.collectionNode = ASCollectionNode(collectionViewLayout: flowLayout)
        
        contentView.addSubview(collectionNode.view)
        
        self.collectionNode.view.translatesAutoresizingMaskIntoConstraints = false
        self.collectionNode.view.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 0).isActive = true
        self.collectionNode.view.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 0).isActive = true
        self.collectionNode.view.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: 0).isActive = true
        self.collectionNode.view.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: 0).isActive = true
        self.collectionNode.delegate = self
        self.collectionNode.dataSource = self
        self.applyStyle()
       
        navigationItem.title = "Select categories"
        
        getCategory()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let navigationBarAppearance = UINavigationBarAppearance()
        navigationBarAppearance.configureWithOpaqueBackground()
        navigationBarAppearance.backgroundColor = .white
        navigationBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.black]
        navigationBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.black]
        
        self.navigationController?.navigationBar.standardAppearance = navigationBarAppearance
        self.navigationController?.navigationBar.scrollEdgeAppearance = navigationBarAppearance
        
    }
    
    func applyStyle() {
        
        self.collectionNode.view.backgroundColor = UIColor.clear
        self.collectionNode.view.showsVerticalScrollIndicator = false
        self.collectionNode.view.allowsSelection = true
        self.collectionNode.view.allowsMultipleSelection = true
        self.collectionNode.view.contentInsetAdjustmentBehavior = .never
        
    }

    @IBAction func skipBtnPressed(_ sender: Any) {
        
        dismissAndPost()
        
    }
    
    @IBAction func NextBtnPressed(_ sender: Any) {
        
        dismissAndPost()
        
    }
    
    func dismissAndPost() {
        
        presentSwiftLoader()
        
        APIManager.shared.setCategory(cateIds: selectedList) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(_):
                
                Dispatch.main.async { [weak self] in
                    guard let self = self else { return }
                    SwiftLoader.hide()
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reloadFeedAfterSetCategory"), object: nil)
                    self.dismiss(animated: true)
                }
                
            case .failure(let error):
               
                Dispatch.main.async { [weak self] in
                    guard let self = self else { return }
                    SwiftLoader.hide()
                    self.showErrorAlert("Oops!", msg: error.localizedDescription)
                }
                
            }
        }

    }
    
    func getCategory() {
        
        APIManager.shared.getCategory { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let apiResponse):
                
                if let data = apiResponse.body?["data"] as? [[String: Any]], !data.isEmpty {
                    
                    for item in data {
                        let converted = CategoryModel(JSON: item)
                        categoryList.append(converted!)
                    }
                    
                    Dispatch.main.async {[weak self] in
                        guard let self = self else { return }
                        self.collectionNode.reloadData()
                    }
                  
                }
                
            case .failure(let error):
                
                print(error)
                
            }
        }
        
    }
    
}


extension CategoryVC: ASCollectionDataSource {
    
    func numberOfSections(in collectionNode: ASCollectionNode) -> Int {
        
        return 1
        
    }
    
    func collectionNode(_ collectionNode: ASCollectionNode, numberOfItemsInSection section: Int) -> Int {
        
        return self.categoryList.count
        
    }

    
    func collectionNode(_ collectionNode: ASCollectionNode, nodeBlockForItemAt indexPath: IndexPath) -> ASCellNodeBlock {
        let category = self.categoryList[indexPath.row]
        
        return {
            
            let node = CategoryNode(categoryName: category.name!)
            node.neverShowPlaceholders = true
            node.debugName = "Node \(indexPath.row)"

            return node
        }
    }
    
    func collectionNode(_ collectionNode: ASCollectionNode, constrainedSizeForItemAt indexPath: IndexPath) -> ASSizeRange {
        // Calculate text width based on its length
        let text = categoryList[indexPath.row].name ?? ""
        let textSize = text.size(withAttributes: [
            NSAttributedString.Key.font: FontManager.shared.roboto(.Bold, size: 14)
        ])
            
        // Define width and height constraints
        let width = textSize.width + 10 // Added 20 for padding
        let minHeight: CGFloat = 55 // Minimum height
        let maxHeight: CGFloat = 55 // Maximum height

        // Create and return size range
        return ASSizeRange(min: CGSize(width: width, height: minHeight), max: CGSize(width: width, height: maxHeight))
    }
    
    func collectionNode(_ collectionNode: ASCollectionNode, didSelectItemAt indexPath: IndexPath) {
        if let item = categoryList[indexPath.row].id {
            if !selectedList.contains(item) {
                selectedList.append(item)
            }
        }
        
        if let node = collectionNode.nodeForItem(at: indexPath) as? CategoryNode {
        
            // Change background color of backgroundNode to red
            node.backgroundNode.backgroundColor = .secondary
            
            // Change text color to white
            let attributes: [NSAttributedString.Key: Any] = [
                .font: FontManager.shared.roboto(.Regular, size: 12),
                .foregroundColor: UIColor.white
            ]
            node.textNode.attributedText = NSAttributedString(string: node.textNode.attributedText?.string ?? "", attributes: attributes)
        }
    }

    func collectionNode(_ collectionNode: ASCollectionNode, didDeselectItemAt indexPath: IndexPath) {
        if let item = categoryList[indexPath.row].id {
            if selectedList.contains(item) {
                selectedList.removeObject(item)
            }
        }
        
        if let node = collectionNode.nodeForItem(at: indexPath) as? CategoryNode {
            
            // Reset background color of backgroundNode to normalButtonBackground
            node.backgroundNode.backgroundColor = .normalButtonBackground
            
            // Reset text color to black
            let attributes: [NSAttributedString.Key: Any] = [
                .font: FontManager.shared.roboto(.Regular, size: 12),
                .foregroundColor: UIColor.black
            ]
            node.textNode.attributedText = NSAttributedString(string: node.textNode.attributedText?.string ?? "", attributes: attributes)
        }
    }
    
    
    func showErrorAlert(_ title: String, msg: String) {
        
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default)
        
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
        
    }

}
