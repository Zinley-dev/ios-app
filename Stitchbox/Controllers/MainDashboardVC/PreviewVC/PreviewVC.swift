//
//  PreviewVC.swift
//  Stitchbox
//
//  Created by Khoi Nguyen on 7/14/23.
//

import UIKit
import AsyncDisplayKit
import AlamofireImage
import Alamofire
import FLAnimatedImage

class PreviewVC: UIViewController, UICollectionViewDelegateFlowLayout, UIAdaptivePresentationControllerDelegate {
    
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var timeLbl: UILabel!
    @IBOutlet weak var blurView: UIView!
    @IBOutlet weak var loadingImage: FLAnimatedImageView!
    @IBOutlet weak var loadingView: UIView!

    let backButton: UIButton = UIButton(type: .custom)
    var currentIndex: Int?
    var isfirstLoad = true
    var posts = [PostModel]()
    var collectionNode: ASCollectionNode!
    var startIndex: Int!
    var isVideoPlaying = false
    var newPlayingIndex: Int?
    var selectedPost = [PostModel]()
  
    override func viewDidLoad() {
        super.viewDidLoad()
        initialSetup()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        pauseVideoIfNeeded()
    }

    /// Performs the initial setup tasks when the view loads.
    private func initialSetup() {
        setupButtons()
        setupCollectionNode()
        setupNavBar()
        blurView.isHidden = true
        delayLoadingPosts()
    }

    /// Delays the loading of posts slightly after the view has loaded.
    private func delayLoadingPosts() {
        delay(0.05) { [weak self] in
            self?.loadPosts()
        }
    }

    /// Pauses the video if there is a new playing index.
    private func pauseVideoIfNeeded() {
        guard let currentIndex = currentIndex, newPlayingIndex != nil else { return }
        pauseVideo(atIndex: currentIndex)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        configureLoadingImage()
        setupLoadingViewAppearance()
        animateAndHideLoadingView()
        playCurrentVideoIfNeeded()
        setupNavBar()
    }

    /// Configures the loading image with an animated GIF.
    private func configureLoadingImage() {
        do {
            let gifData = try loadGifData(named: "fox2")
            let image = FLAnimatedImage(animatedGIFData: gifData)
            loadingImage.animatedImage = image
        } catch {
            print(error.localizedDescription)
        }
    }

    /// Loads GIF data from the specified file name.
    /// - Parameter name: The name of the GIF file.
    /// - Returns: The Data representation of the GIF.
    private func loadGifData(named name: String) throws -> Data {
        guard let path = Bundle.main.path(forResource: name, ofType: "gif") else {
            throw NSError(domain: "FileNotFound", code: 0, userInfo: [NSLocalizedDescriptionKey: "GIF file not found"])
        }
        return try NSData(contentsOfFile: path) as Data
    }

    /// Sets up the appearance of the loading view.
    private func setupLoadingViewAppearance() {
        loadingView.backgroundColor = .white
        navigationController?.setNavigationBarHidden(false, animated: true)
    }

    /// Animates the fading out of the loading view and then hides it.
    private func animateAndHideLoadingView() {
        delay(1) {
            UIView.animate(withDuration: 0.5) {
                self.loadingView.alpha = 0
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
                self?.hideLoadingViewIfInvisible()
            }
        }
    }

    /// Hides the loading view if it is fully transparent.
    private func hideLoadingViewIfInvisible() {
        guard loadingView.alpha == 0 else { return }
        
        loadingView.isHidden = true
        loadingImage.stopAnimating()
        loadingImage.animatedImage = nil
        loadingImage.image = nil
        loadingImage.removeFromSuperview()
    }

    /// Plays the video at the current index if one is set.
    private func playCurrentVideoIfNeeded() {
        guard let currentIndex = currentIndex else { return }
        playVideo(atIndex: currentIndex)
    }

    
}

extension PreviewVC {
    
    /// Sets up the navigation bar with a custom appearance.
    func setupNavBar() {
        configureNavigationBarAppearance()
    }

    /// Configures the appearance of the navigation bar.
    private func configureNavigationBarAppearance() {
        let appearance = createNavigationBarAppearance()
        applyNavigationBarAppearance(appearance)
    }

    /// Creates a UINavigationBarAppearance with specific configurations.
    /// - Returns: A configured UINavigationBarAppearance object.
    private func createNavigationBarAppearance() -> UINavigationBarAppearance {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .clear
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        appearance.backgroundImage = UIImage()
        appearance.shadowImage = UIImage()
        appearance.shadowColor = .clear
        appearance.backgroundEffect = nil
        return appearance
    }

