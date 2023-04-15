//
//  IntroTacticsVC.swift
//  Stitchbox
//
//  Created by Khoi Nguyen on 4/8/23.
//

import UIKit
import SafariServices
import AsyncDisplayKit

class IntroTacticsVC: UIViewController {

    @IBOutlet weak var contentView: UIView!
    var gameList = [TacticsGameModel]()
    var collectionNode: ASCollectionNode!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        let navigationBarAppearance = UINavigationBarAppearance()
        navigationBarAppearance.configureWithOpaqueBackground()
        navigationBarAppearance.backgroundColor = .background
        navigationBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        navigationBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        
        navigationItem.title = "SB-Tactics"
        setupCollectionNode()
        
        self.getsupportGame { (newGames) in
            
            self.insertNewRowsInTableNode(newGames: newGames)
            
        }
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        showMiddleBtn(vc: self)
        
        let navigationBarAppearance = UINavigationBarAppearance()
        navigationBarAppearance.configureWithOpaqueBackground()
        navigationBarAppearance.backgroundColor = .background
        navigationBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        navigationBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]


    }
    
  
    func getsupportGame(block: @escaping ([[String: Any]]) -> Void) {
        
           gameList.removeAll()
        
            APIManager().getSupportedGame { result in
                switch result {
                case .success(let apiResponse):
                    
                    guard let data = apiResponse.body?["data"] as? [[String: Any]] else {
                        let item = [[String: Any]]()
                        DispatchQueue.main.async {
                            block(item)
                        }
                        return
                    }
                    
                    if !data.isEmpty {
                        print("Successfully retrieved \(data.count) games.")
                        let items = data
                        DispatchQueue.main.async {
                            block(items)
                        }
                    } else {
                        
                        let item = [[String: Any]]()
                        DispatchQueue.main.async {
                            block(item)
                        }
                    }
                    
                case .failure(let error):
                    print(error)
                    let item = [[String: Any]]()
                    DispatchQueue.main.async {
                        block(item)
                }
            }
        }
        
    }
    
    func insertNewRowsInTableNode(newGames: [[String: Any]]) {
        
        guard newGames.count > 0 else {
            return
        }
      
        let section = 0
        var items = [TacticsGameModel]()
        var indexPaths: [IndexPath] = []
        let total = self.gameList.count + newGames.count
        
        for row in self.gameList.count...total-1 {
            let path = IndexPath(row: row, section: section)
            indexPaths.append(path)
        }
        
        for i in newGames {

            let item = TacticsGameModel(tacticsGameModel: i)
            items.append(item)
          
        }
        
        self.gameList.append(contentsOf: items)
        self.collectionNode.insertItems(at: indexPaths)
     
        
    }
    
    @IBAction func learnMoreBtnPressed(_ sender: Any) {
        
        let link = URL(string: "https://stitchbox.gg/")
        
        guard let URL = link else {
            return
        }
        
        let SF = SFSafariViewController(url: URL)
        SF.modalPresentationStyle = .fullScreen
        self.present(SF, animated: true)
        
        
    }
    
}



extension IntroTacticsVC {
    
    func setupCollectionNode() {
        let flowLayout = UICollectionViewFlowLayout()
       
        self.collectionNode = ASCollectionNode(collectionViewLayout: flowLayout)
        self.collectionNode.automaticallyRelayoutOnLayoutMarginsChanges = true
        self.collectionNode.view.contentInsetAdjustmentBehavior = .never
        
        // Add the collection node's view as a subview and set constraints
        self.contentView.addSubview(collectionNode.view)
        self.collectionNode.view.translatesAutoresizingMaskIntoConstraints = false
        self.collectionNode.view.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 0).isActive = true
        self.collectionNode.view.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 0).isActive = true
        self.collectionNode.view.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: 0).isActive = true
        self.collectionNode.view.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: 0).isActive = true
        
        self.applyStyle()
        self.wireDelegates()

    }

    
    
    func applyStyle() {
        
        self.collectionNode.view.isPagingEnabled = false
        self.collectionNode.view.backgroundColor = UIColor.clear
        self.collectionNode.view.showsVerticalScrollIndicator = false
        self.collectionNode.view.allowsSelection = true
        self.collectionNode.view.contentInsetAdjustmentBehavior = .never
        self.collectionNode.needsDisplayOnBoundsChange = true
        
    }
    
    func wireDelegates() {
        
        self.collectionNode.delegate = self
        self.collectionNode.dataSource = self
        
    }
    
}



