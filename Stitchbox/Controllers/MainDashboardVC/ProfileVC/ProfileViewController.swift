//
//  ProfileViewController.swift
//  Stitchbox
//
//  Created by Hisoft Hoangnm on 15/12/2022.
//

import UIKit
import ObjectMapper

class ProfileViewController: UIViewController {
    typealias ViewModelType = ProfileViewModel
    // MARK: - Properties
    private var currpage = 1
    
    enum Section: Hashable {
        case header
        case challengeCard
        case posts
    }

    enum Item: Hashable {
        case header(ProfileHeaderData)
        case challengeCard(ChallengeCardHeaderData)
        case posts(PostModel)
    }
    
    
    var followerCount = 0
    var followingCount = 0
    var fistBumpedCount = 0
    var hasLoaded = false
    

    typealias Datasource = UICollectionViewDiffableDataSource<Section, Item>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Item>
    
    private var datasource: Datasource!
    
    @IBOutlet weak var selectAvatarImage: UIImageView!
    @IBOutlet weak var selectCoverImage: UIImageView!
    @IBOutlet weak var challengeCardView: UIView!
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
   
    var ChallengeView = ChallengeCard()
    var pullControl = UIRefreshControl()
    

    var profileData: ProfileHeaderData {
        return ProfileHeaderData(name: "Defaults", username: "", accountType: "Defaults/Public")
    }
    
    var challengeData: ChallengeCardHeaderData {
        return ChallengeCardHeaderData(name: "Defaults")
    }
    
    
    
    func getMyPost(block: @escaping ([[String: Any]]) -> Void) {
        
            APIManager().getMyPost(page: currpage) { result in
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
   
        self.getFistBumperCount()
        self.getFollowing()
        self.getFollowers()

        self.setupChallengeView()
        
        self.getMyPost { (newPosts) in
            
            self.insertNewRowsInCollectionNode(newPosts: newPosts)
            
        }
        
        delay(2) {
            self.hasLoaded = true
        }
       
    }
    
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Hide the Navigation Bar

        self.navigationController?.setNavigationBarHidden(true, animated: animated)
        
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
        navigationBarAppearance.backgroundColor = .background
        navigationBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        navigationBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]

        self.navigationController?.navigationBar.standardAppearance = navigationBarAppearance
        self.navigationController?.navigationBar.scrollEdgeAppearance = navigationBarAppearance
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Show the Navigation Bar

