//
//  EditPostVC.swift
//  Stitchbox
//
//  Created by Khoi Nguyen on 2/3/23.
//

import UIKit

class EditPostVC: UIViewController {

    let backButton: UIButton = UIButton(type: .custom)
    
    
    @IBOutlet weak var playImg: UIImageView!
    @IBOutlet weak var thumbnailImg: UIImageView!
    @IBOutlet weak var hashtagLbl: UILabel!
    @IBOutlet weak var hiddenHashTagTxtField: UITextField!
    @IBOutlet weak var streamingLinkLbl: UILabel!
    @IBOutlet weak var onlyMeLbl: UILabel!
    @IBOutlet weak var followLbl: UILabel!
    @IBOutlet weak var publicLbl: UILabel!
    @IBOutlet weak var streamingLinkBtn: UIButton!
    @IBOutlet weak var avatarImage: UIImageView!
    @IBOutlet weak var settingViewHeight: NSLayoutConstraint!
    @IBOutlet weak var collectionHeight: NSLayoutConstraint!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var descTxtView: UITextView!
    @IBOutlet weak var globalBtn: UIButton!
    @IBOutlet weak var followingBtn: UIButton!
    @IBOutlet weak var privateBtn: UIButton!
    @IBOutlet weak var hashtagBtn: UIButton!
    @IBOutlet weak var allowCmtSwitch: UISwitch!
    
    
    var hashtagList = [String]()
    var mode = 0
    var isAllowComment = true
    var isKeyboardShow = false
    var mediaType = ""
    var origin_width: CGFloat!
    var origin_height: CGFloat!
    var length: Double!
    var renderedImage: UIImage!
    var selectedDescTxtView = ""
    var selectedPost: PostModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.

        //global_fullLink = ""
        //global_host = ""

        setupButtons()
        setupDefaultView()
        settingAllDefaultValue()
        setupScrollView()
        setupTextView()
        setupGesture()
        
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if global_host != "" {
            streamingLinkLbl.text = "Streaming link added for \(global_host)"
        } else {
            streamingLinkLbl.text = "Streaming link"
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardShow),
                                               name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardHide),
                                               name: UIResponder.keyboardWillHideNotification, object: nil)
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        
       
    }
    
    @IBAction func allowCmtSwitchPressed(_ sender: Any) {
        
        if isAllowComment == true {
                  
            isAllowComment =  false
            allowCmtSwitch.setOn(false, animated: true)
            
            print("Allow comment: \(String(describing: self.isAllowComment))")
            
            
        } else {
            
            isAllowComment = true
            allowCmtSwitch.setOn(true, animated: true)
            
            print("Allow comment: \(String(describing: self.isAllowComment))")
            
        }
        
    }
    
    @IBAction func hashtagBtnPressed(_ sender: Any) {
        
        if let HTVC = UIStoryboard(name: "Dashboard", bundle: nil).instantiateViewController(withIdentifier: "HashtagVC") as? HashtagVC {
            
            HTVC.text = self.hiddenHashTagTxtField.text
            
            HTVC.completionHandler = { text in
                
                if !text.findMHashtagText().isEmpty {
                    self.collectionHeight.constant = 70.0
                    self.settingViewHeight.constant = 315
                    self.collectionView.isHidden = false
                    self.hashtagLbl.text = "Hashtag added"
                    self.hashtagLbl.text = "Hashtag #"
                    self.hashtagList = text.findMHashtagText()
                } else {
                    self.collectionHeight.constant = 0.0
                    self.settingViewHeight.constant = 335 - 70
                    self.collectionView.isHidden = true
                    self.hashtagLbl.text = "Hashtag #"
                    self.hashtagList.removeAll()
                }
                
                self.hiddenHashTagTxtField.text = text
                self.collectionView.reloadData()
                
                
            }
            
            
            self.navigationController?.pushViewController(HTVC, animated: true)
            
        }
        
    }
    
    
    @IBAction func globalBtnPressed(_ sender: Any) {
        
        mode = 0
        
        globalBtn.setImage(UIImage(named: "selectedPublic"), for: .normal)
        followingBtn.setImage(UIImage(named: "following"), for: .normal)
        privateBtn.setImage(UIImage(named: "onlyme"), for: .normal)
        
        publicLbl.textColor = .secondary
        followLbl.textColor = .lightGray
        onlyMeLbl.textColor = .lightGray
        
    }
    
    
    @IBAction func followingBtnPressed(_ sender: Any) {
        
        mode = 1
        
        globalBtn.setImage(UIImage(named: "public"), for: .normal)
        followingBtn.setImage(UIImage(named: "selectedFollowing"), for: .normal)
        privateBtn.setImage(UIImage(named: "onlyme"), for: .normal)
        
        publicLbl.textColor = .lightGray
        followLbl.textColor = .secondary
        onlyMeLbl.textColor = .lightGray
    }
    
    @IBAction func privateBtnPressed(_ sender: Any) {
        
        mode = 2
        
        globalBtn.setImage(UIImage(named: "public"), for: .normal)
        followingBtn.setImage(UIImage(named: "following"), for: .normal)
        privateBtn.setImage(UIImage(named: "selectedOnlyme"), for: .normal)
        
        
        publicLbl.textColor = .lightGray
        followLbl.textColor = .lightGray
        onlyMeLbl.textColor = .secondary
        
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        isKeyboardShow = false
        self.view.endEditing(true)
        
    }
    
    @IBAction func StreamingLinkBtnPressed(_ sender: Any) {
        
        
        if let SLVC = UIStoryboard(name: "Dashboard", bundle: nil).instantiateViewController(withIdentifier: "StreamingLinkVC") as? StreamingLinkVC {
            
            self.navigationController?.pushViewController(SLVC, animated: true)
            
        }
        
    }
    


}

