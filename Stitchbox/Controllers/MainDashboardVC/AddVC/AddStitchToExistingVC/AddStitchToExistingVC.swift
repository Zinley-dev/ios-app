//
//  AddStitchToExistingVC.swift
//  Stitchbox
//
//  Created by Khoi Nguyen on 7/12/23.
//

import UIKit
import FLAnimatedImage
import AsyncDisplayKit
import AlamofireImage
import Alamofire
import SCLAlertView

class AddStitchToExistingVC: UIViewController, UICollectionViewDelegateFlowLayout, UIAdaptivePresentationControllerDelegate{

    @IBOutlet weak var linkImg: UIImageView!
    @IBOutlet weak var stitchHeight: NSLayoutConstraint!
    @IBOutlet weak var stitchWidth: NSLayoutConstraint!

    @IBOutlet weak var imgHeight: NSLayoutConstraint!
    @IBOutlet weak var imgWidth: NSLayoutConstraint!
    let backButton: UIButton = UIButton(type: .custom)
    @IBOutlet weak var loadingImage: FLAnimatedImageView!
    @IBOutlet weak var loadingView: UIView!
    @IBOutlet weak var contentView: UIView!
    var collectionNode: ASCollectionNode!
   
    @IBOutlet weak var originalImg: UIImageView!
    @IBOutlet weak var stitchImg: UIImageView!
    
    @IBOutlet weak var originalUsername: UILabel!
    @IBOutlet weak var stitchUsername: UILabel!
    
    @IBOutlet weak var originalView: UIView!
    @IBOutlet weak var stitchView: UIView!
    
    var stitchedPost: PostModel!
    var selectedPost: PostModel!
    var posts = [PostModel]()
    var page = 1
    var stitchId = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        setupNavBar()
        setupButtons()
        setupCollectionNode()
        setupStitch()
        
        let userDefaults = UserDefaults.standard
        
        if userDefaults.bool(forKey: "hasAlertContentBefore") == false {
            
            acceptTermStitch()
            
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        do {
            
            let path = Bundle.main.path(forResource: "fox2", ofType: "gif")!
            let gifData = try NSData(contentsOfFile: path) as Data
            let image = FLAnimatedImage(animatedGIFData: gifData)
            
            
            self.loadingImage.animatedImage = image
            
        } catch {
            print(error.localizedDescription)
        }
        
        loadingView.backgroundColor = self.view.backgroundColor
        navigationController?.setNavigationBarHidden(false, animated: true)
        
        
        delay(1.25) {
            
            UIView.animate(withDuration: 0.5) {
                
                self.loadingView.alpha = 0
                
            }
            
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                
                if self.loadingView.alpha == 0 {
                    
                    self.loadingView.isHidden = true
                    
                }
                
            }
            
        }
        
        
        setupNavBar()
        
    }
    
    func setupNavBar() {
        let navigationBarAppearance = UINavigationBarAppearance()
        navigationBarAppearance.configureWithOpaqueBackground()
        navigationBarAppearance.backgroundColor = .white
        navigationBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.black]
        navigationBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.black]
        
        self.navigationController?.navigationBar.standardAppearance = navigationBarAppearance
        self.navigationController?.navigationBar.scrollEdgeAppearance = navigationBarAppearance
    }

    

}


extension AddStitchToExistingVC {
    
    func setupButtons() {
        
        setupBackButton()
        
    }
    
    
    func setupBackButton() {
        
        backButton.frame = back_frame
        backButton.contentMode = .center
        
        if let backImage = UIImage(named: "back-black") {
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
        navigationItem.title = "Let's stitch"
        
        self.navigationItem.leftBarButtonItem = backButtonBarButton
        
        
        
    }
    
    
    func showErrorAlert(_ title: String, msg: String) {
        
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default)
        
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
        
    }
    
    
}

extension AddStitchToExistingVC {
    
