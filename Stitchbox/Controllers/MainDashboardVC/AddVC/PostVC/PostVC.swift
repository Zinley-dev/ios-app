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

class PostVC: UIViewController {

    
    enum updateMedia {
        case image
        case video
    }
    
    
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
    @IBOutlet weak var descTxtView: UITextView!
    @IBOutlet weak var addBtn: UIButton!
    @IBOutlet weak var globalBtn: UIButton!
    @IBOutlet weak var followingBtn: UIButton!
    @IBOutlet weak var privateBtn: UIButton!
    @IBOutlet weak var hashtagBtn: UIButton!
    @IBOutlet weak var allowCmtSwitch: UISwitch!
    
    var hashtagList = [String]()
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
 
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        container.editControllerDelegate = self
        global_fullLink = ""
        global_host = ""
        wireDelegate()
        setupButtons()
        setupDefaultView()
        setupScrollView()
        setupTextView()
        setupGesture()
        loadPreviousSetting()
        
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

extension PostVC {
    
    func loadPreviousSetting() {
        
        APIManager().getLastSettingPost { result in
            switch result {
            case .success(let apiResponse):
                
                guard let data = apiResponse.body?["data"] as? [[String: Any]]  else {
                    print("Couldn't cast data")
                    return
                }
                
                if let settings = data.first?["settings"] as? [String: Any] {
                    
                    if let allowcomment = settings["allowcomment"] as? Bool {
                        
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
                                        
                                self.publicLbl.textColor = .secondary
                                self.followLbl.textColor = .lightGray
                                self.onlyMeLbl.textColor = .lightGray
                                
                            }
   
                        } else if mode == 1 {
                            
                            self.mode = mode
                            
                            DispatchQueue.main.async {
                                
                                self.globalBtn.setImage(UIImage(named: "public"), for: .normal)
                                self.followingBtn.setImage(UIImage(named: "selectedFollowing"), for: .normal)
                                self.privateBtn.setImage(UIImage(named: "onlyme"), for: .normal)
                                        
                                self.publicLbl.textColor = .lightGray
                                self.followLbl.textColor = .secondary
                                self.onlyMeLbl.textColor = .lightGray
                                
                            }
                            
                            
                        } else if mode == 2 {
                            
                            self.mode = mode
                            
                            DispatchQueue.main.async {
                                
                                self.globalBtn.setImage(UIImage(named: "public"), for: .normal)
                                self.followingBtn.setImage(UIImage(named: "following"), for: .normal)
                                self.privateBtn.setImage(UIImage(named: "selectedOnlyme"), for: .normal)
                                        
                                        
                                self.publicLbl.textColor = .lightGray
                                self.followLbl.textColor = .lightGray
                                self.onlyMeLbl.textColor = .secondary
                                
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
                    
                }
                
                if let video = data.first?["video"] as? [String: Any] {
                    
                    if let streamUrl = video["streamurl"] as? String, streamUrl != "" {
                        
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
                        
                        DispatchQueue.main.async {
                            SwiftLoader.hide()
                            showNote(text: "Your post is being uploaded")
                            self.dismiss(animated: true)
                        }
                        
                        self.uploadImageToDB(image: checkImage)
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
                            
                DispatchQueue.main.async {
                    SwiftLoader.hide()
                    //showNote(text: "Thank you, your video is being uploaded!")
                    self.dismiss(animated: true, completion: nil)
                    NotificationCenter.default.post(name: (NSNotification.Name(rawValue: "switchvc")), object: nil)
                   
                }

                
                Dispatch.background {
                    
                    print("Start uploading video to db")
                    self.uploadVideoToDB(url: self.exportedURL)
                    
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


    
    
    func uploadImageToDB(image: UIImage) {
        
        APIManager().uploadImage(image: image) { result in
            
            switch result {
            case .success(let apiResponse):
                
                guard apiResponse.body?["message"] as? String == "avatar uploaded successfully",
                      let url = apiResponse.body?["url"] as? String  else {
                        return
                }
                
                self.writeContentImageToDB(imageUrl: url)


            case .failure(let error):
                print(error)
            }
            
            
        }
        
        
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
    
    
    func uploadVideoToDB(url: URL) {
    
        let data = try! Data(contentsOf: url)
        
        APIManager().uploadVideo(video: data) { result in
            
            switch result {
            case .success(let apiResponse):
            
                
                guard apiResponse.body?["message"] as? String == "video uploaded successfully",
                    let data = apiResponse.body?["data"] as? [String: Any] else {
                        return
                }
                

                // Try to create a SendBirdRoom object from the data
                let videoInfo =  Mapper<VideoPostModel>().map(JSONObject: data)
                let downloadedUrl = videoInfo?.video_url ?? ""
               
                if downloadedUrl != "" {
                    self.writeContentVideoToDB(videoUrl: downloadedUrl)
                } else {
                    print("Couldn't get video url")
                }
                

            case .failure(let error):
                global_percentComplete = 0.00
                print(error)
            }
            
        } process: { percent in
            global_percentComplete = Double(percent)
            NotificationCenter.default.post(name: (NSNotification.Name(rawValue: "updateProgressBar")), object: nil)
            print("Uploading ... \(percent)%")
        }

    }
    
    
    func writeContentImageToDB(imageUrl: String) {
        
        guard let userDataSource = _AppCoreData.userDataSource.value, let userUID = userDataSource.userID, userUID != "" else {
            print("Can't get userDataSource")
            return
        }

        let loadUsername = userDataSource.userName
        
        var contentPost = [String: Any]()
        
        contentPost = ["content": selectedDescTxtView, "images": [imageUrl], "tags": [userUID]]
        
        var update_hashtaglist = [String]()
        
        if hashtagList.isEmpty == true {
            
            update_hashtaglist = ["#\(loadUsername ?? "")"]
            
        } else {
            
            update_hashtaglist = hashtagList
            if !update_hashtaglist.contains("#\(loadUsername ?? "")") {
                update_hashtaglist.insert("#\(loadUsername ?? "")", at: 0)
            }
            
        }
        
        contentPost["setting"] = ["mode": mode as Any, "allowcomment": isAllowComment, "stream_link": global_fullLink, "length": length!, "is_hashtaged": true, "origin_width": origin_width!, "origin_height": origin_height!, "isTitleCmt": false, "languageCode": Locale.current.languageCode!, "mediaType": mediaType, "hashtag_list": update_hashtaglist]

        APIManager().createPost(params: contentPost) { result in
            switch result {
            case .success(let apiResponse):
                
                print("Posted successfully \(apiResponse)")
            

            case .failure(let error):
                print(error)
            }
        }
        
        
    }
    
    
    
    func writeContentVideoToDB(videoUrl: String) {
 
        guard let userDataSource = _AppCoreData.userDataSource.value, let userUID = userDataSource.userID, userUID != "" else {
            print("Can't get userDataSource")
            return
        }
        
        
        let videoData =  ["raw_url": videoUrl]
        
        
        let loadUsername = userDataSource.userName
        
        var contentPost = [String: Any]()
        
        contentPost = ["content": selectedDescTxtView, "video": videoData, "tags": [userUID]]
        
        var update_hashtaglist = [String]()
        
        if hashtagList.isEmpty == true {
            
            update_hashtaglist = ["#\(loadUsername ?? "")"]
            
        } else {
            
            update_hashtaglist = hashtagList
            if let username = loadUsername {
                if !update_hashtaglist.contains("#\(username)") {
                    update_hashtaglist.insert("#\(username)", at: 0)
                }
            }
            
            
        }
        
        contentPost["setting"] = ["mode": mode as Any, "allowcomment": isAllowComment, "stream_link": global_fullLink, "length": length!, "is_hashtaged": true, "origin_width": origin_width!, "origin_height": origin_height!, "isTitleCmt": false, "languageCode": Locale.current.languageCode!, "mediaType": mediaType, "hashtag_list": update_hashtaglist]

        APIManager().createPost(params: contentPost) { result in
            switch result {
            case .success(let apiResponse):
                
                print("Posted successfully \(apiResponse)")
            

            case .failure(let error):
                print(error)
            }
        }

        
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
        
        publicLbl.textColor = .secondary
        followLbl.textColor = .lightGray
        onlyMeLbl.textColor = .lightGray
        
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
        
        // Do any additional setup after loading the view.
        backButton.setImage(UIImage.init(named: "back_icn_white")?.resize(targetSize: CGSize(width: 13, height: 23)), for: [])
        backButton.addTarget(self, action: #selector(onClickBack(_:)), for: .touchUpInside)
        backButton.frame = back_frame
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
            layout.scrollDirection = .vertical
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

extension PostVC {
    
    @objc func onClickBack(_ sender: AnyObject) {
        
        if let navigationController = self.navigationController {
            navigationController.dismiss(animated: true)
            NotificationCenter.default.post(name: (NSNotification.Name(rawValue: "switchvcToIndex")), object: nil)
        }
    }
    
    @objc func onClickPost(_ sender: AnyObject) {
        
        if global_percentComplete == 0.00 || global_percentComplete == 100.0 {
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
