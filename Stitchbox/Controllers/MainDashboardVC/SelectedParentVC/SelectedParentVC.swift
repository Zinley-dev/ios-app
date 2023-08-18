//
//  SelectedParentVC.swift
//  Stitchbox
//
//  Created by Khoi Nguyen on 8/11/23.
//

import UIKit
import AsyncDisplayKit
import AlamofireImage
import Alamofire
import FLAnimatedImage
import ObjectMapper

class SelectedParentVC: UIViewController, UIScrollViewDelegate {
    
    
    enum loadingMode {
        case myPost
        case userPost
        case hashTags
        case search
        case save
        case trending
        case none
    }
    
    let backButton: UIButton = UIButton(type: .custom)
    
    var keyword = ""
    var userId = ""
    var hashtag = ""
    
    var scrollView: UIScrollView!
    private var containerView: UIView!
    let homeButton: UIButton = UIButton(type: .custom)
    let notiButton = UIButton(type: .custom)
    let searchButton = UIButton(type: .custom)
    
    var hasViewAppeared = false
    var selectedRootPostVC: SelectedRootPostVC!
    var stitchViewController: StitchViewController!
    
    var onPresent = false
    var isRoot = true
    var rootId = ""
   
    lazy var delayItem = workItem()
    var count = 0
    var posts = [PostModel]()
    var startIndex = 0
    var keepLoading = false
    var page = 0
    var selectedLoadingMode = loadingMode.none
    var completedLoading = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        setupButtons()
        
        //----------------------------//
        setupScrollView()
        addViewControllers()
        
        setupNavBar()
        
        if selectedRootPostVC != nil {
            
            if keepLoading {
                selectedRootPostVC.keepLoading = true
                selectedRootPostVC.page = page
                
                switch selectedLoadingMode {

                    case .hashTags:
                        selectedRootPostVC.selectedLoadingMode = .hashTags
                        selectedRootPostVC.hashtag = hashtag
                    case .myPost:
                        selectedRootPostVC.selectedLoadingMode = .myPost
                    case .userPost:
                        selectedRootPostVC.selectedLoadingMode = .userPost
                        selectedRootPostVC.userId = userId
                    case .search:
                        selectedRootPostVC.selectedLoadingMode = .search
                        selectedRootPostVC.keyword = keyword
                    case .save:
                        selectedRootPostVC.selectedLoadingMode = .save
                    case .trending:
                        selectedRootPostVC.selectedLoadingMode = .trending
                    case .none:
                        selectedRootPostVC.selectedLoadingMode = .none
                    
                }
                
            }
            
            selectedRootPostVC.setupCollectionNode()
            selectedRootPostVC.posts = posts
            selectedRootPostVC.startIndex = startIndex
            selectedRootPostVC.addAnimatedLabelToTop()
            selectedRootPostVC.loadPosts()
            selectedRootPostVC.hideLoading()
            completedLoading = true
            
            
            
        } else {
            
            print("Failed to init: selectedRootPostVC")
            
        }
        
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setupNavBar()
        hasViewAppeared = true
        setupObservation()
        if completedLoading {
            resumeVideo()
        }
       
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        hasViewAppeared = false
        removeObservations()
        
