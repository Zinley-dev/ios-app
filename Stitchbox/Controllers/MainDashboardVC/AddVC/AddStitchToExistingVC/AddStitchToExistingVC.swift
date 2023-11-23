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
        
        configureView()
        checkForUserAlertSettings()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setupNavBarAppearance()
    }
    
    /// Configures the view controller's main view.
    private func configureView() {
        setupNavBarAppearance()
        setupButtons()
        setupCollectionNode()
        setupStitch()
    }
    
    /// Sets up the navigation bar appearance.
    func setupNavBarAppearance() {
        let navigationBarAppearance = UINavigationBarAppearance()
        navigationBarAppearance.configureWithOpaqueBackground()
        navigationBarAppearance.backgroundColor = .white
        navigationBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.black]
        navigationBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.black]
        
        navigationController?.navigationBar.standardAppearance = navigationBarAppearance
        navigationController?.navigationBar.scrollEdgeAppearance = navigationBarAppearance
    }
    
    /// Checks and handles the user's alert settings.
    private func checkForUserAlertSettings() {
        let userDefaults = UserDefaults.standard
        if !userDefaults.bool(forKey: "hasAlertContentBefore") {
            acceptTermStitch()
        }
    }


}

extension AddStitchToExistingVC {
    
    /// Sets up the buttons for the view controller.
    func setupButtons() {
        setupBackButton()
    }
    
