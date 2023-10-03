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
    
    
    var tutorialList = ["tut1", "tut2", "tut3"]
    var currentIndex = 0
    var willIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        //setupNavigationController()
        wireDelegates()
        collectionView.alwaysBounceVertical = false
        collectionView.backgroundColor = .white
     
    }
    

    @IBAction func controlBtnPressed(_ sender: Any) {
        
        switch currentIndex {
            
        case 0:
            nextIndex()
        case 1:
            nextIndex()
        case 2:
            print("Show next item here")
            DispatchQueue.main.async { [weak self] in
                UserDefaults.standard.set(true, forKey: "hasShowCleaned")
                if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ShowCleanModeVC") as? ShowCleanModeVC {
                    vc.modalPresentationStyle = .fullScreen
                    self?.present(vc, animated: true)
                }
            }
            
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
        
        self.navigationController?.title = ""
        
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
        let screenWidth = UIScreen.main.bounds.width
        let safeAreaInsets = UIApplication.shared.windows.first?.safeAreaInsets ?? UIEdgeInsets.zero
        let collectionViewBottomConstraint: CGFloat = 20
        let screenHeight = UIScreen.main.bounds.height - safeAreaInsets.top - safeAreaInsets.bottom - collectionViewBottomConstraint

        let headerItem = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .absolute(screenWidth), heightDimension: .absolute(screenHeight)))

        let headerGroup = NSCollectionLayoutGroup.vertical(layoutSize: NSCollectionLayoutSize(widthDimension: .absolute(screenWidth), heightDimension: .absolute(screenHeight)), subitems: [headerItem])

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
            
            cell.backgroundColor = .white
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
            view1.backgroundColor = .black
            view2.backgroundColor = .lightGray
            view3.backgroundColor = .lightGray
           
        case 1:
            view1.backgroundColor = .lightGray
            view2.backgroundColor = .black
            view3.backgroundColor = .lightGray
            
        case 2:
            view1.backgroundColor = .lightGray
            view2.backgroundColor = .lightGray
            view3.backgroundColor = .black
            
     
        default:
            break
        }
        
        controlBtn.setTitle(currentIndex == 2 ? "Let's go" : "Skip", for: .normal)
        
    }

    
    
}
