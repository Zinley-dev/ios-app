//
//  UserProfileVC.swift
//  Stitchbox
//
//  Created by Khoi Nguyen on 1/25/23.
//

import UIKit
import ObjectMapper
import SendBirdSDK
import FLAnimatedImage
import SendBirdUIKit
import SafariServices

class UserProfileVC: UIViewController {
    
    deinit {
        print("UserProfileVC is being deallocated.")
        NotificationCenter.default.removeObserver(self)
        collectionView.delegate = nil
        collectionView.dataSource = nil
    }
    
    private let fireworkController = FountainFireworkController()
    private let fireworkController2 = ClassicFireworkController()
    
    
    enum Section: Hashable {
        case header
        case posts
    }
    
    enum Item: Hashable {
        case header(ProfileHeaderData)
        case posts(PostModel)
    }
    
    let backButton: UIButton = UIButton(type: .custom)
    let shareButton: UIButton = UIButton(type: .custom)
    
    typealias Datasource = UICollectionViewDiffableDataSource<Section, Item>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Item>
    
    private var datasource: Datasource!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var loadingImage: FLAnimatedImageView!
    @IBOutlet weak var loadingView: UIView!
    var get_username = ""
    var get_bio = ""
    
    var pullControl = UIRefreshControl()
    var onPresent = false
    var allowProcess = true
    
    var followerCount = 0
    var followingCount = 0
    var stitchCount = 0
    var firstAnimated = true
    var isFollow = false
   
    
    var demoProfileData: ProfileHeaderData {
        return ProfileHeaderData(name: "", username: "", accountType: "", postCount: 0)
    }
    
    var userId: String?
    var nickname: String?
    var userData: UserDataSource?
    var currpage = 1
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.setupButtons()
        
