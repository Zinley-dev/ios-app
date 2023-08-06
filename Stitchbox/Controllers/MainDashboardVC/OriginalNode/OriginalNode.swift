//
//  OriginalNode.swift
//  Stitchbox
//
//  Created by Khoi Nguyen on 7/6/23.
//

import Foundation


import Foundation
import UIKit
import AsyncDisplayKit
import Alamofire
import SendBirdSDK
import AVFoundation
import AVKit
import MarqueeLabel


fileprivate let FontSize: CGFloat = 13
fileprivate let OrganizerImageSize: CGFloat = 30
fileprivate let HorizontalBuffer: CGFloat = 10

class OriginalNode: ASCellNode, UICollectionViewDelegateFlowLayout, UIAdaptivePresentationControllerDelegate {
    
    
    deinit {
        print("OriginalNode is being deallocated.")
    }

    var hasStitchChecked = false
    var page = 1
    var posts = [PostModel]()
    var saveMin = CGSize(width: 0, height: 0)
    var saveMax = CGSize(width: 0, height: 0)
    var animatedLabel: MarqueeLabel!
    var selectPostCollectionView: SelectPostCollectionView!
    var lastContentOffset: CGFloat = 0
    var mainCollectionNode: ASCollectionNode
    var galleryCollectionNode: ASCollectionNode

    var post: PostModel!
    var currentIndex: Int?
    var isVideoPlaying = false
    var newPlayingIndex: Int?
    
    var isfirstLoad = true
    var imageIndex: Int?
    var hasStitchTo = false
    var isFirst = false
    var stitchDone = false
   
    
    init(with post: PostModel) {
        self.post = post
        
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.minimumLineSpacing = 0.0
        flowLayout.scrollDirection = .horizontal
        mainCollectionNode = ASCollectionNode(collectionViewLayout: flowLayout)
        
        
        let flowLayout1 = UICollectionViewFlowLayout()
        flowLayout1.scrollDirection = .horizontal
        flowLayout1.minimumLineSpacing = 12
        flowLayout1.minimumInteritemSpacing = 12
        galleryCollectionNode = ASCollectionNode(collectionViewLayout: flowLayout1)
        

        super.init()
        
        if !posts.contains(post) {
            posts.append(post)
        }
        

        Dispatch.main.async { [weak self] in
            guard let self = self else { return }
    
            self.mainCollectionNode.backgroundColor = .black
            self.mainCollectionNode.automaticallyRelayoutOnLayoutMarginsChanges = false
            self.mainCollectionNode.leadingScreensForBatching = 2.0
            self.mainCollectionNode.view.contentInsetAdjustmentBehavior = .never
            self.applyStyle()
            self.backgroundColor = .black
            self.mainCollectionNode.view.indicatorStyle = .white
            self.addSubCollection()
            
            self.getStitchTo() {
                
                self.mainCollectionNode.delegate = self
                self.mainCollectionNode.dataSource = self
                
                self.galleryCollectionNode.delegate = self
                self.galleryCollectionNode.dataSource = self
                
                self.stitchDone = true
                
                self.currentIndex = 0
                self.newPlayingIndex = 0
                self.isVideoPlaying = true
                
                if self.isFirst {
                    self.playVideo(index: 0)
                }
                
            }

        }
        
        automaticallyManagesSubnodes = true
        
    }
    
