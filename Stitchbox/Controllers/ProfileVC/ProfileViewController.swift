//
//  ProfileViewController.swift
//  Stitchbox
//
//  Created by Hisoft Hoangnm on 15/12/2022.
//

import UIKit

class ProfileViewController: UIViewController {
    
    enum Section: Hashable {
        case header
        case challengeCard
        case posts
    }

    enum Item: Hashable {
        case header(ProfileHeaderData)
        case challengeCard(ChallengeCardHeaderData)
        case posts(postThumbnail)
    }

    typealias Datasource = UICollectionViewDiffableDataSource<Section, Item>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Item>
    
    private var datasource: Datasource!
    
    @IBOutlet weak var collectionView: UICollectionView!
    var pullControl = UIRefreshControl()

    var demoProfileData: ProfileHeaderData {
        return ProfileHeaderData(name: "Planet Pennies", accountType: "News/Entertainment Company", postCount: 482)
    }
    
    var demoChallengeData: ChallengeCardHeaderData {
        return ChallengeCardHeaderData(name: "Planet Pennies", accountType: "News/Entertainment Company", postCount: 482)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
  
       
        
        pullControl.tintColor = UIColor.secondary
        //pullControl.addTarget(self, action: #selector(refreshListData(_:)), for: .valueChanged)
        
        if #available(iOS 10.0, *) {
            collectionView.refreshControl = pullControl
        } else {
            collectionView.addSubview(pullControl)
        }
        
        collectionView.setCollectionViewLayout(createLayout(), animated: true)
        collectionView.register(ProfilePostsHeaderView.nib, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: ProfilePostsHeaderView.reuseIdentifier)
        collectionView.register(ImageViewCell.self, forCellWithReuseIdentifier: ImageViewCell.reuseIdentifier)
        
        configureDatasource()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Hide the Navigation Bar
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Show the Navigation Bar
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    
    private func cell(collectionView: UICollectionView, indexPath: IndexPath, item: Item) -> UICollectionViewCell {
        switch item {
        case .header(_):
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ProfileHeaderCell.reuseIdentifier, for: indexPath) as? ProfileHeaderCell {
                
                
                cell.editBtn.addTarget(self, action: #selector(settingTapped), for: .touchUpInside)
                return cell
                
            } else {
                
            
                return ProfileHeaderCell()
                
            }
            
        case .challengeCard(_):
            
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ChallengerCardProfileHeaderCell.reuseIdentifier, for: indexPath) as? ChallengerCardProfileHeaderCell {
                
                return cell
                
            } else {
                
            
                return ChallengerCardProfileHeaderCell()
                
            }
            
        case .posts(let data):
            
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

// selector
extension ProfileViewController {
    
    @objc func settingTapped(_ sender: UIButton) {
        
        if let SettingVC = UIStoryboard(name: "Dashboard", bundle: nil).instantiateViewController(withIdentifier: "SettingViewController") as? SettingViewController {
            self.navigationController?.pushViewController(SettingVC, animated: true)
            
        }
        
        
    }
    
    
}

extension ProfileViewController {
    
    func createHeaderSection() -> NSCollectionLayoutSection {
        let headerItem = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0)))
        let headerGroup = NSCollectionLayoutGroup.horizontal(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(0.70)), subitems: [headerItem])
        
        return NSCollectionLayoutSection(group: headerGroup)
    }
    
    func createChallengeCardSection() -> NSCollectionLayoutSection {
        let headerItem = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(self.view.bounds.height * (300/896))))
        let headerGroup = NSCollectionLayoutGroup.horizontal(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(0.35)), subitems: [headerItem])
        headerGroup.contentInsets = .init(top: 8, leading: 20, bottom: 0, trailing: 20)
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
        snapshot.appendItems([.header(demoProfileData)], toSection: .header)
        snapshot.appendItems([.challengeCard(demoChallengeData)], toSection: .challengeCard)
        snapshot.appendItems(postThumbnail.demoPhotos.map({ Item.posts($0) }), toSection: .posts)
        return snapshot
    }
    

}