        if userId != nil {
            
            collectionView.delegate = self
            
            
            pullControl.tintColor = UIColor.secondary
            pullControl.addTarget(self, action: #selector(refreshListData(_:)), for: .valueChanged)
            
            if #available(iOS 10.0, *) {
                collectionView.refreshControl = pullControl
            } else {
                collectionView.addSubview(pullControl)
            }
            
            collectionView.setCollectionViewLayout(createLayout(), animated: true)
            collectionView.register(ProfilePostsHeaderView.nib, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: ProfilePostsHeaderView.reuseIdentifier)
            collectionView.register(ImageViewCell.self, forCellWithReuseIdentifier: ImageViewCell.reuseIdentifier)
            
            configureDatasource()
            
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                self?.loadUserData()
            }
        
         
            
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(UserProfileVC.copyProfile), name: (NSNotification.Name(rawValue: "copy_user")), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(UserProfileVC.report), name: (NSNotification.Name(rawValue: "report_user")), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(UserProfileVC.block), name: (NSNotification.Name(rawValue: "block_user")), object: nil)
        
        
        self.loadingView.isHidden = true
        
        let navigationBarAppearance = UINavigationBarAppearance()
        navigationBarAppearance.configureWithOpaqueBackground()
        navigationBarAppearance.backgroundColor = .white
        navigationBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.black]
        navigationBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.black]
        
        self.navigationController?.navigationBar.standardAppearance = navigationBarAppearance
        self.navigationController?.navigationBar.scrollEdgeAppearance = navigationBarAppearance
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        NotificationCenter.default.removeObserver(self, name: (NSNotification.Name(rawValue: "copy_user")), object: nil)
        NotificationCenter.default.removeObserver(self, name: (NSNotification.Name(rawValue: "report_user")), object: nil)
        NotificationCenter.default.removeObserver(self, name: (NSNotification.Name(rawValue: "block_user")), object: nil)
        
        
    }
    
    
    private func cell(collectionView: UICollectionView, indexPath: IndexPath, item: Item) -> UICollectionViewCell {
        switch item {
        case .header(_):
            
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: UserProfileHeaderCell.reuseIdentifier, for: indexPath) as? UserProfileHeaderCell {
                
                if let data = userData {
                    
                    // display username
                    if let username = data.userName, username != "" {
                        cell.usernameLbl.text = "@\(username)"
                        
                        get_username = username
                    }
                    
                   
                    
                    if let name = data.name, name != "" {
                        navigationItem.title = name
                    }

                    // Avatar Image
                    if data.avatarURL != "", let url = URL(string: data.avatarURL) {
                        if cell.lastAvatarImgUrl != url {
                            cell.lastAvatarImgUrl = url
                            cell.avatarImage.load(url: url, str: data.avatarURL)
                           
                        }
                    } else {
                        cell.avatarImage.image = UIImage.init(named: "defaultuser")
                    }

                 
                    
                    if data.about != "" {
                        cell.descriptionLbl.text = data.about
                        get_bio = data.about
                        
                        // add target using gesture recognizer for image
                        let descriptionTap = UITapGestureRecognizer(target: self, action: #selector(UserProfileVC.descTapped))
                        cell.descriptionLbl.isUserInteractionEnabled = true
                        cell.descriptionLbl.addGestureRecognizer(descriptionTap)
                    }
                    
                    
                    if data.discordUrl != "" {
                        cell.linkStackView.isHidden = false
                        cell.linkLbl.text = data.discordUrl
                        
                        
                        let linkTap = UITapGestureRecognizer(target: self, action: #selector(UserProfileVC.linkTapped))
                        cell.linkStackView.isUserInteractionEnabled = true
                        cell.linkStackView.addGestureRecognizer(linkTap)
                        
                    } else {
                        cell.linkStackView.isHidden = true
                    }
                 
                    
                    cell.numberOfFollowers.text = "\(formatPoints(num: Double(followerCount)))"
                    cell.numberOfFollowing.text = "\(formatPoints(num: Double(followingCount)))"
                    cell.numberOfStitches.text = "\(formatPoints(num: Double(stitchCount)))"
                    
              

                    cell.moreBtn.addTarget(self, action: #selector(moreTapped), for: .touchUpInside)
                    cell.followersBtn.addTarget(self, action: #selector(followAction), for: .touchUpInside)
                    cell.messageBtn.addTarget(self, action: #selector(messageTapped), for: .touchUpInside)
                    
                    
                    let numberOfFollowersTap = UITapGestureRecognizer(target: self, action: #selector(ProfileViewController.followersTapped))
                    cell.followerStack.isUserInteractionEnabled = true
                    cell.followerStack.addGestureRecognizer(numberOfFollowersTap)
                    
                    
                    let numberOfFollowingTap = UITapGestureRecognizer(target: self, action: #selector(ProfileViewController.followingTapped))
                    cell.followingStack.isUserInteractionEnabled = true
                    cell.followingStack.addGestureRecognizer(numberOfFollowingTap)
                    
                    if self.isFollow {
                        cell.followersBtn.setTitle("Following", for: .normal)
                    } else {
                        cell.followersBtn.setTitle("Follow", for: .normal)
                    }
                    
                    
                }
                
                
                return cell
                
            } else {
                
                
                return UserProfileHeaderCell()
                
            }

        case .posts(let data):
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ImageViewCell.reuseIdentifier, for: indexPath) as? ImageViewCell {
                cell.configureWithUrl(with: data)
                return cell
            } else {
                return ImageViewCell()
            }
        }
    }
    
    
    private func configureDatasource() {
        datasource = Datasource(collectionView: collectionView, cellProvider: { [unowned self] collectionView, indexPath, item in
            return self.cell(collectionView: collectionView, indexPath: indexPath, item: item)
        })
        
        datasource.supplementaryViewProvider = { [unowned self] collectionView, kind, indexPath in
            return self.supplementary(collectionView: collectionView, kind: kind, indexPath: indexPath)
        }
        
        datasource.apply(snapshot(), animatingDifferences: false)
    }
    
    
}

// selector for header
extension UserProfileVC {
    
    @objc func followAction(_ sender: UIButton) {
        
        if isFollow {
            
            unfollowUser()
            
        } else {
            
            followUser()
        }
        
    }
    
    func followUser() {
        
        if allowProcess {
            
            self.allowProcess = false
            self.isFollow = true
            followerCount += 1
            self.applyHeaderChange()
            
            APIManager.shared.insertFollows(params: ["FollowId": userId ?? ""]) { [weak self] result in
                guard let self = self else { return }
                
                switch result {
                case .success(_):
                    
                    self.allowProcess = true
                    self.isFollow = true
                    needRecount = true
                   
                    
                    
                case .failure(let error):
                    
                    print(error)
                    
                    DispatchQueue.main.async { [weak self] in
                        guard let self = self else { return }
                        self.allowProcess = true
                        self.isFollow = false
                        self.followerCount += 1
                        showNote(text: "Something happened!")
                        self.applyHeaderChange()
                    }
                    
                    
                }
                
            }
            
        }
        
        
        
    }
    
    
    func unfollowUser() {
        
        if allowProcess {
            
            self.allowProcess = false
            self.isFollow = false
            followerCount -= 1
            self.applyHeaderChange()
            
            APIManager.shared.unFollow(params: ["FollowId": userId ?? ""]) { [weak self] result in
                guard let self = self else { return }
                
                switch result {
                case .success(_):
                    
                    self.isFollow = false
                    needRecount = true
                    self.allowProcess = true
                  
                    
                case .failure(let error):
                    
                    print(error)
                    
                    DispatchQueue.main.async { [weak self] in
                        guard let self = self else { return }
                        self.allowProcess = true
                        self.isFollow = true
                        self.followerCount -= 1
                        showNote(text: "Something happened!")
                        self.applyHeaderChange()
                    }
                    
                    
                }
            }
            
        }
        
        
        
    }
    
    
    @objc func messageTapped(_ sender: UIButton) {
        
        guard let userUID = _AppCoreData.userDataSource.value?.userID, !userUID.isEmpty else { return }
        
        let channelParams = SBDGroupChannelParams()
        channelParams.isDistinct = true
        channelParams.addUserIds([self.userId ?? "", userUID])
        channelParams.operatorUserIds = [userUID]
        
        
        SBDGroupChannel.createChannel(with: channelParams) { [weak self] groupChannel, error in
            guard let self = self else { return }
            guard error == nil, let channelUrl = groupChannel?.channelUrl else {
                self.showErrorAlert("Oops!", msg: error?.localizedDescription ?? "Failed to create message")
                return
            }
            
            self.checkForChannelInvitation(channelUrl: channelUrl, user_ids: [self.userId ?? ""])
            
            let channelVC = ChannelViewController(channelUrl: channelUrl, messageListParams: nil)
            
            let nav = UINavigationController(rootViewController: channelVC)

         
            // Customize the navigation bar appearance
            nav.navigationBar.barTintColor = .white
            nav.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.black]

            nav.modalPresentationStyle = .fullScreen
     
           // self.navigationController?.pushViewController(channelVC, animated: true)
            nav.modalPresentationStyle = .fullScreen
            self.present(nav, animated: true)
            
        }
        
    }
    
    
    func checkForChannelInvitation(channelUrl: String, user_ids: [String]) {
        
        
        APIManager.shared.channelCheckForInviation(userIds: user_ids, channelUrl: channelUrl) { result in
            switch result {
            case .success(let apiResponse):
                // Check if the request was successful
                guard apiResponse.body?["message"] as? String == "success",
                    let data = apiResponse.body?["data"] as? [String: Any] else {
                        return
                }
                
                print(data)
                
               
            case .failure(let error):
                print(error)
            }
        }
        
        
    }
    
    @objc func moreTapped(_ sender: UIButton) {
        
        let userSettingVC = UserSettingVC()
        userSettingVC.modalPresentationStyle = .custom
        userSettingVC.transitioningDelegate = self
        
        global_presetingRate = Double(0.30)
        global_cornerRadius = 45
        
        self.present(userSettingVC, animated: true, completion: nil)
        
    }
    
    @objc func followersTapped(_ sender: UIButton) {
        
        if let MFVC = UIStoryboard(name: "Dashboard", bundle: nil).instantiateViewController(withIdentifier: "MainFollowVC") as? MainFollowVC {
            
            MFVC.showFollowerFirst = true
            MFVC.followerCount = followerCount
            MFVC.followingCount = followingCount
            MFVC.userId = self.userId ?? ""
            MFVC.username = self.userData?.userName ?? ""
            self.navigationController?.setNavigationBarHidden(false, animated: true)
            self.navigationController?.pushViewController(MFVC, animated: true)
            
        }
        
    }
    
    @objc func followingTapped(_ sender: UIButton) {
        //MainFollowVC
        if let MFVC = UIStoryboard(name: "Dashboard", bundle: nil).instantiateViewController(withIdentifier: "MainFollowVC") as? MainFollowVC {
            
            MFVC.showFollowerFirst = false
            MFVC.followerCount = followerCount
            MFVC.followingCount = followingCount
            MFVC.userId = self.userId ?? ""
            MFVC.username = self.userData?.userName ?? ""
            self.navigationController?.setNavigationBarHidden(false, animated: true)
            self.navigationController?.pushViewController(MFVC, animated: true)
            
        }
        
    }
    
    
    @objc func linkTapped(_ sender: UIButton) {
        
        if let discord = userData?.discordUrl, discord != "" {
            
            if let username = _AppCoreData.userDataSource.value?.userName {
                
                let alert = UIAlertController(title: "Hi \(username),", message: "We've verified all the attached links for validity and authenticity. Your device's default browser will protect you from harmful links. We're committed to keeping the community safe and urge you to report any attempts to harm you or other users through this method.", preferredStyle: UIAlertController.Style.actionSheet)
                
                // add the actions (buttons)
                alert.addAction(UIAlertAction(title: "Confirm to open", style: UIAlertAction.Style.default, handler: { action in
                    
                    
                    self.openLink(link: discord)
                    
                }))
                
                alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil))
                self.present(alert, animated: true, completion: nil)
                
            }
            
        }
        
    }
    
    
    func openLink(link: String) {
        
        if link != ""
        {
            guard let requestUrl = URL(string: link) else {
                return
            }
            
            if UIApplication.shared.canOpenURL(requestUrl) {
                
                let SF = SFSafariViewController(url: requestUrl)
                SF.modalPresentationStyle = .fullScreen
                self.present(SF, animated: true)
                
                
            } else {
                showErrorAlert("Oops!", msg: "canOpenURL: failed for URL: \(link)")
            }
            
        } else {
            
            showErrorAlert("Oops!", msg: "Can't open this link")
            
        }
        
    }
 
    
}

// selector for challengeCard
extension UserProfileVC {
    
    
    @objc func descTapped(_ sender: UIButton) {
        
        if let IDVC = UIStoryboard(name: "Dashboard", bundle: nil).instantiateViewController(withIdentifier: "InfoDetailVC") as? InfoDetailVC {
            
            IDVC.bio = get_bio
            IDVC.userame = get_username
            
            hideMiddleBtn(vc: self)
            IDVC.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(IDVC, animated: true)
            
        }
        
    }

    
}


extension UserProfileVC {
    
    func createHeaderSection() -> NSCollectionLayoutSection {
        let headerItem = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(370)))
        let headerGroup = NSCollectionLayoutGroup.horizontal(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(370)), subitems: [headerItem])
        
        let section = NSCollectionLayoutSection(group: headerGroup)
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
        
        return section
    }

    
    func createPhotosSection() -> NSCollectionLayoutSection {
        let numberOfItemsInRow: CGFloat = 3
        let spacing: CGFloat = 5
        let width = (UIScreen.main.bounds.width - (numberOfItemsInRow + 1) * spacing) / numberOfItemsInRow
        let height = width * 13.5 / 9  // This will give you an aspect ratio of 9:16

        let itemSize = NSCollectionLayoutSize(widthDimension: .absolute(width),
                                              heightDimension: .absolute(height))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                               heightDimension: .absolute(height))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: Int(numberOfItemsInRow))
        group.interItemSpacing = NSCollectionLayoutSpacing.fixed(spacing)

        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = spacing
        section.contentInsets = NSDirectionalEdgeInsets(top: spacing, leading: spacing, bottom: spacing, trailing: spacing)

        let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(50))
        let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
        section.boundarySupplementaryItems = [header]
        
        return section
    }

    
    func createLayout() -> UICollectionViewLayout {
        return UICollectionViewCompositionalLayout { [unowned self] index, env in
            return self.sectionFor(index: index, environment: env)
        }
    }
    
}