    /// Configures the back button with its properties, image, and action.
    func setupBackButton() {
        backButton.frame = back_frame
        backButton.contentMode = .center
        configureBackButtonImage()
        backButton.addTarget(self, action: #selector(onClickBack(_:)), for: .touchUpInside)
        backButton.setTitleColor(.white, for: .normal)
        backButton.setTitle("", for: .normal)

        let backButtonBarButton = UIBarButtonItem(customView: backButton)
        navigationItem.title = "Let's stitch"
        self.navigationItem.leftBarButtonItem = backButtonBarButton
    }
    
    /// Configures the image for the back button with appropriate padding and insets.
    private func configureBackButtonImage() {
        guard let backImage = UIImage(named: "back-black") else { return }
        let imageSize = CGSize(width: 13, height: 23)
        let padding = UIEdgeInsets(
            top: (back_frame.height - imageSize.height) / 2,
            left: (back_frame.width - imageSize.width) / 2 - horizontalPadding,
            bottom: (back_frame.height - imageSize.height) / 2,
            right: (back_frame.width - imageSize.width) / 2 + horizontalPadding
        )
        backButton.imageEdgeInsets = padding
        backButton.setImage(backImage, for: [])
    }

    /// Displays an error alert with a given title and message.
    /// - Parameters:
    ///   - title: The title of the alert.
    ///   - msg: The message of the alert.
    func showErrorAlert(_ title: String, msg: String) {
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
}


extension AddStitchToExistingVC {
    
    /// Handles the back button click event.
    /// - Parameter sender: The object that triggered the event.
    @objc func onClickBack(_ sender: AnyObject) {
        self.navigationController?.popViewController(animated: true)
    }
    
}


extension AddStitchToExistingVC: ASCollectionDataSource {
    
    /// Returns the number of sections in the collection node.
    /// - Parameter collectionNode: The collection node requesting this information.
    /// - Returns: The number of sections.
    func numberOfSections(in collectionNode: ASCollectionNode) -> Int {
        return 1
    }
    
    /// Returns the number of items in a given section of the collection node.
    /// - Parameters:
    ///   - collectionNode: The collection node requesting this information.
    ///   - section: The section number.
    /// - Returns: The number of items in the section.
    func collectionNode(_ collectionNode: ASCollectionNode, numberOfItemsInSection section: Int) -> Int {
        return self.posts.count
    }
    
    /// Provides a block that creates and returns a cell node for a given item.
    /// - Parameters:
    ///   - collectionNode: The collection node requesting this information.
    ///   - indexPath: The index path of the item.
    /// - Returns: A block that creates and returns a new cell node.
    func collectionNode(_ collectionNode: ASCollectionNode, nodeBlockForItemAt indexPath: IndexPath) -> ASCellNodeBlock {
        let post = self.posts[indexPath.row]

        return {
            let node = OwnerPostSearchNode(with: post, isSave: false)
            node.neverShowPlaceholders = true
            node.debugName = "Node \(indexPath.row)"
            node.fontSize = 10  // Adjust the font size as needed
            return node
        }
    }
    
    /// Handles batch fetching for additional content in the collection node.
    /// - Parameters:
    ///   - collectionNode: The collection node requesting this information.
    ///   - context: The batch fetching context.
    func collectionNode(_ collectionNode: ASCollectionNode, willBeginBatchFetchWith context: ASBatchContext) {
        retrieveNextPageWithCompletion { [weak self] newPosts in
            guard let self = self else { return }
            self.insertNewRowsInCollectionNode(newPosts: newPosts)
            context.completeBatchFetching(true)
        }
    }
    
}


extension AddStitchToExistingVC: ASCollectionDelegate {
    
    /// Determines the size range for an item at the specified index path in the collection node.
    /// - Parameters:
    ///   - collectionNode: The collection node requesting this information.
    ///   - indexPath: The index path of the item.
    /// - Returns: An `ASSizeRange` object containing the minimum and maximum sizes for the item.
    func collectionNode(_ collectionNode: ASCollectionNode, constrainedSizeForItemAt indexPath: IndexPath) -> ASSizeRange {
        let width = self.collectionNode.view.layer.frame.width / 3 - 2
        let aspectRatio: CGFloat = 13.5 / 9
        let height = width * aspectRatio
        let itemSize = CGSize(width: width, height: height)

        return ASSizeRangeMake(itemSize, itemSize)
    }
    
    /// Determines whether the collection node should batch fetch more content.
    /// - Parameter collectionNode: The collection node requesting this information.
    /// - Returns: A Boolean value indicating whether batch fetching should occur.
    func shouldBatchFetch(for collectionNode: ASCollectionNode) -> Bool {
        return true
    }
    
}


extension AddStitchToExistingVC {

    /// Displays a loader with the specified progress title.
    /// - Parameter progress: The title to display indicating the current progress.
    func swiftLoader(progress: String) {
        let config = createSwiftLoaderConfig()
        SwiftLoader.setConfig(config: config)
        SwiftLoader.show(title: progress, animated: true)
    }

    /// Creates and returns a configuration for the SwiftLoader.
    /// - Returns: A configured instance of SwiftLoader.Config.
    private func createSwiftLoaderConfig() -> SwiftLoader.Config {
        var config = SwiftLoader.Config()
        config.size = 170
        config.backgroundColor = .clear
        config.spinnerColor = .white
        config.titleTextColor = .white
        config.spinnerLineWidth = 3.0
        config.foregroundColor = .black
        config.foregroundAlpha = 0.7
        return config
    }
    
}



extension AddStitchToExistingVC {
    
    /// Sets up the collection node with its layout, delegates, data source, and other properties.
    func setupCollectionNode() {
        configureFlowLayout()
        initializeCollectionNode()
        setupConstraintsForCollectionNode()
        applyStyleToCollectionNode()
        wireCollectionNodeDelegates()
        collectionNode.reloadData()
    }

    /// Configures the flow layout for the collection node.
    private func configureFlowLayout() {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.minimumInteritemSpacing = 2
        flowLayout.minimumLineSpacing = 2
        self.collectionNode = ASCollectionNode(collectionViewLayout: flowLayout)
    }

    /// Initializes the collection node with its properties.
    private func initializeCollectionNode() {
        self.collectionNode.automaticallyRelayoutOnLayoutMarginsChanges = false
        self.collectionNode.leadingScreensForBatching = 2.0
        self.collectionNode.view.contentInsetAdjustmentBehavior = .never
    }

    /// Sets up constraints for the collection node.
    private func setupConstraintsForCollectionNode() {
        self.contentView.addSubview(collectionNode.view)
        collectionNode.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            collectionNode.view.topAnchor.constraint(equalTo: self.contentView.topAnchor),
            collectionNode.view.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor),
            collectionNode.view.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor),
            collectionNode.view.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor)
        ])
    }

    /// Applies styling to the collection node.
    private func applyStyleToCollectionNode() {
        self.collectionNode.view.isPagingEnabled = false
        self.collectionNode.view.backgroundColor = .clear
        self.collectionNode.view.showsVerticalScrollIndicator = false
        self.collectionNode.view.allowsSelection = true
        self.collectionNode.view.contentInsetAdjustmentBehavior = .never
        self.collectionNode.needsDisplayOnBoundsChange = false
    }

    /// Assigns delegates to the collection node.
    private func wireCollectionNodeDelegates() {
        self.collectionNode.delegate = self
        self.collectionNode.dataSource = self
    }
    
    // MARK: - ASCollectionNode Delegate Methods

    func collectionNode(_ collectionNode: ASCollectionNode, didSelectItemAt indexPath: IndexPath) {
        if let node = collectionNode.nodeForItem(at: indexPath) as? OwnerPostSearchNode {
            handleNodeSelection(node, at: indexPath)
        }
    }

    func collectionNode(_ collectionNode: ASCollectionNode, didDeselectItemAt indexPath: IndexPath) {
        if let node = collectionNode.nodeForItem(at: indexPath) as? OwnerPostSearchNode {
            node.layer.borderColor = UIColor.clear.cgColor
        }
    }

    // MARK: - Private Helper Methods

    private func handleNodeSelection(_ node: OwnerPostSearchNode, at indexPath: IndexPath) {
        node.layer.cornerRadius = 10
        node.layer.borderWidth = 2
        node.layer.borderColor = UIColor.secondary.cgColor
        
        if selectedPost?.id != posts[indexPath.row].id {
            selectedPost = posts[indexPath.row]
            setupStitch()
        }
    }
}