    override func didLoad() {
        super.didLoad()
        
        addAnimatedLabelToTop()
        
    }
    
    
    func addSubCollection() {
        
        self.selectPostCollectionView = SelectPostCollectionView()
        self.selectPostCollectionView.translatesAutoresizingMaskIntoConstraints = false
        
        self.view.addSubview(self.selectPostCollectionView)
        self.selectPostCollectionView.isHidden = true
        let height =  UIScreen.main.bounds.height * 1 / 4
        
        NSLayoutConstraint.activate([
            self.selectPostCollectionView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0),
            self.selectPostCollectionView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 0),
            self.selectPostCollectionView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -8),
            self.selectPostCollectionView.heightAnchor.constraint(equalToConstant: height)
        ])
        
        
        selectPostCollectionView.galleryView.addSubview(galleryCollectionNode.view)
        galleryCollectionNode.view.translatesAutoresizingMaskIntoConstraints = false
        galleryCollectionNode.view.topAnchor.constraint(equalTo: selectPostCollectionView.galleryView.topAnchor, constant: 0).isActive = true
        galleryCollectionNode.view.leadingAnchor.constraint(equalTo: selectPostCollectionView.galleryView.leadingAnchor, constant: 0).isActive = true
        galleryCollectionNode.view.trailingAnchor.constraint(equalTo: selectPostCollectionView.galleryView.trailingAnchor, constant: 0).isActive = true
        galleryCollectionNode.view.bottomAnchor.constraint(equalTo: selectPostCollectionView.galleryView.bottomAnchor, constant: 0).isActive = true
        
        
        galleryCollectionNode.view.isPagingEnabled = false
        galleryCollectionNode.view.backgroundColor = UIColor.clear
        galleryCollectionNode.view.showsVerticalScrollIndicator = false
        galleryCollectionNode.view.allowsSelection = true
        galleryCollectionNode.allowsMultipleSelection = false
        galleryCollectionNode.view.contentInsetAdjustmentBehavior = .never
        galleryCollectionNode.needsDisplayOnBoundsChange = true
       
        galleryCollectionNode.allowsMultipleSelection = false
        
        let hideTap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(OriginalNode.hideTapped))
        hideTap.numberOfTapsRequired = 1
        self.selectPostCollectionView.hideBtn.addGestureRecognizer(hideTap)

    }

    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let insets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        
        return ASInsetLayoutSpec(insets: insets, child: mainCollectionNode)
    }
    
    @objc func hideTapped() {
        hideBtnPressed()
    }
    
    func hideBtnPressed() {
        if let cell = self.mainCollectionNode.nodeForItem(at: IndexPath(row: currentIndex!, section: 0)) as? ReelNode {

            if selectPostCollectionView.isHidden == false {

                cell.headerNode.isHidden = false
                cell.contentNode.isHidden = false
                cell.buttonNode.isHidden = false
                self.selectPostCollectionView.isHidden = true
                cell.sideButtonsView.isHidden = false
                

            }
        }
    }



}

extension OriginalNode {
    
    func applyStyle() {
        
        self.mainCollectionNode.view.isPagingEnabled = true
        self.mainCollectionNode.view.backgroundColor = UIColor.black
        self.mainCollectionNode.view.showsVerticalScrollIndicator = false
        self.mainCollectionNode.view.allowsSelection = false
        self.mainCollectionNode.view.contentInsetAdjustmentBehavior = .never
        self.mainCollectionNode.needsDisplayOnBoundsChange = true
        
    }

}


extension OriginalNode: ASCollectionDelegate, ASCollectionDataSource {
    
    
    func numberOfSections(in collectionNode: ASCollectionNode) -> Int {
        return 1
    }
    
    
    func collectionNode(_ collectionNode: ASCollectionNode, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }
  
    func collectionNode(_ collectionNode: ASCollectionNode, nodeBlockForItemAt indexPath: IndexPath) -> ASCellNodeBlock {
        let post = posts[indexPath.row]

        if collectionNode == galleryCollectionNode {
            
            return {
                let node = StitchControlNode(with: post)
                node.neverShowPlaceholders = true
                node.debugName = "Node \(indexPath.row)"
                
                //
                return node
            }
            
        } else {
            
            return { [weak self] in
                guard let self = self else {
                    // Return an empty node if self or post is nil
                    return ASCellNode()
                }

                let node = ReelNode(with: post)

                node.neverShowPlaceholders = true
                node.debugName = "Node \(indexPath.row)"
                
                node.viewStitchBtn = { [weak self] node in
                    self?.viewStitchedPost(node: node as! ReelNode)
                }

                node.soundBtn = { [weak self] node in
                    self?.soundProcess(node: node as! ReelNode)
                }
                
                node.settingBtn = { [weak self] node in
                    self?.settingPost(item: post)
                }
                
                node.automaticallyManagesSubnodes = true

                return node
            }
            
        }
        
        
    }

    
}