extension UserProfileVC {
    
    func sectionFor(index: Int, environment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
        let section = datasource.snapshot().sectionIdentifiers[index]
        
        switch section {
        case .header:
            return createHeaderSection()

        case .posts:
            return createPhotosSection()
        }
    }
    
    private func supplementary(collectionView: UICollectionView, kind: String, indexPath: IndexPath) -> UICollectionReusableView {
        return collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: ProfilePostsHeaderView.reuseIdentifier, for: indexPath)
    }
    
    func snapshot() -> Snapshot {
        var snapshot = Snapshot()
        
        snapshot.appendSections([.header, .posts])
        snapshot.appendItems([.header(demoProfileData)], toSection: .header)
    
        return snapshot
    }
    
    
}

extension UserProfileVC: UICollectionViewDelegate {
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        
        let item = datasource.itemIdentifier(for: indexPath)
        
        switch item {
        case .header(_):
            print("header")
            
        case .posts(_):
            
            let selectedPosts = datasource.snapshot().itemIdentifiers(inSection: .posts)
                .compactMap { item -> PostModel? in
                    if case .posts(let post) = item {
                        return post
                    }
                    return nil
                }

            if let SPVC = UIStoryboard(name: "Dashboard", bundle: nil).instantiateViewController(withIdentifier: "SelectedPostVC") as? SelectedPostVC {
                // Find the index of the selected post
                let currentIndex = indexPath.row

                // Determine the range of posts to include before and after the selected post
                let beforeIndex = max(currentIndex - 5, 0)
                let afterIndex = min(currentIndex + 5, selectedPosts.count - 1)

                // Include up to 5 posts before and after the selected post in the sliced array
                SPVC.posts = Array(selectedPosts[beforeIndex...afterIndex])

                // Set the startIndex to the position of the selected post within the sliced array
                SPVC.startIndex = currentIndex - beforeIndex
               
                self.navigationController?.pushViewController(SPVC, animated: true)
            }


            
        case .none:
            print("None")
        }
        
        
    }
    
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        // Infinite scrolling logic
        let snap = datasource.snapshot().itemIdentifiers(inSection: .posts)
        if indexPath.row == snap.count - 5 {
            self.getUserPost { (newPosts) in
                self.insertNewRowsInCollectionNode(newPosts: newPosts)
            }
        }
    }
    
}



