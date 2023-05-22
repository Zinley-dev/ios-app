//
//  PromoteVC.swift
//  Stitchbox
//
//  Created by Khoi Nguyen on 5/18/23.
//

import UIKit
import AsyncDisplayKit
import FLAnimatedImage

class PromoteVC: UIViewController {
    
    var promotionList = [PromoteModel]()
    let backButton: UIButton = UIButton(type: .custom)
    @IBOutlet weak var loadingImage: FLAnimatedImageView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var loadingView: UIView!
    var firstAnimated = true
    var tableNode: ASTableNode!
    
    required init?(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
        self.tableNode = ASTableNode(style: .plain)
        self.wireDelegates()
  
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupButtons()
        contentView.addSubview(tableNode.view)
        
        self.tableNode.view.translatesAutoresizingMaskIntoConstraints = false
        self.tableNode.view.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 0).isActive = true
        self.tableNode.view.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 0).isActive = true
        self.tableNode.view.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: 0).isActive = true
        self.tableNode.view.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: 0).isActive = true
        
    
        
        self.applyStyle()
        self.tableNode.leadingScreensForBatching = 5
        self.tableNode.automaticallyRelayoutOnLayoutMarginsChanges = true
        self.tableNode.automaticallyAdjustsContentOffset = true
        getPromotion()
    }
    
    
    func getPromotion() {
        
        APIManager().getPromotion { [weak self] result in
            guard let self = self else { return }

            DispatchQueue.main.async {
                switch result {
                case .success(let apiResponse):

                    if let dataDict = apiResponse.body,
                       let data = dataDict["data"] as? [[String: Any]],
                       !data.isEmpty {
                        self.promotionList = []
                        for promotionData in data {
                            if let promotionModel = PromoteModel(data: promotionData) {
                                self.promotionList.append(promotionModel)
                            } else {
                                print("Couldn't cast")
                            }
                        }
                        
                        if !self.promotionList.isEmpty {
                            self.tableNode.reloadData()
                            self.hideAnimation()
                        }
                    } else {
                        self.promotionList = []
                        self.hideAnimation()
                    }
                case .failure(let error):
                    print("Error while getting promotion: \(error.localizedDescription)")
                    self.promotionList = []
                    self.hideAnimation()
                  
                }
            }
        }
        
        
    }
    

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
        if firstAnimated {
                    
                    do {
                        
                        let path = Bundle.main.path(forResource: "fox2", ofType: "gif")!
                        let gifData = try NSData(contentsOfFile: path) as Data
                        let image = FLAnimatedImage(animatedGIFData: gifData)
                        
                        
                        self.loadingImage.animatedImage = image
                        
                    } catch {
                        print(error.localizedDescription)
                    }
                    
                    loadingView.backgroundColor = self.view.backgroundColor
         
                }
        
        let navigationBarAppearance = UINavigationBarAppearance()
        navigationBarAppearance.configureWithOpaqueBackground()
        navigationBarAppearance.backgroundColor = .background
        navigationBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        navigationBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]

        self.navigationController?.navigationBar.standardAppearance = navigationBarAppearance
        self.navigationController?.navigationBar.scrollEdgeAppearance = navigationBarAppearance
        
    }


}

extension PromoteVC {
    
    func setupButtons() {
        
        setupBackButton()
    
    }
    
    
    func setupBackButton() {
    
        backButton.frame = back_frame
        backButton.contentMode = .center

        if let backImage = UIImage(named: "back_icn_white") {
            let imageSize = CGSize(width: 13, height: 23)
            let padding = UIEdgeInsets(top: (back_frame.height - imageSize.height) / 2,
                                       left: (back_frame.width - imageSize.width) / 2 - horizontalPadding,
                                       bottom: (back_frame.height - imageSize.height) / 2,
                                       right: (back_frame.width - imageSize.width) / 2 + horizontalPadding)
            backButton.imageEdgeInsets = padding
            backButton.setImage(backImage, for: [])
        }

        backButton.addTarget(self, action: #selector(onClickBack(_:)), for: .touchUpInside)
        backButton.setTitleColor(UIColor.white, for: .normal)
        backButton.setTitle("", for: .normal)
        let backButtonBarButton = UIBarButtonItem(customView: backButton)
        navigationItem.title = "SB Promotion"

        self.navigationItem.leftBarButtonItem = backButtonBarButton


        
    }

    
    func showErrorAlert(_ title: String, msg: String) {
                                                                                                                                           
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default)
        
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
        
    }

    
}

extension PromoteVC {
    
    @objc func onClickBack(_ sender: AnyObject) {
        if let navigationController = self.navigationController {
            navigationController.popViewController(animated: true)
        }
    }
    
}

extension PromoteVC {
    
    func applyStyle() {
        
        self.tableNode.view.separatorStyle = .none
        self.tableNode.view.separatorColor = UIColor.lightGray
        self.tableNode.view.isPagingEnabled = false
        self.tableNode.view.backgroundColor = .background
        self.tableNode.view.showsVerticalScrollIndicator = false
        
    }
    
    func wireDelegates() {
        
        self.tableNode.delegate = self
        self.tableNode.dataSource = self
    
    }
    
    
}


extension PromoteVC {
    
    
    func tableNode(_ tableNode: ASTableNode, didSelectRowAt indexPath: IndexPath) {
        
        let promote = promotionList[indexPath.row]
        
        if let SDVC = UIStoryboard(name: "Dashboard", bundle: nil).instantiateViewController(withIdentifier: "PromoteDetailVC") as? PromoteDetailVC {
            
            SDVC.promote = promote
            self.navigationController?.pushViewController(SDVC, animated: true)
            
        }
        
    }
    
}

extension PromoteVC: ASTableDelegate {

    func tableNode(_ tableNode: ASTableNode, constrainedSizeForRowAt indexPath: IndexPath) -> ASSizeRange {
        
        let width = UIScreen.main.bounds.size.width;
        
        let min = CGSize(width: width, height: 30);
        let max = CGSize(width: width, height: 1000);
        return ASSizeRangeMake(min, max);
           
    }
    
    
    func shouldBatchFetch(for tableNode: ASTableNode) -> Bool {
        
        return false
    }
    
    
}



extension PromoteVC: ASTableDataSource {
    
    func tableNode(_ tableNode: ASTableNode, numberOfRowsInSection section: Int) -> Int {
        
        if self.promotionList.count == 0 {
            
            tableNode.view.setEmptyMessage("No promotion found")
            
        } else {
            tableNode.view.restore()
        }
        
        return self.promotionList.count
        
    }
    
    func tableNode(_ tableNode: ASTableNode, nodeBlockForRowAt indexPath: IndexPath) -> ASCellNodeBlock {
        
        let promote = self.promotionList[indexPath.row]
       
        return {
            
            let node = PromoteNode(with: promote)
            node.neverShowPlaceholders = true
            node.debugName = "Node \(indexPath.row)"
            
            return node
        }
        
    }

    
    func hideAnimation() {
        
        if firstAnimated {
                    
                    firstAnimated = false
                    
                    UIView.animate(withDuration: 0.5) {
                        
                        Dispatch.main.async {
                            self.loadingView.alpha = 0
                        }
                        
                    }
                    
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        
                        if self.loadingView.alpha == 0 {
                            
                            self.loadingView.isHidden = true
                            
                        }
                        
                    }
                    
                    
                }
        
    }
    
}