extension AddStitchToExistingVC {
    
    /// Retrieves the next page of posts and returns them via a completion block.
    /// - Parameter block: A completion block that receives an array of dictionaries representing posts.
    func retrieveNextPageWithCompletion(block: @escaping ([[String: Any]]) -> Void) {
        APIManager.shared.getMyNonStitchPost(page: page) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let apiResponse):
                self.handleSuccess(apiResponse: apiResponse, completion: block)
            case .failure(let error):
                print("Error retrieving posts: \(error)")
                self.executeCompletionBlockWithEmptyData(block)
            }
        }
    }

    /// Inserts new rows in the collection node based on the provided posts.
    /// - Parameter newPosts: An array of dictionaries representing new posts to be added.
    func insertNewRowsInCollectionNode(newPosts: [[String: Any]]) {
        guard !newPosts.isEmpty else { return }

        let newItems = newPosts.compactMap { PostModel(JSON: $0) }
        let uniqueItems = newItems.filter { !self.posts.contains($0) }

        self.posts.append(contentsOf: uniqueItems)
        self.insertItemsInCollectionNode(items: uniqueItems)
    }

    // MARK: - Private Helper Methods

    private func handleSuccess(apiResponse: APIResponse, completion: @escaping ([[String: Any]]) -> Void) {
        guard let data = apiResponse.body?["data"] as? [[String: Any]], !data.isEmpty else {
            print("No data found in the response.")
            executeCompletionBlockWithEmptyData(completion)
            return
        }

        print("Successfully retrieved \(data.count) posts.")
        self.page += 1
        DispatchQueue.main.async {
            completion(data)
        }
    }

    private func insertItemsInCollectionNode(items: [PostModel]) {
        guard !items.isEmpty else { return }

        let startIndex = self.posts.count - items.count
        let endIndex = startIndex + items.count - 1
        let indexPaths = (startIndex...endIndex).map { IndexPath(row: $0, section: 0) }

        self.collectionNode.insertItems(at: indexPaths)
    }

    private func executeCompletionBlockWithEmptyData(_ completion: @escaping ([[String: Any]]) -> Void) {
        DispatchQueue.main.async {
            completion([[String: Any]]())
        }
    }
}


