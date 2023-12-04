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
import SCLAlertView

class PostVC: UIViewController {

    // Enumeration for different media update types
    enum UpdateMedia {
        case image
        case video
    }

    // IBOutlets for user interface components
    @IBOutlet weak var addView: UIView!
    @IBOutlet weak var stitchView: UIView!
    @IBOutlet weak var categoryInput: UITextField!
    @IBOutlet weak var addLbl: UILabel!
    @IBOutlet weak var hiddenHashTagTxtField: UITextField!
    @IBOutlet weak var stitchLbl: UILabel!
    @IBOutlet weak var onlyMeLbl: UILabel!
    @IBOutlet weak var publicLbl: UILabel!
    @IBOutlet weak var streamingLinkBtn: UIButton!
    @IBOutlet weak var avatarImage: UIImageView!
    @IBOutlet weak var settingViewHeight: NSLayoutConstraint!
    @IBOutlet weak var descTxtView: UITextView!
    @IBOutlet weak var addBtn: UIButton!
    @IBOutlet weak var globalBtn: UIButton!
    @IBOutlet weak var privateBtn: UIButton!
    @IBOutlet weak var allowCmtSwitch: UISwitch!

    // Instance variables for the view controller
    var stitchPost: PostModel!
    var itemList = [GameList]()
    var hashtagList = [String]()
    var mode = 0
    var isAllowComment = true
    var isAllowStitch = true
    let backButton = UIButton(type: .custom)
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
    var container: ContainerController!

    // Deinitializer for the view controller
    deinit {
        print("PostVC is being deallocated.")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Initial setup after the view loads
        initialSetup()
        
        configureContainerController()
        configureStitchPostVisibility()
        checkAndPresentTerms()
    }

    /// Performs the initial setup of the view controller.
    private func initialSetup() {
        addView.backgroundColor = .normalButtonBackground
        setupNavBar()
        setupButtons()
        setupDefaultView()
        setupTextView()
        setupGesture()
        loadPreviousSetting()
        loadAvatar()

        global_fullLink = ""
        global_host = ""
    }

    /// Configures the ContainerController.
    private func configureContainerController() {
        container = ContainerController(modes: [.library, .video], initialMode: .video, restoresPreviousMode: false)
        setupContainerControllerDelegates()
        setupLibraryController()
        setupCameraController()
    }

    /// Sets up delegates for the ContainerController.
    private func setupContainerControllerDelegates() {
        container.editControllerDelegate = self
    }

    /// Configures the library controller within the container.
    private func setupLibraryController() {
        let libraryController = container.libraryController
        libraryController.previewCropController.maxRatioForPortraitMedia = CGSize(width: 1, height: .max)
        libraryController.previewCropController.maxRatioForLandscapeMedia = CGSize(width: .max, height: 1)
        libraryController.previewCropController.defaultsToAspectFillForPortraitMedia = false
        libraryController.previewCropController.defaultsToAspectFillForLandscapeMedia = false
        libraryController.fetchPredicate = NSPredicate(format: "mediaType == %d", PHAssetMediaType.video.rawValue)
        libraryController.draftMediaTypes = [.video]
    }

    /// Configures the camera controller within the container.
    private func setupCameraController() {
        container.cameraController.aspectRatio = CGSize(width: 9, height: 16)
    }

    /// Configures the visibility of the stitch post view.
    private func configureStitchPostVisibility() {
        stitchView.isHidden = (stitchPost == nil)
    }

