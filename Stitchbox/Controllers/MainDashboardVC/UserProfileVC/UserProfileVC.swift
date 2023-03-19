//
//  UserProfileVC.swift
//  Stitchbox
//
//  Created by Khoi Nguyen on 1/25/23.
//

import UIKit
import ObjectMapper

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
    var ChallengeView = ChallengeCard()
    var pullControl = UIRefreshControl()
    var onPresent = false

    var demoProfileData: ProfileHeaderData {
        return ProfileHeaderData(name: "", username: "", accountType: "", postCount: 0)
    }
    
    var demoChallengeData: ChallengeCardHeaderData {
        return ChallengeCardHeaderData(name: "")
    }
    
    var userId: String?
    var nickname: String?
    var userData: UserDataSource?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
  
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
        self.setupButtons()
        loadUserData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
    }
  
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        ChallengeView.frame = challengeCardView.bounds
    }
    
  private func loadUserData() {
      
    APIManager().getUserInfo(userId: self.userId!) { result in
      switch result {
        case .success(let response):
          guard let data = response.body else {
            return
          }
          
          self.userData = Mapper<UserDataSource>().map(JSONObject: data)
          
          let indexPath = IndexPath(item: 0, section: 0);
          let index2Path = IndexPath(item: 0, section: 1);
          
          DispatchQueue.main.async {
            if let cell = self.datasource.itemIdentifier(for: indexPath) {
              if case .header(var param) = cell {
                param.username = self.userData?.userName ?? ""
                param.discord = self.userData?.discordUrl ?? "None"
                param.cover = self.userData?.cover ?? ""
                param.avatar = self.userData?.avatarURL ?? ""
                param.about = self.userData?.about ?? ""
                param.followers = 10
                param.following = 20
                param.fistBumped = 30
                
                
                var snapshot = self.datasource.snapshot()
                // replace item
                snapshot.insertItems([.header(param)], beforeItem: cell)
                snapshot.deleteItems([cell])
                // update datasource
                self.datasource.apply(snapshot)
                
              }
            }
            
            if let cell2 = self.datasource.itemIdentifier(for: index2Path) {
              if case .challengeCard(var param) = cell2 {
                param.name = self.userData?.userName ?? ""
                param.avatar = self.userData?.avatarURL ?? ""
                param.quotes = self.userData?.challengeCard?.quote
                
                
                var snapshot = self.datasource.snapshot()
                // replace item
                snapshot.insertItems([.challengeCard(param)], beforeItem: cell2)
                snapshot.deleteItems([cell2])
                // update datasource
                self.datasource.apply(snapshot)
                
              }
            }
          }

        case .failure(let error):
          print(error)
      }
    }
  }
    
    private func cell(collectionView: UICollectionView, indexPath: IndexPath, item: Item) -> UICollectionViewCell {
      
        switch item {
        case .header(let param):
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: UserProfileHeaderCell.reuseIdentifier, for: indexPath) as? UserProfileHeaderCell {
                
                cell.usernameLbl.text = param.username
                cell.descriptionLbl.text = param.about ?? ""
                
                
                if let avatarUrl = param.avatar, avatarUrl != "" {
                  if let url = URL(string: avatarUrl) {
                    cell.avatarImage.load(url: url, str: avatarUrl)
                    selectAvatarImage.load(url: url, str: avatarUrl)
                  }
                    
                }
              
                if let coverUrl = param.cover, coverUrl != "" {
                  if let url = URL(string: coverUrl) {
                    cell.coverImage.load(url: url, str: coverUrl)
                    selectCoverImage.load(url: url, str: coverUrl)
                  }
                }
              
                  if let discord = param.discord, discord != "" {
                    cell.discordBtn.setTitle("Added and verified", for: .normal)
                  } else {
                    cell.discordBtn.setTitle("None", for: .normal)
                  }
              
            
                cell.numberOfFollowers.text = "\(formatPoints(num: Double(param.followers)))"
                cell.numberOfFollowing.text = "\(formatPoints(num: Double(param.following)))"
                cell.FistBumpedBtn.setTitle("\(formatPoints(num: Double(param.fistBumped)))", for: .normal)
                
              
                // add buttons target
                cell.discordBtn.addTarget(self, action: #selector(discordTapped), for: .touchUpInside)
                cell.FistBumpedBtn.addTarget(self, action: #selector(fistBumpedTapped), for: .touchUpInside)
                cell.followersBtn.addTarget(self, action: #selector(followersTapped), for: .touchUpInside)
                cell.messageBtn.addTarget(self, action: #selector(messageTapped), for: .touchUpInside)
                cell.moreBtn.addTarget(self, action: #selector(moreTapped), for: .touchUpInside)
               
                
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
                
            
                return UserProfileHeaderCell()
                
            }
            
        case .challengeCard(let param):
            
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: UserChallengerCardProfileHeaderCell.reuseIdentifier, for: indexPath) as? UserChallengerCardProfileHeaderCell {
            
              
              // display username
              if let username = param.name, username != "" {
                cell.username.text = username
                ChallengeView.username.text = username
              }
              
              if let avatarUrl = param.avatar, avatarUrl != "" {
                let url = URL(string: avatarUrl)
                cell.userImgView.load(url: url!, str: avatarUrl)
                ChallengeView.userImgView.load(url: url!, str: avatarUrl)
              }
              
              
              if let quotes = param.quotes, quotes != "" {
                cell.infoLbl.text = quotes
              }
              
              
              cell.startTime.text = param.createdDate
              cell.infoLbl.text = "xxxx"
              
              
              
              
                cell.game1.addTarget(self, action: #selector(game1Tapped), for: .touchUpInside)
                cell.game2.addTarget(self, action: #selector(game2Tapped), for: .touchUpInside)
                cell.game3.addTarget(self, action: #selector(game3Tapped), for: .touchUpInside)
                cell.game4.addTarget(self, action: #selector(game4Tapped), for: .touchUpInside)
                
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
extension UserProfileVC {
    
    @objc func settingTapped(_ sender: UIButton) {
        
        if let SVC = UIStoryboard(name: "Dashboard", bundle: nil).instantiateViewController(withIdentifier: "SettingVC") as? SettingVC {
            self.navigationController?.pushViewController(SVC, animated: true)
            
        }
        
    }
    
    
    @objc func messageTapped(_ sender: UIButton) {
        
        print("messageTapped")
        
        print("Init message or open message if have")
        
    }
    
    
    @objc func moreTapped(_ sender: UIButton) {
        
        print("moreTapped")
        
        print("Show more settings")
        
    }
    
    @objc func followersTapped(_ sender: UIButton) {
        
        print("followersTapped")
        
        if let MFVC = UIStoryboard(name: "Dashboard", bundle: nil).instantiateViewController(withIdentifier: "MainFollowVC") as? MainFollowVC {
            self.navigationController?.pushViewController(MFVC, animated: true)
            
        }
        
    }
    
    @objc func followingTapped(_ sender: UIButton) {
        //MainFollowVC
       print("followingTapped")
        
        if let MFVC = UIStoryboard(name: "Dashboard", bundle: nil).instantiateViewController(withIdentifier: "MainFollowVC") as? MainFollowVC {
            self.navigationController?.pushViewController(MFVC, animated: true)
            
        }
        
    }
    
    @objc func editProfileTapped(_ sender: UIButton) {
        
        if let EPVC = UIStoryboard(name: "Dashboard", bundle: nil).instantiateViewController(withIdentifier: "EditPhofileVC") as? EditPhofileVC {
            self.navigationController?.pushViewController(EPVC, animated: true)
            
        }
    
    }
    
    @objc func discordTapped(_ sender: UIButton) {
        
        print("discordTapped - open link discord if have unless ask let user input their discord link")
        
    }
    
    @objc func fistBumpedTapped(_ sender: UIButton) {
        
        print("fistBumpedTapped - Animation for fistbumped")
        
    }
    
    @objc func avatarTapped(sender: AnyObject!) {
  
        print("avatarTapped")
        showFullScreenAvatar()
  
    }
    
    @objc func coverImageTapped(sender: AnyObject!) {
  
        print("coverImageTapped")
        showFullScreenCover()
  
    }
    
}

// selector for challengeCard
extension UserProfileVC {
    
    @objc func editCardTapped(_ sender: UIButton) {
        
        if let ECCVC = UIStoryboard(name: "Dashboard", bundle: nil).instantiateViewController(withIdentifier: "EditChallengeCardVC") as? EditChallengeCardVC {
            self.navigationController?.pushViewController(ECCVC, animated: true)
            
        }
        
    }
    
    @objc func game1Tapped(_ sender: UIButton) {
        // make sure to check if any game is added unless peform adding game for +
        print("game1Tapped")
        
    }
    
    @objc func game2Tapped(_ sender: UIButton) {
        
        print("game2Tapped")
        
    }
    
    @objc func game3Tapped(_ sender: UIButton) {
        
        print("game3Tapped")
        
    }
    
    @objc func game4Tapped(_ sender: UIButton) {
        
        print("game4Tapped")
        
    }
    
}


extension UserProfileVC {
    
    func createHeaderSection() -> NSCollectionLayoutSection {
        let headerItem = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(480)))
        let headerGroup = NSCollectionLayoutGroup.horizontal(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(480)), subitems: [headerItem])
        
        return NSCollectionLayoutSection(group: headerGroup)
    }
    
    func createChallengeCardSection() -> NSCollectionLayoutSection {
        let headerItem = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0)))
        let headerGroup = NSCollectionLayoutGroup.horizontal(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(226)), subitems: [headerItem])
        headerGroup.contentInsets = .init(top: 0, leading: 20, bottom: 0, trailing: 20)
        return NSCollectionLayoutSection(group: headerGroup)
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

            case .none:
                print("None")
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
        
        if selectAvatarImage.isHidden {
        
            self.backgroundView.isHidden = false
            self.selectAvatarImage.alpha = 1.0
            
            UIView.transition(with: selectAvatarImage, duration: 0.5, options: .transitionCrossDissolve, animations: {
                
                self.selectAvatarImage.isHidden = false
                
            })
            
        }
        
    }
    
    
    func showFullScreenCover() {
        
        if selectCoverImage.isHidden {
        
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
        
        
        // Do any additional setup after loading the view.
        backButton.setImage(UIImage.init(named: "back_icn_white")?.resize(targetSize: CGSize(width: 13, height: 23)), for: [])
        backButton.addTarget(self, action: #selector(onClickBack(_:)), for: .touchUpInside)
        backButton.frame = back_frame
        backButton.setTitleColor(UIColor.white, for: .normal)
        backButton.setTitle("", for: .normal)
        backButton.sizeToFit()
        let backButtonBarButton = UIBarButtonItem(customView: backButton)
        
        self.navigationItem.leftBarButtonItem = backButtonBarButton
        
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
        
        
               
    }
    
}
