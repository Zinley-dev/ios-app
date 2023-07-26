//
//  ProfileViewController.swift
//  Stitchbox
//
//  Created by Hisoft Hoangnm on 15/12/2022.
//

import UIKit
import ObjectMapper

class ProfileViewController: UIViewController {
    
    deinit {
        print("ProfileViewController is being deallocated.")
    }
    
    
    typealias ViewModelType = ProfileViewModel
    // MARK: - Properties
    private var currpage = 1
    
    enum Section: Hashable {
        case header
        case posts
    }
    
    enum Item: Hashable {
        case header(ProfileHeaderData)
        case posts(PostModel)
    }
    
    
    var followerCount = 0
    var followingCount = 0
    var hasLoaded = false
    
    
    typealias Datasource = UICollectionViewDiffableDataSource<Section, Item>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Item>
    
    private var datasource: Datasource!
    
   
    @IBOutlet weak var collectionView: UICollectionView!
    
    var pullControl = UIRefreshControl()
    
    
    var profileData: ProfileHeaderData {
        return ProfileHeaderData(name: "Defaults", username: "", accountType: "Defaults/Public")
    }
    
    
    func getMyPost(block: @escaping ([[String: Any]]) -> Void) {
        
        APIManager.shared.getMyPost(page: currpage) { [weak self] result in
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
    
    func insertNewRowsInCollectionNode(newPosts: [[String: Any]]) {
        
        // Check if there are new posts to insert
        guard !newPosts.isEmpty else { return }
        let newItems = newPosts.compactMap { PostModel(JSON: $0) }
        var snapshot = self.datasource.snapshot()
        
        snapshot.appendItems(newItems.map({Item.posts($0)}), toSection: .posts)
        self.datasource.apply(snapshot, animatingDifferences: true)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        NotificationCenter.default.addObserver(self, selector: #selector(ProfileViewController.refreshData), name: (NSNotification.Name(rawValue: "refreshData")), object: nil)
        
        //refreshFollow
        collectionView.delegate = self
        collectionView.backgroundColor = .white
        
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
        wireDelegate()
        setupSettingButton()
        self.getFollowing()
        self.getFollowers()
        
        
        self.getMyPost { (newPosts) in
            
            self.insertNewRowsInCollectionNode(newPosts: newPosts)
            
        }
        
        delay(2) {
            self.hasLoaded = true
        }
        
        
        if let navigationController = self.navigationController {
            navigationController.navigationBar.prefersLargeTitles = false
            navigationController.navigationBar.isTranslucent = false
        }
        
        
        
    }
    
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Hide the Navigation Bar
        
       // self.navigationController?.setNavigationBarHidden(true, animated: animated)
        
        // tabbar
        showMiddleBtn(vc: self)
        
        // check if need to refresh somethings
        
        if needRecount, hasLoaded {
            
            needRecount = false
            refreshFollow()
            
        }
        
        if needReloadPost, hasLoaded {
            
            needReloadPost = false
            refreshPost()
            
        }
        
        
        let navigationBarAppearance = UINavigationBarAppearance()
        navigationBarAppearance.configureWithOpaqueBackground()
        navigationBarAppearance.backgroundColor = .white
        navigationBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.black]
        navigationBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.black]
        
        self.navigationController?.navigationBar.standardAppearance = navigationBarAppearance
        self.navigationController?.navigationBar.scrollEdgeAppearance = navigationBarAppearance
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Show the Navigation Bar
        
        //self.navigationController?.setNavigationBarHidden(false, animated: animated)
        
    }
    

