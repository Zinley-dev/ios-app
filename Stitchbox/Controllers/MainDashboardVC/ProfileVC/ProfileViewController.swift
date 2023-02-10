//
//  ProfileViewController.swift
//  Stitchbox
//
//  Created by Hisoft Hoangnm on 15/12/2022.
//

import UIKit
import RxSwift
import RxCocoa

class ProfileViewController: UIViewController {
    typealias ViewModelType = ProfileViewModel
    // MARK: - Properties
    private var viewModel: ViewModelType! = ViewModelType()
    private let disposeBag = DisposeBag()
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
        return ProfileHeaderData(name: "Defaults", accountType: "Defaults/Public")
    }
    
    var challengeData: ChallengeCardHeaderData {
        return ChallengeCardHeaderData(name: "Defaults")
    }
    
    func bindingUI() {
      
        viewModel.output.myPostObservable.subscribe(onNext: { posts in
            if posts.count == 10 {
                self.currpage += 1
            }
          DispatchQueue.main.async {
            var snapshot = self.datasource.snapshot()
              let items = snapshot.itemIdentifiers(inSection: .posts)
              if items.count > 0 {
                  if case Item.posts(let param) = items[items.count - 1] {
                      if param.imageUrl != posts[posts.count - 1].imageUrl {
                          snapshot.appendItems(posts.map({ Item.posts($0) }), toSection: .posts)
                          self.datasource.apply(snapshot, animatingDifferences: true)
                      }
                  }
              } else {
                  snapshot.appendItems(posts.map({ Item.posts($0) }), toSection: .posts)
                  self.datasource.apply(snapshot, animatingDifferences: true)
                  
              }
              self.pullControl.endRefreshing()
              
              
            
          }
        })
      
      
        viewModel.output.followersObservable.subscribe(onNext: { count in
            let indexPath = IndexPath(item: 0, section: 0);
            DispatchQueue.main.async {
                if let cell = self.datasource.itemIdentifier(for: indexPath) {
                    if case .header(var param) = cell {
                        if (param.followers != count) {
                            param.followers = count
                            var snapshot = self.datasource.snapshot()
                            // replace item
                            snapshot.insertItems([.header(param)], beforeItem: cell)
                            snapshot.deleteItems([cell])
                            // update datasource
                            self.datasource.apply(snapshot)
                        }
                    }
                }
            }
        })
        viewModel.output.followingObservable.subscribe(onNext: { count in
            let indexPath = IndexPath(item: 0, section: 0);
            DispatchQueue.main.async {
                if let cell = self.datasource.itemIdentifier(for: indexPath) {
                    if case .header(var param) = cell {
                        if (param.following != count) {
                            param.following = count
                            var snapshot = self.datasource.snapshot()
                            // replace item
                            snapshot.insertItems([.header(param)], beforeItem: cell)
                            snapshot.deleteItems([cell])
                            // update datasource
                            self.datasource.apply(snapshot)
                        }
                    }
                }
            }
        })
    }
    
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
        wireDelegate()
        bindingUI()
        oldTabbarFr = self.tabBarController?.tabBar.frame ?? .zero
        // Load follwer, follwing
        viewModel.getFollowers()
        viewModel.getMyPost(page: currpage)
        viewModel.getFollowing()
        
        self.setupChallengeView()
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Hide the Navigation Bar
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
        navigationController?.hidesBarsOnSwipe = false        
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
        case .header(let param):
                
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ProfileHeaderCell.reuseIdentifier, for: indexPath) as? ProfileHeaderCell {
                // display username
                if let username = _AppCoreData.userDataSource.value?.userName, username != "" {
                    cell.usernameLbl.text = username
                }
                if let avatarUrl = _AppCoreData.userDataSource.value?.avatarURL, avatarUrl != "" {
                    let url = URL(string: avatarUrl)
                    cell.avatarImage.load(url: url!, str: avatarUrl)
                    selectAvatarImage.load(url: url!, str: avatarUrl)
                }
                if let coverUrl = _AppCoreData.userDataSource.value?.cover, coverUrl != "" {
                    let url = URL(string: coverUrl)
                    cell.coverImage.load(url: url!, str: coverUrl)
                    selectCoverImage.load(url: url!, str: coverUrl)
                }
               
                if let discord = _AppCoreData.userDataSource.value?.discordUrl, discord != "" {
                    cell.discordLbl.text = discord
                } else {
                    cell.discordLbl.text = "None"
                }
                
                if let about = _AppCoreData.userDataSource.value?.about {
                    cell.descriptionLbl.text = about
                }
                
                
                followerCount = param.followers
                followingCount = param.following
               
                cell.numberOfFollowers.text = "\(formatPoints(num: Double(param.followers)))"
                cell.numberOfFollowing.text = "\(formatPoints(num: Double(param.following)))"
                
                
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
                }
                if let avatarUrl = _AppCoreData.userDataSource.value?.avatarURL, avatarUrl != "" {
                    let url = URL(string: avatarUrl)
                    cell.userImgView.load(url: url!, str: avatarUrl)
                    ChallengeView.userImgView.load(url: url!, str: avatarUrl)
                }
                if let card = _AppCoreData.userDataSource.value?.challengeCard {
                    cell.infoLbl.text = card.quote
                }
                

                cell.EditChallenge.addTarget(self, action: #selector(editCardTapped), for: .touchUpInside)
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
extension ProfileViewController {
    
    @objc func refreshListData(_ sender: Any) {
        print("REFRESH....")
        // Load follwer, follwing
        viewModel.getFollowers()
        viewModel.getMyPost(page: 1)
        viewModel.getFollowing()
        
//        DispatchQueue.main.async {
//            self.pullControl.endRefreshing()
//        }
    }
    
    @objc func settingTapped(_ sender: UIButton) {
        
        if let SVC = UIStoryboard(name: "Dashboard", bundle: nil).instantiateViewController(withIdentifier: "SettingVC") as? SettingVC {
            
            //self.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(SVC, animated: true)
            
        }
        
    }
    
    
    @objc func fistBumpedlistTapped(_ sender: UIButton) {
        
        print("fistBumpedlistTapped")
    
        //MainFistBumpVC
        if let MFBVC = UIStoryboard(name: "Dashboard", bundle: nil).instantiateViewController(withIdentifier: "MainFistBumpListVC") as? MainFistBumpVC {
            //self.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(MFBVC, animated: true)
            
        }
       
    }
    
    @objc func followersTapped(_ sender: UIButton) {
        
        print("followersTapped")
        
        if let MFVC = UIStoryboard(name: "Dashboard", bundle: nil).instantiateViewController(withIdentifier: "MainFollowVC") as? MainFollowVC {
            //self.hidesBottomBarWhenPushed = true
            MFVC.showFollowerFirst = true
            MFVC.followerCount = followerCount
            MFVC.followingCount = followingCount
            self.navigationController?.pushViewController(MFVC, animated: true)
            
        }
        
    }
    
    
    @objc func followingTapped(_ sender: UIButton) {
        
        print("followingTapped")
        
        if let MFVC = UIStoryboard(name: "Dashboard", bundle: nil).instantiateViewController(withIdentifier: "MainFollowVC") as? MainFollowVC {
            //self.hidesBottomBarWhenPushed = true
            MFVC.showFollowerFirst = false
            MFVC.followerCount = followerCount
            MFVC.followingCount = followingCount
            self.navigationController?.pushViewController(MFVC, animated: true)
            
        }
        
    }

    
    @objc func editProfileTapped(_ sender: UIButton) {
        
        if let EPVC = UIStoryboard(name: "Dashboard", bundle: nil).instantiateViewController(withIdentifier: "EditPhofileVC") as? EditPhofileVC {
            //self.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(EPVC, animated: true)
            
        }
    
    }
    
    @objc func discordTapped(_ sender: UIButton) {
        
        print("discordTapped - open link discord if have unless ask let user input their discord link")
        
    }
    
    @objc func fistBumpedTapped(_ sender: UIButton) {
        
        if let FBSVC = UIStoryboard(name: "Dashboard", bundle: nil).instantiateViewController(withIdentifier: "FistBumpedStatVC") as? FistBumpedStatVC {
            //self.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(FBSVC, animated: true)
            
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
    
}

// selector for challengeCard
extension ProfileViewController {
    
    @objc func editCardTapped(_ sender: UIButton) {
        
        if let ECCVC = UIStoryboard(name: "Dashboard", bundle: nil).instantiateViewController(withIdentifier: "EditChallengeCardVC") as? EditChallengeCardVC {
            //self.hidesBottomBarWhenPushed = true
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

extension ProfileViewController {
    
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
                
                let snap = datasource.snapshot().itemIdentifiers(inSection: .posts)
                var selectedPost = [PostModel]()
                
                for test in snap {
                    switch test {
                    case .posts(let p):
                        selectedPost.append(p)
                    default:
                        break
                   
                    }
                }
            

            if let SPVC = UIStoryboard(name: "Dashboard", bundle: nil).instantiateViewController(withIdentifier: "SelectedPostVC") as? SelectedPostVC {
                SPVC.selectedPost = selectedPost
                SPVC.startIndex = indexPath.row
                //self.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(SPVC, animated: true)
            }
          

             
            case .none:
                print("None")
        }
        
        
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        let item = datasource.itemIdentifier(for: indexPath)
       
        switch item {
            case .header(_):
                print("header")
                
            case .challengeCard(_):
                
                print("challengeCard")
                //showFullScreenChallengeCard()
                
            case .posts(_):
                
                let snap = datasource.snapshot().itemIdentifiers(inSection: .posts)
                if indexPath.row == snap.count - 5 {
                    
                    print("Load next")
                    
                }
        
            case .none:
                print("None")
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

//setting up navigationCollection Bar
extension ProfileViewController: UINavigationBarDelegate, UINavigationControllerDelegate {
    
    func wireDelegate() {
        self.navigationController?.navigationBar.delegate = self
    }
    
    func position(for bar: UIBarPositioning) -> UIBarPosition {
        return .topAttached
    }
    
    
}