extension OriginalNode {
    
    func settingPost(item: PostModel) {
        
        if let vc = UIViewController.currentViewController() {
            
            global_presetingRate = Double(0.30)
            global_cornerRadius = 45
            
            if item.owner?.id == _AppCoreData.userDataSource.value?.userID {
                
                let postSettingVC = PostSettingVC()
                postSettingVC.modalPresentationStyle = .custom
                postSettingVC.transitioningDelegate = vc.self
                
                if vc is FeedViewController {
                    
                    if let update1 = vc as? FeedViewController {
                        update1.editeddPost = item
                            
                        global_presetingRate = Double(0.35)
                        global_cornerRadius = 45
                        update1.editeddPost = item
                        vc.present(postSettingVC, animated: true, completion: nil)
                        
                    }
                    
                } else {
                    
                    if let update1 = vc as? SelectedPostVC {
                        update1.editeddPost = item
                            
                        global_presetingRate = Double(0.35)
                        global_cornerRadius = 45
                        update1.editeddPost = item
                        vc.present(postSettingVC, animated: true, completion: nil)
                        
                    }
                    
                    
                    
                }
                
            } else {
                
                let newsFeedSettingVC = NewsFeedSettingVC()
                newsFeedSettingVC.modalPresentationStyle = .custom
                newsFeedSettingVC.transitioningDelegate = vc.self
                
                if vc is FeedViewController {
                    
                    if let update1 = vc as? FeedViewController {
                        update1.editeddPost = item
                        if update1.editeddPost?.owner?.id == _AppCoreData.userDataSource.value?.userID {
                            newsFeedSettingVC.isOwner = true
                        } else {
                            newsFeedSettingVC.isOwner = false
                        }
                        
                      
                        vc.present(newsFeedSettingVC, animated: true, completion: nil)
                        
                    }
                    
                } else {
                    
                    if let update1 = vc as? SelectedPostVC {
                        update1.editeddPost = item
                        if update1.editeddPost?.owner?.id == _AppCoreData.userDataSource.value?.userID {
                            newsFeedSettingVC.isOwner = true
                        } else {
                            newsFeedSettingVC.isOwner = false
                        }
                        
                        vc.present(newsFeedSettingVC, animated: true, completion: nil)
                        
                    }
                    
                    
                    
                }
                
            }

            
        }
        
        
    } 
    
}

extension OriginalNode  {
    
    func collectionNode(_ collectionNode: ASCollectionNode, constrainedSizeForItemAt indexPath: IndexPath) -> ASSizeRange {
        
        
        if collectionNode == galleryCollectionNode {
            
            let height =  UIScreen.main.bounds.height * 1 / 4 - 70
            let width = height * 9 / 13.5
            
            let min = CGSize(width: width, height: height)
            let max = CGSize(width: width, height: height)
            
            return ASSizeRangeMake(min, max)
            
        } else {
            
            let min = CGSize(width: self.mainCollectionNode.layer.frame.width, height: 50);
            let max = CGSize(width: self.mainCollectionNode.layer.frame.width, height: mainCollectionNode.frame.height);
           
            if collectionNode.frame.width != 0.0 {
                saveMin = min
            }
            
            if collectionNode.frame.height != 0.0 {
                saveMax = max
            }
            
           
            if collectionNode.frame.width != 0.0, collectionNode.frame.height != 0.0 {
                return ASSizeRangeMake(min, max)
            } else {
                return ASSizeRangeMake(saveMin, saveMax)
            }
            
        }
        
        
        
        
    }
    
    func shouldBatchFetch(for collectionNode: ASCollectionNode) -> Bool {
        
        if collectionNode == galleryCollectionNode {
            return false
        }
        
        return true
    }

    
}



extension OriginalNode {
    
    func getStitchTo(completed: @escaping DownloadComplete) {
        APIManager.shared.getStitchTo(pid: post.id) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let apiResponse):
                guard let data = apiResponse.body?["data"] as? [String: Any] else {
                    
                    completed()
                    return
                    
                }

