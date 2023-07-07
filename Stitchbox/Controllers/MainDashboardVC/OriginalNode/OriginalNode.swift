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


fileprivate let FontSize: CGFloat = 13
fileprivate let OrganizerImageSize: CGFloat = 30
fileprivate let HorizontalBuffer: CGFloat = 10

class OriginalNode: ASCellNode, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIAdaptivePresentationControllerDelegate {
    
    var lastContentOffset: CGFloat = 0
    var collectionNode: ASCollectionNode
    var post: PostModel
    var currentIndex: Int?
    var isVideoPlaying = false
    var newPlayingIndex: Int?
    var imageTimerWorkItem: DispatchWorkItem?
    var isfirstLoad = true
    var imageIndex: Int?
  
    init(with post: PostModel) {
        self.post = post
        post.stitchedPosts.append(post)
        
    
        
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.minimumLineSpacing = 0.0
        flowLayout.scrollDirection = .horizontal
        self.collectionNode = ASCollectionNode(collectionViewLayout: flowLayout)
        // Set the data source and delegate
       
        
        super.init()
       
      
        Dispatch.main.async {
            self.collectionNode.automaticallyRelayoutOnLayoutMarginsChanges = true
            self.collectionNode.leadingScreensForBatching = 2.0
            self.collectionNode.view.contentInsetAdjustmentBehavior = .never
            self.applyStyle()
            self.backgroundColor = .black
        }
        
        self.automaticallyManagesSubnodes = true
        self.collectionNode.delegate = self
        self.collectionNode.dataSource = self
    }
    
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let insets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        return ASInsetLayoutSpec(insets: insets, child: collectionNode)
    }

}

extension OriginalNode {
    
    
    
    func applyStyle() {
        
        self.collectionNode.view.isPagingEnabled = true
        self.collectionNode.view.backgroundColor = UIColor.clear
        self.collectionNode.view.showsVerticalScrollIndicator = false
        self.collectionNode.view.allowsSelection = false
        self.collectionNode.view.contentInsetAdjustmentBehavior = .never
        self.collectionNode.needsDisplayOnBoundsChange = true
        
    }
    
}


extension OriginalNode: ASCollectionDelegate, ASCollectionDataSource {
    
    
    func collectionNode(_ collectionNode: ASCollectionNode, numberOfItemsInSection section: Int) -> Int {
        return post.stitchedPosts.count
    }
  
    func collectionNode(_ collectionNode: ASCollectionNode, nodeBlockForItemAt indexPath: IndexPath) -> ASCellNodeBlock {
        let post = post.stitchedPosts[indexPath.row]
        
        return {
            let node = ReelNode(with: post)
            node.neverShowPlaceholders = true
            node.debugName = "Node \(indexPath.row)"
            
            
            node.settingBtn = { (node) in
                
                self.settingPost(item: post)
                
            }
            
            delay(0.3) {
                if node.hashtagView != nil {
                    node.setCollectionViewDataSourceDelegate(self, forRow: indexPath.row)
                }
            }
            
            
            return node
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
    
    
    func retrieveNextPageWithCompletion(block: @escaping ([[String: Any]]) -> Void) {
        
        APIManager.shared.getUserFeed { [weak self] result in
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
                if !self.post.stitchedPosts.contains(item) {
                    self.post.stitchedPosts.append(item)
                    items.append(item)
                }
            }
        }

        // Construct index paths for the new rows
        if items.count > 0 {
            let startIndex = self.post.stitchedPosts.count - items.count
            let endIndex = startIndex + items.count - 1
            print(startIndex, endIndex)
            let indexPaths = (startIndex...endIndex).map { IndexPath(row: $0, section: 0) }

            // Insert new items at index paths
            self.collectionNode.insertItems(at: indexPaths)
        }
    }

    
    
}

extension OriginalNode {
    
    func collectionNode(_ collectionNode: ASCollectionNode, willBeginBatchFetchWith context: ASBatchContext) {
        
        retrieveNextPageWithCompletion { [weak self] (newPosts) in
            guard let self = self else { return }
            self.insertNewRowsInCollectionNode(newPosts: newPosts)
            
            self.cleanupPosts(collectionNode: collectionNode)
            
            context.completeBatchFetching(true)
        }
    }