extension UserProfileVC {
    
    func setupButtons() {
        
        setupBackButton()
        setupShareButton()
        
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
        
        self.navigationItem.leftBarButtonItem = backButtonBarButton
        
        
        
    }
    
    
    func setupShareButton() {
        
        shareButton.frame = back_frame
        shareButton.contentMode = .center
        
        if let backImage = UIImage(named: "share-lightmode") {
            let imageSize = CGSize(width: 23, height: 23)
            let padding = UIEdgeInsets(top: (back_frame.height - imageSize.height) / 2,
                                       left: (back_frame.width - imageSize.width) / 2 + horizontalPadding,
                                       bottom: (back_frame.height - imageSize.height) / 2,
                                       right: (back_frame.width - imageSize.width) / 2 - horizontalPadding)
            shareButton.imageEdgeInsets = padding
            shareButton.setImage(backImage, for: [])
        }
        
        shareButton.addTarget(self, action: #selector(moreTapped(_:)), for: .touchUpInside)
        shareButton.setTitleColor(UIColor.white, for: .normal)
        shareButton.setTitle("", for: .normal)
        let shareButtonBarButton = UIBarButtonItem(customView: shareButton)
        
        self.navigationItem.rightBarButtonItem = shareButtonBarButton
        
        
        
    }
    
    func setupTitle() {
        
        navigationItem.title = nickname
        
    }
    
    
    @objc func onClickBack(_ sender: AnyObject) {
    
        
        if onPresent {
            self.dismiss(animated: true)
        } else {
            if let navigationController = self.navigationController {
                navigationController.popViewController(animated: true)
            }
        }
        
    }
    
    
}


extension UserProfileVC {
    
