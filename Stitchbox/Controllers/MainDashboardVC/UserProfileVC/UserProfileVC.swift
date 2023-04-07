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

class UserProfileVC: UIViewController {

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
    
    let backButton: UIButton = UIButton(type: .custom)
    
    typealias Datasource = UICollectionViewDiffableDataSource<Section, Item>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Item>
    
    private var datasource: Datasource!
    
    @IBOutlet weak var selectAvatarImage: UIImageView!
    @IBOutlet weak var selectCoverImage: UIImageView!
    @IBOutlet weak var challengeCardView: UIView!
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var loadingImage: FLAnimatedImageView!
    @IBOutlet weak var loadingView: UIView!
    
    var ChallengeView = ChallengeCard()
    var pullControl = UIRefreshControl()
    var onPresent = false
    var allowProcess = true
    var allowFistBumped = true
    var followerCount = 0
    var followingCount = 0
    var fistBumpedCount = 0
    var firstAnimated = true
    var isFollow = false
    var isFistBump = false

    var demoProfileData: ProfileHeaderData {
        return ProfileHeaderData(name: "", username: "", accountType: "", postCount: 0)
    }
    
    var demoChallengeData: ChallengeCardHeaderData {
        return ChallengeCardHeaderData(name: "")
    }
    
    var userId: String?
    var nickname: String?
    var userData: UserDataSource?
    var currpage = 1
    
    let fistBumpedImg = UIImage(named: "fistBumpedStats")
    let fistBumpImg = UIImage(named: "FistBumped")
    
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
           
            
            self.setupChallengeView()
        
            self.loadUserData()
           
            self.setupChallengeView()
            
           
            
            NotificationCenter.default.addObserver(self, selector: #selector(UserProfileVC.copyProfile), name: (NSNotification.Name(rawValue: "copy_user")), object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(UserProfileVC.report), name: (NSNotification.Name(rawValue: "report_user")), object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(UserProfileVC.block), name: (NSNotification.Name(rawValue: "block_user")), object: nil)
            
            
        }

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
        if !loadingView.isHidden {
            
            do {
                
                let path = Bundle.main.path(forResource: "fox2", ofType: "gif")!
                let gifData = try NSData(contentsOfFile: path) as Data
                let image = FLAnimatedImage(animatedGIFData: gifData)
                
                
                self.loadingImage.animatedImage = image
                
            } catch {
                print(error.localizedDescription)
            }
            
            loadingView.backgroundColor = self.view.backgroundColor
            
        }
        

        
        
