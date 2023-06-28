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
import ObjectMapper
import Cache
import AlamofireImage

class PostVC: UIViewController {

    
    enum updateMedia {
        case image
        case video
    }
    
    var itemList = [GameList]()
    @IBOutlet weak var categoryInput: UITextField!
    @IBOutlet weak var addLbl: UILabel!
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
    @IBOutlet weak var collectionLayout: UICollectionViewFlowLayout! {
        didSet {
            collectionLayout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        }
    }
    @IBOutlet weak var descTxtView: UITextView!
    @IBOutlet weak var addBtn: UIButton!
    @IBOutlet weak var globalBtn: UIButton!
    @IBOutlet weak var followingBtn: UIButton!
    @IBOutlet weak var privateBtn: UIButton!
    @IBOutlet weak var hashtagBtn: UIButton!
    @IBOutlet weak var allowCmtSwitch: UISwitch!
    @IBOutlet weak var gameImage: UIImageView!
    @IBOutlet weak var selectedGameLbl: UILabel!
    
    var hashtagList = [String]()
    var selectedGameId = ""
    var mode = 0
    var isAllowComment = true
    let backButton: UIButton = UIButton(type: .custom)
    let container = ContainerController(modes: [.library, .photo, .video])
    var isKeyboardShow = false
    var mediaType = ""
    var selectedVideo: SessionVideo!
    var selectedImage: SessionImage!
    var exportedURL: URL!
    var origin_width: CGFloat!
    var origin_height: CGFloat!
    var length: Double!
    var renderedImage: UIImage!
    var selectedDescTxtView = ""
    
    var dayPicker = UIPickerView()
 
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        container.editControllerDelegate = self
        global_fullLink = ""
        global_host = ""
        setupButtons()
        setupDefaultView()
        setupScrollView()
        setupTextView()
        setupGesture()
        loadPreviousSetting()
        loadAvatar()
        loadAddGame()
        
        self.dayPicker.delegate = self
        
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
    
    func createDayPicker() {

        categoryInput.inputView = dayPicker

    }
    
    @IBAction func changeGameBtnPressed(_ sender: Any) {
        
        createDayPicker()
        categoryInput.becomeFirstResponder()
        
    }
    
    func loadAddGame() {
        
        
        for item in global_suppport_game_list {
            if item.name != "Steam" {
                itemList.append(item)
            }
        }

        
    }
    
    @IBAction func addMediaBtnPressed(_ sender: Any) {
    
        // Include only Image from the users drafts
        container.libraryController.draftMediaTypes = [.image, .video]
        
        container.libraryController.previewCropController.maxRatioForPortraitMedia = CGSize(width: 1, height: .max)
        container.libraryController.previewCropController.maxRatioForLandscapeMedia = CGSize(width: .max, height: 1)
        container.libraryController.previewCropController.defaultsToAspectFillForPortraitMedia = false
        container.libraryController.previewCropController.defaultsToAspectFillForLandscapeMedia = false
       
        
        let nav = UINavigationController(rootViewController: container)
        nav.modalPresentationStyle = .fullScreen
        
        self.present(nav, animated: true, completion: nil)
        
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
                    self.collectionHeight.constant = 50.0
                    self.settingViewHeight.constant = 295
                    self.collectionView.isHidden = false
                    self.hashtagLbl.text = "Hashtag added"
                    self.hashtagLbl.text = "Hashtag #"
                    self.hashtagList = text.findMHashtagText()
                } else {
                    self.collectionHeight.constant = 0.0
                    self.settingViewHeight.constant = 295 - 50
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
        
        publicLbl.textColor = .white
        followLbl.textColor = .white
        onlyMeLbl.textColor = .white
        
    }
    
    
    @IBAction func followingBtnPressed(_ sender: Any) {
        
        mode = 1
        
        globalBtn.setImage(UIImage(named: "public"), for: .normal)
        followingBtn.setImage(UIImage(named: "selectedFollowing"), for: .normal)
        privateBtn.setImage(UIImage(named: "onlyme"), for: .normal)
        
        publicLbl.textColor = .white
        followLbl.textColor = .white
        onlyMeLbl.textColor = .white
    }
    
