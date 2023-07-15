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

class OriginalNode: ASCellNode, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIAdaptivePresentationControllerDelegate {
    
    
    deinit {
        print("OriginalNode is being deallocated.")
    }

    var page = 1
    var posts = [PostModel]()
    
    var animatedLabel: MarqueeLabel!
    var selectPostCollectionView: SelectPostCollectionView!
    var lastContentOffset: CGFloat = 0
    var collectionNode: ASCollectionNode
    weak var post: PostModel!
    var currentIndex: Int?
    var isVideoPlaying = false
    var newPlayingIndex: Int?
    var imageTimerWorkItem: DispatchWorkItem?
    var isfirstLoad = true
    var imageIndex: Int?
    
    init(with post: PostModel) {
        self.post = post
        
        if !posts.contains(post) {
            posts.append(post)
        }

    
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.minimumLineSpacing = 0.0
        flowLayout.scrollDirection = .horizontal
        self.collectionNode = ASCollectionNode(collectionViewLayout: flowLayout)
        // Set the data source and delegate
       
        
        super.init()
       
      
        Dispatch.main.async { [weak self] in
            guard let self = self else { return }
            self.collectionNode.backgroundColor = .black
            self.collectionNode.automaticallyRelayoutOnLayoutMarginsChanges = false
            self.collectionNode.leadingScreensForBatching = 2.0
            self.collectionNode.view.contentInsetAdjustmentBehavior = .never
            self.applyStyle()
            self.backgroundColor = .black
            self.collectionNode.view.indicatorStyle = .white
            
            self.addAnimatedLabelToTop()
        }
        
        self.automaticallyManagesSubnodes = true
        self.collectionNode.delegate = self
        self.collectionNode.dataSource = self
        addSubCollection()
        self.getStitchTo()
        

    }
    
    func addSubCollection() {
        DispatchQueue.main.async() { [weak self] in
            guard let self = self else { return }
            self.selectPostCollectionView = SelectPostCollectionView()
            self.selectPostCollectionView.translatesAutoresizingMaskIntoConstraints = false
            
            // Set collectionView layout scroll direction to horizontal
            if let layout = self.selectPostCollectionView.collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
                layout.scrollDirection = .horizontal
                layout.minimumLineSpacing = 12
                layout.minimumInteritemSpacing = 12
            }
            
            self.view.addSubview(self.selectPostCollectionView)
            self.selectPostCollectionView.isHidden = true
            self.selectPostCollectionView.collectionView.delegate = self
            self.selectPostCollectionView.collectionView.dataSource = self
            
            self.selectPostCollectionView.collectionView.register(ImageViewCell.self, forCellWithReuseIdentifier: ImageViewCell.reuseIdentifier)
            
            NSLayoutConstraint.activate([
                self.selectPostCollectionView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0),
                self.selectPostCollectionView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 0),
                self.selectPostCollectionView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -8),
                self.selectPostCollectionView.heightAnchor.constraint(equalToConstant: 280)
            ])
            
            self.selectPostCollectionView.collectionView.allowsMultipleSelection = false

            let hideTap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(OriginalNode.hideTapped))
            hideTap.numberOfTapsRequired = 1
            self.selectPostCollectionView.hideBtn.addGestureRecognizer(hideTap)
        }
    }

    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let insets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        
        return ASInsetLayoutSpec(insets: insets, child: collectionNode)
    }
    
    @objc func hideTapped() {
        hideBtnPressed()
    }
    
    func hideBtnPressed() {
        if let cell = self.collectionNode.nodeForItem(at: IndexPath(row: currentIndex!, section: 0)) as? ReelNode {

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
        
        self.collectionNode.view.isPagingEnabled = true
        self.collectionNode.view.backgroundColor = UIColor.black
        self.collectionNode.view.showsVerticalScrollIndicator = false
        self.collectionNode.view.allowsSelection = false
        self.collectionNode.view.contentInsetAdjustmentBehavior = .never
        self.collectionNode.needsDisplayOnBoundsChange = true
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == self.selectPostCollectionView.collectionView {
            let numberOfItemsInRow: CGFloat = 3
            let spacing: CGFloat = 5
            let width = (UIScreen.main.bounds.width - (numberOfItemsInRow + 1) * spacing) / numberOfItemsInRow
            let height = width * 13.5 / 9  // This will give you an aspect ratio of 9:16
            
           
            return CGSize(width: width, height: height)
        } else {
            return CGSize(width: 0, height: 0)
        }
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

            return node
        }
    }

    
}