        if isRoot {
            if selectedRootPostVC.currentIndex != nil {
                selectedRootPostVC.pauseVideo(index: selectedRootPostVC.currentIndex!)
            }
        } else {
            if stitchViewController.currentIndex != nil {
                stitchViewController.pauseVideo(index: stitchViewController.currentIndex!)
            }
        }
        
        
    }
    
    func setupObservation()  {
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(SelectedParentVC.observeRootChange), name: (NSNotification.Name(rawValue: "observeRootChangeForSelected")), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(SelectedParentVC.copyProfile), name: (NSNotification.Name(rawValue: "copy_profile_selected")), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(SelectedParentVC.copyPost), name: (NSNotification.Name(rawValue: "copy_post_selected")), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(SelectedParentVC.reportPost), name: (NSNotification.Name(rawValue: "report_post_selected")), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(SelectedParentVC.removePost), name: (NSNotification.Name(rawValue: "remove_post_selected")), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(SelectedParentVC.sharePost), name: (NSNotification.Name(rawValue: "share_post_selected")), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(SelectedParentVC.createPostForStitch), name: (NSNotification.Name(rawValue: "create_new_for_stitch_selected")), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(SelectedParentVC.stitchToExistingPost), name: (NSNotification.Name(rawValue: "stitch_to_exist_one_selected")), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(SelectedParentVC.onClickDelete), name: (NSNotification.Name(rawValue: "delete_selected")), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(SelectedParentVC.onClickEdit), name: (NSNotification.Name(rawValue: "edit_selected")), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(SelectedParentVC.onClickDownload), name: (NSNotification.Name(rawValue: "download_selected")), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(SelectedParentVC.onClickStats), name: (NSNotification.Name(rawValue: "stats_selected")), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(SelectedParentVC.onClickShowInfo), name: (NSNotification.Name(rawValue: "showInfo_selected")), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(SelectedParentVC.onClickHideInfo), name: (NSNotification.Name(rawValue: "hideInfo_selected")), object: nil)
        

        
    }
    
    func removeObservations() {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "observeRootChangeForSelected"), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "copy_profile_selected"), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "copy_post_selected"), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "report_post_selected"), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "remove_post_selected"), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "share_post_selected"), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "create_new_for_stitch_selected"), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "stitch_to_exist_one_selected"), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "delete_selected"), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "edit_selected"), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "download_selected"), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "stats_selected"), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "showInfo_selected"), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "hideInfo_selected"), object: nil)
    }

    
    
    
    
    private func setupScrollView() {
        scrollView = UIScrollView()
        scrollView.delegate = self
        scrollView.isPagingEnabled = true
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        //scrollView.bounces = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.contentInsetAdjustmentBehavior = .never
        scrollView.backgroundColor = .clear
        view.addSubview(scrollView)

        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor,constant: 0)
        ])


        containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.backgroundColor = .blue
        scrollView.addSubview(containerView)

        NSLayoutConstraint.activate([
                   containerView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
                   containerView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
                   containerView.topAnchor.constraint(equalTo: scrollView.topAnchor),
                   
                   containerView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
                   containerView.heightAnchor.constraint(equalTo: scrollView.heightAnchor)
               ])
    }

    private func addViewControllers() {
        let storyboard = UIStoryboard(name: "Dashboard", bundle: nil)
        
        selectedRootPostVC = storyboard.instantiateViewController(withIdentifier: "SelectedRootPostVC") as? SelectedRootPostVC
        stitchViewController = storyboard.instantiateViewController(withIdentifier: "StitchViewController") as? StitchViewController

        add(childViewController: selectedRootPostVC, at: 0)
        add(childViewController: stitchViewController, at: 1)

        containerView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 2).isActive = true
        
        stitchViewController.selectedStitch = true
    }

    private func add(childViewController: UIViewController, at index: Int) {
        addChild(childViewController)
        let childView = childViewController.view!
        containerView.addSubview(childView)

        childView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            childView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: view.bounds.width * CGFloat(index)),
            childView.topAnchor.constraint(equalTo: containerView.topAnchor),
            childView.widthAnchor.constraint(equalTo: view.widthAnchor),
            childView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor) // Constraint to containerView's bottom
        ])

        childViewController.didMove(toParent: self)
    }
    
    
    func setupNavBar() {
        
        let navigationBarAppearance = UINavigationBarAppearance()
        navigationBarAppearance.configureWithDefaultBackground()
        navigationBarAppearance.backgroundColor = .clear
        navigationBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        navigationBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        navigationBarAppearance.backgroundImage = UIImage()
        navigationBarAppearance.shadowImage = UIImage()
        navigationBarAppearance.shadowColor = .clear
        navigationBarAppearance.backgroundEffect = nil

        self.navigationController?.navigationBar.standardAppearance = navigationBarAppearance
        self.navigationController?.navigationBar.compactAppearance = navigationBarAppearance
        self.navigationController?.navigationBar.scrollEdgeAppearance = navigationBarAppearance
        self.navigationController?.navigationBar.isTranslucent = true

        
        navigationController?.setNavigationBarHidden(false, animated: true)
        
    }


}