    private func cleanupPosts(collectionNode: ASCollectionNode) {
        let postThreshold = 55 // scale down from 100 to 55
        let postsToRemove = 27 // scale down from 50 to 27
        let startIndex = 8 // scale down from 15 to 8

        if self.post.stitchedPosts.count > postThreshold {
            // check if we have enough posts to remove
            if (startIndex + postsToRemove) <= self.post.stitchedPosts.count {
                // remove the posts from startIndex to startIndex + postsToRemove
                self.post.stitchedPosts.removeSubrange(startIndex..<(startIndex + postsToRemove))

                // generate the index paths for old posts
                let indexPathsToRemove = Array(startIndex..<(startIndex + postsToRemove)).map { IndexPath(row: $0, section: 0) }

                // delete the old posts from collectionNode
                collectionNode.performBatchUpdates({
                    collectionNode.deleteItems(at: indexPathsToRemove)
                }, completion: nil)
            }
        }
    }

    
}

extension OriginalNode {
    
    func settingPost(item: PostModel) {
        
        if let vc = UIViewController.currentViewController() {
            
            let newsFeedSettingVC = NewsFeedSettingVC()
            newsFeedSettingVC.modalPresentationStyle = .custom
            newsFeedSettingVC.transitioningDelegate = vc.self
            
            global_presetingRate = Double(0.35)
            global_cornerRadius = 45
            
            if vc is FeedViewController {
                
                if let update1 = vc as? FeedViewController {
                    
                    if update1.editeddPost?.owner?.id == _AppCoreData.userDataSource.value?.userID {
                        newsFeedSettingVC.isOwner = true
                    } else {
                        newsFeedSettingVC.isOwner = false
                    }
                    
                    update1.editeddPost = item
                    vc.present(newsFeedSettingVC, animated: true, completion: nil)
                    
                }
                
            } else {
                
                if let update1 = vc as? SelectedPostVC {
                    
                    if update1.editeddPost?.owner?.id == _AppCoreData.userDataSource.value?.userID {
                        newsFeedSettingVC.isOwner = true
                    } else {
                        newsFeedSettingVC.isOwner = false
                    }
                    
                    update1.editeddPost = item
                    vc.present(newsFeedSettingVC, animated: true, completion: nil)
                    
                }
                
                
                
            }
            
            
            
            
        }
        
        
    }
    
    @objc func copyPost() {
        
        if let vc = UIViewController.currentViewController() {
            
            if vc is FeedViewController {
                
                if let update1 = vc as? FeedViewController {
                    
                    if let id = update1.editeddPost?.id {
                        
                        let link = "https://stitchbox.gg/app/post/?uid=\(id)"
                        
                        UIPasteboard.general.string = link
                        showNote(text: "Post link is copied")
                        
                    } else {
                        showNote(text: "Post link is unable to be copied")
                    }
                    
                }
                
            } else {
                
                if let update1 = vc as? SelectedPostVC {
                    
                    if let id = update1.editeddPost?.id {
                        
                        let link = "https://stitchbox.gg/app/post/?uid=\(id)"
                        
                        UIPasteboard.general.string = link
                        showNote(text: "Post link is copied")
                        
                    } else {
                        showNote(text: "Post link is unable to be copied")
                    }
                    
                }
                
                
                
            }
            
            
            
        }
    
    }
    
    @objc func copyProfile() {
        
        if let vc = UIViewController.currentViewController() {
            
            if vc is FeedViewController {
                
                if let update1 = vc as? FeedViewController {
                    
                    if let id = update1.editeddPost?.owner?.id {
                        
                        let link = "https://stitchbox.gg/app/account/?uid=\(id)"
                        
                        UIPasteboard.general.string = link
                        showNote(text: "User profile link is copied")
                        
                    } else {
                        showNote(text: "User profile link is unable to be copied")
                    }
                    
                }
                
            } else {
                
                if let update1 = vc as? SelectedPostVC {
                    
                    if let id = update1.editeddPost?.owner?.id {
                        
                        let link = "https://stitchbox.gg/app/account/?uid=\(id)"
                        
                        UIPasteboard.general.string = link
                        showNote(text: "User profile link is copied")
                        
                    } else {
                        showNote(text: "User profile link is unable to be copied")
                    }
                    
                }
                
                
                
            }
            
            
            
        }
        
    }
    
    @objc func removePost() {
        

        
        
    }
    