                if !data.isEmpty {
                    if let posted = PostModel(JSON: data) {
                        posted.stitchedTo = true
                        self.posts.append(posted)
                        self.hasStitchTo = true
                       
                        completed()
                        
                      
                    }
                } else {
                    completed()
                }

            case .failure(let error):
                
                completed()
                print("StitchTo: error \(error)")
                
            }
        }
    }

    
    func checkStitched() {
        if !hasStitchChecked {
            hasStitchChecked = true
        }
    }

    func retrieveNextPageWithCompletion(block: @escaping ([[String: Any]]) -> Void) {
        
        APIManager.shared.getSuggestStitch(rootId: post.id, page: page) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let apiResponse):
                print(apiResponse)
                self.checkStitched()
                guard let data = apiResponse.body?["data"] as? [[String: Any]] else {
                    let item = [[String: Any]]()
                    DispatchQueue.main.async {
                        block(item)
                    }
                    return
                }
                if !data.isEmpty {
                    print("Successfully retrieved \(data.count) posts.")
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
                self.checkStitched()
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
                if !posts.contains(item) {
                    posts.append(item)
                    items.append(item)
                }
            }
        }

        // Construct index paths for the new rows
        if items.count > 0 {
            let startIndex = posts.count - items.count
            let endIndex = startIndex + items.count - 1
            print(startIndex, endIndex)
            let indexPaths = (startIndex...endIndex).map { IndexPath(row: $0, section: 0) }

            // Insert new items at index paths
            self.mainCollectionNode.insertItems(at: indexPaths)
            //self.selectPostCollectionView.collectionView.insertItems(at: indexPaths)
        }
    }

    
}

extension OriginalNode {
    
    func collectionNode(_ collectionNode: ASCollectionNode, willBeginBatchFetchWith context: ASBatchContext) {
        
        retrieveNextPageWithCompletion { [weak self] (newPosts) in
            guard let self = self else { return }
            
            if let vc = UIViewController.currentViewController() {
                
                if vc is FeedViewController || vc is SelectedPostVC {
                    self.insertNewRowsInCollectionNode(newPosts: newPosts)
                    context.completeBatchFetching(true)
                    //self.cleanupPosts(collectionNode: collectionNode)
                } else {
                    context.completeBatchFetching(true)
                }
                
            } else {
                context.completeBatchFetching(true)
            }
           
        }
    }

   
    func addAnimatedLabelToTop() {
        animatedLabel = MarqueeLabel(frame: CGRect.zero, rate: 30.0, fadeLength: 10.0)
        animatedLabel.translatesAutoresizingMaskIntoConstraints = false
        animatedLabel.backgroundColor = UIColor.clear
        animatedLabel.type = .continuous
        animatedLabel.leadingBuffer = 15.0
        animatedLabel.trailingBuffer = 10.0
        animatedLabel.animationDelay = 0.0
        animatedLabel.textAlignment = .center
        animatedLabel.font = FontManager.shared.roboto(.Bold, size: 16)
        animatedLabel.textColor = UIColor.white
        animatedLabel.layer.masksToBounds = true
        animatedLabel.layer.cornerRadius = 10 // Round the corners for a cleaner look

        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(container)
        container.addSubview(animatedLabel)
        
        NSLayoutConstraint.activate([
            container.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 100),
            container.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -100),
            container.topAnchor.constraint(equalTo: self.view.topAnchor),
            container.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 55),
            animatedLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 10), // Add padding around the text
            animatedLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -10), // Add padding around the text
            animatedLabel.topAnchor.constraint(equalTo: container.topAnchor, constant: 10), // Add padding around the text
            animatedLabel.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -10) // Add padding around the text
        ])
        
        // Make the label tappable
        container.isUserInteractionEnabled = true
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(OriginalNode.labelTapped))
        tap.numberOfTapsRequired = 1
        container.addGestureRecognizer(tap)
        
    }


    func applyAnimationText(text: String) {
        animatedLabel.text = text + "                   "
        animatedLabel.restartLabel()
    }

    @objc func labelTapped() {
        if currentIndex != nil, currentIndex! + 1 < posts.count {
            
            let indexPath = IndexPath(item: currentIndex! + 1, section: 0)
            mainCollectionNode.scrollToItem(at: indexPath, at: .centeredVertically, animated: true)
            
        }
    }
    
}