extension EditPostVC {
    
    
    func loadAvatar() {
        
        if let avatarUrl = _AppCoreData.userDataSource.value?.avatarURL, avatarUrl != "" {
            let url = URL(string: avatarUrl)
            avatarImage.load(url: url!, str: avatarUrl)
        }
        
        
    }
    
    func setupButtons() {
        
        setupBackButton()
        createDisablePostBtn()
        emptyBtnLbl()
    
    }
    
    
    func settingAllDefaultValue() {
        
        setDefaultDesc()
        setDefaultMeia()
        setDefaultMode()
        setDefaultComment()
        setDefaultHashtag()
        setDefaultStreamingLink()
        loadAvatar()
    }
    
    func setupBackButton() {
        
        // Do any additional setup after loading the view.
        backButton.setImage(UIImage.init(named: "back_icn_white")?.resize(targetSize: CGSize(width: 13, height: 23)), for: [])
        backButton.addTarget(self, action: #selector(onClickBack(_:)), for: .touchUpInside)
        backButton.frame = CGRect(x: -10, y: 0, width: 15, height: 25)
        backButton.setTitleColor(UIColor.white, for: .normal)
        backButton.setTitle("     Edit Post", for: .normal)
        backButton.sizeToFit()
        let backButtonBarButton = UIBarButtonItem(customView: backButton)
    
        self.navigationItem.leftBarButtonItem = backButtonBarButton
       
    }
    
    func setupGesture() {
        
        let descTap = UITapGestureRecognizer(target: self, action: #selector(EditPostVC.dismissKeyboardOnTap))
        descTxtView.isUserInteractionEnabled = true
        descTxtView.addGestureRecognizer(descTap)
        
    }
    
    func setupTextView() {
        
        descTxtView.delegate = self
        
    }
    
    func setDefaultStreamingLink() {
    

    }
    
    func setDefaultComment() {
    
        
        if selectedPost.setting?.allowComment == true {
            
            isAllowComment = true
            allowCmtSwitch.setOn(true, animated: true)
            
        } else {
            
            isAllowComment =  false
            allowCmtSwitch.setOn(false, animated: true)
            
        }
    }
    
    func setDefaultDesc() {
        
        if selectedPost.content != "" {
            
            descTxtView.text = selectedPost.content
        }
        
    }
    
    func setDefaultHashtag() {
        
        
        
    }
    
    func setDefaultMeia() {
        
        DispatchQueue.global().async {
            
            if let data = try? Data(contentsOf: self.selectedPost.imageUrl) {
                DispatchQueue.main.async {
                    self.thumbnailImg.image = UIImage(data: data)
                }
            }
            
        }
        
        
        
        if selectedPost.muxPlaybackId != "" {
            playImg.isHidden = false
        } else {
            playImg.isHidden = true
        }
        
        
    }
    
    func setDefaultMode() {
        
        if selectedPost.setting?.mode == 0 {
            
            mode = 0
            
            globalBtn.setImage(UIImage(named: "selectedPublic"), for: .normal)
            followingBtn.setImage(UIImage(named: "following"), for: .normal)
            privateBtn.setImage(UIImage(named: "onlyme"), for: .normal)
            
            publicLbl.textColor = .secondary
            followLbl.textColor = .lightGray
            onlyMeLbl.textColor = .lightGray
            
        } else if selectedPost.setting?.mode == 1 {
            
            mode = 1
            
            globalBtn.setImage(UIImage(named: "public"), for: .normal)
            followingBtn.setImage(UIImage(named: "selectedFollowing"), for: .normal)
            privateBtn.setImage(UIImage(named: "onlyme"), for: .normal)
            
            publicLbl.textColor = .lightGray
            followLbl.textColor = .secondary
            onlyMeLbl.textColor = .lightGray
            
        } else if selectedPost.setting?.mode == 2 {
            
            mode = 2
            
            globalBtn.setImage(UIImage(named: "public"), for: .normal)
            followingBtn.setImage(UIImage(named: "following"), for: .normal)
            privateBtn.setImage(UIImage(named: "selectedOnlyme"), for: .normal)
            
            
            publicLbl.textColor = .lightGray
            followLbl.textColor = .lightGray
            onlyMeLbl.textColor = .secondary
            
        }
        
    
    }

   
    func createDisablePostBtn() {
       
        let createButton = UIButton(type: .custom)
        //createButton.addTarget(self, action: #selector(onClickPost(_:)), for: .touchUpInside)
        createButton.semanticContentAttribute = .forceRightToLeft
        createButton.setTitle("Save", for: .normal)
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
    
    func createPostBtn() {
      
        let createButton = UIButton(type: .custom)
        createButton.addTarget(self, action: #selector(onClickPost(_:)), for: .touchUpInside)
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
    

    
    func emptyBtnLbl() {
        
       
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
            layout.scrollDirection = .vertical
            layout.itemSize = CGSize(width: 120, height: 30)
        }
    }
    

}


extension EditPostVC {
    
    @objc func onClickBack(_ sender: AnyObject) {
        if let navigationController = self.navigationController {
            navigationController.popViewController(animated: true)
        }
    }
    
    @objc func onClickPost(_ sender: AnyObject) {
        
            print("Edited click")

      
    }
    
    @objc func handleKeyboardShow(notification: Notification) {
        isKeyboardShow = true
    }
    
    
    @objc func handleKeyboardHide(notification: Notification) {
        isKeyboardShow = false
    }
    
    @objc func dismissKeyboardOnTap(sender: AnyObject!) {
  
        if isKeyboardShow {
            self.view.endEditing(true)
        } else {
            descTxtView.becomeFirstResponder()
        }
  
    }
    
}

extension EditPostVC: UICollectionViewDelegate, UICollectionViewDataSource {
    
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
                self.collectionHeight.constant = 0.0
                self.settingViewHeight.constant = 335 - 70
                
                self.hiddenHashTagTxtField.text = ""
                self.hashtagLbl.text = "Hashtag #"
                
            } else {
                
                self.hiddenHashTagTxtField.text = self.hashtagList.joined(separator: "")
            
            }
            
            collectionView.reloadData()
           
        }
        
    }
    
    
}

extension EditPostVC: UITextViewDelegate {
    