    func reloadAllCurrentHashtag() {
        
        
        
        if let vc = UIViewController.currentViewController() {
            
            if vc is FeedViewController {
                
                if let update1 = vc as? FeedViewController {
                    
                    if !update1.posts.isEmpty {
                        for index in 0..<update1.posts.count {
                            let indexPath = IndexPath(item: index, section: 0) // Assuming there is only one section
                            if let node = collectionNode.nodeForItem(at: indexPath) as? ReelNode {
                                
                                if node.hashtagView != nil {
                                    node.setCollectionViewDataSourceDelegate(self, forRow: indexPath.row)
                                    node.hashtagView.collectionView.reloadData()
                                }
                                
                            }
                        }
                    }
                    
                }
                
            } else {
                
                if let update1 = vc as? SelectedPostVC {
                    
                    if !update1.posts.isEmpty {
                        for index in 0..<update1.posts.count {
                            let indexPath = IndexPath(item: index, section: 0) // Assuming there is only one section
                            if let node = collectionNode.nodeForItem(at: indexPath) as? ReelNode {
                                
                                if node.hashtagView != nil {
                                    node.setCollectionViewDataSourceDelegate(self, forRow: indexPath.row)
                                    node.hashtagView.collectionView.reloadData()
                                }
                                
                            }
                        }
                    }
                    
                }
                
                
                
            }
            
            
            
        }
        
        

    }
    
    @objc func reportPost() {
        
        if let vc = UIViewController.currentViewController() {
            
            if vc is FeedViewController {
                
                if let update1 = vc as? FeedViewController {
                    
                    
                    let slideVC =  reportView()
                    
                    slideVC.post_report = true
                    slideVC.postId = update1.editeddPost?.id ?? ""
                    slideVC.modalPresentationStyle = .custom
                    slideVC.transitioningDelegate = update1.self
                    global_presetingRate = Double(0.75)
                    global_cornerRadius = 35
                    
                    delay(0.1) {
                        update1.present(slideVC, animated: true, completion: nil)
                    }
                    
                }
                
            } else {
                
                if let update1 = vc as? SelectedPostVC {
                    
                    
                    let slideVC =  reportView()
                    
                    slideVC.post_report = true
                    slideVC.postId = update1.editeddPost?.id ?? ""
                    slideVC.modalPresentationStyle = .custom
                    slideVC.transitioningDelegate = update1.self
                    global_presetingRate = Double(0.75)
                    global_cornerRadius = 35
                    
                    delay(0.1) {
                        update1.present(slideVC, animated: true, completion: nil)
                    }
                    
                }
                
                
                
            }
            
            
            
        }
    
        
    }
    
    @objc func sharePost() {
        
        
        if let vc = UIViewController.currentViewController() {
            
            if vc is FeedViewController {
                
                if let update1 = vc as? FeedViewController {
                    
                    
                    guard let userDataSource = _AppCoreData.userDataSource.value, let userUID = userDataSource.userID, userUID != "" else {
                        print("Sendbird: Can't get userUID")
                        return
                    }
                    
                    let loadUsername = userDataSource.userName
                    let items: [Any] = ["Hi I am \(loadUsername ?? "") from Stitchbox, let's check out this!", URL(string: "https://stitchbox.gg/app/post/?uid=\(update1.editeddPost?.id ?? "")")!]
                    let ac = UIActivityViewController(activityItems: items, applicationActivities: nil)
                    
                    ac.completionWithItemsHandler = { (activityType, completed:Bool, returnedItems:[Any]?, error: Error?) in
                        
                        
                    }
                    
                    delay(0.1) {
                        update1.present(ac, animated: true, completion: nil)
                    }
                    
                }
                
            } else {
                
                if let update1 = vc as? SelectedPostVC {
                    
                    
                    guard let userDataSource = _AppCoreData.userDataSource.value, let userUID = userDataSource.userID, userUID != "" else {
                        print("Sendbird: Can't get userUID")
                        return
                    }
                    
                    let loadUsername = userDataSource.userName
                    let items: [Any] = ["Hi I am \(loadUsername ?? "") from Stitchbox, let's check out this!", URL(string: "https://stitchbox.gg/app/post/?uid=\(update1.editeddPost?.id ?? "")")!]
                    let ac = UIActivityViewController(activityItems: items, applicationActivities: nil)
                    
                    ac.completionWithItemsHandler = { (activityType, completed:Bool, returnedItems:[Any]?, error: Error?) in
                        
                        
                    }
                    
                    delay(0.1) {
                        update1.present(ac, animated: true, completion: nil)
                    }
                    
                }
                
                
                
            }
            
            
            
        }
        
        
    }
    