    /// Checks for user consent and presents terms if necessary.
    private func checkAndPresentTerms() {
        guard let stitchPost = stitchPost, !UserDefaults.standard.bool(forKey: "hasAlertContentBefore") else { return }
        delay(0.25) { [weak self] in
            self?.acceptTermStitch()
        }
    }

    
    /// Sets up the navigation bar appearance.
    func setupNavBar() {
        let navigationBarAppearance = UINavigationBarAppearance()
        navigationBarAppearance.configureWithOpaqueBackground()
        navigationBarAppearance.backgroundColor = .white
        navigationBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.black]
        navigationBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.black]
        
        self.navigationController?.navigationBar.standardAppearance = navigationBarAppearance
        self.navigationController?.navigationBar.scrollEdgeAppearance = navigationBarAppearance
    }

    /// Called when the view is about to appear.
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setupNavBar()
        registerForKeyboardNotifications()
    }

    /// Registers for keyboard show and hide notifications.
    private func registerForKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardShow),
                                               name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardHide),
                                               name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    /// Called when the view is about to disappear.
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        unregisterForKeyboardNotifications()
    }

    /// Unregisters from keyboard show and hide notifications.
    private func unregisterForKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    
    
    /// Action for when the add media button is pressed.
    @IBAction func addMediaBtnPressed(_ sender: Any) {
        presentCamera()
    }

    /// Presents the camera interface.
    func presentCamera() {
        let nav = UINavigationController(rootViewController: container)
        nav.modalPresentationStyle = .fullScreen
        self.present(nav, animated: true, completion: nil)
    }

    /// Action for when the allow comment switch is pressed.
    @IBAction func allowCmtSwitchPressed(_ sender: Any) {
        toggleAllowComment()
    }

    /// Toggles the 'allow comment' setting.
    private func toggleAllowComment() {
        isAllowComment.toggle()
        allowCmtSwitch.setOn(isAllowComment, animated: true)
        print("Allow comment: \(isAllowComment)")
    }

    /// Action for when the global button is pressed.
    @IBAction func globalBtnPressed(_ sender: Any) {
        setModeToPublic()
        updateModeUI(isPublicMode: true)
    }

    /// Sets the mode to public.
    private func setModeToPublic() {
        mode = 0 // Assuming 0 represents the public mode
    }

    
    /// Handles the action when the private button is pressed.
    @IBAction func privateBtnPressed(_ sender: Any) {
        setModeToPrivate()
        updateModeUI(isPublicMode: false)
    }

    /// Sets the mode to private.
    private func setModeToPrivate() {
        mode = 2 // Assuming 2 represents the private mode
    }


    /// Overrides the method to dismiss the keyboard when touching outside of an input field.
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        requestToDismissKeyboard()
    }

    /// Dismisses the keyboard.
    private func requestToDismissKeyboard() {
        isKeyboardShow = false
        self.view.endEditing(true)
    }

    /// Handles the action when the stitch button is pressed.
    @IBAction func stitchBtnPressed(_ sender: Any) {
        navigateToPreviewVC()
    }

    /// Navigates to the PreviewVC with the selected post.
    private func navigateToPreviewVC() {
        if let SPVC = UIStoryboard(name: "Dashboard", bundle: nil).instantiateViewController(withIdentifier: "PreviewVC") as? PreviewVC {
            SPVC.selectedPost = [stitchPost]
            SPVC.startIndex = 0
            self.navigationController?.pushViewController(SPVC, animated: true)
        }
    }

    
}