extension SelectedParentVC {
    
    func setupButtons() {
        
        setupBackButton()
        setupTitle()
        
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
        
        self.navigationItem.leftBarButtonItem = backButtonBarButton
        
        
        
    }
    
    func setupTitle() {
        
        self.navigationItem.title = ""
        
        
    }
    
    @objc func onClickBack(_ sender: AnyObject) {
        if let navigationController = self.navigationController {
        
            if onPresent {
                self.dismiss(animated: true)
            } else {
                navigationController.popViewController(animated: true)
            }
            
        }
    }
    
}


extension SelectedParentVC {
    
    func showErrorAlert(_ title: String, msg: String) {
        
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        
        
        present(alert, animated: true, completion: nil)
        
    }
    
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



extension SelectedParentVC {

    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let pageIndex = scrollView.contentOffset.x / view.frame.width
        
        switch pageIndex {
        case 0:
            print("FeedViewController is fully shown")
            showRoot()
            
            
        case 1:
            showStitch()
            
            
            
        default:
            print("Unknown page")
        }
    }
    
    func showRoot() {
        
        isRoot = true
        if stitchViewController.currentIndex != nil {
            stitchViewController.pauseVideo(index: stitchViewController.currentIndex!)
        } else {
            stitchViewController.currentIndex = 0
            stitchViewController.pauseVideo(index: 0)
        }
        
        if selectedRootPostVC.currentIndex != nil {
            selectedRootPostVC.playVideo(index: selectedRootPostVC.currentIndex!)
        } else {
            selectedRootPostVC.currentIndex = 0
            selectedRootPostVC.playVideo(index: 0)
        }
        
    }
    
    func showStitch() {
        
        isRoot = false
        if selectedRootPostVC.currentIndex != nil {
            selectedRootPostVC.pauseVideo(index: selectedRootPostVC.currentIndex!)
        } else {
            selectedRootPostVC.pauseVideo(index: 0)
        }
        
        
        if stitchViewController.currentIndex != nil, !stitchViewController.posts.isEmpty {
            stitchViewController.playVideo(index: stitchViewController.currentIndex!)
        }
        
    }


}


extension SelectedParentVC {
    
    @objc func observeRootChange() {
        
        var shouldReload = false
        
        if rootId == "" || rootId != mainRootId {
            rootId = mainRootId
            shouldReload = true
            print("observeRootChange - \(rootId)")
        } else {
            print("observeRootChange - \(rootId) - \(mainRootId)")
        }
        
        if shouldReload {
            
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.scrollView.isScrollEnabled = false
            }
            
            stitchViewController.rootId = rootId
            count += 1
            
            delayItem.perform(after: 1.05) { [weak self] in
                guard let self = self else { return }
                print("Loading stitches: \(self.count) - \(self.stitchViewController.rootId)")
                self.stitchViewController.clearAllData()
                
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    self.scrollView.isScrollEnabled = true
                }
            }
        }
    }
    
}


extension SelectedParentVC {
    