    @objc func onClickBack(_ sender: AnyObject) {
        if let navigationController = self.navigationController {
            navigationController.popViewController(animated: true)
        }
    }
    
}

extension AddStitchToExistingVC: ASCollectionDataSource {
    
    func numberOfSections(in collectionNode: ASCollectionNode) -> Int {
        
        return 1
        
    }
    
    func collectionNode(_ collectionNode: ASCollectionNode, numberOfItemsInSection section: Int) -> Int {
        
        return self.posts.count
    }
    
    func collectionNode(_ collectionNode: ASCollectionNode, nodeBlockForItemAt indexPath: IndexPath) -> ASCellNodeBlock {
        let post = self.posts[indexPath.row]
        
        return {
            let node = OwnerPostSearchNode(with: post, isSave: false)
            node.neverShowPlaceholders = true
            node.debugName = "Node \(indexPath.row)"
            node.FontSize = 10
            //
            return node
        }
    }
    
    func collectionNode(_ collectionNode: ASCollectionNode, willBeginBatchFetchWith context: ASBatchContext) {
        
        retrieveNextPageWithCompletion { [weak self] (newPosts) in
            guard let self = self else { return }
            self.insertNewRowsInCollectionNode(newPosts: newPosts)

            context.completeBatchFetching(true)
        }
    }

    
}

extension AddStitchToExistingVC: ASCollectionDelegate {
    
    func collectionNode(_ collectionNode: ASCollectionNode, constrainedSizeForItemAt indexPath: IndexPath) -> ASSizeRange {
        
        
        let size = self.collectionNode.view.layer.frame.width/3 - 2
        let height = size * 13.5 / 9
        let min = CGSize(width: size, height: height)
        let max = CGSize(width: size, height: height)
        

        return ASSizeRangeMake(min, max)
    }
    
    func shouldBatchFetch(for collectionNode: ASCollectionNode) -> Bool {
        return true
    }
    
}


extension AddStitchToExistingVC {
    
    func swiftLoader(progress: String) {
        
        var config : SwiftLoader.Config = SwiftLoader.Config()
        config.size = 170
        
        config.backgroundColor = UIColor.clear
        config.spinnerColor = UIColor.white
        config.titleTextColor = UIColor.white
        
        
        config.spinnerLineWidth = 3.0
        config.foregroundColor = UIColor.black
        config.foregroundAlpha = 0.7
        
        
        SwiftLoader.setConfig(config: config)
        
        
        SwiftLoader.show(title: progress, animated: true)
        
        
    }
    
}



extension AddStitchToExistingVC {
    