    @objc private func refreshListData(_ sender: Any) {
        // self.pullControl.endRefreshing() // You can stop after API Call
        // Call API
        
        clearAllData()
        
    }
    
    @objc func clearAllData() {
        
        reloadPost()
        
        checkIfFollow()
       
        
        reloadUserInformation {
            self.reloadGetFollowers {
                self.reloadGetFollowing {
                    self.reloadGetStitches {
                        self.applyAllChange()
                        Dispatch.main.async {
                            self.pullControl.endRefreshing()
                        }
                    }
                    
                }
            }
        }
        
        
    }
    
    func reloadPost() {
        
        var snapshot = self.datasource.snapshot()
        snapshot.deleteItems(snapshot.itemIdentifiers(inSection: .posts))
        datasource.apply(snapshot, animatingDifferences: false) // Apply the updated snapshot
        currpage = 1
        
        self.getUserPost { (newPosts) in
            
            self.insertNewRowsInCollectionNode(newPosts: newPosts)
            
        }
        
        
    }
    
}

extension UserProfileVC {
    
    func loadUserData() {
        
        APIManager.shared.getUserInfo(userId: self.userId!) {[weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let response):
                guard let data = response.body else {
                    return
                }
                
                self.userData = Mapper<UserDataSource>().map(JSONObject: data)
                self.applyUIChange()
                self.hideAnimation()
                
               
                DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                                        
                    self?.countFollowings()
                    self?.countFollowers()
                    self?.checkIfFollow()
                    self?.getStitchCount()
                    
                    self?.getUserPost { (newPosts) in
                        
                        self?.insertNewRowsInCollectionNode(newPosts: newPosts)
                        
                    }
                                        
                }
                
                
            case .failure(_):
                
                Dispatch.main.async { [weak self] in
                    guard let self = self else { return }
                    self.hideAnimation()
                    self.NoticeBlockAndDismiss()
                }
                
            }
        }
    }
    
    func getStitchCount() {
        
        APIManager.shared.countStitchByUser(userId: userId!) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let apiResponse):
                
                print(apiResponse)
                  
                guard let totalStitch = apiResponse.body?["totalStitch"] as? Int else {
                    print("Couldn't find the 'totalStitch' key")
                    self.stitchCount = 0
                    return
                }
                
                self.stitchCount = totalStitch
                self.applyUIChange()
                
            case .failure(let error):
                self.stitchCount = 0
                print("Error loading stitch: ", error)
                
            }
        }
        
       
    }
    
    func countFollowers() {
        
        APIManager.shared.getFollowers(userId: userId, page: 1) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let response):
                guard response.body?["message"] as? String == "success",
                      let data = response.body?["paging"] as? [String: Any] else {
                    return
                }
                
                if let followersGet = data["total"] as? Int {
                    self.followerCount = followersGet
                } else {
                    self.followerCount = 0
                }
                
                self.applyUIChange()
                
            case .failure(let error):
                print("Error loading follower: ", error)
            }
        }
        
    }
    
    func countFollowings() {
        
        APIManager.shared.getFollows(userId: userId, page:1) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let response):
                
                guard response.body?["message"] as? String == "success",
                      let data = response.body?["paging"] as? [String: Any] else {
                    self.followingCount = 0
                    return
                }
                
                if let followingsGet = data["total"] as? Int {
                    self.followingCount = followingsGet
                } else {
                    self.followingCount = 0
                }
                
                self.applyUIChange()
                
            case .failure(let error):
                print("Error loading following: ", error)
                
            }
        }
        
    }
    
 
    
    func getUserPost(block: @escaping ([[String: Any]]) -> Void) {
        
        APIManager.shared.getUserPost(userId: self.userId ?? "", page: currpage) { [weak self] result in
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
                    self.currpage += 1
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
    
    func checkIfFollow() {
        
        APIManager.shared.isFollowing(uid: userId ?? "") { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let apiResponse):
                
                print(apiResponse)
                
                guard let isFollowing = apiResponse.body?["data"] as? Bool else {
                    return
                }
                
                self.isFollow = isFollowing
                self.applyHeaderChange()
                
            case .failure(let error):
                print(error)
                
            }
        }
        
    }

    
    func insertNewRowsInCollectionNode(newPosts: [[String: Any]]) {
        
        // Check if there are new posts to insert
        guard !newPosts.isEmpty else { return }
        let newItems = newPosts.compactMap { PostModel(JSON: $0) }
        var snapshot = self.datasource.snapshot()
        
        snapshot.appendItems(newItems.map({Item.posts($0)}), toSection: .posts)
        self.datasource.apply(snapshot, animatingDifferences: true)
        
    }
    
    
    
    func applyHeaderChange() {
        
        Dispatch.main.async {
            var updatedSnapshot = self.datasource.snapshot()
            updatedSnapshot.reloadSections([.header])
            self.datasource.apply(updatedSnapshot, animatingDifferences: false)
        }
        
        
    }
    
    func applyAllChange() {
        Dispatch.main.async {
            var updatedSnapshot = self.datasource.snapshot()
            updatedSnapshot.reloadSections([.header, .posts])
            self.datasource.apply(updatedSnapshot, animatingDifferences: false)
        }
        
    }
    
    func applyUIChange() {
        
        Dispatch.main.async {
            var updatedSnapshot = self.datasource.snapshot()
            updatedSnapshot.reloadSections([.header])
            self.datasource.apply(updatedSnapshot, animatingDifferences: false)
        }
        
    }
    
}