extension PostVC {
    
    
    /// Loads the user's avatar image from a URL.
    func loadAvatar() {
        guard let avatarUrlString = _AppCoreData.userDataSource.value?.avatarURL,
              let url = URL(string: avatarUrlString), !avatarUrlString.isEmpty else {
            return // Early return if URL is not valid or empty
        }

        avatarImage.load(url: url, str: avatarUrlString)
    }
    
    
    /// Loads previous settings from the API and updates the UI accordingly.
    func loadPreviousSetting() {
        APIManager.shared.getLastSettingPost { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .success(let apiResponse):
                self.handleApiResponse(apiResponse)
            case .failure(let error):
                self.handleApiError(error)
            }
        }
    }

    /// Handles the successful API response.
    /// - Parameter apiResponse: The response received from the API.
    private func handleApiResponse(_ apiResponse: APIResponse) {
        guard let data = apiResponse.body?["data"] as? [[String: Any]],
              let settings = data.first?["setting"] as? [String: Any] else {
            DispatchQueue.main.async { self.setDefaultMode() }
            return
        }

        updateAllowCommentSetting(from: settings)
        updateModeSetting(from: settings)
    }

    /// Updates the 'Allow Comment' setting based on the API response.
    /// - Parameter settings: Dictionary containing the settings data.
    private func updateAllowCommentSetting(from settings: [String: Any]) {
        if let allowComment = settings["allowComment"] as? Bool {
            isAllowComment = allowComment
            DispatchQueue.main.async { self.allowCmtSwitch.setOn(allowComment, animated: true) }
        }
    }

    /// Updates the mode setting based on the API response.
    /// - Parameter settings: Dictionary containing the settings data.
    private func updateModeSetting(from settings: [String: Any]) {
        guard let mode = settings["mode"] as? Int else {
            DispatchQueue.main.async { self.setDefaultMode() }
            return
        }
        
        self.mode = mode
        let isPublicMode = (mode == 0)
        DispatchQueue.main.async { self.updateModeUI(isPublicMode: isPublicMode) }
    }

    /// Updates the UI based on the mode.
    /// - Parameter isPublicMode: Boolean indicating if the mode is public.
    private func updateModeUI(isPublicMode: Bool) {
        let publicImageName = isPublicMode ? "selectedPublic" : "public"
        let privateImageName = isPublicMode ? "onlyme" : "selectedOnlyme"
        let publicTextColor = isPublicMode ? UIColor.black : UIColor.lightGray
        let privateTextColor = isPublicMode ? UIColor.lightGray : UIColor.black

        globalBtn.setImage(UIImage(named: publicImageName)?.resize(targetSize: CGSize(width: 30, height: 30)), for: .normal)
        privateBtn.setImage(UIImage(named: privateImageName)?.resize(targetSize: CGSize(width: 30, height: 30)), for: .normal)
        publicLbl.textColor = publicTextColor
        onlyMeLbl.textColor = privateTextColor
    }

    /// Handles errors received from the API.
    /// - Parameter error: The error that occurred.
    private func handleApiError(_ error: Error) {
        DispatchQueue.main.async { self.setDefaultMode() }
        print(error)
    }

    
    /// Handles the click event for the post button.
    /// - Parameter sender: The object that triggered the event.
    @objc func onClickPost(_ sender: AnyObject) {
        // Checking if there is no ongoing upload or if the upload is complete
        guard isUploadReady() else {
            showErrorAlert("Oops!", msg: "Your current post is being uploaded, please try again later.")
            return
        }

        // Determining the action based on the media type
        switch mediaType {
        case "image":
            //uploadImage() // Call the relevant function for image upload
            break // Placeholder until the actual image upload functionality is implemented
        case "video":
            uploadVideo()
        default:
            showErrorAlert("Oops!", msg: "Unknown media type selected, please try again.")
        }
    }

    /// Checks if the media is ready for upload.
    /// - Returns: Boolean indicating if the upload is ready to begin.
    private func isUploadReady() -> Bool {
        return global_percentComplete == 0.00 || global_percentComplete == 100.0
    }
    
    
    /// Initiates the video upload process.
    func uploadVideo() {
        // Checking if the selected video duration is greater than the minimum required duration
        guard selectedVideo.duration.seconds > 3.0 else {
            showErrorAlert("Oops!", msg: "Please upload a video with a duration longer than 3 seconds.")
            return
        }
        
        print("Start exporting")
        exportVideo(video: selectedVideo) { [weak self] in
            guard let self = self else { return }

            // Uploading the video in a background thread
            self.uploadVideoToDatabase()

            // Performing UI updates in the main thread after upload initiation
            self.performPostUploadUIActions()
        }
    }

    /// Uploads the video to the database.
    private func uploadVideoToDatabase() {
        Dispatch.background { [weak self] in
            guard let self = self else { return }
            
            print("Start uploading video to db")
            self.uploadVideoContent()
        }
    }

    /// Uploads the video content based on whether a stitch post exists.
    private func uploadVideoContent() {
        let stitchId = stitchPost?.id ?? ""
        UploadContentManager.shared.uploadVideoToDB(url: exportedURL, hashtagList: hashtagList, selectedDescTxtView: selectedDescTxtView, isAllowComment: isAllowComment, mediaType: mediaType, mode: mode, origin_width: origin_width, origin_height: origin_height, length: length, isAllowStitch: isAllowStitch, stitchId: stitchId)
    }

    /// Performs UI updates after initiating the video upload.
    private func performPostUploadUIActions() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            SwiftLoader.hide()
            showNote(text: "Thank you, your content is being uploaded!")
            self.dismiss(animated: true, completion: nil)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "switchvc"), object: nil)
        }
    }

    
    func exportImage(currentImage: SessionImage, completed: @escaping DownloadComplete) {

    }

    
    /// Exports a given video and handles progress updates and completion.
    /// - Parameters:
    ///   - video: The SessionVideo to be exported.
    ///   - completed: A closure to be called when the export is complete.
    func exportVideo(video: SessionVideo, completed: @escaping DownloadComplete) {
        VideoExporter.shared.export(video: video,
                                    progress: handleExportProgress,
                                    completion: handleExportCompletion(video: video, completed: completed))
    }

    /// Handles the export progress updates.
    /// - Parameter progress: The current progress of the export.
    private func handleExportProgress(progress: Double) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.updateExportProgress(progress: progress)
        }
    }

    /// Updates the UI based on the current export progress.
    /// - Parameter progress: The current progress of the export.
    private func updateExportProgress(progress: Double) {
        let formattedProgress = String(format: "%.2f", progress * 100)
        swiftLoader(progress: "Exporting: \(formattedProgress)%")
    }

    /// Handles the completion of the export.
    /// - Parameters:
    ///   - video: The SessionVideo that was exported.
    ///   - completed: The closure to call after handling completion.
    /// - Returns: A closure that takes an optional error.
    private func handleExportCompletion(video: SessionVideo, completed: @escaping DownloadComplete) -> ((Error?) -> Void) {
        return { [weak self] error in
            guard let self = self else { return }
            DispatchQueue.main.async { SwiftLoader.hide() }

            if let error = error {
                self.handleExportError(error)
                return
            }

            self.updateVideoInformation(video: video)
            completed()
        }
    }

    /// Handles the error occurred during video export.
    /// - Parameter error: The error occurred during export.
    private func handleExportError(_ error: Error) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.showErrorAlert("Ops!", msg: "Unable to export video: \(error)")
        }
        print("Unable to export video: \(error)")
    }

    /// Updates the video information after successful export.
    /// - Parameter video: The exported SessionVideo.
    private func updateVideoInformation(video: SessionVideo) {
        self.exportedURL = video.exportedVideoURL
        self.origin_width = video.renderSize.width
        self.origin_height = video.renderSize.height
        self.length = video.duration.seconds
    }

}