extension OriginalNode {
    
    
    func soundProcess(node: ReelNode) {
        
        if selectPostCollectionView.isHidden == false {
            
            hideBtnPressed()
            
        } else {
            node.soundProcess()
        }

        
    }
    
    
    func viewStitchedPost(node: ReelNode) {
        
         
        if node.headerNode.isHidden == false {
            node.headerNode.isHidden = true
            node.contentNode.isHidden = true
            node.sideButtonsView.isHidden = true
            node.buttonNode.isHidden = true
            self.selectPostCollectionView.isHidden = false
          
            
        }

    }
    
    func pauseVideo(index: Int) {
        
        
        if let cell = self.mainCollectionNode.nodeForItem(at: IndexPath(row: index, section: 0)) as? ReelNode {
            
            // Seek to the beginning of the video
            cell.videoNode.player?.seek(to: CMTime(seconds: 0, preferredTimescale: 1))
             
            // Pause the video
            cell.videoNode.pause()
            
        }
        
    }

    
    
    func seekVideo(index: Int, time: CMTime) {
        
        if let cell = self.mainCollectionNode.nodeForItem(at: IndexPath(row: index, section: 0)) as? ReelNode {
            
            cell.videoNode.player?.seek(to: time)
            
        }
        
    }
    
    
    func updateCellAppearance(_ cell: StitchControlNode, isSelected: Bool) {
        cell.layer.cornerRadius = 10
        cell.layer.borderWidth = isSelected ? 2 : 0
        cell.layer.borderColor = isSelected ? UIColor.secondary.cgColor : UIColor.clear.cgColor
        cell.isSelected = isSelected
    }

    func playVideo(index: Int) {
        
        
        guard let cell = self.mainCollectionNode.nodeForItem(at: IndexPath(row: index, section: 0)) as? ReelNode, !cell.videoNode.isPlaying() else {
            return
        }
        
        // Cell selection/deselection logic
        let indexPath = IndexPath(row: index, section: 0)
        if let imgCell = galleryCollectionNode.nodeForItem(at: indexPath) as? StitchControlNode {
            updateCellAppearance(imgCell, isSelected: true)
            galleryCollectionNode.selectItem(at: indexPath, animated: false, scrollPosition: [])
            galleryCollectionNode.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)

            // Deselect all other cells
            for i in 0..<galleryCollectionNode.numberOfItems(inSection: 0) {
                if i != index, let otherCell = galleryCollectionNode.nodeForItem(at: IndexPath(row: i, section: 0)) as? StitchControlNode {
                    updateCellAppearance(otherCell, isSelected: false)
                }
            }
        } else {
            print("Couldn't cast ?")
        }

        
        if hasStitchChecked {
            
            self.handleAnimationTextAndImage(for: index, cell: cell)
            
            if let sideButtonsView = cell.sideButtonsView {
                sideButtonsView.stitchCount.text = "\(index + 1)/\(posts.count)"
            }
            
        } else {
            
            delay(0.75) { [weak self] in
                guard let self = self else { return }
                self.handleAnimationTextAndImage(for: index, cell: cell)
                
                if let sideButtonsView = cell.sideButtonsView {
                    sideButtonsView.stitchCount.text = "\(index + 1)/\(posts.count)"
                }
            }
            
        }

        
        if index == 0 {
            delay(0.75) { [weak self] in
                guard let self = self else { return }
                self.processStichGuideline()
            }
        } else {
            processStichGuideline()
        }

        let isHidden = !selectPostCollectionView.isHidden
        cell.headerNode.isHidden = isHidden
        cell.contentNode.isHidden = isHidden
        cell.sideButtonsView?.isHidden = isHidden
        cell.buttonNode.isHidden = isHidden

    
        cell.videoNode.muted = shouldMute ?? !globalIsSound
       