    func pauseVideo(index: Int) {
        
        if let cell = self.collectionNode.nodeForItem(at: IndexPath(row: index, section: 0)) as? ReelNode {
             
            cell.videoNode.pause()
            
        }
        
    }
    
    
    func seekVideo(index: Int, time: CMTime) {
        
        if let cell = self.collectionNode.nodeForItem(at: IndexPath(row: index, section: 0)) as? ReelNode {
            
            cell.videoNode.player?.seek(to: time)
            
        }
        
    }
    
    
    func playVideo(index: Int) {
        
        
        if let cell = self.collectionNode.nodeForItem(at: IndexPath(row: index, section: 0)) as? ReelNode {
            
            if !cell.videoNode.isPlaying() {
                
                if cell.sideButtonsView != nil {
                    cell.sideButtonsView.viewStitchBtn.spin()
                }
                
                if let muteStatus = shouldMute {
                    
                    
                    if muteStatus {
                        cell.videoNode.muted = true
                    } else {
                        cell.videoNode.muted = false
                    }
                    
                    cell.videoNode.play()
                    
                } else {

                    
                    if globalIsSound {
                        cell.videoNode.muted = false
                    } else {
                        cell.videoNode.muted = true
                    }
                    
                    cell.videoNode.play()
                    
                }
                
                
            }
            
        }
        
    }

    
}



extension OriginalNode {
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HashtagCell.cellReuseIdentifier(), for: indexPath) as! HashtagCell

        // Check if collectionView.tag is within the range of the posts array
        guard collectionView.tag < post.stitchedPosts.count else {
            print("Error: No post for tag \(collectionView.tag)")
            cell.hashTagLabel.text = "Error: post not found"
            return cell
        }
        
        let item = post.stitchedPosts[collectionView.tag]

        // Check if indexPath.row is within the range of the hashtags array
        guard indexPath.row < item.hashtags.count else {
            print("Error: No hashtag for index \(indexPath.row)")
            cell.hashTagLabel.text = "Error: hashtag not found"
            return cell
        }

        cell.hashTagLabel.text = item.hashtags[indexPath.row]
        cell.backgroundColor = .clear
        cell.hashTagLabel.backgroundColor = .clear
        return cell
    }
    
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView.tag < post.stitchedPosts.count {
            return post.stitchedPosts[collectionView.tag].hashtags.count
        } else {
            print("Warning: collectionView.tag is out of range!")
            return 0
        }
    }

    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let selectedHashtag = post.stitchedPosts[collectionView.tag].hashtags[indexPath.row]
        
        
        
        if let vc = UIViewController.currentViewController() {
            
            if vc is FeedViewController {
                
                if let update1 = vc as? FeedViewController {
                    
                    
                    if let PLWHVC = UIStoryboard(name: "Dashboard", bundle: nil).instantiateViewController(withIdentifier: "PostListWithHashtagVC") as? PostListWithHashtagVC {
                        
                        PLWHVC.hidesBottomBarWhenPushed = true
                        hideMiddleBtn(vc: update1.self)
                        PLWHVC.searchHashtag = selectedHashtag
                        update1.navigationController?.pushViewController(PLWHVC, animated: true)
                        
                    }
                    
                }
                
            } else {
                
                if let update1 = vc as? SelectedPostVC {
                    
                    
                    if let PLWHVC = UIStoryboard(name: "Dashboard", bundle: nil).instantiateViewController(withIdentifier: "PostListWithHashtagVC") as? PostListWithHashtagVC {
                        
                        PLWHVC.searchHashtag = selectedHashtag
                        update1.navigationController?.pushViewController(PLWHVC, animated: true)
                        
                    }
                    
                }
                
                
                
            }
            
            
            
        }
        
        
    }
    
    
}



extension OriginalNode {
    
    
    func collectionNode(_ collectionNode: ASCollectionNode, willDisplayItemWith node: ASCellNode) {
        
        if isfirstLoad {
            isfirstLoad = false
            let post = post.stitchedPosts[0]
            if !post.muxPlaybackId.isEmpty {
                currentIndex = 0
                newPlayingIndex = 0
                isVideoPlaying = true
            }
            
        }
        
    }
    
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if !post.stitchedPosts.isEmpty, scrollView == collectionNode.view {
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
                if distanceFromCenter < minDistanceFromCenter {
                    newPlayingIndex = cell.indexPath!.row
                    minDistanceFromCenter = distanceFromCenter
                }
            }
            
            if !post.stitchedPosts[newPlayingIndex!].muxPlaybackId.isEmpty {
                foundVisibleVideo = true
                //playTimeBar.isHidden = false
                imageIndex = nil
            } else {
                //playTimeBar.isHidden = true
                imageIndex = newPlayingIndex
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
