//
//  SB-ProfileVC.swift
//  Stitchbox
//
//  Created by Khoi Nguyen on 4/14/23.
//

import UIKit

class SB_ProfileVC: UIViewController, UICollectionViewDelegate {

    enum Section: Hashable {
        case profileHeader
        case history
    }

    enum Item: Hashable {
        case profileHeader(ChallengeCardHeaderData)
        case history(badgeThumbnail)
    }

    let backButton: UIButton = UIButton(type: .custom)
    let rightButton: UIButton = UIButton(type: .custom)
    
    typealias Datasource = UICollectionViewDiffableDataSource<Section, Item>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Item>
    
    private var datasource: Datasource!
    
    @IBOutlet weak var collectionView: UICollectionView!
   
    var demoChallengeData: ChallengeCardHeaderData {
        return ChallengeCardHeaderData(name: "Planet Pennies")
    }
    
   
    var pullControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupButtons()
        
        collectionView.delegate = self
       
        collectionView.setCollectionViewLayout(createLayout(), animated: true)
        collectionView.register(RiotHistoryView.nib, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: RiotHistoryView.reuseIdentifier)
        collectionView.register(ImageViewCell.self, forCellWithReuseIdentifier: ImageViewCell.reuseIdentifier)
        
        configureDatasource()
        
        pullControl.tintColor = UIColor.secondary
        pullControl.addTarget(self, action: #selector(refreshListData(_:)), for: .valueChanged)
        
        if #available(iOS 10.0, *) {
            collectionView.refreshControl = pullControl
        } else {
            collectionView.addSubview(pullControl)
        }
        
        
    }
    

    private func cell(collectionView: UICollectionView, indexPath: IndexPath, item: Item) -> UICollectionViewCell {
        switch item {
        case .profileHeader(_):
            
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: LOLProfileHeaderCell.reuseIdentifier, for: indexPath) as? LOLProfileHeaderCell {
            
                
                if let data = _AppCoreData.userDataSource.value?.riotLOLAccount {
                    
                    cell.region.text = data.region
                    cell.username.text = data.riotUsername
                    cell.level.text = "Level \(data.riotLevel)"
                    
                    if data.rank?.tier != "" {
                        cell.rank.text = "\(data.rank?.tier ?? "None") \(data.rank?.division ?? "0") - \(data.lp)LP"
                    } else {
                        cell.rank.text = ""
                    }
                 
                    
                    if data.riotProfileImage != "" {
                        let url = URL(string: data.riotProfileImage)
                        cell.iconImgView.load(url: url!, str: data.riotProfileImage)
                    } else {
                        cell.iconImgView.image = UIImage.init(named: "defaultuser")
                    }
                    
                    if data.rank?.tierImage != "" {
                        let url = URL(string: data.rank!.tierImage)
                        cell.rankImgView.load(url: url!, str: data.rank!.tierImage)
                    }
                    
                    cell.liveGame.addTarget(self, action: #selector(liveTacticsTapped), for: .touchUpInside)
                    cell.refresh.addTarget(self, action: #selector(refreshTapped), for: .touchUpInside)
                    cell.upgrade.addTarget(self, action: #selector(upgradeTapped), for: .touchUpInside)
                
                }

               
                return cell
                
            } else {
                
            
                return ChallengerCardProfileHeaderCell()
                
            }
            
        case .history(let data):
            
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ImageViewCell.reuseIdentifier, for: indexPath) as? ImageViewCell {
                
                cell.configure(with: data.image)
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


extension SB_ProfileVC {
    
    func setupButtons() {
        
        setupBackButton()
        setupRightButton()
        navigationItem.title = "League of Legends"
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
        let backButtonBarButton = UIBarButtonItem(customView: backButton)

        self.navigationItem.leftBarButtonItem = backButtonBarButton

  
    }
    
    
    func setupRightButton() {
    
        rightButton.frame = back_frame
        rightButton.contentMode = .center

        if let backImage = UIImage(named: "edit_challengeCard") {
            let imageSize = CGSize(width: 25, height: 25)
            let padding = UIEdgeInsets(top: (back_frame.height - imageSize.height) / 2,
                                       left: (back_frame.width - imageSize.width) / 2 + horizontalPadding,
                                       bottom: (back_frame.height - imageSize.height) / 2,
                                       right: (back_frame.width - imageSize.width) / 2 - horizontalPadding)
            rightButton.imageEdgeInsets = padding
            rightButton.setImage(backImage, for: [])
        }

        rightButton.addTarget(self, action: #selector(onClickEdit(_:)), for: .touchUpInside)
        rightButton.setTitleColor(UIColor.white, for: .normal)
    
        let rightButtonBarButton = UIBarButtonItem(customView: rightButton)

        self.navigationItem.rightBarButtonItem = rightButtonBarButton

  
    }

   
    @objc func onClickBack(_ sender: AnyObject) {
        if let navigationController = self.navigationController {
            navigationController.popViewController(animated: true)
        }
    }
    
    @objc func onClickEdit(_ sender: AnyObject) {
        if let navigationController = self.navigationController {
            if let RSVC = UIStoryboard(name: "Dashboard", bundle: nil).instantiateViewController(withIdentifier: "RiotSyncVC") as? RiotSyncVC {
               
                navigationController.pushViewController(RSVC, animated: true)
                
            }
        }
    }
    
}


extension SB_ProfileVC {
    
    func createProfileSection() -> NSCollectionLayoutSection {
        let headerItem = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0)))
        let headerGroup = NSCollectionLayoutGroup.horizontal(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(300)), subitems: [headerItem])
        headerGroup.contentInsets = .init(top: 0, leading: 0, bottom: 0, trailing: 0)
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

extension SB_ProfileVC {
    
    func sectionFor(index: Int, environment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
        let section = datasource.snapshot().sectionIdentifiers[index]
        
        switch section {
        case .profileHeader:
            return createProfileSection()
        case .history:
            return createPhotosSection()
        }
    }
    
    private func supplementary(collectionView: UICollectionView, kind: String, indexPath: IndexPath) -> UICollectionReusableView {
        return collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: RiotHistoryView.reuseIdentifier, for: indexPath)
    }
    
    func snapshot() -> Snapshot {
        var snapshot = Snapshot()

        snapshot.appendSections([.profileHeader, .history])
        snapshot.appendItems([.profileHeader(demoChallengeData)], toSection: .profileHeader)
     
        return snapshot
    }
    

}

extension SB_ProfileVC {
    
    //In_gameVC
    
    @objc func liveTacticsTapped(_ sender: UIButton) {
     
        if let IGVC = UIStoryboard(name: "Dashboard", bundle: nil).instantiateViewController(withIdentifier: "In_gameVC") as? In_gameVC {
           
            self.navigationController?.pushViewController(IGVC, animated: true)

        }
     
    }
    
    @objc func refreshTapped(_ sender: UIButton) {
        // make sure to check if any game is added unless peform adding game for +

        
    }
    
    @objc func upgradeTapped(_ sender: UIButton) {
        // make sure to check if any game is added unless peform adding game for +

        
    }
    
    
    @objc func refreshListData(_ sender: Any) {
    
        pullControl.endRefreshing()
       
    }
    
}


extension SB_ProfileVC {
    
    
    func showErrorAlert(_ title: String, msg: String) {
                                                                                                                                           
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        
                                                                                       
        present(alert, animated: true, completion: nil)
        
    }
    
}