        if !cell.videoNode.isPlaying() {
            cell.videoNode.play()
        }
        
      
    }

    
    func handleAnimationTextAndImage(for index: Int, cell: ReelNode) {
        let nextIndex = index + 1
        let postCount = self.posts.count
        
        if nextIndex < postCount {
            let item = self.posts[nextIndex]
            if let nextUsername = item.owner?.username {
                
                if item.stitchedTo {
                    self.applyAnimationText(text: "Up next: @\(nextUsername)'s original!")
                } else {
                    self.applyAnimationText(text: "Up next: @\(nextUsername)'s stitch!")
                }
               
            }
        } else {
            self.applyAnimationText(text: "")
        }
        
        if cell.sideButtonsView != nil {
            if postCount > 1 {
                cell.sideButtonsView.statusImg.isHidden = false
                if posts[index].stitchedTo {
                    cell.sideButtonsView.statusImg.image = UIImage.init(named: "star white")
                } else {
                    cell.sideButtonsView.statusImg.image = UIImage.init(named: index == 0 ? "star white" : "partner white")
                }
            } else {
                cell.sideButtonsView.statusImg.isHidden = true
            }
        } else {
            
            delay(0.75) { [weak self] in
                guard let self = self else { return }
                if cell.sideButtonsView != nil {
                    if postCount > 1 {
                        cell.sideButtonsView.statusImg.isHidden = false
                        if self.posts[index].stitchedTo {
                            cell.sideButtonsView.statusImg.image = UIImage.init(named: "star white")
                        } else {
                            cell.sideButtonsView.statusImg.image = UIImage.init(named: index == 0 ? "star white" : "partner white")
                        }
                    } else {
                        cell.sideButtonsView.statusImg.isHidden = true
                    }
                }
            }
            
        }
        
        
    }

    
}



extension OriginalNode {
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    
        let item = posts[indexPath.row]

        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ImageViewCell.reuseIdentifier, for: indexPath) as? ImageViewCell else {
            // Make sure you have registered the cell with reuseIdentifier
            fatalError("ImageViewCell is not registered or identifier is wrong")
        }
        if indexPath.row != currentIndex {
            //cell.reset()
        }
        
        collectionView.deselectItem(at: indexPath, animated: false)
        cell.configureWithUrl(with: item)

        if let username = item.owner?.username {
            cell.infoLabel.text = "@\(username)"
            cell.infoLabel.font = FontManager.shared.roboto(.Bold, size: 11)

        } else {
            cell.infoLabel.text = ""
        }
        
        return cell
        
    }

    
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }
    
    
    func collectionNode(_ collectionNode: ASCollectionNode, didSelectItemAt indexPath: IndexPath) {
        
        if collectionNode == galleryCollectionNode {
            
            if let currentIndex = currentIndex, abs(currentIndex - indexPath.row) > 1 {
                var prev = IndexPath(item: currentIndex, section: 0)
                
                // If the user is moving forward
                if indexPath.row > currentIndex {
                    prev = IndexPath(item: indexPath.row - 1, section: 0)
                }
                
                // If the user is moving backward
                if indexPath.row < currentIndex {
                    prev = IndexPath(item: indexPath.row + 1, section: 0)
                }
                
                mainCollectionNode.scrollToItem(at: prev, at: .centeredVertically, animated: false)
                mainCollectionNode.scrollToItem(at: indexPath, at: .centeredVertically, animated: true)
                print("scroll: scroll1")
            } else {
                mainCollectionNode.scrollToItem(at: indexPath, at: .centeredVertically, animated: true)
                print("scroll: scroll2")
            }
            
            
        }
        
        
    }

    
}