    func setupCollectionNode() {
        let flowLayout = UICollectionViewFlowLayout()
        
        flowLayout.minimumInteritemSpacing = 2 // Set minimum spacing between items to 0
        flowLayout.minimumLineSpacing = 2 // Set minimum line spacing to 0
        
        self.collectionNode = ASCollectionNode(collectionViewLayout: flowLayout)
        self.collectionNode.automaticallyRelayoutOnLayoutMarginsChanges = false
        self.collectionNode.leadingScreensForBatching = 2.0
        self.collectionNode.view.contentInsetAdjustmentBehavior = .never
        // Set the data source and delegate
        self.collectionNode.dataSource = self
        self.collectionNode.delegate = self
        
        // Add the collection node's view as a subview and set constraints
        self.contentView.addSubview(collectionNode.view)
        self.collectionNode.view.translatesAutoresizingMaskIntoConstraints = false
        self.collectionNode.view.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 0).isActive = true
        self.collectionNode.view.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 0).isActive = true
        self.collectionNode.view.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: 0).isActive = true
        self.collectionNode.view.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: 0).isActive = true
        
        self.applyStyle()
        self.wireDelegates()
        
        // Reload the data on the collection node
        self.collectionNode.reloadData()
    }
    
    
    
    func applyStyle() {
        
        self.collectionNode.view.isPagingEnabled = false
        self.collectionNode.view.backgroundColor = UIColor.clear
        self.collectionNode.view.showsVerticalScrollIndicator = false
        self.collectionNode.view.allowsSelection = true
        self.collectionNode.view.contentInsetAdjustmentBehavior = .never
        self.collectionNode.needsDisplayOnBoundsChange = false
        
    }
    
    func wireDelegates() {
        
        self.collectionNode.delegate = self
        self.collectionNode.dataSource = self
        
    }
    
    
    func collectionNode(_ collectionNode: ASCollectionNode, didSelectItemAt indexPath: IndexPath) {
        
        if let node = collectionNode.nodeForItem(at: indexPath as IndexPath) as? OwnerPostSearchNode {
            
            if node.isSelected == true {
                
                node.layer.cornerRadius = 10
                node.layer.borderWidth = 2
                node.layer.borderColor = UIColor.secondary.cgColor
            
                if selectedPost == nil {
                    selectedPost = posts[indexPath.row]
                    setupStitch()
                } else {
                    if selectedPost.id != posts[indexPath.row].id {
                        selectedPost = posts[indexPath.row]
                        setupStitch()
                    }
                }
                
            }
            
           
        }
    
    }
    
    func collectionNode(_ collectionNode: ASCollectionNode, didDeselectItemAt indexPath: IndexPath) {
        
        if let node = collectionNode.nodeForItem(at: indexPath as IndexPath) as? OwnerPostSearchNode {
            
            node.layer.borderColor = UIColor.clear.cgColor
            
            
        }
    }

    
}



extension AddStitchToExistingVC {
    
