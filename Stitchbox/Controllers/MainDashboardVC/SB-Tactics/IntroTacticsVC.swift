//
//  IntroTacticsVC.swift
//  Stitchbox
//
//  Created by Khoi Nguyen on 4/8/23.
//

import UIKit
import SafariServices
import AsyncDisplayKit
import ZSWTappableLabel
import ZSWTaggedString

class IntroTacticsVC: UIViewController, ZSWTappableLabelTapDelegate {

    @IBOutlet weak var termOfUsedLbl: ZSWTappableLabel!
    @IBOutlet weak var contentView: UIView!
    var gameList = [TacticsGameModel]()
    var collectionNode: ASCollectionNode!
    
    static let URLAttributeName = NSAttributedString.Key(rawValue: "URL")
    let proButton: UIButton = UIButton(type: .custom)
    
    enum LinkType: String {
      case Privacy = "Privacy"
      case TermsOfUse = "TOU"
         
      var URL: Foundation.URL {
          switch self {
          case .Privacy:
              return Foundation.URL(string: "https://stitchbox.gg/")!
          case .TermsOfUse:
              return Foundation.URL(string: "https://stitchbox.gg/")!
             
          }
      }
          
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        navigationItem.title = "SB-Tactics"
        setupCollectionNode()
        navigationControllerDelegate()
        
        self.getsupportGame { (newGames) in
            
            self.insertNewRowsInTableNode(newGames: newGames)
            
        }
        
        
        termOfUsedLbl.tapDelegate = self
          
          let options = ZSWTaggedStringOptions()
          options["link"] = .dynamic({ tagName, tagAttributes, stringAttributes in
              guard let typeString = tagAttributes["type"] as? String,
                  let type = LinkType(rawValue: typeString) else {
                      return [NSAttributedString.Key: AnyObject]()
              }
              
              return [
                  .tappableRegion: true,
                  .tappableHighlightedBackgroundColor: UIColor.lightGray,
                  .tappableHighlightedForegroundColor: UIColor.black,
                  .foregroundColor: UIColor.white,
                  .underlineStyle: NSUnderlineStyle.single.rawValue,
                  StartViewController.URLAttributeName: type.URL
              ]
          })
        
     
          
        let string = NSLocalizedString("*We currently provide service for selected games. More games will be added soon. Tap to learn more about our <link type='TOU'>Terms of use</link> and <link type='Privacy'>Privacy Policy</link>.", comment: "")
          
        termOfUsedLbl.attributedText = try? ZSWTaggedString(string: string).attributedString(with: options)
        
        
        let navigationBarAppearance = UINavigationBarAppearance()
        navigationBarAppearance.configureWithOpaqueBackground()
        navigationBarAppearance.backgroundColor = .background
        navigationBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        navigationBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]

        if let navigationController = self.navigationController {
            navigationController.navigationBar.prefersLargeTitles = false
            navigationController.navigationBar.standardAppearance = navigationBarAppearance
            navigationController.navigationBar.scrollEdgeAppearance = navigationBarAppearance
            navigationController.navigationBar.isTranslucent = false
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

        if let navigationController = self.navigationController {
            navigationController.navigationBar.prefersLargeTitles = false
            navigationController.navigationBar.standardAppearance = navigationBarAppearance
            navigationController.navigationBar.scrollEdgeAppearance = navigationBarAppearance
            navigationController.navigationBar.isTranslucent = false
        }
        
        checkAccountStatus()
       
    }
    
    func checkAccountStatus() {
        
        if let passEligible = _AppCoreData.userDataSource.value?.passEligible {
            
            if passEligible {
                
                self.navigationItem.title = "SB-Tactics - Pro"
                self.navigationItem.rightBarButtonItem = nil
                
            } else {
                
                checkPlan()
                
            }
            
        } else {
            
            checkPlan()
            
        }
        
    }
    
    func checkPlan() {
        
        IAPManager.shared.checkPermissions { result in
            if result == false {
                self.navigationItem.title = "SB-Tactics"
                self.setupProButton()
            } else {
                self.navigationItem.title = "SB-Tactics - Pro"
                self.navigationItem.rightBarButtonItem = nil
            }
        }
        
        
    }
    
    func tappableLabel(_ tappableLabel: ZSWTappableLabel, tappedAt idx: Int, withAttributes attributes: [NSAttributedString.Key : Any] = [:]) {
        guard let URL = attributes[IntroTacticsVC.URLAttributeName] as? URL else {
            return
        }
        
        let SF = SFSafariViewController(url: URL)
        SF.modalPresentationStyle = .fullScreen
        self.present(SF, animated: true)
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
    
    
    @objc func getProBtnPressed(_ sender: AnyObject) {
        
        if let SVC = UIStoryboard(name: "Dashboard", bundle: nil).instantiateViewController(withIdentifier: "SubcriptionVC") as? SubcriptionVC {
            
            let nav = UINavigationController(rootViewController: SVC)

            // Customize the navigation bar appearance
            nav.navigationBar.barTintColor = .background
            nav.navigationBar.tintColor = .white
            nav.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]

            nav.modalPresentationStyle = .fullScreen
            self.present(nav, animated: true, completion: nil)
        }
        
    }
    

    
}



extension IntroTacticsVC {
    
    func setupProButton() {
    
        proButton.frame = back_frame
        proButton.contentMode = .center


        proButton.addTarget(self, action: #selector(getProBtnPressed(_:)), for: .touchUpInside)
        proButton.setTitleColor(UIColor.white, for: .normal)
        proButton.setTitle("Go Pro+", for: .normal)
        let originalButtonBarButton = UIBarButtonItem(customView: proButton)

        self.navigationItem.rightBarButtonItem = originalButtonBarButton
        
    }
    
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
            
            if let SBCB = UIStoryboard(name: "Dashboard", bundle: nil).instantiateViewController(withIdentifier: "SB_ChatBot") as? SB_ChatBot {
                
                SBCB.name = game.name
                SBCB.short_name = game.shortName
                SBCB.gameId = game.id
                SBCB.hidesBottomBarWhenPushed = true
                hideMiddleBtn(vc: self)
                self.navigationController?.pushViewController(SBCB, animated: true)
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

extension IntroTacticsVC: UINavigationBarDelegate, UINavigationControllerDelegate {
    
    func navigationControllerDelegate() {
        self.navigationController?.delegate = self
    }
    
}