    /// Applies the given navigation bar appearance to the navigation controller.
    /// - Parameter appearance: The UINavigationBarAppearance to apply.
    private func applyNavigationBarAppearance(_ appearance: UINavigationBarAppearance) {
        guard let navigationController = self.navigationController else { return }
        navigationController.navigationBar.standardAppearance = appearance
        navigationController.navigationBar.compactAppearance = appearance
        navigationController.navigationBar.scrollEdgeAppearance = appearance
        navigationController.navigationBar.isTranslucent = true
    }
}


extension PreviewVC {
    
    /// Loads posts into the collection view.
    func loadPosts() {
        guard hasSelectedPosts() else { return }
        appendSelectedPostsToDataSource()
        reloadDataAndScrollToStartIndex()
    }

    /// Checks if there are selected posts.
    /// - Returns: Boolean indicating if selected posts are present.
    private func hasSelectedPosts() -> Bool {
        return !selectedPost.isEmpty
    }

    /// Appends the selected posts to the data source and updates the collection view.
    private func appendSelectedPostsToDataSource() {
        let startIndex = posts.count
        let endIndex = startIndex + selectedPost.count - 1
        let indexPaths = (startIndex...endIndex).map { IndexPath(row: $0, section: 0) }
        
        posts.append(contentsOf: selectedPost)
        collectionNode.insertItems(at: indexPaths)
    }

    /// Reloads the collection view data and scrolls to the start index if it's set.
    private func reloadDataAndScrollToStartIndex() {
        guard let startIndex = startIndex, !posts[startIndex].muxPlaybackId.isEmpty else {
            isVideoPlaying = false
            return
        }

        scrollToItemAndPlayVideo(at: startIndex)
    }

    /// Scrolls to the item at the specified index and plays the video after a delay.
    /// - Parameter index: The index to scroll to and play the video.
    private func scrollToItemAndPlayVideo(at index: Int) {
        let indexPath = IndexPath(row: index, section: 0)
        collectionNode.scrollToItem(at: indexPath, at: .centeredVertically, animated: false)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(250)) { [weak self] in
            guard let self = self, let currentCell = self.collectionNode.nodeForItem(at: indexPath) as? VideoNode else { return }
            self.playVideo(atIndex: index)
        }
    }

}

extension PreviewVC {
    
    /// Sets up all buttons in the view controller.
    func setupButtons() {
        setupBackButton()
    }
    
    /// Configures the back button with appropriate properties and layout.
    func setupBackButton() {
        configureBackButtonFrameAndContentMode()
        configureBackButtonImage()
        configureBackButtonTargetAndAppearance()
        addBackButtonToNavigationBar()
    }
    
    /// Configures the frame and content mode of the back button.
    private func configureBackButtonFrameAndContentMode() {
        backButton.frame = back_frame
        backButton.contentMode = .center
    }
    