extension AddStitchToExistingVC {
    
    /// Configures the stitch view with appropriate sizing and content.
    /// This function calculates the size of image views based on the screen width and
    /// updates the UI based on the availability of `selectedPost` or `stitchedPost`.
    func setupStitch() {
        configureStitchSize()
        updateStitchContent()
    }

    /// Calculates and sets the width and height of the stitch and image views
    /// based on the screen width and a predefined aspect ratio.
    private func configureStitchSize() {
        let numberOfItemsInRow: CGFloat = 3
        let spacing: CGFloat = 5
        let totalSpacing = (numberOfItemsInRow + 1) * spacing
        let width = (UIScreen.main.bounds.width - totalSpacing) / numberOfItemsInRow
        let aspectRatio: CGFloat = 13.5 / 9  // Aspect ratio of 9:16
        let height = width * aspectRatio
        
        imgWidth.constant = width
        imgHeight.constant = height
        stitchHeight.constant = height
        stitchWidth.constant = width
    }

    /// Updates the content of the stitch view based on the available data.
    /// Shows or hides elements and updates their content if needed.
    private func updateStitchContent() {
        if let stitch = selectedPost {
            configureStitchView(with: stitch)
        } else {
            stitchView.isHidden = true
            linkImg.isHidden = true
            if let data = stitchedPost {
                configureOriginalView(with: data)
            }
        }
    }

    /// Configures the stitch view with the given post data.
    /// - Parameter stitch: The selected post to display.
    private func configureStitchView(with stitch: PostModel) {  // Replace PostType with your actual post type
        stitchImg.loadProfileContent(url: stitch.imageUrl, str: stitch.imageUrl.absoluteString)
        stitchUsername.text = "@\(stitch.owner?.username ?? "")"
        stitchView.isHidden = false
        linkImg.isHidden = false
        createStitchButtonIfNeeded()
    }

    /// Configures the original view with the given post data.
    /// - Parameter data: The stitched post to display.
    private func configureOriginalView(with data: PostModel) {  // Replace PostType with your actual post type
        originalImg.loadProfileContent(url: data.imageUrl, str: data.imageUrl.absoluteString)
        originalUsername.text = "@\(data.owner?.username ?? "")"
    }

    /// Creates the stitch button if it doesn't already exist in the navigation bar.
    private func createStitchButtonIfNeeded() {
        if navigationItem.rightBarButtonItem == nil {
            createStitchBtn()
        }
    }
    
    
    // MARK: - UI Creation

    /// Creates a 'Stitch' button and adds it to the navigation bar.
    func createStitchBtn() {
        let createButton = createCustomButton()
        let customView = createCustomButtonContainer(with: createButton)
        let createBarButton = UIBarButtonItem(customView: customView)

        let fixedSpace = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        fixedSpace.width = 2

        self.navigationItem.rightBarButtonItem = createBarButton
    }

    // MARK: - Private Helper Methods

    /// Creates a custom UIButton for stitching.
    private func createCustomButton() -> UIButton {
        let button = UIButton(type: .custom)
        button.addTarget(self, action: #selector(onClickStitch(_:)), for: .touchUpInside)
        configureButtonAppearance(button)
        return button
    }

    /// Configures the appearance of the given button.
    private func configureButtonAppearance(_ button: UIButton) {
        button.semanticContentAttribute = .forceRightToLeft
        button.setTitle("Stitch", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: 2, bottom: 0, right: -2)
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: -2, bottom: 0, right: 2)
        button.frame = CGRect(x: 0, y: 0, width: 80, height: 30)
        button.backgroundColor = .secondary
        button.cornerRadius = 15 // Assuming there's an extension to set corner radius
    }