extension UserProfileVC {
    
    func reloadUserInformation(completed: @escaping DownloadComplete) {
        
        APIManager.shared.getUserInfo(userId: self.userId!) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let response):
                guard let data = response.body else {
                    completed()
                    return
                }
                
                self.userData = Mapper<UserDataSource>().map(JSONObject: data)
                completed()
                
            case .failure(let error):
                print(error)
                completed()
            }
        }
        
    }
    
    func reloadGetStitches(completed: @escaping DownloadComplete) {
        
        APIManager.shared.countStitchByUser(userId: userId!) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let apiResponse):
                  
                guard let totalStitch = apiResponse.body?["totalStitch"] as? Int else {
                    print("Couldn't find the 'totalStitch' key")
                    self.stitchCount = 0
                    completed()
                    return
                }
                
                self.stitchCount = totalStitch
                completed()
                
            case .failure(let error):
                self.stitchCount = 0
                print("Error loading stitch: ", error)
                completed()
            }
        }
    }
    
    func reloadGetFollowing(completed: @escaping DownloadComplete) {
        
        APIManager.shared.getFollows(userId: userId, page:1) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let response):
                
                guard response.body?["message"] as? String == "success",
                      let data = response.body?["paging"] as? [String: Any] else {
                    self.followingCount = 0
                    completed()
                    return
                }
                
                if let followingsGet = data["total"] as? Int {
                    self.followingCount = followingsGet
                } else {
                    self.followingCount = 0
                }
                
                completed()
                
            case .failure(let error):
                print("Error loading following: ", error)
                completed()
                
            }
        }
    }
    func reloadGetFollowers(completed: @escaping DownloadComplete) {
        
        APIManager.shared.getFollowers(userId: userId, page: 1) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let response):
                guard response.body?["message"] as? String == "success",
                      let data = response.body?["paging"] as? [String: Any] else {
                    completed()
                    return
                }
                
                if let followersGet = data["total"] as? Int {
                    self.followerCount = followersGet
                } else {
                    self.followerCount = 0
                }
                
                completed()
                
            case .failure(let error):
                print("Error loading follower: ", error)
                completed()
            }
        }
    }
  
    
    func showErrorAlert(_ title: String, msg: String) {
        
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        
        
        present(alert, animated: true, completion: nil)
        
    }
    
}