    /// Sets the image for the back button with proper insets.
    private func configureBackButtonImage() {
        guard let backImage = UIImage(named: "back_icn_white") else { return }
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
    
    /// Configures the target, title, and appearance of the back button.
    private func configureBackButtonTargetAndAppearance() {
        backButton.addTarget(self, action: #selector(onClickBack(_:)), for: .touchUpInside)
        backButton.setTitleColor(.white, for: .normal)
        backButton.setTitle("", for: .normal)
    }
    
    /// Adds the back button to the navigation bar.
    private func addBackButtonToNavigationBar() {
        let backButtonBarButton = UIBarButtonItem(customView: backButton)
        self.navigationItem.leftBarButtonItem = backButtonBarButton
    }
    
    /// Action for the back button click event.
    @objc func onClickBack(_ sender: AnyObject) {
        navigationController?.popViewController(animated: true)
    }
}

extension PreviewVC {
    
    /// Displays an error alert with a specified title and message.
    /// - Parameters:
    ///   - title: The title for the alert.
    ///   - msg: The message to be displayed in the alert.
    func showErrorAlert(_ title: String, msg: String) {
        let alert = createAlertController(title: title, message: msg)
        present(alert, animated: true)
    }
    
    /// Configures and displays a SwiftLoader with the given progress title.
    /// - Parameter progress: The progress title to display on the loader.
    func showSwiftLoader(withProgressTitle progress: String) {
        let config = createSwiftLoaderConfig()
        SwiftLoader.setConfig(config: config)
        SwiftLoader.show(title: progress, animated: true)
    }

    /// Creates an alert controller with a title and message.
    /// - Parameters:
    ///   - title: The title for the alert.
    ///   - message: The message for the alert.
    /// - Returns: A UIAlertController instance.
    private func createAlertController(title: String, message: String) -> UIAlertController {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        return alert
    }

    /// Creates a SwiftLoader configuration.
    /// - Returns: A SwiftLoader.Config instance.
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


extension PreviewVC {
    
    
    /// Called before a cell is displayed in the collection view.
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        handleFirstLoadIfNeeded(forItemAt: indexPath)
    }

    /// Handles the first load of the collection view.
    /// - Parameter indexPath: The index path of the item.
    private func handleFirstLoadIfNeeded(forItemAt indexPath: IndexPath) {
        guard isfirstLoad, indexPath.row == 0, let firstPost = posts.first, !firstPost.muxPlaybackId.isEmpty else {
            return
        }

        isfirstLoad = false
        currentIndex = indexPath.row
        newPlayingIndex = currentIndex
        playVideo(atIndex: currentIndex!)
        isVideoPlaying = true
    }
    
  
}

extension PreviewVC: ASCollectionDataSource, ASCollectionDelegate {
    
    
    
    /// Returns the size range for an item at the specified index path in the collection node.
    func collectionNode(_ collectionNode: ASCollectionNode, constrainedSizeForItemAt indexPath: IndexPath) -> ASSizeRange {
        let size = CGSize(width: view.bounds.width, height: contentView.frame.height)
        return ASSizeRangeMake(size, size)
    }
    
    /// Returns the number of sections in the collection node.
    func numberOfSections(in collectionNode: ASCollectionNode) -> Int {
        return 1
    }
    
    /// Returns the number of items in a given section of the collection node.
    func collectionNode(_ collectionNode: ASCollectionNode, numberOfItemsInSection section: Int) -> Int {
        return self.posts.count
    }
    
    /// Provides a block that creates and configures a cell node for the given index path.
    func collectionNode(_ collectionNode: ASCollectionNode, nodeBlockForItemAt indexPath: IndexPath) -> ASCellNodeBlock {
        let post = self.posts[indexPath.row]

        return { [weak self] in
            guard let strongSelf = self else { return ASCellNode() }
            return strongSelf.createCellNode(for: post, at: indexPath)
        }
    }

    /// Creates and configures a cell node for the given post and index path.
    /// - Parameters:
    ///   - post: The post data for the cell node.
    ///   - indexPath: The index path of the cell node in the collection.
    /// - Returns: A configured `ASCellNode`.
    private func createCellNode(for post: PostModel, at indexPath: IndexPath) -> ASCellNode {
        let node = VideoNode(with: post, isPreview: true, firstItem: false, level: 0, indexPath: 0)
        node.neverShowPlaceholders = true
        node.debugName = "Node \(indexPath.row)"
        node.automaticallyManagesSubnodes = true
        return node
    }
}

extension PreviewVC {
    
    /// Sets up the collection node with necessary configurations.
    func setupCollectionNode() {
        configureFlowLayout()
        initializeCollectionNode()
        setupCollectionNodeConstraints()
        applyCollectionNodeStyle()
        wireCollectionNodeDelegates()
        collectionNode.reloadData()
    }
    
    /// Configures the flow layout for the collection node.
    private func configureFlowLayout() {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.minimumLineSpacing = 0.0
        collectionNode = ASCollectionNode(collectionViewLayout: flowLayout)
    }

    /// Initializes the collection node.
    private func initializeCollectionNode() {
        collectionNode.view.contentInsetAdjustmentBehavior = .never
        contentView.addSubview(collectionNode.view)
        collectionNode.view.translatesAutoresizingMaskIntoConstraints = false
    }

    /// Sets up constraints for the collection node's view.
    private func setupCollectionNodeConstraints() {
        NSLayoutConstraint.activate([
            collectionNode.view.topAnchor.constraint(equalTo: contentView.topAnchor),
            collectionNode.view.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            collectionNode.view.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            collectionNode.view.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }

    /// Applies style configurations to the collection node.
    private func applyCollectionNodeStyle() {
        collectionNode.view.isPagingEnabled = true
        collectionNode.view.backgroundColor = .clear
        collectionNode.view.showsVerticalScrollIndicator = false
        collectionNode.view.allowsSelection = false
        collectionNode.view.contentInsetAdjustmentBehavior = .never
    }

    /// Wires the delegate and data source of the collection node.
    private func wireCollectionNodeDelegates() {
        collectionNode.delegate = self
        collectionNode.dataSource = self
    }
}


extension PreviewVC {
    /// Pauses the video at the specified index.
    /// - Parameter index: The index of the video to pause.
    func pauseVideo(atIndex index: Int) {
        guard let videoCell = getVideoCell(at: index) else { return }
        videoCell.pauseVideo(shouldSeekToStart: false)
    }

    /// Plays the video at the specified index.
    /// - Parameter index: The index of the video to play.
    func playVideo(atIndex index: Int) {
        guard let videoCell = getVideoCell(at: index) else { return }
        videoCell.setNeedsLayout()
        videoCell.playVideo()
    }

    /// Retrieves the VideoNode cell at the specified index.
    /// - Parameter index: The index of the cell to retrieve.
    /// - Returns: An optional VideoNode instance if found.
    private func getVideoCell(at index: Int) -> VideoNode? {
        let indexPath = IndexPath(row: index, section: 0)
        return self.collectionNode.nodeForItem(at: indexPath) as? VideoNode
    }
}