        self.navigationController?.setNavigationBarHidden(false, animated: animated)
      
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        ChallengeView.frame = challengeCardView.bounds
    }
    
    
    private func cell(collectionView: UICollectionView, indexPath: IndexPath, item: Item) -> UICollectionViewCell {
        switch item {
        case .header(_):
                
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ProfileHeaderCell.reuseIdentifier, for: indexPath) as? ProfileHeaderCell {
                // display username
                if let username = _AppCoreData.userDataSource.value?.userName, username != "" {
                    cell.usernameLbl.text = username
                }
                
                if let avatarUrl = _AppCoreData.userDataSource.value?.avatarURL, avatarUrl != "" {
                    let url = URL(string: avatarUrl)
                    cell.avatarImage.load(url: url!, str: avatarUrl)
                    selectAvatarImage.load(url: url!, str: avatarUrl)
                } else {
                    cell.avatarImage.image = UIImage.init(named: "defaultuser")
                    selectAvatarImage.image = UIImage.init(named: "defaultuser")
                }
                
                if let coverUrl = _AppCoreData.userDataSource.value?.cover, coverUrl != "" {
                    let url = URL(string: coverUrl)
                    cell.coverImage.load(url: url!, str: coverUrl)
                    selectCoverImage.load(url: url!, str: coverUrl)
                }
               
                if let discord = _AppCoreData.userDataSource.value?.discordUrl, discord != "" {
                    cell.discordLbl.isHidden = true
                    cell.discordChecked.isHidden = false
                } else {
                    cell.discordLbl.text = "None"
                }
                
                if let about = _AppCoreData.userDataSource.value?.about {
                    cell.descriptionLbl.text = about
                }
                

                cell.numberOfFollowers.text = "\(formatPoints(num: Double(followerCount)))"
                cell.numberOfFollowing.text = "\(formatPoints(num: Double(followingCount)))"
                cell.numberOfFistBumps.text = "\(formatPoints(num: Double(fistBumpedCount)))"
                
                // add buttons target
                cell.editBtn.addTarget(self, action: #selector(settingTapped), for: .touchUpInside)
                cell.fistBumpedListBtn.addTarget(self, action: #selector(fistBumpedlistTapped), for: .touchUpInside)
                cell.discordBtn.addTarget(self, action: #selector(discordTapped), for: .touchUpInside)
                cell.FistBumpedBtn.addTarget(self, action: #selector(fistBumpedTapped), for: .touchUpInside)
                cell.editProfileBtn.addTarget(self, action: #selector(editProfileTapped), for: .touchUpInside)
                
                // add target using gesture recognizer for image
                let avatarTap = UITapGestureRecognizer(target: self, action: #selector(ProfileViewController.avatarTapped))
                cell.avatarImage.isUserInteractionEnabled = true
                cell.avatarImage.addGestureRecognizer(avatarTap)
                
                let coverImageTap = UITapGestureRecognizer(target: self, action: #selector(ProfileViewController.coverImageTapped))
                cell.coverImage.isUserInteractionEnabled = true
                cell.coverImage.addGestureRecognizer(coverImageTap)
                
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
            
        case .challengeCard(_):
            
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ChallengerCardProfileHeaderCell.reuseIdentifier, for: indexPath) as? ChallengerCardProfileHeaderCell {
                
                // display username
                if let username = _AppCoreData.userDataSource.value?.userName, username != "" {
                    cell.username.text = username
                    ChallengeView.username.text = username
                }
                
                if let avatarUrl = _AppCoreData.userDataSource.value?.avatarURL, avatarUrl != "" {
                    let url = URL(string: avatarUrl)
                    cell.userImgView.load(url: url!, str: avatarUrl)
                    ChallengeView.userImgView.load(url: url!, str: avatarUrl)
                } else {
                    cell.userImgView.image = UIImage.init(named: "defaultuser")
                    ChallengeView.userImgView.image = UIImage.init(named: "defaultuser")
                    
                }
                
                ChallengeView.badgeWidth.constant = cell.badgeWidth.constant
                
                if let card = _AppCoreData.userDataSource.value?.challengeCard
                {
                    if card.quote != "" {
                        cell.infoLbl.text = card.quote
                        ChallengeView.infoLbl.text = card.quote
                    } else {
                        cell.infoLbl.text = "Stitchboxer"
                        ChallengeView.infoLbl.text = "Stitchboxer"
                    }
                   
                    if let createAt = _AppCoreData.userDataSource.value?.createdAt  {
                        let DateFormatter = DateFormatter()
                        DateFormatter.dateStyle = .medium
                        DateFormatter.timeStyle = .none
                        cell.startTime.text = DateFormatter.string(from: createAt)
                        ChallengeView.startTime.text = DateFormatter.string(from: createAt)
                    } else {
                        cell.startTime.text = "None"
                        ChallengeView.startTime.text = "None"
                    }
                    
                    cell.badgeImgView.image = UIImage.init(named: card.badge)
                    ChallengeView.badgeImgView.image = UIImage.init(named: card.badge)
                    
    
                        if card.games.isEmpty == true {
                            cell.game1.isHidden = false
                            cell.game2.isHidden = true
                            cell.game3.isHidden = true
                            cell.game4.isHidden = true
                            
                            //
                            
                            ChallengeView.game1.isHidden = false
                            ChallengeView.game2.isHidden = true
                            ChallengeView.game3.isHidden = true
                            ChallengeView.game4.isHidden = true
                            
                        
                        } else {
                            
                            if card.games.count == 1 {
                                
                                cell.game1.isHidden = false
                                cell.game2.isHidden = false
                                cell.game3.isHidden = true
                                cell.game4.isHidden = true
                              
                                //
                                
                                ChallengeView.game1.isHidden = false
                                ChallengeView.game2.isHidden = false
                                ChallengeView.game3.isHidden = true
                                ChallengeView.game4.isHidden = true
                                
                                if let empty = URL(string: emptyimage) {
                                    
                                    let game1 = global_suppport_game_list.first(where: { $0._id == card.games[0].gameId })
                                  
                                    cell.game1.setImageWithCache(from: URL(string: game1?.cover ?? "") ?? empty)
                                    cell.game2.setImage(UIImage(named: "game_add"), for: .normal)
                                    
                                    ChallengeView.game1.setImageWithCache(from: URL(string: game1?.cover ?? "") ?? empty)
                                    ChallengeView.game2.setImage(UIImage(named: "game_add"), for: .normal)
                                }
                               
                                
                                
                            } else if card.games.count == 2 {
                                
                                cell.game1.isHidden = false
                                cell.game2.isHidden = false
                                cell.game3.isHidden = false
                                cell.game4.isHidden = true
                               
                                
                                
                                ChallengeView.game1.isHidden = false
                                ChallengeView.game2.isHidden = false
                                ChallengeView.game3.isHidden = false
                                ChallengeView.game4.isHidden = true
                                
                                if let empty = URL(string: emptyimage) {
                                    
                                    let game1 = global_suppport_game_list.first(where: { $0._id == card.games[0].gameId })
                                    let game2 = global_suppport_game_list.first(where: { $0._id == card.games[1].gameId })
                                    
                                    cell.game1.setImageWithCache(from: URL(string: game1?.cover ?? "") ?? empty)
                                    cell.game2.setImageWithCache(from: URL(string: game2?.cover ?? "") ?? empty)
                                    cell.game3.setImage(UIImage(named: "game_add"), for: .normal)
                                    
                                    ChallengeView.game1.setImageWithCache(from: URL(string: game1?.cover ?? "") ?? empty)
                                    ChallengeView.game2.setImageWithCache(from: URL(string: game2?.cover ?? "") ?? empty)
                                    ChallengeView.game3.setImage(UIImage(named: "game_add"), for: .normal)
                                }
                                
                                
                            } else if card.games.count == 3 {
                                
                                cell.game1.isHidden = false
                                cell.game2.isHidden = false
                                cell.game3.isHidden = false
                                cell.game4.isHidden = false
                                
                                ChallengeView.game1.isHidden = false
                                ChallengeView.game2.isHidden = false
                                ChallengeView.game3.isHidden = false
                                ChallengeView.game4.isHidden = false
                                
                                
                                if let empty = URL(string: emptyimage) {
                                    
                                    let game1 = global_suppport_game_list.first(where: { $0._id == card.games[0].gameId })
                                    let game2 = global_suppport_game_list.first(where: { $0._id == card.games[1].gameId })
                                    let game3 = global_suppport_game_list.first(where: { $0._id == card.games[2].gameId })
                                    
                                    
                                    cell.game1.setImageWithCache(from: URL(string: game1?.cover ?? "") ?? empty)
                                    cell.game2.setImageWithCache(from: URL(string: game2?.cover ?? "") ?? empty)
                                    cell.game3.setImageWithCache(from: URL(string: game3?.cover ?? "") ?? empty)
                                    cell.game4.setImage(UIImage(named: "game_add"), for: .normal)
                                    
                                    ChallengeView.game1.setImageWithCache(from: URL(string: game1?.cover ?? "") ?? empty)
                                    ChallengeView.game2.setImageWithCache(from: URL(string: game2?.cover ?? "") ?? empty)
                                    ChallengeView.game3.setImageWithCache(from: URL(string: game3?.cover ?? "") ?? empty)
                                    ChallengeView.game4.setImage(UIImage(named: "game_add"), for: .normal)
                                }
                                
                                
                            } else if card.games.count == 4 {
                                
                               
                                if let empty = URL(string: emptyimage) {
                                    
                                    let game1 = global_suppport_game_list.first(where: { $0._id == card.games[0].gameId })
                                    let game2 = global_suppport_game_list.first(where: { $0._id == card.games[1].gameId })
                                    let game3 = global_suppport_game_list.first(where: { $0._id == card.games[2].gameId })
                                    let game4 = global_suppport_game_list.first(where: { $0._id == card.games[3].gameId })
                                
                                    cell.game1.setImageWithCache(from: URL(string: game1?.cover ?? "") ?? empty)
                                    cell.game2.setImageWithCache(from: URL(string: game2?.cover ?? "") ?? empty)
                                    cell.game3.setImageWithCache(from: URL(string: game3?.cover ?? "") ?? empty)
                                    cell.game4.setImageWithCache(from: URL(string: game4?.cover ?? "") ?? empty)
                                    
                                    ChallengeView.game1.setImageWithCache(from: URL(string: game1?.cover ?? "") ?? empty)
                                    ChallengeView.game2.setImageWithCache(from: URL(string: game2?.cover ?? "") ?? empty)
                                    ChallengeView.game3.setImageWithCache(from: URL(string: game3?.cover ?? "") ?? empty)
                                    ChallengeView.game4.setImageWithCache(from: URL(string: game4?.cover ?? "") ?? empty)
                                }
                                
                            }
                            
                            
                        
                    }
                  
                    
                }
                
                
                let fullString = NSMutableAttributedString(string: "")
                let image1Attachment = NSTextAttachment()
                image1Attachment.image = UIImage(named: "fistBumpedStats")
                image1Attachment.bounds = CGRect(x: 0, y: -2, width: 30, height: 12)
                let image1String = NSAttributedString(attachment: image1Attachment)
                fullString.append(image1String)
                
                
                fullString.append(NSAttributedString(string: "  \(formatPoints(num: Double(fistBumpedCount)))"))
                cell.fistBumpedLbl.attributedText = fullString
                ChallengeView.fistBumpedLbl.attributedText = fullString

                cell.EditChallenge.addTarget(self, action: #selector(editCardTapped), for: .touchUpInside)
                cell.game1.addTarget(self, action: #selector(game1Tapped), for: .touchUpInside)
                cell.game2.addTarget(self, action: #selector(game2Tapped), for: .touchUpInside)
                cell.game3.addTarget(self, action: #selector(game3Tapped), for: .touchUpInside)
                cell.game4.addTarget(self, action: #selector(game4Tapped), for: .touchUpInside)
                
                
                ChallengeView.game1.addTarget(self, action: #selector(game1Tapped), for: .touchUpInside)
                ChallengeView.game2.addTarget(self, action: #selector(game2Tapped), for: .touchUpInside)
                ChallengeView.game3.addTarget(self, action: #selector(game3Tapped), for: .touchUpInside)
                ChallengeView.game4.addTarget(self, action: #selector(game4Tapped), for: .touchUpInside)
                
                return cell
                
            } else {
                
            
                return ChallengerCardProfileHeaderCell()
                
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
    
   
    
    
    func setupChallengeView() {
    
        self.challengeCardView.addSubview(ChallengeView)
        
        
        let size = (self.view.bounds.width - 40) * (40/388)
        let cornerRadius = size/2
        
        ChallengeView.gameWidth.constant = size
        ChallengeView.gameHeight.constant = size
        
      
        ChallengeView.game1.layer.cornerRadius = cornerRadius
        ChallengeView.game2.layer.cornerRadius = cornerRadius
        ChallengeView.game3.layer.cornerRadius = cornerRadius
        ChallengeView.game4.layer.cornerRadius = cornerRadius
    
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
                    self.reloadGetFistBumperCount {
                        self.applyAllChange()
                        Dispatch.main.async {
                            self.pullControl.endRefreshing()
                        }
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
    
    
    @objc func fistBumpedlistTapped(_ sender: UIButton) {
     
        if let MFBVC = UIStoryboard(name: "Dashboard", bundle: nil).instantiateViewController(withIdentifier: "MainFistBumpListVC") as? MainFistBumpVC {
            MFBVC.hidesBottomBarWhenPushed = true
            hideMiddleBtn(vc: self)
            self.navigationController?.pushViewController(MFBVC, animated: true)
            
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
    
    @objc func fistBumpedTapped(_ sender: UIButton) {
        
        if let FBSVC = UIStoryboard(name: "Dashboard", bundle: nil).instantiateViewController(withIdentifier: "FistBumpedStatVC") as? FistBumpedStatVC {
            FBSVC.hidesBottomBarWhenPushed = true
            hideMiddleBtn(vc: self)
            self.navigationController?.pushViewController(FBSVC, animated: true)
            
        }
        
    }
    
    @objc func avatarTapped(sender: AnyObject!) {
  
        showFullScreenAvatar()
  
    }
    
    @objc func coverImageTapped(sender: AnyObject!) {
  
        showFullScreenCover()
  
    }
    
}

// selector for challengeCard
extension ProfileViewController {
    
    @objc func editCardTapped(_ sender: UIButton) {
        
        if let ECCVC = UIStoryboard(name: "Dashboard", bundle: nil).instantiateViewController(withIdentifier: "EditChallengeCardVC") as? EditChallengeCardVC {
        
            ECCVC.hidesBottomBarWhenPushed = true
            hideMiddleBtn(vc: self)
            ECCVC.fistBumpedCount = fistBumpedCount
            self.navigationController?.pushViewController(ECCVC, animated: true)
            
        }
        
    }
    
    @objc func game1Tapped(_ sender: UIButton) {
        // make sure to check if any game is added unless peform adding game for +

        if let card = _AppCoreData.userDataSource.value?.challengeCard, let username = _AppCoreData.userDataSource.value?.userName
        {
            
            if card.games.isEmpty == true {
                
                //AddGameVC
                if let AGVC = UIStoryboard(name: "Dashboard", bundle: nil).instantiateViewController(withIdentifier: "AddGameVC") as? AddGameVC {
                    AGVC.hidesBottomBarWhenPushed = true
                    hideMiddleBtn(vc: self)
                    
                    if let games = _AppCoreData.userDataSource.value?.challengeCard?.games
                    {
                        AGVC.gameList = games
                        
                    }
                    
                    self.navigationController?.pushViewController(AGVC, animated: true)
                    
                }
                
            } else {
                
                if let game = card.games.first {
                    
                    let alert = UIAlertController(title: "Hey \(username)!", message: "We've verified all the attached links for validity and authenticity. Your device's default browser will protect you from harmful links. We're committed to keeping the community safe and urge you to report any attempts to harm you or other users through this method.", preferredStyle: UIAlertController.Style.actionSheet)
                    
                    // add the actions (buttons)
                    alert.addAction(UIAlertAction(title: "Confirm to open", style: UIAlertAction.Style.default, handler: { action in
                        
                        
                        self.openLink(link: game.link)
                        
                    }))
                    
                    alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                    
                }
                
                
            }
            
        }
        
    }
    
    @objc func game2Tapped(_ sender: UIButton) {
        
        if let card = _AppCoreData.userDataSource.value?.challengeCard, let username = _AppCoreData.userDataSource.value?.userName
        {
            
            if card.games.count >= 2 {
                
                let game = card.games[1]
                
                let alert = UIAlertController(title: "Hey \(username)!", message: "We've verified all the attached links for validity and authenticity. Your device's default browser will protect you from harmful links. We're committed to keeping the community safe and urge you to report any attempts to harm you or other users through this method.", preferredStyle: UIAlertController.Style.actionSheet)

                                // add the actions (buttons)
                alert.addAction(UIAlertAction(title: "Confirm to open", style: UIAlertAction.Style.default, handler: { action in
                                    
                                
                    self.openLink(link: game.link)
                                    
                }))

                alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil))
                self.present(alert, animated: true, completion: nil)
                
            } else {
                
                //AddGameVC
                if let AGVC = UIStoryboard(name: "Dashboard", bundle: nil).instantiateViewController(withIdentifier: "AddGameVC") as? AddGameVC {
                    AGVC.hidesBottomBarWhenPushed = true
                    hideMiddleBtn(vc: self)
                    
                    if let games = _AppCoreData.userDataSource.value?.challengeCard?.games
                    {
                        AGVC.gameList = games
                        
                    }
                    
                    self.navigationController?.pushViewController(AGVC, animated: true)
                    
                }
                
            }
            
            
        }
        
    }
    
    @objc func game3Tapped(_ sender: UIButton) {
        
        if let card = _AppCoreData.userDataSource.value?.challengeCard, let username = _AppCoreData.userDataSource.value?.userName
        {
            
            if card.games.count >= 3 {
                
                let game = card.games[2]
                
                let alert = UIAlertController(title: "Hey \(username)!", message: "We've verified all the attached links for validity and authenticity. Your device's default browser will protect you from harmful links. We're committed to keeping the community safe and urge you to report any attempts to harm you or other users through this method.", preferredStyle: UIAlertController.Style.actionSheet)

                                // add the actions (buttons)
                alert.addAction(UIAlertAction(title: "Confirm to open", style: UIAlertAction.Style.default, handler: { action in
                                    
                                
                    self.openLink(link: game.link)
                                    
                }))

                alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil))
                self.present(alert, animated: true, completion: nil)
                
            } else {
                
                //AddGameVC
                if let AGVC = UIStoryboard(name: "Dashboard", bundle: nil).instantiateViewController(withIdentifier: "AddGameVC") as? AddGameVC {
                    AGVC.hidesBottomBarWhenPushed = true
                    hideMiddleBtn(vc: self)
                    
                    if let games = _AppCoreData.userDataSource.value?.challengeCard?.games
                    {
                        AGVC.gameList = games
                        
                    }
                    
                    self.navigationController?.pushViewController(AGVC, animated: true)
                    
                }
                
            }
            
            
        }
        
    }
    
    @objc func game4Tapped(_ sender: UIButton) {
        
        if let card = _AppCoreData.userDataSource.value?.challengeCard, let username = _AppCoreData.userDataSource.value?.userName
        {
            
            if card.games.count >= 4 {
                
                let game = card.games[3]
                
                
                let alert = UIAlertController(title: "Hey \(username)!", message: "We've verified all the attached links for validity and authenticity. Your device's default browser will protect you from harmful links. We're committed to keeping the community safe and urge you to report any attempts to harm you or other users through this method.", preferredStyle: UIAlertController.Style.actionSheet)

                                // add the actions (buttons)
                alert.addAction(UIAlertAction(title: "Confirm to open", style: UIAlertAction.Style.default, handler: { action in
                                    
                                
                    self.openLink(link: game.link)
                                    
                }))

                alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil))

                self.present(alert, animated: true, completion: nil)

                
            } else {
                
                //AddGameVC
                if let AGVC = UIStoryboard(name: "Dashboard", bundle: nil).instantiateViewController(withIdentifier: "AddGameVC") as? AddGameVC {
                    AGVC.hidesBottomBarWhenPushed = true
                    hideMiddleBtn(vc: self)
                    
                    if let games = _AppCoreData.userDataSource.value?.challengeCard?.games
                    {
                        AGVC.gameList = games
                        
                    }
                    
                    self.navigationController?.pushViewController(AGVC, animated: true)
                    
                }
                
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
        let headerItem = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(480)))
        let headerGroup = NSCollectionLayoutGroup.horizontal(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(480)), subitems: [headerItem])
        
        let section = NSCollectionLayoutSection(group: headerGroup)
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
        
        return section
    }

    func createChallengeCardSection() -> NSCollectionLayoutSection {
        let headerItem = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0)))
        let headerGroup = NSCollectionLayoutGroup.horizontal(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(236)), subitems: [headerItem])
        headerGroup.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 20, bottom: 0, trailing: 20)
        
        let section = NSCollectionLayoutSection(group: headerGroup)
        section.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 0, bottom: 0, trailing: 0)
        
        return section
    }


    
    func createPhotosSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                              heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                               heightDimension: .fractionalWidth(1/3))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 3)
        
        let section = NSCollectionLayoutSection(group: group)
        
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
        case .challengeCard:
            return createChallengeCardSection()
        case .posts:
            return createPhotosSection()
        }
    }
    
    private func supplementary(collectionView: UICollectionView, kind: String, indexPath: IndexPath) -> UICollectionReusableView {
        return collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: ProfilePostsHeaderView.reuseIdentifier, for: indexPath)
    }
    
    func snapshot() -> Snapshot {
        var snapshot = Snapshot()

        snapshot.appendSections([.header, .challengeCard, .posts])
        snapshot.appendItems([.header(profileData)], toSection: .header)
        snapshot.appendItems([.challengeCard(challengeData)], toSection: .challengeCard)

        return snapshot
    }
    

}

extension ProfileViewController: UICollectionViewDelegate {
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let item = datasource.itemIdentifier(for: indexPath)
       
        switch item {
            case .header(_):
                print("header")
                
            case .challengeCard(_):
                
                print("challengeCard")
                showFullScreenChallengeCard()
                
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
    
    func showFullScreenChallengeCard() {
        
        if challengeCardView.isHidden {
        
            self.backgroundView.isHidden = false
            self.challengeCardView.alpha = 1.0
            
            UIView.transition(with: challengeCardView, duration: 0.5, options: .transitionCrossDissolve, animations: {
                
                self.challengeCardView.isHidden = false
                
            })
            
        }
        
    }
    
    func showFullScreenAvatar() {
        
        if selectAvatarImage.image != nil {
            
            if selectAvatarImage.isHidden {
            
                self.backgroundView.isHidden = false
                self.selectAvatarImage.alpha = 1.0
                
                UIView.transition(with: selectAvatarImage, duration: 0.5, options: .transitionCrossDissolve, animations: {
                    
                    self.selectAvatarImage.isHidden = false
                    
                })
                
            }
            
        } else {
            
            if let EPVC = UIStoryboard(name: "Dashboard", bundle: nil).instantiateViewController(withIdentifier: "EditPhofileVC") as? EditPhofileVC {
                EPVC.hidesBottomBarWhenPushed = true
                hideMiddleBtn(vc: self)
                self.navigationController?.pushViewController(EPVC, animated: true)
                
            }
            
        }
        
    }
    
    
    func showFullScreenCover() {
        
        if selectCoverImage.image != nil {
            
            if selectCoverImage.isHidden {
            
                self.backgroundView.isHidden = false
                self.selectCoverImage.alpha = 1.0
                
                UIView.transition(with: selectCoverImage, duration: 0.5, options: .transitionCrossDissolve, animations: {
                    
                    self.selectCoverImage.isHidden = false
                    
                })
                
            }
            
        } else {
            
            if let EPVC = UIStoryboard(name: "Dashboard", bundle: nil).instantiateViewController(withIdentifier: "EditPhofileVC") as? EditPhofileVC {
                EPVC.hidesBottomBarWhenPushed = true
                hideMiddleBtn(vc: self)
                self.navigationController?.pushViewController(EPVC, animated: true)
                
            }
            
        }
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        if challengeCardView.isHidden == false {
            
            let touch = touches.first
            guard let location = touch?.location(in: self.view) else { return }
            if !challengeCardView.frame.contains(location) {
                
                
                UIView.animate(withDuration: 0.3, animations: {
                    self.challengeCardView.alpha = 0
                }) { (finished) in
                    self.challengeCardView.isHidden = finished
                    self.backgroundView.isHidden = true
                }
              
            }
                
        } else if selectAvatarImage.isHidden == false {
            
            let touch = touches.first
            guard let location = touch?.location(in: self.view) else { return }
            if !selectAvatarImage.frame.contains(location) {
                
                
                UIView.animate(withDuration: 0.3, animations: {
                    self.selectAvatarImage.alpha = 0
                }) { (finished) in
                    self.selectAvatarImage.isHidden = finished
                    self.backgroundView.isHidden = true
                }
              
            }
                
        } else if selectCoverImage.isHidden == false {
            
            let touch = touches.first
            guard let location = touch?.location(in: self.view) else { return }
            if !selectCoverImage.frame.contains(location) {
                
                
                UIView.animate(withDuration: 0.3, animations: {
                    self.selectCoverImage.alpha = 0
                }) { (finished) in
                    self.selectCoverImage.isHidden = finished
                    self.backgroundView.isHidden = true
                }
              
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

//setting up navigationCollection Bar
extension ProfileViewController: UINavigationBarDelegate, UINavigationControllerDelegate {
    
    func wireDelegate() {
        self.navigationController?.navigationBar.delegate = self
    }
    
    func position(for bar: UIBarPositioning) -> UIBarPosition {
        return .topAttached
    }
}

extension ProfileViewController {
    
    func getFollowing() {
      
        APIManager().getFollows(page:1) { result in
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
      
        APIManager().getFollowers(page: 1) { result in
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
    func getFistBumperCount(userID: String =  _AppCoreData.userDataSource.value?.userID ?? "") {
       
        APIManager().getFistBumperCount(userID: userID){
            result in
            switch result {
            case .success(let response):
                
                guard response.body?["message"] as? String == "success",
                      let data = response.body?["paging"] as? [String: Any] else {
                    self.fistBumpedCount = 0
       
                    return
                }
            
                if let fistBumpedGet = data["total"] as? Int {
                    self.fistBumpedCount = fistBumpedGet
                } else {
                    self.fistBumpedCount = 0
                }
                
                self.applyHeaderChange()
                
            case .failure(let error):
                print("Error loading fistbumpers: ", error)
                self.fistBumpedCount = 0
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
            updatedSnapshot.reloadSections([.header, .challengeCard, .posts])
            self.datasource.apply(updatedSnapshot, animatingDifferences: false)
        }
    
    }
    
    func applyUIChange() {
        
        Dispatch.main.async {
            var updatedSnapshot = self.datasource.snapshot()
            updatedSnapshot.reloadSections([.header, .challengeCard])
            self.datasource.apply(updatedSnapshot, animatingDifferences: false)
        }
        
        
    }
    
    
    func reloadUserInformation(completed: @escaping DownloadComplete) {

        APIManager().getme { result in
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
      
        APIManager().getFollows(page:1) { result in
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
      
        APIManager().getFollowers(page: 1) { result in
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
    func reloadGetFistBumperCount(userID: String =  _AppCoreData.userDataSource.value?.userID ?? "", completed: @escaping DownloadComplete) {
       
        APIManager().getFistBumperCount(userID: userID){
            result in
            switch result {
            case .success(let response):
                
                guard response.body?["message"] as? String == "success",
                      let data = response.body?["paging"] as? [String: Any] else {
                    self.fistBumpedCount = 0
                    completed()
                    return
                }
            
                if let fistBumpedGet = data["total"] as? Int {
                    self.fistBumpedCount = fistBumpedGet
                } else {
                    self.fistBumpedCount = 0
                }
                
                completed()
                
            case .failure(let error):
                print("Error loading fistbumpers: ", error)
                self.fistBumpedCount = 0
                completed()
            }
        }
    }
    
    
    
}




