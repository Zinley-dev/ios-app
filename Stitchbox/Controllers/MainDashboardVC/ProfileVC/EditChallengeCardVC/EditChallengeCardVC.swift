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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if newSlogan != "", !didChanged {
            didChanged = true
            Dispatch.main.async {
                var updatedSnapshot = self.datasource.snapshot()
                updatedSnapshot.reloadSections([.challengeCard])
                self.datasource.apply(updatedSnapshot, animatingDifferences: true)
            }
            
        }
        
    }
    
    
    private func cell(collectionView: UICollectionView, indexPath: IndexPath, item: Item) -> UICollectionViewCell {
        switch item {
        case .challengeCard(_):
            
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ChallengerCardProfileHeaderCell.reuseIdentifier, for: indexPath) as? ChallengerCardProfileHeaderCell {
            
                // display username
                if let username = _AppCoreData.userDataSource.value?.userName, username != "" {
                    cell.username.text = username
                }
                
                if let avatarUrl = _AppCoreData.userDataSource.value?.avatarURL, avatarUrl != "" {
                    let url = URL(string: avatarUrl)
                    cell.userImgView.load(url: url!, str: avatarUrl)
                }
                
                if let card = _AppCoreData.userDataSource.value?.challengeCard
                {
                    
                    if newSlogan != "" {
                        
                        cell.infoLbl.text = newSlogan
                        
                    } else {
                        
                        if card.quote != "" {
                            cell.infoLbl.text = card.quote
                        } else {
                            cell.infoLbl.text = "Stitchbox User"
                        }
                        
                    }
                   
                    
                    if let createAt = _AppCoreData.userDataSource.value?.createdAt  {
                      
                        let DateFormatter = DateFormatter()
                        DateFormatter.dateStyle = .medium
                        DateFormatter.timeStyle = .none
                        cell.startTime.text = DateFormatter.string(from: createAt)
                       
                    } else {
                        cell.startTime.text = "None"
                      
                    }
                    
                    if bID != nil {
                        let image = UIImage.init(named: "b\(bID!+1)")
                        cell.badgeImgView.image = image
                    } else {
                        cell.badgeImgView.image = UIImage.init(named: card.badge)
                    }
                    
                
                    if card.games.isEmpty == true {
                        cell.game1.isHidden = false
                        cell.game2.isHidden = true
                        cell.game3.isHidden = true
                        cell.game4.isHidden = true
               
                        
                    } else {
                        
                        if card.games.count == 1 {
                            
                            cell.game1.isHidden = false
                            cell.game2.isHidden = false
                            cell.game3.isHidden = true
                            cell.game4.isHidden = true
                            
                          
                            if let empty = URL(string: emptyimage) {
                                
                                let game1 = global_suppport_game_list.first(where: { $0._id == card.games[0].gameId })
                              
                                cell.game1.setImageWithCache(from: URL(string: game1?.cover ?? "") ?? empty)
                                cell.game2.setImage(UIImage(named: "game_add"), for: .normal)
                        
                            }
                            
                        } else if card.games.count == 2 {
                            
                            cell.game1.isHidden = false
                            cell.game2.isHidden = false
                            cell.game3.isHidden = false
                            cell.game4.isHidden = true
                            
                            if let empty = URL(string: emptyimage) {
                                
                                let game1 = global_suppport_game_list.first(where: { $0._id == card.games[0].gameId })
                                let game2 = global_suppport_game_list.first(where: { $0._id == card.games[1].gameId })
                                
                                cell.game1.setImageWithCache(from: URL(string: game1?.cover ?? "") ?? empty)
                                cell.game2.setImageWithCache(from: URL(string: game2?.cover ?? "") ?? empty)
                                cell.game3.setImage(UIImage(named: "game_add"), for: .normal)
                                
                            
                            }
                            
                            
                        } else if card.games.count == 3 {
                            
                            cell.game1.isHidden = false
                            cell.game2.isHidden = false
                            cell.game3.isHidden = false
                            cell.game4.isHidden = false
                           
                            if let empty = URL(string: emptyimage) {
                                
                                let game1 = global_suppport_game_list.first(where: { $0._id == card.games[0].gameId })
                                let game2 = global_suppport_game_list.first(where: { $0._id == card.games[1].gameId })
                                let game3 = global_suppport_game_list.first(where: { $0._id == card.games[2].gameId })
                                
                                
                                cell.game1.setImageWithCache(from: URL(string: game1?.cover ?? "") ?? empty)
                                cell.game2.setImageWithCache(from: URL(string: game2?.cover ?? "") ?? empty)
                                cell.game3.setImageWithCache(from: URL(string: game3?.cover ?? "") ?? empty)
                                cell.game4.setImage(UIImage(named: "game_add"), for: .normal)
                
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
        navigationItem.title = "Edit Challenge Card"
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
    
    func editCard() {
        
        let alert = UIAlertController(title: "Hi, \(_AppCoreData.userDataSource.value?.userName ?? "user")!", message: "Challenge card update", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

        alert.addAction(UIAlertAction(title: "Edit slogan", style: .default, handler: { action in

            if let ESVC = UIStoryboard(name: "Dashboard", bundle: nil).instantiateViewController(withIdentifier: "EditSloganVC") as? EditSloganVC {
                self.navigationController?.pushViewController(ESVC, animated: true)
                
            }
            
        }))
        
        
        alert.addAction(UIAlertAction(title: "View games", style: .default, handler: { action in

            if let AGVC = UIStoryboard(name: "Dashboard", bundle: nil).instantiateViewController(withIdentifier: "AddGameVC") as? AddGameVC {
                
                if let games = _AppCoreData.userDataSource.value?.challengeCard?.games
                {
                    AGVC.gameList = games
                    
                }
                
                self.navigationController?.pushViewController(AGVC, animated: true)
            }
            
            
        }))

        self.present(alert, animated: true)
        
    }
    
    @objc func editCardTapped(_ sender: UIButton) {
        
        editCard()
        
    }
    
    @objc func game1Tapped(_ sender: UIButton) {
        // make sure to check if any game is added unless peform adding game for +
        if let card = _AppCoreData.userDataSource.value?.challengeCard
        {
            
            if card.games.isEmpty == true {
                
                //AddGameVC
                if let AGVC = UIStoryboard(name: "Dashboard", bundle: nil).instantiateViewController(withIdentifier: "AddGameVC") as? AddGameVC {
                    
                    if let games = _AppCoreData.userDataSource.value?.challengeCard?.games
                    {
                        AGVC.gameList = games
                        
                    }
                    
                    self.navigationController?.pushViewController(AGVC, animated: true)
                    
                }
                
            } else {
                
                if let game = card.games.first {
                    
                    if game.link != ""
                    {
                        guard let requestUrl = URL(string: game.link) else {
                            return
                        }

                        if UIApplication.shared.canOpenURL(requestUrl) {
                             UIApplication.shared.open(requestUrl, options: [:], completionHandler: nil)
                        } else {
                            showErrorAlert("Oops!", msg: "canOpenURL: failed for URL: \(game.link)")
                        }
                        
                    } else {
                        
                        showErrorAlert("Oops!", msg: "Can't open this link")
                        
                    }
                    
                    
                }
                
                
            }
            
            
        }
        
    }
    
    @objc func game2Tapped(_ sender: UIButton) {
        
        if let card = _AppCoreData.userDataSource.value?.challengeCard
        {
            
            if card.games.count >= 2 {
                
                let game = card.games[1]
                if game.link != ""
                {
                    guard let requestUrl = URL(string: game.link) else {
                        return
                    }

                    if UIApplication.shared.canOpenURL(requestUrl) {
                         UIApplication.shared.open(requestUrl, options: [:], completionHandler: nil)
                    } else {
                        showErrorAlert("Oops!", msg: "canOpenURL: failed for URL: \(game.link)")
                    }
                    
                } else {
                    
                    showErrorAlert("Oops!", msg: "Can't open this link")
                    
                }
                
                
            } else {
                
                //AddGameVC
                if let AGVC = UIStoryboard(name: "Dashboard", bundle: nil).instantiateViewController(withIdentifier: "AddGameVC") as? AddGameVC {
                    
                    
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
        
        if let card = _AppCoreData.userDataSource.value?.challengeCard
        {
            
            if card.games.count >= 3 {
                
                let game = card.games[2]
                if game.link != ""
                {
                    guard let requestUrl = URL(string: game.link) else {
                        return
                    }

                    if UIApplication.shared.canOpenURL(requestUrl) {
                         UIApplication.shared.open(requestUrl, options: [:], completionHandler: nil)
                    } else {
                        showErrorAlert("Oops!", msg: "canOpenURL: failed for URL: \(game.link)")
                    }
                    
                } else {
                    
                    showErrorAlert("Oops!", msg: "Can't open this link")
                    
                }
                
            } else {
                
                //AddGameVC
                if let AGVC = UIStoryboard(name: "Dashboard", bundle: nil).instantiateViewController(withIdentifier: "AddGameVC") as? AddGameVC {
                    
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
        
        if let card = _AppCoreData.userDataSource.value?.challengeCard
        {
            
            if card.games.count >= 4 {
                
                let game = card.games[3]
                if game.link != ""
                {
                    guard let requestUrl = URL(string: game.link) else {
                        return
                    }

                    if UIApplication.shared.canOpenURL(requestUrl) {
                         UIApplication.shared.open(requestUrl, options: [:], completionHandler: nil)
                    } else {
                        showErrorAlert("Oops!", msg: "canOpenURL: failed for URL: \(game.link)")
                    }
                    
                } else {
                    
                    showErrorAlert("Oops!", msg: "Can't open this link")
                    
                }
                
            } else {
                
                //AddGameVC
                if let AGVC = UIStoryboard(name: "Dashboard", bundle: nil).instantiateViewController(withIdentifier: "AddGameVC") as? AddGameVC {
                
                    if let games = _AppCoreData.userDataSource.value?.challengeCard?.games
                    {
                        AGVC.gameList = games
                        
                    }
                    
                    self.navigationController?.pushViewController(AGVC, animated: true)
                    
                }
                
            }
            
            
        }
        
    }
    
    @objc func onClickSave(_ sender: AnyObject) {
        
        if let badgeID = bID {
            
            presentSwiftLoader()
            APIManager.shared.updateChallengeCard(params: ["badge": "b\(badgeID+1)"]) { result in
                switch result {
                case .success(let apiResponse):
                    
                    guard apiResponse.body?["message"] as? String == "success" else {
                            return
                    }
                    
                    DispatchQueue.main {
                        SwiftLoader.hide()
                        self.bID = nil
                        self.didCreateSave = false
                        self.navigationItem.rightBarButtonItem = nil
                        
                        if self.didSelectIndex != nil {
                            
                            if let cell = self.collectionView.cellForItem(at: self.didSelectIndex!) as? ImageViewCell {
                                self.didSelect = false
                                cell.borderColors = .clear
                                cell.borderWidths = 0.0
                                cell.cornerRadius = 0.0
                                    
                            }
                            
                        }
                        
                        NotificationCenter.default.post(name: (NSNotification.Name(rawValue: "refreshData")), object: nil)
                        
                        showNote(text: "Updated successfully")
                    }
                    
                case .failure(let error):
                    DispatchQueue.main {
                        print(error)
                        SwiftLoader.hide()
                        self.showErrorAlert("Oops!", msg: error.localizedDescription)
                    }
                
                }
            }
            
            
        } else {
            
            self.showErrorAlert("Oops!", msg: "Please choose your badge")
            
        }
        
    }
    
}


extension EditChallengeCardVC {
    
    func createChallengeCardSection() -> NSCollectionLayoutSection {
        let headerItem = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0)))
        let headerGroup = NSCollectionLayoutGroup.horizontal(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(226)), subitems: [headerItem])
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

extension EditChallengeCardVC {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        
        let item = datasource.itemIdentifier(for: indexPath)
       
        switch item {
            case .challengeCard(_):
                editCard()
                
            case .badges(_):
                
            
                        if didSelect, let cell = collectionView.cellForItem(at: didSelectIndex!) as? ImageViewCell {
                            resetCellSelection(cell)
                           
                        }

                        didSelectIndex = indexPath

                        if let cell = collectionView.cellForItem(at: indexPath) as? ImageViewCell {
                            selectCell(cell)
                            bID = indexPath.row

                            reloadBadgeCell(indexPath)

                            if !didCreateSave {
                                didCreateSave = true
                                createSaveBtn()
                            }
                        }

            
         
             
            case .none:
                print("None")
        }
        
        
        //didSelectIndex
        
        
    }
    
    
    func resetCellSelection(_ cell: ImageViewCell) {
        cell.borderColors = .clear
        cell.borderWidths = 0.0
        cell.cornerRadius = 0.0
    }

    func selectCell(_ cell: ImageViewCell) {
        didSelect = true
        cell.borderColors = .secondary
        cell.borderWidths = 2.0
        cell.cornerRadius = 5.0
    }

    func reloadBadgeCell(_ indexPath: IndexPath) {
        var updatedSnapshot = datasource.snapshot()
        updatedSnapshot.reloadSections([.challengeCard])
        self.datasource.apply(updatedSnapshot, animatingDifferences: false)
    }

    
    func createSaveBtn() {
      
        let createButton = UIButton(type: .custom)
        createButton.addTarget(self, action: #selector(onClickSave(_:)), for: .touchUpInside)
        createButton.semanticContentAttribute = .forceRightToLeft
        createButton.setTitle("Save", for: .normal)
        createButton.setTitleColor(.white, for: .normal)
        createButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        createButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 2, bottom: 0, right: -2)
        createButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: -2, bottom: 0, right: 2)
        createButton.frame = CGRect(x: 0, y: 0, width: 80, height: 30)
        createButton.backgroundColor = .primary
        createButton.cornerRadius = 15
        let customView = UIView(frame: CGRect(x: 0, y: 0, width: 80, height: 30))
        customView.addSubview(createButton)
        createButton.center = customView.center
        let createBarButton = UIBarButtonItem(customView: customView)

        let fixedSpace = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        fixedSpace.width = 2
      
        self.navigationItem.rightBarButtonItem = createBarButton
         
    }
    
    func showErrorAlert(_ title: String, msg: String) {
                                                                                                                                           
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        
                                                                                       
        present(alert, animated: true, completion: nil)
        
    }
    
}