extension UserProfileVC {
    
    
    @objc func copyProfile() {
        
        if let id = self.userId {
            
            let link = "https://stitchbox.net/app/account/?uid=\(id)"
            
            UIPasteboard.general.string = link
            showNote(text: "User profile link is copied")
            
        } else {
            showNote(text: "User profile link is unable to be copied")
        }
        
    }
    
    @objc func report() {
        
        let slideVC =  reportView()
        
        slideVC.user_report = true
        slideVC.userId = self.userId!
        slideVC.modalPresentationStyle = .custom
        slideVC.transitioningDelegate = self
        global_presetingRate = Double(0.70)
        global_cornerRadius = 35
        
        delay(0.1) {
            self.present(slideVC, animated: true, completion: nil)
        }
        
    }
    
    @objc func block() {
        
        let alert = UIAlertController(title: "Are you sure to block \(userData?.userName ?? "")!", message: "Blocking someone means you can't see each other's content or messages, except in a group chat. It's important to only block someone if you feel it's necessary for your safety or well-being, and to report any concerning behavior to the Stitchbox moderators or authorities.", preferredStyle: UIAlertController.Style.actionSheet)
        
        // add the actions (buttons)
        alert.addAction(UIAlertAction(title: "Block", style: UIAlertAction.Style.destructive, handler: { action in
            
            self.initBlock(uid: self.userId ?? "")
            
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil))
        
        // show the alert
        delay(0.1) {
            self.present(alert, animated: true, completion: nil)
        }
        
    }
    
    
    func initBlock(uid: String) {
        
        presentSwiftLoader()
        
        SBDMain.blockUserId(uid) { blockedUser, error in
            
            if error != nil {
                
                SwiftLoader.hide()
                self.showErrorAlert("Oops!", msg: "User can't be blocked now due to internal error from our SB chat system, please try again")
                
            } else {
                
                APIManager.shared.insertBlocks(params: ["blockId": uid]) { [weak self] result in
                    guard let self = self else { return }
                    
                    switch result {
                    case .success(_):
                        
                        Dispatch.main.async {
                            SwiftLoader.hide()
                            self.NoticeBlockAndDismiss()
                        }
                        
                    case .failure(let error):
                        Dispatch.main.async {
                            SwiftLoader.hide()
                            self.showErrorAlert("Oops!", msg: "\(error.localizedDescription)")
                        }
                    }
                }
                
            }
            
        }
        
    }
    
    
    func NoticeBlockAndDismiss() {
        
        let sheet = UIAlertController(title: "Oops!", message: "This user isn't available now.", preferredStyle: .alert)
        
        
        let ok = UIAlertAction(title: "Got it", style: .default) { (alert) in
            
            if self.onPresent {
                self.dismiss(animated: true)
            } else {
                if let navigationController = self.navigationController {
                    navigationController.popViewController(animated: true)
                }
            }
            
        }
        
        sheet.addAction(ok)
        
        
        self.present(sheet, animated: true, completion: nil)
        
    }
    
    
    func hideAnimation() {
        
        if firstAnimated {
            
            firstAnimated = false
            
            delay(1) {
                
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
    
    func addfireWork(imgView: UIImageView) {
        self.fireworkController.addFirework(sparks: 10, above: imgView)
        self.fireworkController2.addFireworks(count: 10, sparks: 8, around: imgView)
    }
    
    
}
