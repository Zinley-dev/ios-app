//
//  EditChallengeCardVC.swift
//  Stitchbox
//
//  Created by Khoi Nguyen on 1/19/23.
//

import UIKit

class EditChallengeCardVC: UIViewController, UICollectionViewDelegate {

    enum Section: Hashable {
        case challengeCard
        case badges
    }

    enum Item: Hashable {
        case challengeCard(ChallengeCardHeaderData)
        case badges(badgeThumbnail)
    }

    let backButton: UIButton = UIButton(type: .custom)
    
    typealias Datasource = UICollectionViewDiffableDataSource<Section, Item>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Item>
    
    private var datasource: Datasource!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var demoChallengeData: ChallengeCardHeaderData {
        return ChallengeCardHeaderData(name: "Planet Pennies")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupButtons()
        
        collectionView.delegate = self
       
        collectionView.setCollectionViewLayout(createLayout(), animated: true)
        collectionView.register(BadgesHeaderView.nib, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: BadgesHeaderView.reuseIdentifier)
        collectionView.register(ImageViewCell.self, forCellWithReuseIdentifier: ImageViewCell.reuseIdentifier)
        
        configureDatasource()
     
        
    }
    
    
    private func cell(collectionView: UICollectionView, indexPath: IndexPath, item: Item) -> UICollectionViewCell {
        switch item {
        case .challengeCard(_):
            
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ChallengerCardProfileHeaderCell.reuseIdentifier, for: indexPath) as? ChallengerCardProfileHeaderCell {
                
                cell.EditChallenge.addTarget(self, action: #selector(editCardTapped), for: .touchUpInside)
                cell.game1.addTarget(self, action: #selector(game1Tapped), for: .touchUpInside)
                cell.game2.addTarget(self, action: #selector(game2Tapped), for: .touchUpInside)
                cell.game3.addTarget(self, action: #selector(game3Tapped), for: .touchUpInside)
                cell.game4.addTarget(self, action: #selector(game4Tapped), for: .touchUpInside)
                
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


extension EditChallengeCardVC {
    
    func setupButtons() {
        
        setupBackButton()
    
    }
    
    
    func setupBackButton() {
        
        // Do any additional setup after loading the view.
        backButton.setImage(UIImage.init(named: "back_icn_white")?.resize(targetSize: CGSize(width: 13, height: 23)), for: [])
        backButton.addTarget(self, action: #selector(onClickBack(_:)), for: .touchUpInside)
        backButton.frame = CGRect(x: -10, y: 0, width: 15, height: 25)
        backButton.setTitleColor(UIColor.white, for: .normal)
        backButton.setTitle("     Edit Challenge Card", for: .normal)
        backButton.sizeToFit()
        let backButtonBarButton = UIBarButtonItem(customView: backButton)
    
        self.navigationItem.leftBarButtonItem = backButtonBarButton
       
    }
    
   
    @objc func onClickBack(_ sender: AnyObject) {
        if let navigationController = self.navigationController {
            navigationController.popViewController(animated: true)
        }
    }

    
}

// selector for challengeCard
extension EditChallengeCardVC {
    
    @objc func editCardTapped(_ sender: UIButton) {
        
        if let ESVC = UIStoryboard(name: "Dashboard", bundle: nil).instantiateViewController(withIdentifier: "EditSloganVC") as? EditSloganVC {
            self.navigationController?.pushViewController(ESVC, animated: true)
            
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


extension EditChallengeCardVC {
    
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

extension EditChallengeCardVC {
    
    func sectionFor(index: Int, environment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
        let section = datasource.snapshot().sectionIdentifiers[index]
        
        switch section {
        case .challengeCard:
            return createChallengeCardSection()
        case .badges:
            return createPhotosSection()
        }
    }
    
    private func supplementary(collectionView: UICollectionView, kind: String, indexPath: IndexPath) -> UICollectionReusableView {
        return collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: BadgesHeaderView.reuseIdentifier, for: indexPath)
    }
    
    func snapshot() -> Snapshot {
        var snapshot = Snapshot()

        snapshot.appendSections([.challengeCard, .badges])
        snapshot.appendItems([.challengeCard(demoChallengeData)], toSection: .challengeCard)
        snapshot.appendItems(badgeThumbnail.demoPhotos.map({ Item.badges($0) }), toSection: .badges)
        return snapshot
    }
    

}