extension PostVC {

    // MARK: - Setup Methods

    /// Sets up the gesture recognizer for the description text view.
    func setupGesture() {
        let descTap = UITapGestureRecognizer(target: self, action: #selector(PostVC.dismissKeyboardOnTap))
        descTxtView.isUserInteractionEnabled = true
        descTxtView.addGestureRecognizer(descTap)
    }

    /// Sets up the description text view.
    func setupTextView() {
        descTxtView.delegate = self
    }

    /// Sets the default mode for the post view controller.
    func setDefaultMode() {
        mode = 0 // Assuming mode 0 is the default mode

        globalBtn.setImage(UIImage(named: "selectedPublic"), for: .normal)
        privateBtn.setImage(UIImage(named: "onlyme"), for: .normal)
        
        publicLbl.textColor = .black
        onlyMeLbl.textColor = .lightGray
    }

    /// Sets up various buttons in the view controller.
    func setupButtons() {
        setupBackButton()
        createDisablePostBtn()
        emptyBtnLbl()
    }

    /// Creates a disabled post button.
    func createDisablePostBtn() {
        configurePostButton(withTarget: nil, titleColor: .black, backgroundColor: .lightGray, buttonLabel: "Add")
    }

    /// Creates an enabled post button.
    func createPostBtn() {
        configurePostButton(withTarget: #selector(onClickPost(_:)), titleColor: .white, backgroundColor: .secondary, buttonLabel: "Added")
    }

    /// Configures the post button with given attributes.
    private func configurePostButton(withTarget target: Selector?, titleColor: UIColor, backgroundColor: UIColor, buttonLabel: String) {
        addLbl.text = buttonLabel
        let createButton = UIButton(type: .custom)
        if let target = target {
            createButton.addTarget(self, action: target, for: .touchUpInside)
        }
        createButton.semanticContentAttribute = .forceRightToLeft
        createButton.setTitle("Post", for: .normal)
        createButton.setTitleColor(titleColor, for: .normal)
        createButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        createButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 2, bottom: 0, right: -2)
        createButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: -2, bottom: 0, right: 2)
        createButton.frame = CGRect(x: 0, y: 0, width: 80, height: 30)
        createButton.backgroundColor = backgroundColor
        createButton.cornerRadius = 15
        createBarButton(withButton: createButton)
    }

    /// Creates and sets a navigation bar button with the given button.
    private func createBarButton(withButton button: UIButton) {
        let customView = UIView(frame: CGRect(x: 0, y: 0, width: 80, height: 30))
        customView.addSubview(button)
        button.center = customView.center
        let createBarButton = UIBarButtonItem(customView: customView)
        let fixedSpace = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        fixedSpace.width = 2
        self.navigationItem.rightBarButtonItem = createBarButton
    }

