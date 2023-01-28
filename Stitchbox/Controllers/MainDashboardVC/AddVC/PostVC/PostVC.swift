//
//  PostVC.swift
//  Stitchbox
//
//  Created by Khoi Nguyen on 1/21/23.
//

import UIKit
import PixelSDK
import Alamofire
import Photos

class PostVC: UIViewController {

    
    enum updateMedia {
        case image
        case video
    }
    
    
    @IBOutlet weak var onlyMeLbl: UILabel!
    @IBOutlet weak var followLbl: UILabel!
    @IBOutlet weak var publicLbl: UILabel!
    @IBOutlet weak var streamingLinkBtn: UIButton!
    @IBOutlet weak var avatarImage: UIImageView!
    @IBOutlet weak var settingViewHeight: NSLayoutConstraint!
    @IBOutlet weak var collectionHeight: NSLayoutConstraint!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var descTxtView: UITextView!
    @IBOutlet weak var addBtn: UIButton!
    @IBOutlet weak var globalBtn: UIButton!
    @IBOutlet weak var followingBtn: UIButton!
    @IBOutlet weak var privateBtn: UIButton!
    @IBOutlet weak var hashtagBtn: UIButton!
    @IBOutlet weak var allowCmtSwitch: UISwitch!
    
    var hashtagList = [String]()
    var mode: String!
    let backButton: UIButton = UIButton(type: .custom)
    let container = ContainerController(modes: [.library, .photo])
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        wireDelegate()
        setupButtons()
        setupDefaultView()
        
    }
    
    @IBAction func addMediaBtnPressed(_ sender: Any) {
    
        // Include only Image from the users drafts
        container.libraryController.draftMediaTypes = [.image, .video]
        
        container.libraryController.previewCropController.maxRatioForPortraitMedia = CGSize(width: 3, height: 4)
        container.libraryController.previewCropController.maxRatioForLandscapeMedia = CGSize(width: 16, height: 9)
        let nav = UINavigationController(rootViewController: container)
        nav.modalPresentationStyle = .fullScreen
        
        self.present(nav, animated: true, completion: nil)
        
    }
    
    @IBAction func allowCmtSwitchPressed(_ sender: Any) {
        
        
        
    }
    
    @IBAction func hashtagBtnPressed(_ sender: Any) {
        
        if let HTVC = UIStoryboard(name: "Dashboard", bundle: nil).instantiateViewController(withIdentifier: "HashtagVC") as? HashtagVC {
            
            self.navigationController?.pushViewController(HTVC, animated: true)
            
        }
        
    }
    
    
    @IBAction func globalBtnPressed(_ sender: Any) {
        
        mode = "Public"
        
        globalBtn.setImage(UIImage(named: "selectedPublic"), for: .normal)
        followingBtn.setImage(UIImage(named: "following"), for: .normal)
        privateBtn.setImage(UIImage(named: "onlyme"), for: .normal)
        
        publicLbl.textColor = .secondary
        followLbl.textColor = .lightGray
        onlyMeLbl.textColor = .lightGray
        
    }
    
    
    @IBAction func followingBtnPressed(_ sender: Any) {
        
        mode = "Following"
        
        globalBtn.setImage(UIImage(named: "public"), for: .normal)
        followingBtn.setImage(UIImage(named: "selectedFollowing"), for: .normal)
        privateBtn.setImage(UIImage(named: "onlyme"), for: .normal)
        
        publicLbl.textColor = .lightGray
        followLbl.textColor = .secondary
        onlyMeLbl.textColor = .lightGray
    }
    
    @IBAction func privateBtnPressed(_ sender: Any) {
        
        mode = "Only me"
        
        globalBtn.setImage(UIImage(named: "public"), for: .normal)
        followingBtn.setImage(UIImage(named: "following"), for: .normal)
        privateBtn.setImage(UIImage(named: "selectedOnlyme"), for: .normal)
        
        
        publicLbl.textColor = .lightGray
        followLbl.textColor = .lightGray
        onlyMeLbl.textColor = .secondary
        
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        
        self.view.endEditing(true)
        
    }
    
    @IBAction func StreamingLinkBtnPressed(_ sender: Any) {
        
        
        if let SLVC = UIStoryboard(name: "Dashboard", bundle: nil).instantiateViewController(withIdentifier: "StreamingLinkVC") as? StreamingLinkVC {
            
            self.navigationController?.pushViewController(SLVC, animated: true)
            
        }
        
    }
}

extension PostVC {
    
    func setupButtons() {
        
        setupBackButton()
        createDisablePostBtn()
        emptyBtnLbl()
    
    }
   