extension IntroTacticsVC: ASCollectionDataSource, ASCollectionDelegate {
    
    func numberOfSections(in collectionNode: ASCollectionNode) -> Int {
        
        return 1
        
    }
    
    func collectionNode(_ collectionNode: ASCollectionNode, numberOfItemsInSection section: Int) -> Int {
        
        return self.gameList.count
    }
    
    func collectionNode(_ collectionNode: ASCollectionNode, nodeBlockForItemAt indexPath: IndexPath) -> ASCellNodeBlock {
        
        let game = self.gameList[indexPath.row]
        
        return {
            let node = TacticsGameNode(with: game)
            node.neverShowPlaceholders = true
            node.debugName = "Node \(indexPath.row)"
            return node
        }
    }
    
 
    
}

extension IntroTacticsVC {
    
    func collectionNode(_ collectionNode: ASCollectionNode, constrainedSizeForItemAt indexPath: IndexPath) -> ASSizeRange {
        let size = self.collectionNode.view.layer.frame.width / 3 - 10
        let min = CGSize(width: size, height: size * 1.5);
        let max = CGSize(width: size, height: size * 1.5);
        
        return ASSizeRangeMake(min, max);
    }
    
    func shouldBatchFetch(for collectionNode: ASCollectionNode) -> Bool {
        return false
    }
    
}

extension IntroTacticsVC {
    

    func collectionNode(_ collectionNode: ASCollectionNode, didSelectItemAt indexPath: IndexPath) {
        let game = gameList[indexPath.row]
        
        if game.status == true {
            
            if let data = _AppCoreData.userDataSource.value {
                
                // check for if already linked or null then process search and sync
                
                if game.name == "League of Legends" {
                    
                    //SB_ProfileVC
                    
                    
                    /*
                    if let SBPVC = UIStoryboard(name: "Dashboard", bundle: nil).instantiateViewController(withIdentifier: "SB_ProfileVC") as? SB_ProfileVC {
                       
                        SBPVC.hidesBottomBarWhenPushed = true
                        hideMiddleBtn(vc: self)
                        self.navigationController?.pushViewController(SBPVC, animated: true)
                    } */
                    
                    
                    if let RSVC = UIStoryboard(name: "Dashboard", bundle: nil).instantiateViewController(withIdentifier: "RiotSyncVC") as? RiotSyncVC {
                       
                        RSVC.hidesBottomBarWhenPushed = true
                        hideMiddleBtn(vc: self)
                        self.navigationController?.pushViewController(RSVC, animated: true)
                    }
                    
                } else {
                    
                    
                    if let SBCB = UIStoryboard(name: "Dashboard", bundle: nil).instantiateViewController(withIdentifier: "SB_ChatBot") as? SB_ChatBot {
                       
                        SBCB.hidesBottomBarWhenPushed = true
                        hideMiddleBtn(vc: self)
                        self.navigationController?.pushViewController(SBCB, animated: true)
                    }
                    
                }
                
                
            }
            
            
            
        } else {
            
            showErrorAlert("Oops!", msg: "This game is currently unavailable for service, please try again later.")
            
        }
        
        
    } 
    
    
    func showErrorAlert(_ title: String, msg: String) {
                                                                                                                                           
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        
                                                                                       
        present(alert, animated: true, completion: nil)
        
    }
    
    
}