    /// Sets up the back button on the navigation bar.
    func setupBackButton() {
        backButton.frame = back_frame
        backButton.contentMode = .center
        configureBackButtonImage()
        backButton.addTarget(self, action: #selector(onClickBack(_:)), for: .touchUpInside)
        backButton.setTitleColor(UIColor.white, for: .normal)
        navigationItem.title = "Create Post"
        setNavigationItem(withButton: backButton)
    }

    /// Configures the image for the back button.
    private func configureBackButtonImage() {
        if let backImage = UIImage(named: "back-black") {
            let imageSize = CGSize(width: 13, height: 23)
            let padding = UIEdgeInsets(top: (back_frame.height - imageSize.height) / 2,
                                       left: (back_frame.width - imageSize.width) / 2 - horizontalPadding,
                                       bottom: (back_frame.height - imageSize.height) / 2,
                                       right: (back_frame.width - imageSize.width) / 2 + horizontalPadding)
            backButton.imageEdgeInsets = padding
            backButton.setImage(backImage, for: [])
        }
    }

    /// Sets the given button as a left navigation item.
    private func setNavigationItem(withButton button: UIButton) {
        let backButtonBarButton = UIBarButtonItem(customView: button)
        self.navigationItem.leftBarButtonItem = backButtonBarButton
    }

    /// Clears the titles of various buttons.
    func emptyBtnLbl() {
        addBtn.setTitle("", for: .normal)
        globalBtn.setTitle("", for: .normal)
        privateBtn.setTitle("", for: .normal)
        streamingLinkBtn.setTitle("", for: .normal)
    }

    /// Sets up the default view for the view controller.
    /// Sets up the default view by adjusting the setting view height based on the presence of a stitch post.
    func setupDefaultView() {
        settingViewHeight.constant = stitchPost == nil ? 175 : 225
    }
}


extension PostVC {

    // MARK: - User Interaction Handlers

    /// Handles the back button click event.
    /// - Parameter sender: The object that triggered the event.
    @objc func onClickBack(_ sender: AnyObject) {
        // Dismissing the view controller if it is embedded in a navigation controller
        if let navigationController = self.navigationController {
            navigationController.dismiss(animated: true)
            // Notifying other parts of the app that the view controller has been dismissed
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "switchvcToIndex"), object: nil)
        }
    }

    // MARK: - Keyboard Event Handlers

    /// Handles the keyboard show event.
    /// - Parameter notification: The notification object containing keyboard information.
    @objc func handleKeyboardShow(notification: Notification) {
        isKeyboardShow = true
    }

    /// Handles the keyboard hide event.
    /// - Parameter notification: The notification object containing keyboard information.
    @objc func handleKeyboardHide(notification: Notification) {
        isKeyboardShow = false
    }

    // MARK: - Gesture Handlers

    /// Dismisses the keyboard on tap or brings the text view into focus, depending on the keyboard state.
    /// - Parameter sender: The object that triggered the event.
    @objc func dismissKeyboardOnTap(sender: AnyObject!) {
        // Dismissing the keyboard if it is visible
        if isKeyboardShow {
            self.view.endEditing(true)
        } else {
            // Bringing the text view into focus otherwise
            descTxtView.becomeFirstResponder()
        }
    }
}


extension PostVC: EditControllerDelegate {

    // MARK: - EditControllerDelegate Methods

    /// Called when the EditController's view has loaded.
    /// - Parameters:
    ///   - editController: The EditController instance.
    ///   - session: The PixelSDKSession that was loaded.
    func editController(_ editController: EditController, didLoadEditing session: PixelSDKSession) {
        print("EditController view did load")
    }
    
    /// Called when editing is finished in the EditController.
    /// - Parameters:
    ///   - editController: The EditController instance.
    ///   - session: The PixelSDKSession that has finished editing.
    func editController(_ editController: EditController, didFinishEditing session: PixelSDKSession) {
        // Handling the media based on its type (video or image)
        if let video = session.video {
            mediaType = "video"
            selectedVideo = video
        } else if let image = session.image {
            selectedImage = image
            mediaType = "image"
        }

        // Creating the post button after editing is finished
        createPostBtn()

        // Dismissing the EditController
        self.dismiss(animated: true, completion: nil)
    }

    /// Called when editing is cancelled in the EditController.
    /// - Parameters:
    ///   - editController: The EditController instance.
    ///   - session: The PixelSDKSession that was cancelled.
    func editController(_ editController: EditController, didCancelEditing session: PixelSDKSession?) {
        print("Editing was cancelled in EditController")
    }
}


extension PostVC: UITextViewDelegate {

    // MARK: - UITextViewDelegate Methods