    func createDisablePostBtn() {
        
        let createButton = UIButton(type: .custom)
        createButton.addTarget(self, action: #selector(onClickPost(_:)), for: .touchUpInside)
        createButton.semanticContentAttribute = .forceRightToLeft
        createButton.setTitle("Post", for: .normal)
        createButton.setTitleColor(.lightGray, for: .normal)
        createButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        createButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 2, bottom: 0, right: -2)
        createButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: -2, bottom: 0, right: 2)
        createButton.frame = CGRect(x: 0, y: 0, width: 80, height: 30)
        createButton.backgroundColor = .disableButtonBackground
        createButton.cornerRadius = 15
        let customView = UIView(frame: CGRect(x: 0, y: 0, width: 80, height: 30))
        customView.addSubview(createButton)
        createButton.center = customView.center
        let createBarButton = UIBarButtonItem(customView: customView)

        let fixedSpace = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        fixedSpace.width = 2
      
        self.navigationItem.rightBarButtonItem = createBarButton
         
    }
    
    
    func setupBackButton() {
        
        // Do any additional setup after loading the view.
        backButton.setImage(UIImage.init(named: "back_icn_white")?.resize(targetSize: CGSize(width: 13, height: 23)), for: [])
        backButton.addTarget(self, action: #selector(onClickBack(_:)), for: .touchUpInside)
        backButton.frame = CGRect(x: -10, y: 0, width: 15, height: 25)
        backButton.setTitleColor(UIColor.white, for: .normal)
        backButton.setTitle("     Create Post", for: .normal)
        backButton.sizeToFit()
        let backButtonBarButton = UIBarButtonItem(customView: backButton)
    
        self.navigationItem.leftBarButtonItem = backButtonBarButton
       
    }

    
    func emptyBtnLbl() {
        
        addBtn.setTitle("", for: .normal)
        globalBtn.setTitle("", for: .normal)
        privateBtn.setTitle("", for: .normal)
        followingBtn.setTitle("", for: .normal)
        hashtagBtn.setTitle("", for: .normal)
        streamingLinkBtn.setTitle("", for: .normal)
        
    }
    
    func setupDefaultView() {
        
        collectionHeight.constant = 0.0
        settingViewHeight.constant = 335 - 70
        
    }

    func setupScrollView() {
        collectionView.contentInset = UIEdgeInsets.init(top: 0, left: 14, bottom: 0, right: 14)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(SelectedHashtagCollectionViewCell.nib(), forCellWithReuseIdentifier: SelectedHashtagCollectionViewCell.cellReuseIdentifier())
        collectionHeight.constant = 0
        collectionView.isHidden = true
        
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = .horizontal
            layout.itemSize = CGSize(width: 120, height: 30)
        }
    }
    
}

extension PostVC: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return hashtagList.count
    }
     
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = (collectionView.dequeueReusableCell(withReuseIdentifier: SelectedHashtagCollectionViewCell.cellReuseIdentifier(), for: indexPath)) as! SelectedHashtagCollectionViewCell
        
        
        cell.hashtag.text = hashtagList[indexPath.row]
        
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        hashtagList.remove(at: indexPath.row)
        
        DispatchQueue.main.async {
            if self.hashtagList.count == 0 {
                self.collectionHeight.constant = 0
                self.collectionView.isHidden = true
            }
            
            collectionView.reloadData()
           
        }
        
    }
    
    
}

extension PostVC {
    
    @objc func onClickBack(_ sender: AnyObject) {
        self.dismiss(animated: true)
    }
    
    @objc func onClickPost(_ sender: AnyObject) {
        print("Posted")
    }
    
}

//setting up navigationCollection Bar
extension PostVC: UINavigationBarDelegate, UINavigationControllerDelegate {
    
    func wireDelegate() {
        self.navigationController?.navigationBar.delegate = self
    }
    
    func position(for bar: UIBarPositioning) -> UIBarPosition {
        return .topAttached
    }
    
    
}


extension PostVC: EditControllerDelegate {
    
    func editController(_ editController: EditController, didLoadEditing session: PixelSDKSession) {
        // Called after the EditController's view did load.
        
        print("Did load here")
    }
    
    func editController(_ editController: EditController, didFinishEditing session: PixelSDKSession) {
        // Called when the Next button in the EditController is pressed.
        // Use this time to either dismiss the UINavigationController, or push a new controller on.
        
    
        self.dismiss(animated: true, completion: nil)
        
    }
    
    func editController(_ editController: EditController, didCancelEditing session: PixelSDKSession?) {
        // Called when the back button in the EditController is pressed.
        
        print("Did cancel load here")
        
    }
    
}