    @IBAction func privateBtnPressed(_ sender: Any) {
        
        mode = 2
        
        globalBtn.setImage(UIImage(named: "public"), for: .normal)
        followingBtn.setImage(UIImage(named: "following"), for: .normal)
        privateBtn.setImage(UIImage(named: "selectedOnlyme"), for: .normal)
        
        
        publicLbl.textColor = .white
        followLbl.textColor = .white
        onlyMeLbl.textColor = .white
        
        
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

extension PostVC {
    
    
    func loadAvatar() {
        
        if let avatarUrl = _AppCoreData.userDataSource.value?.avatarURL, avatarUrl != "" {
            let url = URL(string: avatarUrl)
            avatarImage.load(url: url!, str: avatarUrl)
        }
        
        
    }
    
    func loadPreviousSetting() {
        
        APIManager.shared.getLastSettingPost { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .success(let apiResponse):
                
                guard let data = apiResponse.body?["data"] as? [[String: Any]]  else {
                    print("Couldn't cast data")
                    return
                }
                
                print(apiResponse)
                
                if let settings = data.first?["setting"] as? [String: Any] {
                    
                    if let allowcomment = settings["allowComment"] as? Bool {
                        
                        if allowcomment == true {
                                  
                            self.isAllowComment =  true
                            DispatchQueue.main.async {
                                self.allowCmtSwitch.setOn(true, animated: true)
                            }
                            print("Allow comment: \(String(describing: self.isAllowComment))")
                            
                            
                        } else {
                            
                            self.isAllowComment = false
                            DispatchQueue.main.async {
                                self.allowCmtSwitch.setOn(false, animated: true)
                            }
                            
                            print("Allow comment: \(String(describing: self.isAllowComment))")
                            
                        }
                        
                    }
                    
                    if let mode = settings["mode"] as? Int {
                        
                        if mode == 0 {
                            
                            self.mode = mode
                            
                            DispatchQueue.main.async {
                                
                                self.globalBtn.setImage(UIImage(named: "selectedPublic"), for: .normal)
                                self.followingBtn.setImage(UIImage(named: "following"), for: .normal)
                                self.privateBtn.setImage(UIImage(named: "onlyme"), for: .normal)
                                        
                                self.publicLbl.textColor = .white
                                self.followLbl.textColor = .white
                                self.onlyMeLbl.textColor = .white
                                
                            }
   
                        } else if mode == 1 {
                            
                            self.mode = mode
                            
                            DispatchQueue.main.async {
                                
                                self.globalBtn.setImage(UIImage(named: "public"), for: .normal)
                                self.followingBtn.setImage(UIImage(named: "selectedFollowing"), for: .normal)
                                self.privateBtn.setImage(UIImage(named: "onlyme"), for: .normal)
                                        
                                self.publicLbl.textColor = .white
                                self.followLbl.textColor = .white
                                self.onlyMeLbl.textColor = .white
                                
                            }
                            
                            
                        } else if mode == 2 {
                            
                            self.mode = mode
                            
                            DispatchQueue.main.async {
                                
                                self.globalBtn.setImage(UIImage(named: "public"), for: .normal)
                                self.followingBtn.setImage(UIImage(named: "following"), for: .normal)
                                self.privateBtn.setImage(UIImage(named: "selectedOnlyme"), for: .normal)
                                        
                                        
                                self.publicLbl.textColor = .white
                                self.followLbl.textColor = .white
                                self.onlyMeLbl.textColor = .white
                                
                            }
                            
                            
                        } else {
                            DispatchQueue.main.async {
                                self.setDefaultMode()
                            }
                        }
                        
                    } else {
                        DispatchQueue.main.async {
                            self.setDefaultMode()
                        }
                    }
                    
                } else {
                    
                    DispatchQueue.main.async {
                        self.setDefaultMode()
                    }
                    
                }
                
                
                
                if let streamUrl = data.first?["streamLink"] as? String {
                    
                    if let url = URL(string: streamUrl) {
                        
                        if let domain = url.host {
                            
                            if check_Url(host: domain) == true {
                                
                                global_host = domain
                                global_fullLink = streamUrl
                                DispatchQueue.main.async {
                                    self.streamingLinkLbl.text = "Streaming link added for \(global_host)"
                                }
    
                            }
                            
                        }
                    }

                }


            case .failure(let error):
                DispatchQueue.main.async {
                    self.setDefaultMode()
                }
                print(error)
            }
        }
        
    }
    
    
    func uploadImage() {
        
        if selectedImage != nil {
            
            print("Start exporting image")
            self.exportImage(currentImage: self.selectedImage) {
                
                Dispatch.background {
                    
                    print("Start uploading")
                    if let checkImage = self.renderedImage {

                        
                        Dispatch.background {
                            
                            UploadContentManager.shared.uploadImageToDB(image: checkImage, hashtagList: self.hashtagList, selectedDescTxtView: self.selectedDescTxtView, isAllowComment: self.isAllowComment, mediaType: self.mediaType, mode: self.mode, origin_width: self.origin_width, origin_height: self.origin_height, gameID: self.selectedGameId)
                            
                        }
                        
                        
                        
                        
                        DispatchQueue.main.async {
                            SwiftLoader.hide()
                            showNote(text: "Thank you, your content is being uploaded!")
                            self.dismiss(animated: true, completion: nil)
                            NotificationCenter.default.post(name: (NSNotification.Name(rawValue: "switchvc")), object: nil)
                        }
                        
                    } else {
                        self.showErrorAlert("Oops!", msg: "We encountered error while getting your exported image, please try again!")
                    }
                    
                }
    
            }
             
            
        } else {
            
            showErrorAlert("Oops!", msg: "We encountered error while getting your selected image, please try again!")
            
        }
        
        
        
    }
    
    func uploadVideo() {
        
        if self.selectedVideo.duration.seconds > 3.0 {
            
            print("Start exporting")
            self.exportVideo(video: self.selectedVideo){

                
                Dispatch.background {
                    
                    print("Start uploading video to db")
                    UploadContentManager.shared.uploadVideoToDB(url: self.exportedURL, hashtagList: self.hashtagList, selectedDescTxtView: self.selectedDescTxtView, isAllowComment: self.isAllowComment, mediaType: self.mediaType, mode: self.mode, origin_width: self.origin_width, origin_height: self.origin_height, length: self.length, gameID: self.selectedGameId)
                    
                }
                
                DispatchQueue.main.async {
                    SwiftLoader.hide()
                    showNote(text: "Thank you, your content is being uploaded!")
                    self.dismiss(animated: true, completion: nil)
                    NotificationCenter.default.post(name: (NSNotification.Name(rawValue: "switchvc")), object: nil)
                   
                }
                    
                                    
            }
          
            
        } else {
            
            
            self.showErrorAlert("Oops!", msg: "Please upload a video with a duration is longer than 3 seconds.")
            
        }
        
    }
    
    func exportImage(currentImage: SessionImage, completed: @escaping DownloadComplete) {
        ImageExporter.shared.export(images: [currentImage], progress: { [weak self] progress in
            self?.swiftLoader(progress: "Uploading")
        }, completion: { [weak self] error, imageList  in
            guard let self = self else { return }
            DispatchQueue.main.async {
                //SwiftLoader.hide()
            }
            if let error = error {
                print("Unable to export image: \(error)")
                self.showErrorAlert("Ops!", msg: "Unable to export image: \(error)")
                return
            }
            if let exportedImage = imageList?.first {
                self.renderedImage = exportedImage
                self.origin_width = exportedImage.size.width
                self.origin_height = exportedImage.size.height
                self.length = 0.0
                completed()
            } else {
                print("Unable to export image: image list is nil or empty")
                self.showErrorAlert("Ops!", msg: "Unable to export image: image list is nil or empty")
            }
        })
    }

    
    func exportVideo(video: SessionVideo, completed: @escaping DownloadComplete) {
        
        VideoExporter.shared.export(video: video, progress: { progress in
            DispatchQueue.main.async {
                self.swiftLoader(progress: "Exporting: \(String(format:"%.2f", Float(progress) * 100))%")
            }
        }, completion: {  error in
            if let error = error {
                
                
                DispatchQueue.main.async {
                    SwiftLoader.hide()
                }
                
                print("Unable to export video: \(error)")
                self.showErrorAlert("Ops!", msg: "Unable to export video: \(error)")
                    return
            }
                    
            self.exportedURL = video.exportedVideoURL
            
            self.origin_width = video.renderSize.width
            self.origin_height = video.renderSize.height
            self.length = video.duration.seconds

            completed()
         
        })
        
        
    }
    


  
}

extension PostVC {
    