extension OriginalNode {
    
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if !posts.isEmpty, scrollView == mainCollectionNode.view, stitchDone {
            // Check if it's a horizontal scroll
            if lastContentOffset != scrollView.contentOffset.x {
                lastContentOffset = scrollView.contentOffset.x
            } else {
                return
            }
            
            // Get the visible rect of the collection view.
            let visibleRect = CGRect(origin: scrollView.contentOffset, size: scrollView.bounds.size)
            
            // Calculate the visible cells.
            let visibleCells = mainCollectionNode.visibleNodes.compactMap { $0 as? ReelNode }
            
            // Find the index of the visible video that is closest to the center of the screen.
            var minDistanceFromCenter = CGFloat.infinity
            
            var foundVisibleVideo = false
            
            for cell in visibleCells {
                    let cellRect = cell.view.convert(cell.bounds, to: mainCollectionNode.view)
                    let cellCenter = CGPoint(x: cellRect.midX, y: cellRect.midY)
                    let distanceFromCenter = abs(cellCenter.x - visibleRect.midX) // Use the x-coordinate for horizontal scroll
                    
                    // Only switch video if the distance from center is less than the min distance
                    // and also less than the threshold.
                    if distanceFromCenter < minDistanceFromCenter {
                        newPlayingIndex = cell.indexPath!.row
                        minDistanceFromCenter = distanceFromCenter
                    }
                }
            
            if newPlayingIndex != nil {
                
                if newPlayingIndex! < posts.count {
                    
                    if !posts[newPlayingIndex!].muxPlaybackId.isEmpty {
                        foundVisibleVideo = true
                        //playTimeBar.isHidden = false
                        imageIndex = nil
                    } else {
                        //playTimeBar.isHidden = true
                        imageIndex = newPlayingIndex
                    }
                    
                }
                
                
                
                if foundVisibleVideo {
                    // Start playing the new video if it's different from the current playing video.
                    if let newPlayingIndex = newPlayingIndex, currentIndex != newPlayingIndex {
                        // Pause the current video, if any.
                        if let currentIndex = currentIndex {
                            pauseVideo(index: currentIndex)
                        }
                        // Play the new video.
                        currentIndex = newPlayingIndex
                        playVideo(index: currentIndex!)
                        isVideoPlaying = true
                        
                        if let node = mainCollectionNode.nodeForItem(at: IndexPath(item: currentIndex!, section: 0)) as? ReelNode {
                            resetView(cell: node)
                        }
                    } else {
                        // Do nothing if the current index is the same as newPlayingIndex
                    }
                }
                
                // If the video is stuck, reset the buffer by seeking to the current playback time.
                if let currentIndex = currentIndex, let cell = mainCollectionNode.nodeForItem(at: IndexPath(row: currentIndex, section: 0)) as? ReelNode {
                    if let playerItem = cell.videoNode.currentItem, !playerItem.isPlaybackLikelyToKeepUp {
                        if let currentTime = cell.videoNode.currentItem?.currentTime() {
                            cell.videoNode.player?.seek(to: currentTime)
                        } else {
                            cell.videoNode.player?.seek(to: CMTime.zero)
                        }
                    }
                }
                
                // If there's no current playing video and no visible video, pause the last playing video, if any.
                if !isVideoPlaying && currentIndex != nil {
                    pauseVideo(index: currentIndex!)
                    currentIndex = nil
                }
            }
            
            }
            

    }

    func processStichGuideline() {
        
        let userDefaults = UserDefaults.standard
        if userDefaults.bool(forKey: "hasShowStitched") == false {
            
            if posts.count > 1, currentIndex == 0 {
                
                
                userDefaults.set(true, forKey: "hasShowStitched")
                userDefaults.synchronize() // This forces the app to update userDefaults
                
                
                // Scroll slightly to the next item.
                let nextOffset = mainCollectionNode.contentOffset.x + mainCollectionNode.frame.width * 0.2
                mainCollectionNode.setContentOffset(CGPoint(x: nextOffset, y: 0), animated: true)

                // Delay the scroll back by 1 second.
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) { [weak self] in
                    guard let self = self else { return }
                    // Scroll back to the original item.
                    let currentIndexPath = IndexPath(item: self.currentIndex!, section: 0)
                    self.mainCollectionNode.scrollToItem(at: currentIndexPath, at: .left, animated: true)
                }
                
            }
            
        }
        
        
    }
    
    func cleanup(view: UIView) {
        if let recognizers = view.gestureRecognizers {
            for recognizer in recognizers {
                view.removeGestureRecognizer(recognizer)
            }
        }
    }


}