    @objc func onClickDelete(_ sender: AnyObject) {
        presentSwiftLoader()

        // Check which view controller's post we should delete
        let postToDelete: String? = isRoot ? selectedRootPostVC.editeddPost?.id : stitchViewController.editeddPost?.id

        if let id = postToDelete, !id.isEmpty {
            APIManager.shared.deleteMyPost(pid: id) { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success(_):
                    needReloadPost = true
                    Dispatch.main.async { [weak self] in
                        SwiftLoader.hide()
                        guard let self = self else { return }
                        if self.isRoot {
                            self.removePostOnRequest(from: self.selectedRootPostVC)
                        } else {
                            self.removePostOnRequest(from: self.stitchViewController)
                        }
                    }
                case .failure(let error):
                    print(error)
                    SwiftLoader.hide()
                    self.showErrorAfterDelay(message: "Unable to delete this post. \(error.localizedDescription), please try again.")
                }
            }
        } else {
            self.showErrorAfterDelay(message: "Unable to delete this post, please try again.")
        }
    }

    func removePostOnRequest(from controller: UIViewController) {
        if let vc = controller as? SelectedRootPostVC, let deletingPost = vc.editeddPost, let indexPath = vc.posts.firstIndex(of: deletingPost) {
            vc.posts.removeObject(deletingPost)
            manageCollectionView(in: vc, for: indexPath)
        } else if let vc = controller as? StitchViewController, let deletingPost = vc.editeddPost, let indexPath = vc.posts.firstIndex(of: deletingPost) {
            vc.posts.removeObject(deletingPost)
            manageCollectionView(in: vc, for: indexPath)
        }
    }
    
    @objc func removePost(_ sender: AnyObject) {
        
        
        if isRoot {
            
            if let deletingPost = selectedRootPostVC.editeddPost {
                
                if let indexPath = selectedRootPostVC.posts.firstIndex(of: deletingPost) {
                    
                    selectedRootPostVC.posts.removeObject(deletingPost)
                    // check if there are no more posts
                    if selectedRootPostVC.posts.isEmpty {
                        selectedRootPostVC.collectionNode.reloadData()
                    } else {
                        selectedRootPostVC.collectionNode.deleteItems(at: [IndexPath(item: indexPath, section: 0)])
                        
                    }
                }
            }
        } else {
            
            if let deletingPost = stitchViewController.editeddPost {
                
                if let indexPath = stitchViewController.posts.firstIndex(of: deletingPost) {
                    
                    stitchViewController.posts.removeObject(deletingPost)
                    
                    // check if there are no more posts
                    if stitchViewController.posts.isEmpty {
                        stitchViewController.collectionNode.reloadData()
                       
                    } else {
                        stitchViewController.collectionNode.deleteItems(at: [IndexPath(item: indexPath, section: 0)])
                        
                        
                    }
                }
            }
            
        }
         
       
    }

    func manageCollectionView(in controller: UIViewController, for indexPath: Int) {
        
        if let vc = controller as? FeedViewController {
            if vc.posts.isEmpty {
                vc.collectionNode.reloadData()
            } else {
                vc.collectionNode.deleteItems(at: [IndexPath(item: indexPath, section: 0)])
            }
        } else if let vc = controller as? StitchViewController {
            if vc.posts.isEmpty {
                vc.collectionNode.reloadData()
                
            } else {
                vc.collectionNode.deleteItems(at: [IndexPath(item: indexPath, section: 0)])
                
            }
        }
        
    }

    func showErrorAfterDelay(message: String) {
        delay(0.1) { [weak self] in
            guard let self = self else { return }
            SwiftLoader.hide()
            self.showErrorAlert("Oops!", msg: message)
        }
    }

    

    
    @objc func onClickEdit(_ sender: AnyObject) {
        guard let EPVC = UIStoryboard(name: "Dashboard", bundle: nil).instantiateViewController(withIdentifier: "EditPostVC") as? EditPostVC else {
            return
        }

        navigationController?.setNavigationBarHidden(false, animated: true)
        EPVC.selectedPost = isRoot ? selectedRootPostVC.editeddPost : stitchViewController.editeddPost
        navigationController?.pushViewController(EPVC, animated: true)
    }

    @objc func onClickShowInfo(_ sender: AnyObject) {
        
        if isRoot, let index = selectedRootPostVC.currentIndex, !selectedRootPostVC.posts.isEmpty {
            if let node = selectedRootPostVC.collectionNode.nodeForItem(at: IndexPath(row: index, section: 0)) as? VideoNode {
                node.showAllInfo()
            }
        } else if let index = stitchViewController.currentIndex, !stitchViewController.posts.isEmpty {
            if let node = stitchViewController.collectionNode.nodeForItem(at: IndexPath(row: index, section: 0)) as? VideoNode {
                node.showAllInfo()
            }
        }
    }
    
    
    @objc func onClickHideInfo(_ sender: AnyObject) {
        
        if isRoot, let index = selectedRootPostVC.currentIndex, !selectedRootPostVC.posts.isEmpty {
            if let node = selectedRootPostVC.collectionNode.nodeForItem(at: IndexPath(row: index, section: 0)) as? VideoNode {
                node.hideAllInfo()
            }
        } else if let index = stitchViewController.currentIndex, !stitchViewController.posts.isEmpty {
            if let node = stitchViewController.collectionNode.nodeForItem(at: IndexPath(row: index, section: 0)) as? VideoNode {
                node.hideAllInfo()
            }
        }
    }

    @objc func onClickStats(_ sender: AnyObject) {
        guard let VVC = UIStoryboard(name: "Dashboard", bundle: nil).instantiateViewController(withIdentifier: "ViewVC") as? ViewVC else {
            return
        }

        VVC.selected_item = isRoot ? selectedRootPostVC.editeddPost : stitchViewController.editeddPost

        delay(0.1) {
            self.navigationController?.setNavigationBarHidden(false, animated: true)
            self.navigationController?.pushViewController(VVC, animated: true)
        }
    }

    @objc func onClickDownload(_ sender: AnyObject) {
        let post = isRoot ? selectedRootPostVC.editeddPost : stitchViewController.editeddPost
        
        guard let selectedPost = post else { return }
        
        if selectedPost.muxPlaybackId != "" {
            let url = "https://stream.mux.com/\(selectedPost.muxPlaybackId)/high.mp4"
            downloadVideo(url: url, id: selectedPost.muxAssetId)
        }
    }

    
    func downloadVideo(url: String, id: String) {
        AF.request(url).downloadProgress { [weak self] progress in
            guard let self = self else { return }
            self.swiftLoader(progress: String(format: "%.2f", progress.fractionCompleted * 100) + "%")
        }.responseData { [weak self] response in
            guard let self = self else { return }
            switch response.result {
            case .success(let data):
                self.saveVideoWithData(data, id: id)
            case .failure(let error):
                print(error)
            }
        }
    }

    func saveVideoWithData(_ data: Data, id: String) {
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let videoURL = documentsURL.appendingPathComponent("\(id).mp4")
        do {
            try data.write(to: videoURL)
            self.addVideoToPhotoLibrary(url: videoURL)
        } catch {
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                SwiftLoader.hide()
                print("Something went wrong!")
                self.showErrorAlert("Oops!", msg: "Failed to save video.")
            }
        }
    }

    func addVideoToPhotoLibrary(url: URL) {
        PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: url)
        }) { saved, error in
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                SwiftLoader.hide()
                if let error = error {
                    print("Error: \(error.localizedDescription)")
                    self.showErrorAlert("Oops!", msg: error.localizedDescription)
                } else {
                    let alertController = UIAlertController(title: "Your video was successfully saved", message: nil, preferredStyle: .alert)
                    let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                    alertController.addAction(defaultAction)
                    self.present(alertController, animated: true, completion: nil)
                }
            }
        }
    }


    @objc func copyPost() {
        let postID = isRoot ? selectedRootPostVC.editeddPost?.id : stitchViewController.editeddPost?.id

        if let id = postID {
            let link = "https://stitchbox.net/app/post/?uid=\(id)"
            UIPasteboard.general.string = link
            showNote(text: "Post link is copied")
        } else {
            showNote(text: "Post link is unable to be copied")
        }
    }

    
    @objc func copyProfile() {
        let ownerID = isRoot ? selectedRootPostVC.editeddPost?.owner?.id : stitchViewController.editeddPost?.owner?.id

        if let id = ownerID {
            let link = "https://stitchbox.net/app/account/?uid=\(id)"
            UIPasteboard.general.string = link
            showNote(text: "User profile link is copied")
        } else {
            showNote(text: "User profile link is unable to be copied")
        }
    }

    
    
    
    @objc func reportPost() {
        let slideVC = reportView()
        slideVC.post_report = true
        slideVC.postId = isRoot ? selectedRootPostVC.editeddPost?.id ?? "" : stitchViewController.editeddPost?.id ?? ""
        slideVC.modalPresentationStyle = .custom
        slideVC.transitioningDelegate = self
        global_presetingRate = 0.75
        global_cornerRadius = 35
        
        delay(0.1) {[weak self] in
            guard let self = self else { return }
            self.present(slideVC, animated: true, completion: nil)
        }
    }

    
    @objc func sharePost() {
        
        guard let userDataSource = _AppCoreData.userDataSource.value,
              let userUID = userDataSource.userID,
              userUID != "" else {
            print("Sendbird: Can't get userUID")
            return
        }

        let postId = isRoot ? selectedRootPostVC.editeddPost?.id : stitchViewController.editeddPost?.id
        guard let id = postId else {
            print("Failed to get postId")
            return
        }

        let loadUsername = userDataSource.userName
        let items: [Any] = ["Hi I am \(loadUsername ?? "") from Stitchbox, let's check out this!", URL(string: "https://stitchbox.net/app/post/?uid=\(id)")!]
        let ac = UIActivityViewController(activityItems: items, applicationActivities: nil)

        ac.completionWithItemsHandler = { (activityType, completed:Bool, returnedItems:[Any]?, error: Error?) in
            // Completion logic here if needed
        }

        delay(0.1) {[weak self] in
            self?.present(ac, animated: true, completion: nil)
        }
    }

    @objc func createPostForStitch() {

        guard let PNVC = UIStoryboard(name: "Dashboard", bundle: nil).instantiateViewController(withIdentifier: "PostNavVC") as? PostNavVC else {
            return
        }

        PNVC.modalPresentationStyle = .fullScreen

        let postForStitch = isRoot ? selectedRootPostVC.editeddPost : stitchViewController.editeddPost

        if let rootvc = PNVC.viewControllers[0] as? PostVC {
            rootvc.stitchPost = postForStitch
        } else {
            printContent(PNVC.viewControllers[0])
        }

        delay(0.1) {
            self.present(PNVC, animated: true)
        }
    }

    
    
    @objc func stitchToExistingPost() {
        
        guard let ASTEVC = UIStoryboard(name: "Dashboard", bundle: nil).instantiateViewController(withIdentifier: "AddStitchToExistingVC") as? AddStitchToExistingVC else {
            return
        }

        ASTEVC.hidesBottomBarWhenPushed = true
        ASTEVC.stitchedPost = isRoot ? selectedRootPostVC.editeddPost : stitchViewController.editeddPost
        hideMiddleBtn(vc: self)

        delay(0.1) {
            self.navigationController?.pushViewController(ASTEVC, animated: true)
        }
    }

    
    func resumeVideo() {
        
        if isRoot {
            if selectedRootPostVC.currentIndex != nil {
                selectedRootPostVC.playVideo(index: selectedRootPostVC.currentIndex!)
            }
        } else {
            if stitchViewController.currentIndex != nil {
                stitchViewController.playVideo(index: stitchViewController.currentIndex!)
            }
        }
        
    }

    
}