extension OriginalNode {
    
    func settingPost(item: PostModel) {
        
        if let vc = UIViewController.currentViewController() {
            
            global_presetingRate = Double(0.35)
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
        let min = CGSize(width: self.collectionNode.layer.frame.width, height: 50);
        let max = CGSize(width: self.collectionNode.layer.frame.width, height: collectionNode.frame.height);
        
        return ASSizeRangeMake(min, max);
    }
    
    func shouldBatchFetch(for collectionNode: ASCollectionNode) -> Bool {
        return true
    }

    
}



extension OriginalNode {
    
    func getStitchTo() {
        APIManager.shared.getStitchTo(pid: post.id) { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .success(let apiResponse):
              
                guard let data = apiResponse.body?["data"] as? [String: Any] else {
                    return
                }
                
                if !data.isEmpty {
                    
                    print(data)
                    
                    if let post = PostModel(JSON: data) {
                        
                        print(post.id, post.content)
                        
                    }
                }
                
                
                /*
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    self.posts.insert(originalPost, at: 0)
                    self.collectionNode.insertItems(at: [IndexPath(item: 0, section: 0)])
                    self.selectPostCollectionView.collectionView.reloadData()
                }*/

            case .failure(let error):
                DispatchQueue.main.async {
                    print("StitchTo: error \(error)")
                    

                }

            }
        }
    }