    /// Called when the user begins editing the text view.
    /// - Parameter textView: The UITextView that began editing.
    func textViewDidBeginEditing(_ textView: UITextView) {
        // Checking if the specific text view is being edited
        if textView == descTxtView {
            // Clearing the default text when editing begins
            if textView.text == "Got something fun to share? Keep it snappy – max 100 characters! 😊" {
                textView.text = ""
            }
        }
    }

    /// Called when the user ends editing the text view.
    /// - Parameter textView: The UITextView that ended editing.
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView == descTxtView {
            // Restoring the default text if the text view is empty
            if textView.text.isEmpty {
                textView.text = "Got something fun to share? Keep it snappy – max 100 characters! 😊"
            } else {
                // Storing the entered text for further use
                selectedDescTxtView = textView.text
            }
        }
    }

    /// Called to determine if the text should be changed.
    /// - Parameters:
    ///   - textView: The UITextView containing the changes.
    ///   - range: The range of characters to be replaced.
    ///   - text: The replacement text.
    /// - Returns: Boolean value indicating if the text should be changed.
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        // Calculating the new text length after the replacement
        let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
        let numberOfChars = newText.count

        // Allowing change only if the new text is within the character limit
        return numberOfChars <= 100 // Character limit is 100
    }
}


extension PostVC {
    
    /// Displays an error alert with a given title and message.
    /// - Parameters:
    ///   - title: The title of the alert.
    ///   - msg: The message to be displayed in the alert.
    func showErrorAlert(_ title: String, msg: String) {
        // Creating an alert controller with the provided title and message
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        
        // Adding an 'OK' action to the alert for dismissal
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        
        // Presenting the alert
        present(alert, animated: true, completion: nil)
    }

    
    /// Configures and displays a loading spinner with a progress title.
    /// - Parameter progress: The progress title to be displayed with the loader.
    func swiftLoader(progress: String) {
        // Initializing the configuration for the SwiftLoader
        var config = SwiftLoader.Config()
        config.size = 170 // Setting the size of the loader
        config.backgroundColor = UIColor.clear
        config.spinnerColor = UIColor.white
        config.titleTextColor = UIColor.white
        config.spinnerLineWidth = 3.0
        config.foregroundColor = UIColor.black
        config.foregroundAlpha = 0.7 // Setting background color and transparency

        // Applying the configuration to the SwiftLoader
        SwiftLoader.setConfig(config: config)
        
        // Displaying the loader with the provided progress title
        SwiftLoader.show(title: progress, animated: true)
    }

    
    
    func acceptTermStitch() {
        // Checking if the username is available
        if let username = _AppCoreData.userDataSource.value?.userName {
            
            // Customizing the appearance of the alert
            let appearance = SCLAlertView.SCLAppearance(
                kTitleFont: FontManager.shared.roboto(.Medium, size: 15),
                kTextFont: FontManager.shared.roboto(.Regular, size: 13),
                kButtonFont: FontManager.shared.roboto(.Medium, size: 13),
                showCloseButton: false,
                dynamicAnimatorActive: true,
                buttonsLayout: .horizontal
            )
            
            // Initializing the alert with the custom appearance
            let alert = SCLAlertView(appearance: appearance)
            
            // Adding a 'Decline' button to the alert
            _ = alert.addButton("Decline", backgroundColor: .normalButtonBackground, textColor: .black) {
                // Action for the Decline button
                self.showNoteAndDismiss(text: "Thank you and feel free to enjoy other videos at Stitchbox!")
            }

            // Adding an 'Agree' button to the alert
            _ = alert.addButton("Agree", backgroundColor: UIColor.secondary, textColor: .white) {
                // Action for the Agree button
                self.updateUserConsentInUserDefaults()
                showNote(text: "Thank you and enjoy Stitch!")
            }
            
            // Terms to be displayed in the alert
            let terms = "Ensure your content maintains relevance to the original topic. Exhibit respect towards the original author in your content. Abide by our terms of use and guidelines in the creation of your content."
            
            // Adding an icon to the alert
            let icon = UIImage(named:"fistBumpedStats")
            
            // Displaying the alert
            _ = alert.showCustom("Hi \(username),", subTitle: terms, color: UIColor.white, icon: icon!)
        }
    }

    // Function to show a note and dismiss the view
    private func showNoteAndDismiss(text: String) {
        showNote(text: text)
        self.dismiss(animated: true)
    }

    // Function to update user consent in UserDefaults
    private func updateUserConsentInUserDefaults() {
        let userDefaults = UserDefaults.standard
        userDefaults.set(true, forKey: "hasAlertContentBefore")
        userDefaults.synchronize() // Forcing the app to update UserDefaults
    }

}