        let navigationBarAppearance = UINavigationBarAppearance()
        navigationBarAppearance.configureWithOpaqueBackground()
        navigationBarAppearance.backgroundColor = .background
        navigationBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        navigationBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]

        self.navigationController?.navigationBar.standardAppearance = navigationBarAppearance
        self.navigationController?.navigationBar.scrollEdgeAppearance = navigationBarAppearance
        
    }

    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        ChallengeView.frame = challengeCardView.bounds
        
    }
    
    private func cell(collectionView: UICollectionView, indexPath: IndexPath, item: Item) -> UICollectionViewCell {
        switch item {
        case .header(_):
                
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: UserProfileHeaderCell.reuseIdentifier, for: indexPath) as? UserProfileHeaderCell {
                
                if let data = userData {
                    
                    // display username
                    if let username = data.userName, username != "" {
                        cell.usernameLbl.text = username
                        navigationItem.title = username
                    }
                    
                    if data.avatarURL != "" {
                        
                        let url = URL(string: data.avatarURL)
                        cell.avatarImage.load(url: url!, str: data.avatarURL)
                        selectAvatarImage.load(url: url!, str: data.avatarURL)
                        
                    } else {
                        
                        cell.avatarImage.image = UIImage.init(named: "defaultuser")
                        selectAvatarImage.image = UIImage.init(named: "defaultuser")
                        
                    }
                    
                    if data.cover != "" {
                        let url = URL(string: data.cover)
                        cell.coverImage.load(url: url!, str: data.cover)
                        selectCoverImage.load(url: url!, str: data.cover)
                    }
                    
                    if data.discordUrl != "" {
                        
                        cell.discordLbl.isHidden = true
                        cell.discordChecked.isHidden = false
                        
                    } else {
                        
                        cell.discordLbl.text = "None"
                        
                    }
                    
                    if data.about != "" {
                        cell.descriptionLbl.text = data.about
                    }
                    

                    cell.numberOfFollowers.text = "\(formatPoints(num: Double(followerCount)))"
                    cell.numberOfFollowing.text = "\(formatPoints(num: Double(followingCount)))"
                    cell.numberOfFistBumps.text = "\(formatPoints(num: Double(fistBumpedCount)))"
                    
                    // add buttons target
                    
                    cell.discordBtn.addTarget(self, action: #selector(discordTapped), for: .touchUpInside)
                    cell.FistBumpedBtn.addTarget(self, action: #selector(fistBumpedTapped), for: .touchUpInside)
                    cell.moreBtn.addTarget(self, action: #selector(moreTapped), for: .touchUpInside)
                    cell.followersBtn.addTarget(self, action: #selector(followAction), for: .touchUpInside)
                    cell.messageBtn.addTarget(self, action: #selector(messageTapped), for: .touchUpInside)
                   
                    
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
                    
                    if self.isFollow {
                        cell.followersBtn.setTitle("Following", for: .normal)
                    } else {
                        cell.followersBtn.setTitle("Follow", for: .normal)
                    }
                    
                    if self.isFistBump {
                        cell.fistBumpImage.image = fistBumpedImg
                    } else {
                        cell.fistBumpImage.image = fistBumpImg
                    }
                    
                }
                
                
                return cell
                
            } else {
                
            
                return UserProfileHeaderCell()
                
            }
            
        case .challengeCard(_):
            
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: UserChallengerCardProfileHeaderCell.reuseIdentifier, for: indexPath) as? UserChallengerCardProfileHeaderCell {
                
                if let data = userData {
                    
                    // display username
                    if data.userName != "" {
                        cell.username.text = data.userName
                        ChallengeView.username.text = data.userName
                    } else {
                        print("userData is null")
                    }
                    
                    if data.avatarURL != "" {
                        
                        let url = URL(string: data.avatarURL)
                        cell.userImgView.load(url: url!, str: data.avatarURL)
                        ChallengeView.userImgView.load(url: url!, str: data.avatarURL)
                        
                    } else {
                        cell.userImgView.image = UIImage.init(named: "defaultuser")
                        ChallengeView.userImgView.image = UIImage.init(named: "defaultuser")
                    }
                    
                }
                
                ChallengeView.badgeWidth.constant = cell.badgeWidth.constant
                
                if let card = userData?.challengeCard
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
                            cell.game1.isHidden = true
                            cell.game2.isHidden = true
                            cell.game3.isHidden = true
                            cell.game4.isHidden = true
                            
                            //
                            
                            ChallengeView.game1.isHidden = true
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
                                    cell.game2.isHidden = true
                                    
                                    ChallengeView.game1.setImageWithCache(from: URL(string: game1?.cover ?? "") ?? empty)
                                    ChallengeView.game2.isHidden = true
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
                                    cell.game3.isHidden = true
                                    
                                    ChallengeView.game1.setImageWithCache(from: URL(string: game1?.cover ?? "") ?? empty)
                                    ChallengeView.game2.setImageWithCache(from: URL(string: game2?.cover ?? "") ?? empty)
                                    ChallengeView.isHidden = true
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
                                    cell.game4.isHidden = true
                                    
                                    ChallengeView.game1.setImageWithCache(from: URL(string: game1?.cover ?? "") ?? empty)
                                    ChallengeView.game2.setImageWithCache(from: URL(string: game2?.cover ?? "") ?? empty)
                                    ChallengeView.game3.setImageWithCache(from: URL(string: game3?.cover ?? "") ?? empty)
                                    ChallengeView.game4.isHidden = true
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
                
            
                return UserChallengerCardProfileHeaderCell()
                
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
            
            APIManager().insertFollows(params: ["FollowId": userId ?? ""]) { result in
                switch result {
                case .success(_):
                  
                    self.allowProcess = true
                    self.isFollow = true
                    needRecount = true
                    Dispatch.main.async {
                        self.reloadPost()
                    }
                  
                  
                case .failure(let error):
                    
                    print(error)
                    
                    DispatchQueue.main.async {
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
        
                APIManager().unFollow(params: ["FollowId": userId ?? ""]) { result in
                    switch result {
                    case .success(_):
                        
                        self.isFollow = false
                        needRecount = true
                        self.allowProcess = true
                        
                        Dispatch.main.async {
                            self.reloadPost()
                        }
                        
                    case .failure(let error):
                        
                        print(error)
                        
                        DispatchQueue.main.async {
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
        

        SBDGroupChannel.createChannel(with: channelParams) { groupChannel, error in
            guard error == nil, let channelUrl = groupChannel?.channelUrl else {
                self.showErrorAlert("Oops!", msg: error?.localizedDescription ?? "Failed to create message")
                return
            }

            checkForChannelInvitation(channelUrl: channelUrl, user_ids: [self.userId ?? ""])

            let channelVC = ChannelViewController(channelUrl: channelUrl, messageListParams: nil)
            
            self.navigationController?.setNavigationBarHidden(false, animated: true)
            self.hidesBottomBarWhenPushed = false
            self.navigationController?.pushViewController(channelVC, animated: true)
            
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
    
    
    @objc func discordTapped(_ sender: UIButton) {
        
        if let discord = userData?.discordUrl, discord != "" {
            
            if let username = _AppCoreData.userDataSource.value?.userName {
                
                let alert = UIAlertController(title: "Hey \(username)!", message: "We've verified all the attached links for validity and authenticity. Your device's default browser will protect you from harmful links. We're committed to keeping the community safe and urge you to report any attempts to harm you or other users through this method.", preferredStyle: UIAlertController.Style.actionSheet)

                                // add the actions (buttons)
                alert.addAction(UIAlertAction(title: "Confirm to open", style: UIAlertAction.Style.default, handler: { action in
                                    
                                
                    self.openLink(link: discord)
                                    
                }))

                alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil))
                self.present(alert, animated: true, completion: nil)
                
            }
           
        }
        
    }
    
    @objc func fistBumpedTapped(_ sender: UIButton) {
        
        if isFistBump {
            
            unfistBump()
            
        } else {
            
            giveFistBump()
            
        }
        
    }
    
    @objc func avatarTapped(sender: AnyObject!) {
  
        print("avatarTapped")
        showFullScreenAvatar()
  
    }
    
    @objc func coverImageTapped(sender: AnyObject!) {
  
        print("coverImageTapped")
        showFullScreenCover()
  
    }
    
    func giveFistBump() {
        
        if allowFistBumped {
            
            fistBumpedAnimation()
            self.allowFistBumped = false
            self.isFistBump = true
            fistBumpedCount += 1
            self.applyUIChange()
            
            APIManager().addFistBump(userID: self.userId!) { result in
                switch result {
                case .success(_):
                    
                    self.isFistBump = true
                    self.allowFistBumped = true
                   
                case .failure(_):
                    DispatchQueue.main.async {
                        self.isFistBump = false
                        self.allowFistBumped = true
                        self.fistBumpedCount -= 1
                        self.applyUIChange()
                        showNote(text: "Something happened!")
                    }
                    
                    
                }
            }
            
            
        }
        
        
    }
    
    func unfistBump() {
        
        
        if allowFistBumped {
            
            
            self.isFistBump = false
            self.allowFistBumped = false
            fistBumpedCount -= 1
            self.applyUIChange()
            
            APIManager().deleteFistBump(userID: self.userId!) { result in
                switch result {
                case .success(_):
                    
                    self.isFistBump = false
                    self.allowFistBumped = true
                   
                case .failure(_):
                    DispatchQueue.main.async {
                        self.allowFistBumped = true
                        self.isFistBump = true
                        self.fistBumpedCount += 1
                        self.applyUIChange()
                        showNote(text: "Something happened!")
                    }
                    
                    
                }
            }
            
            
        }
        
        
        
    }
    
    func fistBumpedAnimation() {
        
        let imgView = UIImageView()
        imgView.image = UIImage(named: "fistBumpedStats")
        imgView.frame.size = CGSize(width: 170, height: 120)
       
        imgView.center = self.view.center
        self.view.addSubview(imgView)
        
        
        imgView.transform = CGAffineTransform.identity
        
        UIView.animate(withDuration: 1.0) {
            
            imgView.alpha = 0
            
        }
        
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            
            if imgView.alpha == 0 {
                
                imgView.removeFromSuperview()
                
            }
            
        }
        
    }

    
}

// selector for challengeCard
extension UserProfileVC {

    
    @objc func game1Tapped(_ sender: UIButton) {
        // make sure to check if any game is added unless peform adding game for +

        if let card = userData?.challengeCard
        {
            
            if card.games.isEmpty == true {
               
            } else {
                
                let game = card.games[0]
                
                if let username = _AppCoreData.userDataSource.value?.userName {
                    
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
        
        if let card = userData?.challengeCard
        {
            
            if card.games.count >= 2 {
                
                let game = card.games[1]
                
                if let username = _AppCoreData.userDataSource.value?.userName {
                    
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
    
    @objc func game3Tapped(_ sender: UIButton) {
        
        if let card = userData?.challengeCard
        {
            
            if card.games.count >= 3 {
                
                let game = card.games[2]
                
                if let username = _AppCoreData.userDataSource.value?.userName {
                    
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
    
    @objc func game4Tapped(_ sender: UIButton) {
        
        if let card = userData?.challengeCard
        {
            
            if card.games.count >= 4 {
                
                let game = card.games[3]
                
                if let username = _AppCoreData.userDataSource.value?.userName {
                    
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


extension UserProfileVC {
    
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

extension UserProfileVC {
    
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
        snapshot.appendItems([.header(demoProfileData)], toSection: .header)
        snapshot.appendItems([.challengeCard(demoChallengeData)], toSection: .challengeCard)
        return snapshot
    }
    

}

extension UserProfileVC: UICollectionViewDelegate {
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        
        let item = datasource.itemIdentifier(for: indexPath)
        
        switch item {
            case .header(_):
                print("header")
                
            case .challengeCard(_):
                
                print("challengeCard")
                showFullScreenChallengeCard()
                
            case .posts(_):
                
                print("posts")
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
                    self.navigationController?.setNavigationBarHidden(false, animated: true)
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

// handle challenge card was tapped
extension UserProfileVC {
    
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
        
        if selectAvatarImage.isHidden, selectAvatarImage != nil {
        
            self.backgroundView.isHidden = false
            self.selectAvatarImage.alpha = 1.0
            
            UIView.transition(with: selectAvatarImage, duration: 0.5, options: .transitionCrossDissolve, animations: {
                
                self.selectAvatarImage.isHidden = false
                
            })
            
        }
        
    }
    
    
    func showFullScreenCover() {
        
        if selectCoverImage.isHidden, selectCoverImage.image != nil {
        
            self.backgroundView.isHidden = false
            self.selectCoverImage.alpha = 1.0
            
            UIView.transition(with: selectCoverImage, duration: 0.5, options: .transitionCrossDissolve, animations: {
                
                self.selectCoverImage.isHidden = false
                
            })
            
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
    
    
    
    
}


extension UserProfileVC {
    
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
        
        navigationItem.title = nickname
        
    }
    
    
    @objc func onClickBack(_ sender: AnyObject) {
        
        NotificationCenter.default.removeObserver(self, name: (NSNotification.Name(rawValue: "copy_user")), object: nil)
        NotificationCenter.default.removeObserver(self, name: (NSNotification.Name(rawValue: "report_user")), object: nil)
        NotificationCenter.default.removeObserver(self, name: (NSNotification.Name(rawValue: "block_user")), object: nil)
        
        
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
    
    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
       if scrollView.panGestureRecognizer.translation(in: scrollView).y < 0 {
          navigationController?.setNavigationBarHidden(true, animated: true)
       } else {
          navigationController?.setNavigationBarHidden(false, animated: true)
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
        checkIfFistBump()
    
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
  
        APIManager().getUserInfo(userId: self.userId!) { result in
          switch result {
            case .success(let response):
              guard let data = response.body else {
                return
              }
              
              self.userData = Mapper<UserDataSource>().map(JSONObject: data)
              self.applyUIChange()
              self.hideAnimation()
              
              self.countFistBumped()
              self.countFollowings()
              self.countFollowers()
              self.checkIfFollow()
              self.checkIfFistBump()
            
              self.getUserPost { (newPosts) in
                  
                  self.insertNewRowsInCollectionNode(newPosts: newPosts)
                  
              }
              
            case .failure(_):
              
              Dispatch.main.async {
                  self.hideAnimation()
                  self.NoticeBlockAndDismiss()
              }
           
          }
        }
      }
    
    func countFollowers() {
        
        APIManager().getFollowers(userId: userId, page: 1) { result in
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
        
        APIManager().getFollows(userId: userId, page:1) { result in
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
    
    
    func countFistBumped() {
        
        APIManager().getFistBumperCount(userID: userId ?? ""){
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
                
                self.applyUIChange()
                
            case .failure(let error):
                print("Error loading fistbumpers: ", error)
                self.fistBumpedCount = 0
            }
        }
        
        
    }
    
    func getUserPost(block: @escaping ([[String: Any]]) -> Void) {

        APIManager().getUserPost(userId: self.userId ?? "", page: currpage) { result in
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
        
        APIManager().isFollowing(uid: userId ?? "") { result in
                switch result {
                case .success(let apiResponse):
                    
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
    
    func checkIfFistBump() {
        
        
        APIManager().isFistBumpee(userID: userId ?? "") { result in
                switch result {
                case .success(let apiResponse):
                    
                    guard let isFistBump = apiResponse.body?["data"] as? Bool else {
                        return
                    }
                    
                    self.isFistBump = isFistBump
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
    
}

extension UserProfileVC {
    
    func reloadUserInformation(completed: @escaping DownloadComplete) {

        APIManager().getUserInfo(userId: self.userId!) { result in
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
    
    
    func reloadGetFollowing(completed: @escaping DownloadComplete) {
      
        APIManager().getFollows(userId: userId, page:1) { result in
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
      
        APIManager().getFollowers(userId: userId, page: 1) { result in
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
    func reloadGetFistBumperCount(completed: @escaping DownloadComplete) {
       
        APIManager().getFistBumperCount(userID: userId ?? ""){
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
            
            let link = "https://stitchbox.gg/app/account/?uid=\(id)"
            
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
        global_presetingRate = Double(0.75)
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
                
                APIManager().insertBlocks(params: ["blockId": uid]) { result in
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
            
            
            NotificationCenter.default.removeObserver(self, name: (NSNotification.Name(rawValue: "copy_user")), object: nil)
            NotificationCenter.default.removeObserver(self, name: (NSNotification.Name(rawValue: "report_user")), object: nil)
            NotificationCenter.default.removeObserver(self, name: (NSNotification.Name(rawValue: "block_user")), object: nil)
            
            
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