    func retrieveNextPageWithCompletion(block: @escaping ([[String: Any]]) -> Void) {
        
        APIManager.shared.getStitchPost(rootId: post.id, page: page) {  result in
            
            switch result {
            case .success(let apiResponse):
                print(apiResponse)
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
            self.collectionNode.insertItems(at: indexPaths)
            self.selectPostCollectionView.collectionView.insertItems(at: indexPaths)
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

    func cleanupPosts(collectionNode: ASCollectionNode) {

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
        animatedLabel.font = UIFont.boldSystemFont(ofSize: 16) // Use a bold font for emphasis
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
            collectionNode.scrollToItem(at: indexPath, at: .centeredVertically, animated: true)
            
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
        
        if let cell = self.collectionNode.nodeForItem(at: IndexPath(row: index, section: 0)) as? ReelNode {
            
            // Seek to the beginning of the video
            cell.videoNode.player?.seek(to: CMTime(seconds: 0, preferredTimescale: 1))
             
            // Pause the video
            cell.videoNode.pause()
            
        }
        
    }

    
    
    func seekVideo(index: Int, time: CMTime) {
        
        if let cell = self.collectionNode.nodeForItem(at: IndexPath(row: index, section: 0)) as? ReelNode {
            
            cell.videoNode.player?.seek(to: time)
            
        }
        
    }
    
    
    func updateCellAppearance(_ cell: ImageViewCell, isSelected: Bool) {
        cell.layer.cornerRadius = 10
        cell.layer.borderWidth = isSelected ? 2 : 0
        cell.layer.borderColor = isSelected ? UIColor.secondary.cgColor : UIColor.clear.cgColor
        cell.isSelected = isSelected
    }

    func playVideo(index: Int) {
        guard let cell = self.collectionNode.nodeForItem(at: IndexPath(row: index, section: 0)) as? ReelNode, !cell.videoNode.isPlaying() else {
            return
        }

        // Cell selection/deselection logic
        let indexPath = IndexPath(row: index, section: 0)
        if let imgCell = selectPostCollectionView.collectionView.cellForItem(at: indexPath) as? ImageViewCell {
            updateCellAppearance(imgCell, isSelected: true)
            selectPostCollectionView.collectionView.selectItem(at: indexPath, animated: false, scrollPosition: [])
            self.selectPostCollectionView.collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)

            // Deselect all other cells
            for i in 0..<selectPostCollectionView.collectionView.numberOfItems(inSection: 0) {
                if i != index, let otherCell = selectPostCollectionView.collectionView.cellForItem(at: IndexPath(row: i, section: 0)) as? ImageViewCell {
                    updateCellAppearance(otherCell, isSelected: false)
                }
            }
        } else {
            print("Couldn't cast ?")
        }

        if index == 0 && self.posts.count <= 1 {
            delay(1) { [weak self] in
                guard let self = self else { return }
                self.handleAnimationTextAndImage(for: index, cell: cell)
            }
        } else {
            self.handleAnimationTextAndImage(for: index, cell: cell)
        }

        let isHidden = !selectPostCollectionView.isHidden
        cell.headerNode.isHidden = isHidden
        cell.contentNode.isHidden = isHidden
        cell.sideButtonsView?.isHidden = isHidden
        cell.buttonNode.isHidden = isHidden

        if let sideButtonsView = cell.sideButtonsView {
            sideButtonsView.stitchCount.text = "\(index + 1)"
        }

        cell.videoNode.muted = shouldMute ?? !globalIsSound
        cell.videoNode.play()
    }

    
    func handleAnimationTextAndImage(for index: Int, cell: ReelNode) {
        let nextIndex = index + 1
        let postCount = self.posts.count
        
        if nextIndex < postCount {
            let item = self.posts[nextIndex]
            if let nextUsername = item.owner?.username {
                self.applyAnimationText(text: "Up next: @\(nextUsername)'s stitch!")
            }
        } else {
            self.applyAnimationText(text: "")
        }
        
        if postCount > 1 {
            cell.sideButtonsView.statusImg.isHidden = false
            cell.sideButtonsView.statusImg.image = UIImage.init(named: index == 0 ? "star white" : "partner white")
        } else {
            cell.sideButtonsView.statusImg.isHidden = true
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

    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
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
            
            collectionNode.scrollToItem(at: prev, at: .centeredVertically, animated: false)
            collectionNode.scrollToItem(at: indexPath, at: .centeredVertically, animated: true)
            print("scroll: scroll1")
        } else {
            collectionNode.scrollToItem(at: indexPath, at: .centeredVertically, animated: true)
            print("scroll: scroll2")
        }
    }

    


    
}



extension OriginalNode {
    
    
    func collectionNode(_ collectionNode: ASCollectionNode, willDisplayItemWith node: ASCellNode) {
        
        if isfirstLoad {
            isfirstLoad = false
            let post = posts[0]
            if !post.muxPlaybackId.isEmpty {
                currentIndex = 0
                newPlayingIndex = 0
                isVideoPlaying = true
            }
            
        }
        
    }
    
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if !posts.isEmpty, scrollView == collectionNode.view {
            // Check if it's a horizontal scroll
            if lastContentOffset != scrollView.contentOffset.x {
                lastContentOffset = scrollView.contentOffset.x
            } else {
                return
            }
            
            // Get the visible rect of the collection view.
            let visibleRect = CGRect(origin: scrollView.contentOffset, size: scrollView.bounds.size)
            
            // Calculate the visible cells.
            let visibleCells = collectionNode.visibleNodes.compactMap { $0 as? ReelNode }
            
            // Find the index of the visible video that is closest to the center of the screen.
            var minDistanceFromCenter = CGFloat.infinity
            
            var foundVisibleVideo = false
            
            for cell in visibleCells {
                    let cellRect = cell.view.convert(cell.bounds, to: collectionNode.view)
                    let cellCenter = CGPoint(x: cellRect.midX, y: cellRect.midY)
                    let distanceFromCenter = abs(cellCenter.x - visibleRect.midX) // Use the x-coordinate for horizontal scroll
                    
                    // Only switch video if the distance from center is less than the min distance
                    // and also less than the threshold.
                    if distanceFromCenter < minDistanceFromCenter {
                        newPlayingIndex = cell.indexPath!.row
                        minDistanceFromCenter = distanceFromCenter
                    }
                }
            
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
                    
                    if let node = collectionNode.nodeForItem(at: IndexPath(item: currentIndex!, section: 0)) as? ReelNode {
                        resetView(cell: node)
                    }
                } else {
                    // Do nothing if the current index is the same as newPlayingIndex
                }
            } else {
                if let currentIndex = currentIndex {
                    pauseVideo(index: currentIndex)
                }
                
                imageTimerWorkItem?.cancel()
                imageTimerWorkItem = DispatchWorkItem { [weak self] in
                    guard let self = self else { return }
                    if self.imageIndex != nil {
                        if let node = self.collectionNode.nodeForItem(at: IndexPath(item: self.imageIndex!, section: 0)) as? ReelNode {
                            if self.imageIndex == self.newPlayingIndex {
                                resetView(cell: node)
                                node.endImage(id: node.post.id)
                            }
                        }
                    }
                }
                
                if let imageTimerWorkItem = imageTimerWorkItem {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: imageTimerWorkItem)
                }
                
                // Reset the current playing index.
                currentIndex = nil
            }
            
            // If the video is stuck, reset the buffer by seeking to the current playback time.
            if let currentIndex = currentIndex, let cell = collectionNode.nodeForItem(at: IndexPath(row: currentIndex, section: 0)) as? ReelNode {
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