    func setupSettingButton() {
        
        let settingButton = UIButton(type: .custom)
        settingButton.setImage(UIImage.init(named: "settings black")?.resize(targetSize: CGSize(width: 25, height: 25)), for: [])
        settingButton.addTarget(self, action: #selector(settingTapped(_:)), for: .touchUpInside)
        settingButton.frame = CGRect(x: -1, y: 0, width: 30, height: 30)
        let settingButtonBar = UIBarButtonItem(customView: settingButton)
        
        let saveButton = UIButton(type: .custom)
        saveButton.setImage(UIImage(named: "save-unfill")?.resize(targetSize: CGSize(width: 25, height: 25)), for: [])
        saveButton.addTarget(self, action: #selector(saveTapped(_:)), for: .touchUpInside)
        saveButton.frame = CGRect(x: -1, y: 0, width: 30, height: 30)
        let saveBarButton = UIBarButtonItem(customView: saveButton)
        
        
        let pendingButton = UIButton(type: .custom)
        pendingButton.setImage(UIImage(named: "pending-actions-icon-original")?.resize(targetSize: CGSize(width: 25, height: 25)), for: [])
        pendingButton.addTarget(self, action: #selector(pendingTapped(_:)), for: .touchUpInside)
        pendingButton.frame = CGRect(x: -1, y: 0, width: 30, height: 30)
        let pendingBarButton = UIBarButtonItem(customView: pendingButton)
        
        
        let fixedSpace = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        fixedSpace.width = 2
        
        
        //let promotionBarButton = self.createPromotionButton()
        self.navigationItem.rightBarButtonItems = [settingButtonBar, fixedSpace, saveBarButton]
        self.navigationItem.leftBarButtonItems = [pendingBarButton]
    
    }
    
    
    private func cell(collectionView: UICollectionView, indexPath: IndexPath, item: Item) -> UICollectionViewCell {
        switch item {
        case .header(_):
            
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ProfileHeaderCell.reuseIdentifier, for: indexPath) as? ProfileHeaderCell {
                // display username
                if let username = _AppCoreData.userDataSource.value?.userName, username != "" {
                    cell.usernameLbl.text = "@\(username)"
                    
                }
                
                if let name = _AppCoreData.userDataSource.value?.name, name != "" {
                    navigationItem.title = name
                }
                
                if let avatarUrl = _AppCoreData.userDataSource.value?.avatarURL, avatarUrl != "", let url = URL(string: avatarUrl) {
                    if cell.lastAvatarImgUrl != url {
                        cell.lastAvatarImgUrl = url
                        cell.avatarImage.load(url: url, str: avatarUrl)
                        
                    }
                } else {
                    cell.avatarImage.image = UIImage.init(named: "defaultuser")
                   
                }
                
                
                if let about = _AppCoreData.userDataSource.value?.about {
                    cell.descriptionLbl.text = about
                    
                    // add target using gesture recognizer for image
                    let descriptionTap = UITapGestureRecognizer(target: self, action: #selector(ProfileViewController.descTapped))
                    cell.descriptionLbl.isUserInteractionEnabled = true
                    cell.descriptionLbl.addGestureRecognizer(descriptionTap)
                    
                }
                

                cell.numberOfFollowers.text = "\(formatPoints(num: Double(followerCount)))"
                cell.numberOfFollowing.text = "\(formatPoints(num: Double(followingCount)))"
         
                
                // add buttons target
                cell.insightBtn.addTarget(self, action: #selector(insightTapped), for: .touchUpInside)
             

                cell.editProfileBtn.addTarget(self, action: #selector(editProfileTapped), for: .touchUpInside)
                
                
                let numberOfFollowersTap = UITapGestureRecognizer(target: self, action: #selector(ProfileViewController.followersTapped))
                cell.followerStack.isUserInteractionEnabled = true
                cell.followerStack.addGestureRecognizer(numberOfFollowersTap)
                
                
                let numberOfFollowingTap = UITapGestureRecognizer(target: self, action: #selector(ProfileViewController.followingTapped))
                cell.followingStack.isUserInteractionEnabled = true
                cell.followingStack.addGestureRecognizer(numberOfFollowingTap)
                
                
                return cell
                
            } else {
                
                
                return ProfileHeaderCell()
                
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
extension ProfileViewController {
    
    @objc func refreshListData(_ sender: Any) {
        
        var snapshot = self.datasource.snapshot()
        snapshot.deleteItems(snapshot.itemIdentifiers(inSection: .posts))
        datasource.apply(snapshot, animatingDifferences: false) // Apply the updated snapshot
        
        currpage = 1
        
        self.getMyPost { (newPosts) in
            
            self.insertNewRowsInCollectionNode(newPosts: newPosts)
            
        }
        
        
        reloadUserInformation {
            self.reloadGetFollowers {
                self.reloadUserInformation {
                    self.applyAllChange()
                    Dispatch.main.async {
                        self.pullControl.endRefreshing()
                    }
                }
            }
        }
        
        
    }
    
    @objc func refreshData(_ sender: Any) {
        
        reloadUserInformation {
            self.applyUIChange()
            
        }
        
        
    }
    
    func refreshFollow() {
        
        reloadGetFollowers {
            self.reloadGetFollowing {
                self.applyHeaderChange()
            }
        }
        
        
    }
    
    func refreshPost() {
        
        var snapshot = self.datasource.snapshot()
        snapshot.deleteItems(snapshot.itemIdentifiers(inSection: .posts))
        datasource.apply(snapshot, animatingDifferences: false) // Apply the updated snapshot
        currpage = 1
        
        self.getMyPost { (newPosts) in
            
            self.insertNewRowsInCollectionNode(newPosts: newPosts)
            
        }
        
        
    }
    
    
    @objc func settingTapped(_ sender: UIButton) {
        
        if let SVC = UIStoryboard(name: "Dashboard", bundle: nil).instantiateViewController(withIdentifier: "SettingVC") as? SettingVC {
            
            SVC.hidesBottomBarWhenPushed = true
            hideMiddleBtn(vc: self)
            self.navigationController?.pushViewController(SVC, animated: true)
            
        }
        
    }
    
    
    
    @objc func pendingTapped(_ sender: UIButton) {
        
        if let PVC = UIStoryboard(name: "Dashboard", bundle: nil).instantiateViewController(withIdentifier: "StitchDashboardVC") as? StitchDashboardVC {
            
            PVC.hidesBottomBarWhenPushed = true
            hideMiddleBtn(vc: self)
            self.navigationController?.pushViewController(PVC, animated: true)
            
        }
        
    }
    
    @objc func saveTapped(_ sender: UIButton) {
        
        if let SPVC = UIStoryboard(name: "Dashboard", bundle: nil).instantiateViewController(withIdentifier: "SavePostVC") as? SavePostVC {
            
            SPVC.hidesBottomBarWhenPushed = true
            hideMiddleBtn(vc: self)
            self.navigationController?.pushViewController(SPVC, animated: true)
            
        }
        
    }
    
    
    @objc func insightTapped(_ sender: UIButton) {
        
  
        
        if let SSVC = UIStoryboard(name: "Dashboard", bundle: nil).instantiateViewController(withIdentifier: "StitchStatVC") as? StitchStatVC {
            
            SSVC.hidesBottomBarWhenPushed = true
            hideMiddleBtn(vc: self)
            self.navigationController?.pushViewController(SSVC, animated: true)
            
        }
        
    }
    
    @objc func followersTapped(_ sender: UIButton) {
        
        if let MFVC = UIStoryboard(name: "Dashboard", bundle: nil).instantiateViewController(withIdentifier: "MainFollowVC") as? MainFollowVC {
            
            MFVC.hidesBottomBarWhenPushed = true
            MFVC.showFollowerFirst = true
            MFVC.followerCount = followerCount
            MFVC.followingCount = followingCount
            MFVC.userId = _AppCoreData.userDataSource.value?.userID ?? ""
            hideMiddleBtn(vc: self)
            self.navigationController?.pushViewController(MFVC, animated: true)
            
        }
        
    }
    
    @objc func descTapped(_ sender: UIButton) {
        
        if let IDVC = UIStoryboard(name: "Dashboard", bundle: nil).instantiateViewController(withIdentifier: "InfoDetailVC") as? InfoDetailVC {
            
            IDVC.bio = _AppCoreData.userDataSource.value?.about ?? ""
            IDVC.userame = _AppCoreData.userDataSource.value?.userName ?? ""
            
            hideMiddleBtn(vc: self)
            IDVC.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(IDVC, animated: true)
            
        }
        
    }
    
    
    @objc func followingTapped(_ sender: UIButton) {
        
        if let MFVC = UIStoryboard(name: "Dashboard", bundle: nil).instantiateViewController(withIdentifier: "MainFollowVC") as? MainFollowVC {
            
            MFVC.hidesBottomBarWhenPushed = true
            MFVC.showFollowerFirst = false
            MFVC.followerCount = followerCount
            MFVC.followingCount = followingCount
            MFVC.userId = _AppCoreData.userDataSource.value?.userID ?? ""
            hideMiddleBtn(vc: self)
            self.navigationController?.pushViewController(MFVC, animated: true)
            
        }
        
    }
    
    
    @objc func editProfileTapped(_ sender: UIButton) {
        
        if let EPVC = UIStoryboard(name: "Dashboard", bundle: nil).instantiateViewController(withIdentifier: "EditPhofileVC") as? EditPhofileVC {
            
            EPVC.hidesBottomBarWhenPushed = true
            hideMiddleBtn(vc: self)
            self.navigationController?.pushViewController(EPVC, animated: true)
            
        }
        
    }
    
    @objc func discordTapped(_ sender: UIButton) {
        
        if let discord = _AppCoreData.userDataSource.value?.discordUrl, discord != "" {
            
            if let username = _AppCoreData.userDataSource.value?.userName {
                
                let alert = UIAlertController(title: "Hey \(username)!", message: "We've verified all the attached links for validity and authenticity. Your device's default browser will protect you from harmful links. We're committed to keeping the community safe and urge you to report any attempts to harm you or other users through this method.", preferredStyle: UIAlertController.Style.actionSheet)
                
                // add the actions (buttons)
                alert.addAction(UIAlertAction(title: "Confirm to open", style: UIAlertAction.Style.default, handler: { action in
                    
                    
                    self.openLink(link: discord)
                    
                }))
                
                alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil))
                self.present(alert, animated: true, completion: nil)
                
            }
            
        } else {
            
            if let EPVC = UIStoryboard(name: "Dashboard", bundle: nil).instantiateViewController(withIdentifier: "EditPhofileVC") as? EditPhofileVC {
                EPVC.hidesBottomBarWhenPushed = true
                hideMiddleBtn(vc: self)
                self.navigationController?.pushViewController(EPVC, animated: true)
                
            }
        }
        
    }

    
}

// selector for challengeCard
extension ProfileViewController {

    func openLink(link: String) {
        
        if link != ""
        {
            guard let requestUrl = URL(string: link) else {
                return
            }
            
            if UIApplication.shared.canOpenURL(requestUrl) {
                UIApplication.shared.open(requestUrl, options: [:], completionHandler: nil)
            } else {
                showErrorAlert("Oops!", msg: "canOpenURL: failed for URL: \(link)")
            }
            
        } else {
            
            showErrorAlert("Oops!", msg: "Can't open this link")
            
        }
        
    }
    
    
}

extension ProfileViewController {
    
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

extension ProfileViewController {
    
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
        snapshot.appendItems([.header(profileData)], toSection: .header)
        
        return snapshot
    }
    
    
}

extension ProfileViewController: UICollectionViewDelegate {
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let item = datasource.itemIdentifier(for: indexPath)
        
        switch item {
        case .header(_):
            print("header")
            
        case .posts(_):
            
            let selectedPost = datasource.snapshot().itemIdentifiers(inSection: .posts)
                .compactMap { item -> PostModel? in
                    if case .posts(let post) = item {
                        return post
                    }
                    return nil
                }
            
            
            if let SPVC = UIStoryboard(name: "Dashboard", bundle: nil).instantiateViewController(withIdentifier: "SelectedPostVC") as? SelectedPostVC {
                
                SPVC.selectedPost = selectedPost
                SPVC.startIndex = indexPath.row
                SPVC.hidesBottomBarWhenPushed = true
                hideMiddleBtn(vc: self)
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
            self.getMyPost { (newPosts) in
                self.insertNewRowsInCollectionNode(newPosts: newPosts)
            }
        }
    }
    
    
}

// handle challenge card was tapped
extension ProfileViewController {

    func showErrorAlert(_ title: String, msg: String) {
        
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        
        
        present(alert, animated: true, completion: nil)
        
    }
    
}

//setting up navigationCollection Bar
extension ProfileViewController: UINavigationBarDelegate, UINavigationControllerDelegate {
    
    func wireDelegate() {
        self.navigationController?.delegate = self
    }
    
}

extension ProfileViewController {
    
    func getFollowing() {
        
        APIManager.shared.getFollows(page:1) { [weak self] result in
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
                
                self.applyHeaderChange()
                
            case .failure(let error):
                print("Error loading following: ", error)
                
            }
        }
    }
    func getFollowers() {
        
        APIManager.shared.getFollowers(page: 1) { [weak self] result in
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
                
                self.applyHeaderChange()
                
            case .failure(let error):
                print("Error loading follower: ", error)
            }
        }
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
    
    
    func reloadUserInformation(completed: @escaping DownloadComplete) {
        
        APIManager.shared.getme { result in
           
            switch result {
            case .success(let response):
                
                if let data = response.body {
                    
                    if !data.isEmpty {
                        
                        if let newUserData = Mapper<UserDataSource>().map(JSON: data) {
                            _AppCoreData.reset()
                            _AppCoreData.userDataSource.accept(newUserData)
                            completed()
                        } else {
                            completed()
                        }
                        
                        
                    } else {
                        completed()
                    }
                    
                } else {
                    completed()
                }
                
                
            case .failure(let error):
                print("Error loading profile: ", error)
                completed()
            }
        }
        
    }
    
    
    func reloadGetFollowing(completed: @escaping DownloadComplete) {
        
        APIManager.shared.getFollows(page:1) { [weak self] result in
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
        
        APIManager.shared.getFollowers(page: 1) { [weak self] result in
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

    
    
}