    func setupGesture() {
        
        let descTap = UITapGestureRecognizer(target: self, action: #selector(PostVC.dismissKeyboardOnTap))
        descTxtView.isUserInteractionEnabled = true
        descTxtView.addGestureRecognizer(descTap)
        
    }
    
    func setupTextView() {
        
        descTxtView.delegate = self
        
    }
    
    func setDefaultMode() {
        
        mode = 0
        
        globalBtn.setImage(UIImage(named: "selectedPublic"), for: .normal)
        followingBtn.setImage(UIImage(named: "following"), for: .normal)
        privateBtn.setImage(UIImage(named: "onlyme"), for: .normal)
        
        publicLbl.textColor = .white
        followLbl.textColor = .white
        onlyMeLbl.textColor = .white
        
    }
    
    func setupButtons() {
        
        setupBackButton()
        createDisablePostBtn()
        emptyBtnLbl()
    
    }
   
    func createDisablePostBtn() {
        addLbl.text = "Add"
        let createButton = UIButton(type: .custom)
        //createButton.addTarget(self, action: #selector(onClickPost(_:)), for: .touchUpInside)
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
    
    func createPostBtn() {
        addLbl.text = "Added"
        let createButton = UIButton(type: .custom)
        createButton.addTarget(self, action: #selector(onClickPost(_:)), for: .touchUpInside)
        createButton.semanticContentAttribute = .forceRightToLeft
        createButton.setTitle("Post", for: .normal)
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
        navigationItem.title = "Create Post"
       
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
        settingViewHeight.constant = 295 - 50
        
    }

    func setupScrollView() {
        
        collectionView.contentInset = UIEdgeInsets.init(top: 0, left: 14, bottom: 0, right: 14)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(HashtagCell.nib(), forCellWithReuseIdentifier: HashtagCell.cellReuseIdentifier())
        collectionHeight.constant = 0
        collectionView.isHidden = true
        
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false

    }
    
}

extension PostVC: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return hashtagList.count
    }
     
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = (collectionView.dequeueReusableCell(withReuseIdentifier: HashtagCell.cellReuseIdentifier(), for: indexPath)) as! HashtagCell
        
  
        cell.hashTagLabel.text = hashtagList[indexPath.row]
        cell.hashTagLabel.font = UIFont.systemFont(ofSize: 12)
        cell.hashTagLabel.backgroundColor = .clear
        cell.backgroundColor = .primary
        
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        hashtagList.remove(at: indexPath.row)
        
        DispatchQueue.main.async {
            if self.hashtagList.count == 0 {
                self.collectionHeight.constant = 0
                self.collectionView.isHidden = true
                self.collectionHeight.constant = 0.0
                self.settingViewHeight.constant = 295 - 50
                
                self.hiddenHashTagTxtField.text = ""
                self.hashtagLbl.text = "Hashtag #"
                
            } else {
                
                self.hiddenHashTagTxtField.text = self.hashtagList.joined(separator: "")
            
            }
            
            collectionView.reloadData()
           
        }
        
    }
    
    
}

extension PostVC {
    
