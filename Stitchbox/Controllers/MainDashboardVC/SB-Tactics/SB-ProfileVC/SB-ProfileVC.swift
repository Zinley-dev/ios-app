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
        case badges
    }

    enum Item: Hashable {
        case profileHeader(ChallengeCardHeaderData)
        case badges(badgeThumbnail)
    }

    let backButton: UIButton = UIButton(type: .custom)
    
    typealias Datasource = UICollectionViewDiffableDataSource<Section, Item>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Item>
    
    private var datasource: Datasource!
    
    @IBOutlet weak var collectionView: UICollectionView!
   
    var fistBumpedCount = 0
   
    var demoChallengeData: ChallengeCardHeaderData {
        return ChallengeCardHeaderData(name: "Planet Pennies")
    }
    
    var didSelectIndex: IndexPath?
    var didSelect = false
    var bID: Int?
    var didCreateSave = false
  
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupButtons()
        
        collectionView.delegate = self
       
        collectionView.setCollectionViewLayout(createLayout(), animated: true)
        collectionView.register(BadgesHeaderView.nib, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: BadgesHeaderView.reuseIdentifier)
        collectionView.register(ImageViewCell.self, forCellWithReuseIdentifier: ImageViewCell.reuseIdentifier)
        
        configureDatasource()
        newSlogan = ""
        didChanged = false
        
    }
    

    private func cell(collectionView: UICollectionView, indexPath: IndexPath, item: Item) -> UICollectionViewCell {
        switch item {
        case .profileHeader(_):
            
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: LOLProfileHeaderCell.reuseIdentifier, for: indexPath) as? LOLProfileHeaderCell {
            

               
                return cell
                
            } else {
                
            
                return ChallengerCardProfileHeaderCell()
                
            }
            
        case .badges(let data):
            
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
        navigationItem.title = "League Of Legends"
        let backButtonBarButton = UIBarButtonItem(customView: backButton)

        self.navigationItem.leftBarButtonItem = backButtonBarButton

  
    }

   
    @objc func onClickBack(_ sender: AnyObject) {
        if let navigationController = self.navigationController {
            navigationController.popViewController(animated: true)
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
        case .badges:
            return createPhotosSection()
        }
    }
    
    private func supplementary(collectionView: UICollectionView, kind: String, indexPath: IndexPath) -> UICollectionReusableView {
        return collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: BadgesHeaderView.reuseIdentifier, for: indexPath)
    }
    
    func snapshot() -> Snapshot {
        var snapshot = Snapshot()

        snapshot.appendSections([.profileHeader, .badges])
        snapshot.appendItems([.profileHeader(demoChallengeData)], toSection: .profileHeader)
        snapshot.appendItems(badgeThumbnail.demoPhotos.map({ Item.badges($0) }), toSection: .badges)
        return snapshot
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