    /// Creates a custom view container for the button.
    private func createCustomButtonContainer(with button: UIButton) -> UIView {
        let customView = UIView(frame: CGRect(x: 0, y: 0, width: 80, height: 30))
        customView.addSubview(button)
        button.center = customView.center
        return customView
    }
    
    // MARK: - Button Action

    /// Handles the click event for stitching a post.
    @objc func onClickStitch(_ sender: AnyObject) {
        if let stitchedPost = stitchedPost, let selectedPost = selectedPost {
            swiftLoader(progress: "Stitching...")
            
            APIManager.shared.stitch(rootId: stitchedPost.id, memberId: selectedPost.id) { [weak self] result in
                guard let self = self else { return }

                switch result {
                case .success(let apiResponse):
                    print(apiResponse)
                    DispatchQueue.main.async { [weak self] in
                        guard let self = self else { return }
                        SwiftLoader.hide()
                        if let navigationController = self.navigationController {
                            navigationController.popViewController(animated: true)
                        }
                        showNote(text: "Stitched successfully")
                    }

                case .failure(let error):
                    DispatchQueue.main.async {
                        SwiftLoader.hide()
                        self.showErrorAlert("Oops!", msg: "Couldn't stitch now, please try again. Error: \(error.localizedDescription)")
                    }
                }
            }
        } else {
            showErrorAlert("Oops!", msg: "No post selected for stitching")
        }
    }
    
    /// Shows a terms and conditions alert to the user.
    func acceptTermStitch() {
        guard let username = _AppCoreData.userDataSource.value?.userName else { return }

        let appearance = configureAlertAppearance()
        let alert = SCLAlertView(appearance: appearance)

        addDeclineButton(to: alert)
        addAgreeButton(to: alert)

        let terms = getTermsString()
        let icon = UIImage(named: "stitchboxlogonew")
        alert.showCustom("Hi \(username),", subTitle: terms, color: UIColor.white, icon: icon!)
    }

    // MARK: - Private Helper Methods

    /// Configures the appearance for the alert.
    private func configureAlertAppearance() -> SCLAlertView.SCLAppearance {
        return SCLAlertView.SCLAppearance(
            kTitleFont: FontManager.shared.roboto(.Medium, size: 15),
            kTextFont: FontManager.shared.roboto(.Regular, size: 13),
            kButtonFont: FontManager.shared.roboto(.Medium, size: 13),
            showCloseButton: false,
            dynamicAnimatorActive: true,
            buttonsLayout: .horizontal
        )
    }

    /// Adds a 'Decline' button to the alert.
    private func addDeclineButton(to alert: SCLAlertView) {
        _ = alert.addButton("Decline", backgroundColor: .normalButtonBackground, textColor: .black) {
            self.showNoteAndDismiss(text: "Thank you and feel free to enjoy other videos at Stitchbox!")
        }
    }

    /// Adds an 'Agree' button to the alert.
    private func addAgreeButton(to alert: SCLAlertView) {
        _ = alert.addButton("Agree", backgroundColor: UIColor.secondary, textColor: .white) {
            self.updateUserDefaultAndShowNote()
        }
    }

    /// Updates UserDefaults and shows a note.
    private func updateUserDefaultAndShowNote() {
        let userDefaults = UserDefaults.standard
        userDefaults.set(true, forKey: "hasAlertContentBefore")
        userDefaults.synchronize() // Forces the app to update UserDefaults
        showNote(text: "Thank you and enjoy Stitch!")
    }

    /// Shows a note and dismisses the view controller.
    private func showNoteAndDismiss(text: String) {
        showNote(text: text)
        if let navigationController = self.navigationController {
            navigationController.popViewController(animated: true)
        } else {
            self.dismiss(animated: true)
        }
    }

    /// Returns the terms string.
    private func getTermsString() -> String {
        return """
               Ensure your content maintains relevance to the original topic.
               Exhibit respect towards the original author in your content.
               Abide by our terms of use and guidelines in the creation of your content.
               """
    }

}