    @objc func onClickBack(_ sender: AnyObject) {
        
        if let navigationController = self.navigationController {
            navigationController.dismiss(animated: true)
            NotificationCenter.default.post(name: (NSNotification.Name(rawValue: "switchvcToIndex")), object: nil)
        }
    }
    
    @objc func onClickPost(_ sender: AnyObject) {
        
        if global_percentComplete == 0.00 || global_percentComplete == 100.0 {
            
            guard selectedGameId != ""  else {
                showErrorAlert("Oops!", msg: "Please select your uploading game.")
                return
            }
            
            
            if mediaType == "image" {
                uploadImage()
            } else if mediaType == "video" {
                uploadVideo()
            } else {
                showErrorAlert("Oops!", msg: "Unknown media type selected, please try again.")
            }
        } else {
            self.showErrorAlert("Oops!", msg: "Your current post is being uploaded, please try again later.")
        }
        
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

extension PostVC: EditControllerDelegate {
    
    func editController(_ editController: EditController, didLoadEditing session: PixelSDKSession) {
        // Called after the EditController's view did load.
        
        print("Did load here")
    }
    
    func editController(_ editController: EditController, didFinishEditing session: PixelSDKSession) {
        // Called when the Next button in the EditController is pressed.
        // Use this time to either dismiss the UINavigationController, or push a new controller on.
        
        
        if let video = session.video {
            
          
            mediaType = "video"
            selectedVideo = video
           
            
        } else if let image = session.image {
            selectedImage = image
            mediaType = "image"
          
            
        }
        
        createPostBtn()
    
        self.dismiss(animated: true, completion: nil)
        
    }
    
    func editController(_ editController: EditController, didCancelEditing session: PixelSDKSession?) {
        // Called when the back button in the EditController is pressed.
        
        print("Did cancel load here")
        
    }
    
}

extension PostVC: UITextViewDelegate {
    

    func textViewDidBeginEditing(_ textView: UITextView) {
        
        if textView == descTxtView {
            
            if textView.text == "Hi, let's unleash your gameplay!" {
                
                textView.text = ""
                
            }
            
        }
        
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView == descTxtView {
            
            if textView.text == "" {
                
                textView.text = "Hi, let's unleash your gameplay!"
                
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

extension PostVC {
    
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


extension PostVC: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        
        return 1

    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        return itemList.count
    }
    
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        var pickerLabel: UILabel? = (view as? UILabel)
        if pickerLabel == nil {
            pickerLabel = UILabel()
            pickerLabel?.backgroundColor = UIColor.darkGray
            pickerLabel?.font = UIFont.systemFont(ofSize: 15)
            pickerLabel?.textAlignment = .center
        }
        
        pickerLabel?.text = itemList[row].name
        pickerLabel?.textColor = UIColor.white

        return pickerLabel!
    }
    
   
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
       
        if let imgUrl = URL.init(string: itemList[row].cover) {
          
            imageStorage.async.object(forKey: itemList[row].cover) { result in
                if case .value(let image) = result {
                    
                    DispatchQueue.main.async {
                        self.gameImage.image = image
                    }
                   
                   
                } else {
                    
                    AF.request(imgUrl).responseImage { [weak self] response in
                       guard let self = self else { return }
                       switch response.result {
                        case let .success(value):
                           
                          
                           DispatchQueue.main.async {
                               self.gameImage.image = value
                           }
                           
                           try? imageStorage.setObject(value, forKey: itemList[row].cover, expiry: .date(Date().addingTimeInterval(2 * 3600)))
                                              
                               case let .failure(error):
                                   print(error)
                            }
                                          
                      }
                    
                }
            }
            
        }
        
        selectedGameId = itemList[row]._id
    
        
    }
    
    
}
