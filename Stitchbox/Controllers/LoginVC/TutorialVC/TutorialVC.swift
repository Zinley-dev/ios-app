//
//  TutorialVC.swift
//  Stitchbox
//
//  Created by Khoi Nguyen on 1/25/23.
//

import UIKit

class TutorialVC: UIViewController {

    @IBOutlet weak var controlBtn: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var view1: circleView!
    @IBOutlet weak var view2: circleView!
    @IBOutlet weak var view3: circleView!
    @IBOutlet weak var view4: circleView!
    
    var tutorialList = ["welcome", "streaming link", "fist bump" , "challenge card"]
    var currentIndex = 0
    var willIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupNavigationController()
        wireDelegates()
        
    }
    

    @IBAction func controlBtnPressed(_ sender: Any) {
        
        switch currentIndex {
            
        case 0:
            nextIndex()
        case 1:
            nextIndex()
        case 2:
            nextIndex()
        case 3:
            print("Show next item here")
        default:
            break
        }
        
    }
    
    func nextIndex() {
        
        currentIndex += 1
        
        collectionView.scrollToItem(at: IndexPath(item: currentIndex, section: 0), at: .right, animated: true)
        
        
    }
    

}

extension TutorialVC {
    
    func setupNavigationController() {
        
        //self.navigationController?.navigationItem.leftBarButtonItem = nil
        //self.navigationController?.navigationItem.rightBarButtonItem = nil
        //self.navigationController?.isNavigationBarHidden = true
        
        self.navigationController?.title = "DKM"
        
    }
    
    
    func createLayout() -> UICollectionViewLayout {
        return UICollectionViewCompositionalLayout { [unowned self] index, env in
            return self.sectionFor(environment: env)
        }
    }
    
    
    func sectionFor(environment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
       
        createHeaderSection()
        
    }
    
    func createHeaderSection() -> NSCollectionLayoutSection {
        let headerItem = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0)))
    
        let headerGroup = NSCollectionLayoutGroup.vertical(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0)), subitems: [headerItem])
    
        let section = NSCollectionLayoutSection(group: headerGroup)
        
        section.orthogonalScrollingBehavior = .groupPaging
        
        return section
    }
    
    
}


extension TutorialVC: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func wireDelegates() {
        
        collectionView.setCollectionViewLayout(createLayout(), animated: true)
        collectionView.register(ImageViewCell.self, forCellWithReuseIdentifier: ImageViewCell.reuseIdentifier)
        collectionView.delegate = self
        collectionView.dataSource = self
        
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tutorialList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
    
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ImageViewCell.reuseIdentifier, for: indexPath) as? ImageViewCell {
            
            cell.configure(with: UIImage.init(named: tutorialList[indexPath.row])!)
          
            return cell
            
        } else {
        
            return ImageViewCell()
            
        }
        
    }
    
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
    
        willIndex = indexPath.row
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        if willIndex != indexPath.row {
                   
            currentIndex = willIndex
                   
        }
        
        
        updateUI(currentIndex: currentIndex)
    }

    func updateUI(currentIndex: Int) {
        switch currentIndex {
        case 0:
            view1.backgroundColor = .white
            view2.backgroundColor = .lightGray
            view3.backgroundColor = .lightGray
            view4.backgroundColor = .lightGray
        case 1:
            view1.backgroundColor = .lightGray
            view2.backgroundColor = .white
            view3.backgroundColor = .lightGray
            view4.backgroundColor = .lightGray
        case 2:
            view1.backgroundColor = .lightGray
            view2.backgroundColor = .lightGray
            view3.backgroundColor = .white
            view4.backgroundColor = .lightGray
        case 3:
            view1.backgroundColor = .lightGray
            view2.backgroundColor = .lightGray
            view3.backgroundColor = .lightGray
            view4.backgroundColor = .white
        default:
            break
        }
        controlBtn.setTitle(currentIndex == 3 ? "Let's go" : "Skip", for: .normal)
    }

    
    
}