    func retrieveNextPageWithCompletion(block: @escaping ([[String: Any]]) -> Void) {
        
        APIManager.shared.getMyNonStitchPost(page: page) { [weak self] result in
            guard let self = self else { return }
            
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
                    print("Successfully retrieved \(data.count) posts.")
                    self.page += 1
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
    
    func insertNewRowsInCollectionNode(newPosts: [[String: Any]]) {

        // checking empty
        guard newPosts.count > 0 else {
            return
        }

        // Create new PostModel objects and append them to the current posts
        var items = [PostModel]()
        for i in newPosts {
            if let item = PostModel(JSON: i) {
                if !self.posts.contains(item) {
                    self.posts.append(item)
                    items.append(item)
                }
            }
        }

        // Construct index paths for the new rows
        if items.count > 0 {
            let startIndex = self.posts.count - items.count
            let endIndex = startIndex + items.count - 1
            print(startIndex, endIndex)
            let indexPaths = (startIndex...endIndex).map { IndexPath(row: $0, section: 0) }

            // Insert new items at index paths
            self.collectionNode.insertItems(at: indexPaths)
        }
    }

    
}

extension AddStitchToExistingVC {
    
    func setupStitch() {
        
        let numberOfItemsInRow: CGFloat = 3
        let spacing: CGFloat = 5
        let width = (UIScreen.main.bounds.width - (numberOfItemsInRow + 1) * spacing) / numberOfItemsInRow
        let height = width * 13.5 / 9  // This will give you an aspect ratio of 9:16
        
        
        imgWidth.constant = width
        imgHeight.constant = height
        
        stitchHeight.constant = height
        stitchWidth.constant = width
        
        
        if let stitch = selectedPost {
            stitchImg.loadProfileContent(url: stitch.imageUrl, str: stitch.imageUrl.absoluteString)
            stitchUsername.text = "@\(stitch.owner?.username ?? "")"
            stitchView.isHidden = false
            linkImg.isHidden = false
            if self.navigationItem.rightBarButtonItem == nil {
                createStitchBtn()
            }
            
        } else {
            stitchView.isHidden = true
            linkImg.isHidden = true
            if let data = stitchedPost {
                originalImg.loadProfileContent(url: data.imageUrl, str: data.imageUrl.absoluteString)
                originalUsername.text = "@\(data.owner?.username ?? "")"
            }
        }
        
    }
    
    
    func createStitchBtn() {
    
        let createButton = UIButton(type: .custom)
        createButton.addTarget(self, action: #selector(onClickStitch(_:)), for: .touchUpInside)
        createButton.semanticContentAttribute = .forceRightToLeft
        createButton.setTitle("Stitch", for: .normal)
        createButton.setTitleColor(.white, for: .normal)
        createButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        createButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 2, bottom: 0, right: -2)
        createButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: -2, bottom: 0, right: 2)
        createButton.frame = CGRect(x: 0, y: 0, width: 80, height: 30)
        createButton.backgroundColor = .secondary
        createButton.cornerRadius = 15
        let customView = UIView(frame: CGRect(x: 0, y: 0, width: 80, height: 30))
        customView.addSubview(createButton)
        createButton.center = customView.center
        let createBarButton = UIBarButtonItem(customView: customView)

        let fixedSpace = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        fixedSpace.width = 2
      
        self.navigationItem.rightBarButtonItem = createBarButton
         
    }
    
    @objc func onClickStitch(_ sender: AnyObject) {
        
        if stitchedPost != nil {
            
            swiftLoader(progress: "Stitching...")
     
            print("Done")
            
            APIManager.shared.stitch(rootId: stitchedPost.id, memberId: selectedPost.id) { [weak self] result in
                guard let self = self else { return }

                switch result {
                case .success(let apiResponse):
                    print(apiResponse)
                    DispatchQueue.main.async { [weak self] in
                        guard let self = self else { return }
                        if let navigationController = self.navigationController {
                            SwiftLoader.hide()
                            navigationController.popViewController(animated: true)
                            showNote(text: "Stitched successfully")
                        }
                    }

                case .failure(let error):
                    DispatchQueue.main.async {
                        print(error)
                        SwiftLoader.hide()
                        self.showErrorAlert("Oops!", msg: "Couldn't stitch now, please try again")
                    }

                }
            }
            
        } else {
            
            self.showErrorAlert("Oops!", msg: "Couldn't stitch now, please try again")
            
        }
        
        
    }
    
    
    func acceptTermStitch() {
        
        if let username = _AppCoreData.userDataSource.value?.userName {
           
            let appearance = SCLAlertView.SCLAppearance(
                kTitleFont: FontManager.shared.roboto(.Medium, size: 15),
                kTextFont: FontManager.shared.roboto(.Regular, size: 13),
                kButtonFont: FontManager.shared.roboto(.Medium, size: 13),
                showCloseButton: false,
                dynamicAnimatorActive: true,
                buttonsLayout: .horizontal
            )
            
            let alert = SCLAlertView(appearance: appearance)
            
            _ = alert.addButton("Decline", backgroundColor: .normalButtonBackground, textColor: .black) {
                
                showNote(text: "Thank you and feel feel free to enjoy other videos at Stitchbox!")
                
                if let navigationController = self.navigationController {
                    navigationController.popViewController(animated: true)
                } else {
                    self.dismiss(animated: true)
                }
             
            }
            
            

            _ = alert.addButton("Agree", backgroundColor: UIColor.secondary, textColor: .white) {
                
                let userDefaults = UserDefaults.standard
                
                userDefaults.set(true, forKey: "hasAlertContentBefore")
                userDefaults.synchronize() // This forces the app to update userDefaults
                
                showNote(text: "Thank you and enjoy Stitch!")
                
            }
            
           
            
            let terms = """
                        Ensure your content maintains relevance to the original topic.
                        Exhibit respect towards the original author in your content.
                        Abide by our terms of use and guidelines in the creation of your content.
                        """
                    
                    let icon = UIImage(named:"Logo")
                    
                    _ = alert.showCustom("Hi \(username),", subTitle: terms, color: UIColor.white, icon: icon!)
            
        }
        
        
        
    }
    
}