    func textViewDidBeginEditing(_ textView: UITextView) {
        
        if textView == descTxtView {
            
            if textView.text == "Hi, what's on your thought?" {
                
                textView.text = ""
                
            }
            
        }
        
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView == descTxtView {
            
            if textView.text == "" {
                
                textView.text = "Hi, what's on your thought?"
                
            } else {
                selectedDescTxtView = textView.text
            }
            
        }
        
        
    }
    
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
        let numberOfChars = newText.count
        return numberOfChars <= 200    // 200 Limit Value
    }
    
    
}

extension EditPostVC {
    
    // func show error alert
    
    func showErrorAlert(_ title: String, msg: String) {
                                                                    
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        
                                                                                       
        present(alert, animated: true, completion: nil)
        
    }
    
    func swiftLoader(progress: String) {
        
        var config : SwiftLoader.Config = SwiftLoader.Config()
        config.size = 170
        
        config.backgroundColor = UIColor.clear
        config.spinnerColor = UIColor.white
        config.titleTextColor = UIColor.white
        
        
        config.spinnerLineWidth = 3.0
        config.foregroundColor = UIColor.black
        config.foregroundAlpha = 0.7
        
        
        SwiftLoader.setConfig(config: config)
        
        
        SwiftLoader.show(title: progress, animated: true)
        
    }
    
}

