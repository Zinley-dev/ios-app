//
//  EditPostVC.swift
//  Stitchbox
//
//  Created by Khoi Nguyen on 2/3/23.
//

import UIKit

class EditPostVC: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var playImg: UIImageView!
    @IBOutlet weak var thumbnailImg: UIImageView!
    @IBOutlet weak var hiddenHashTagTxtField: UITextField!
    @IBOutlet weak var onlyMeLbl: UILabel!
    @IBOutlet weak var publicLbl: UILabel!
    @IBOutlet weak var avatarImage: UIImageView!
    @IBOutlet weak var settingViewHeight: NSLayoutConstraint!
    @IBOutlet weak var descTxtView: UITextView!
    @IBOutlet weak var globalBtn: UIButton!
    @IBOutlet weak var privateBtn: UIButton!
    @IBOutlet weak var allowCmtSwitch: UISwitch!

    // MARK: - Properties
    var backButton: UIButton = UIButton(type: .custom)
    var isAllowStitch = true
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
    var firstLoad = true

    // Global variables (consider moving these to a more appropriate place if they're used across multiple view controllers)
    var global_host = ""
    var global_fullLink = ""

    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }

    // MARK: - UI Setup
    private func setupUI() {
        setupButtons()
        settingAllDefaultValues()
        setupTextView()
        setupGesture()
        // Any other UI setup code can be added here
    }
    
    
    // MARK: - View Lifecycle Methods

    /// Prepares the view controller's UI and sets up necessary notifications when the view is about to appear.
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureNavigationBarAppearance()
        registerForKeyboardNotifications()
    }

    /// Cleans up notifications when the view is about to disappear.
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        deregisterFromKeyboardNotifications()
    }

    // MARK: - Private Helpers

    /// Configures the appearance of the navigation bar.
    private func configureNavigationBarAppearance() {
        let navigationBarAppearance = UINavigationBarAppearance()
        navigationBarAppearance.configureWithOpaqueBackground()
        navigationBarAppearance.backgroundColor = .white
        navigationBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.black]
        navigationBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.black]
        navigationController?.navigationBar.standardAppearance = navigationBarAppearance
        navigationController?.navigationBar.scrollEdgeAppearance = navigationBarAppearance
    }

    /// Registers the view controller to receive keyboard show and hide notifications.
    private func registerForKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardShow),
                                               name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardHide),
                                               name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    /// Deregisters the view controller from receiving keyboard notifications.
    private func deregisterFromKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    /// Toggles the state of the allow comment switch.
    @IBAction func allowCmtSwitchPressed(_ sender: Any) {
        isAllowComment.toggle()
        allowCmtSwitch.setOn(isAllowComment, animated: true)
    }
    
    
    // MARK: - Action Handlers

    /// Action for when the global button is pressed.
    @IBAction func globalBtnPressed(_ sender: Any) {
        mode = 0
        updateModeDisplay()
    }

    /// Action for when the private button is pressed.
    @IBAction func privateBtnPressed(_ sender: Any) {
        mode = 2
        updateModeDisplay()
    }

    /// Overrides the touchesBegan method to dismiss the keyboard when touching outside of an input field.
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        isKeyboardShow = false
        view.endEditing(true)
    }

    // MARK: - Private Helpers

    /// Updates the UI elements based on the current mode.
    private func updateModeDisplay() {
        let isGlobalSelected = mode == 0
        let globalImageName = isGlobalSelected ? "selectedPublic" : "public"
        let privateImageName = isGlobalSelected ? "onlyme" : "selectedOnlyme"
        globalBtn.setImage(UIImage(named: globalImageName)?.resize(targetSize: CGSize(width: 30, height: 30)), for: .normal)
        privateBtn.setImage(UIImage(named: privateImageName)?.resize(targetSize: CGSize(width: 30, height: 30)), for: .normal)
        publicLbl.textColor = isGlobalSelected ? .black : .lightGray
        onlyMeLbl.textColor = isGlobalSelected ? .lightGray : .black
    }

    
}


extension EditPostVC {

    // MARK: - Configuration Methods

    /// Loads the user's avatar from a URL.
    func loadAvatar() {
        guard let avatarUrlString = _AppCoreData.userDataSource.value?.avatarURL,
              let url = URL(string: avatarUrlString), !avatarUrlString.isEmpty else {
            // Consider adding a default image or handling for when avatar URL is not available
            return
        }

        avatarImage.load(url: url, str: avatarUrlString)
    }

    /// Sets up all the buttons used in the view controller.
    func setupButtons() {
        setupBackButton()
        createPostBtn()
        emptyBtnLbl() // Consider renaming for clarity, e.g., `clearButtonLabels`
    }

    /// Sets all default values for the view controller.
    func settingAllDefaultValues() {
        setDefaultDesc()
        setDefaultMedia()
        setDefaultMode()
        setDefaultComment()
        loadAvatar()
    }

    // MARK: - Private Helpers

    // If there are any helper methods that are used within these functions, consider adding them here.
    // For example, methods that assist in setting up UI elements or processing data.

}


extension EditPostVC {

    // MARK: - UI Setup Methods

    /// Configures the back button with appropriate styling and adds it to the navigation bar.
    func setupBackButton() {
        configureBackButton()
        let backButtonBarButton = UIBarButtonItem(customView: backButton)
        navigationItem.leftBarButtonItem = backButtonBarButton
        navigationItem.title = "Edit Post"
    }

    /// Sets up tap gesture recognizer for the description text view.
    func setupGesture() {
        let descTap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboardOnTap))
        descTxtView.isUserInteractionEnabled = true
        descTxtView.addGestureRecognizer(descTap)
    }

    /// Configures the text view and sets its delegate.
    func setupTextView() {
        descTxtView.delegate = self
    }

    // MARK: - Private Helpers

    /// Configures the back button's appearance and action.
    private func configureBackButton() {
        backButton.frame = back_frame
        backButton.contentMode = .center
        backButton.setTitleColor(.white, for: .normal)
        backButton.setTitle("", for: .normal)
        backButton.addTarget(self, action: #selector(onClickBack(_:)), for: .touchUpInside)

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
}


extension EditPostVC {

    // MARK: - Default Settings Methods

    /// Sets the default state for the comment switch based on the selected post's settings.
    func setDefaultComment() {
        isAllowComment = selectedPost.setting?.allowComment ?? false
        allowCmtSwitch.setOn(isAllowComment, animated: true)
    }

    /// Sets the default description in the text view from the selected post.
    func setDefaultDesc() {
        descTxtView.text = selectedPost.content.isEmpty ? "Got something fun to share? Keep it snappy – max 100 characters! 😊" : selectedPost.content
    }

    /// Sets the default media display for the selected post.
    func setDefaultMedia() {
        loadThumbnailImage()
        playImg.isHidden = selectedPost.muxPlaybackId.isEmpty
    }

    /// Sets the default mode (public or private) based on the selected post's settings.
    func setDefaultMode() {
        mode = selectedPost.setting?.mode ?? 0
        updateModeDisplay()
    }

    // MARK: - Private Helpers

    /// Loads and sets the thumbnail image asynchronously.
    private func loadThumbnailImage() {
        DispatchQueue.global().async { [weak self] in
            guard let self = self, let data = try? Data(contentsOf: self.selectedPost.imageUrl) else { return }
            DispatchQueue.main.async {
                self.thumbnailImg.image = UIImage(data: data)
            }
        }
    }

}


extension EditPostVC {

    // MARK: - Button Creation Methods

    /// Creates a disabled post button and adds it to the navigation bar.
    func createDisablePostBtn() {
        let createButton = configureButton(title: "Save", titleColor: .lightGray, backgroundColor: .disableButtonBackground, isEnabled: false)
        addBarButton(with: createButton)
    }

    /// Creates an enabled post button and adds it to the navigation bar.
    func createPostBtn() {
        let createButton = configureButton(title: "Save", titleColor: .white, backgroundColor: .secondary, isEnabled: true)
        createButton.addTarget(self, action: #selector(onClickPost(_:)), for: .touchUpInside)
        addBarButton(with: createButton)
    }

    /// Clears the text of global and private buttons.
    func emptyBtnLbl() {
        globalBtn.setTitle("", for: .normal)
        privateBtn.setTitle("", for: .normal)
    }

    // MARK: - Private Helpers

    /// Configures a button with given properties.
    /// - Parameters:
    ///   - title: The title of the button.
    ///   - titleColor: The color of the title text.
    ///   - backgroundColor: The background color of the button.
    ///   - isEnabled: A Boolean indicating whether the button is enabled.
    /// - Returns: A configured UIButton.
    private func configureButton(title: String, titleColor: UIColor, backgroundColor: UIColor, isEnabled: Bool) -> UIButton {
        let button = UIButton(type: .custom)
        button.semanticContentAttribute = .forceRightToLeft
        button.setTitle(title, for: .normal)
        button.setTitleColor(titleColor, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: 2, bottom: 0, right: -2)
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: -2, bottom: 0, right: 2)
        button.frame = CGRect(x: 0, y: 0, width: 80, height: 30)
        button.backgroundColor = backgroundColor
        button.cornerRadius = 15
        button.isEnabled = isEnabled
        return button
    }

    /// Adds a button to the navigation bar.
    /// - Parameter button: The UIButton to add to the navigation bar.
    private func addBarButton(with button: UIButton) {
        let customView = UIView(frame: CGRect(x: 0, y: 0, width: 80, height: 30))
        customView.addSubview(button)
        button.center = customView.center

        let createBarButton = UIBarButtonItem(customView: customView)
        self.navigationItem.rightBarButtonItem = createBarButton
    }
}


extension EditPostVC {

    // MARK: - Action Methods

    /// Handles the back button click.
    @objc func onClickBack(_ sender: AnyObject) {
        navigationController?.popViewController(animated: true)
    }

    /// Handles the post button click.
    @objc func onClickPost(_ sender: AnyObject) {
        guard let contentPost = createPostContent() else { return }
        updatePost(content: contentPost)
    }

    /// Handles keyboard show notification.
    @objc func handleKeyboardShow(notification: Notification) {
        isKeyboardShow = true
    }

    /// Handles keyboard hide notification.
    @objc func handleKeyboardHide(notification: Notification) {
        isKeyboardShow = false
    }

    /// Dismisses keyboard on tap.
    @objc func dismissKeyboardOnTap(sender: AnyObject!) {
        if isKeyboardShow {
            view.endEditing(true)
        } else {
            descTxtView.becomeFirstResponder()
        }
    }

    // MARK: - Private Helpers

    /// Creates the content for a post.
    /// - Returns: A dictionary representing the post content or nil if user data is unavailable.
    private func createPostContent() -> [String: Any]? {
        guard let userDataSource = _AppCoreData.userDataSource.value,
              let userUID = userDataSource.userID, !userUID.isEmpty else {
            print("Can't get userDataSource")
            return nil
        }

        let updateText = getPostDescription()
        let updateHashtagList = getHashtags(using: userDataSource.userName)
        
        let contentPost: [String: Any] = [
            "id": selectedPost.id,
            "content": updateText,
            "hashtags": updateHashtagList, // This should be [String]
            "setting": [
                "mode": mode as Any,
                "allowComment": isAllowComment,
                "allowStitch": isAllowStitch
            ] // This is [String: Any]
        ]

        print("contentPost: \(contentPost)")
        return contentPost
    }


    /// Gets post description, excluding placeholder text.
    /// - Returns: The post description.
    private func getPostDescription() -> String {
        guard let text = descTxtView.text, text != "Got something fun to share? Keep it snappy – max 100 characters! 😊" else {
            return ""
        }
        return text
    }

    /// Generates a hashtag list, including the username.
    /// - Parameter username: The username to include in the hashtag list.
    /// - Returns: An array of hashtags.
    private func getHashtags(using username: String?) -> [String] {
        var updateHashtagList = hashtagList
        if let username = username, !updateHashtagList.contains("#\(username)") {
            updateHashtagList.insert("#\(username)", at: 0)
        }
        return updateHashtagList
    }

    /// Updates the post with given content.
    /// - Parameter content: The content to update the post with.
    private func updatePost(content: [String: Any]) {
        presentSwiftLoader()
        APIManager.shared.updatePost(params: content) { [weak self] result in
            guard let self = self else { return }
            self.handlePostUpdateResult(result)
        }
    }

    /// Handles the result of a post update attempt.
    /// - Parameter result: The result of the post update attempt.
    private func handlePostUpdateResult(_ result: Result) {
        switch result {
        case .success:
            handleSuccessfulPostUpdate()
        case .failure(let error):
            handleFailedPostUpdate(with: error)
        }
    }

    /// Handles a successful post update.
    private func handleSuccessfulPostUpdate() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            SwiftLoader.hide()
            showNote(text: "Updated successfully!")
            self.navigationController?.popBack(3)
        }
    }

    /// Handles a failed post update.
    /// - Parameter error: The error that occurred during the post update.
    private func handleFailedPostUpdate(with error: Error) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            SwiftLoader.hide()
            self.showErrorAlert("Oops", msg: "Unable to update \(error.localizedDescription)")
        }
    }
}


extension EditPostVC: UITextViewDelegate {

    // MARK: - UITextViewDelegate Methods

    /// Handles the behavior when the text view begins editing.
    /// - Parameter textView: The UITextView being edited.
    func textViewDidBeginEditing(_ textView: UITextView) {
        clearPlaceholderTextIfNeeded(for: textView)
    }

    /// Handles the behavior when the text view ends editing.
    /// - Parameter textView: The UITextView that ended editing.
    func textViewDidEndEditing(_ textView: UITextView) {
        restorePlaceholderTextIfNeeded(for: textView)
        updateSelectedDescriptionIfNotEmpty(for: textView)
    }

    /// Determines whether the text view should change text in a given range.
    /// - Parameters:
    ///   - textView: The UITextView asking for the change.
    ///   - range: The range of characters to be replaced.
    ///   - text: The replacement text.
    /// - Returns: A Boolean value indicating whether the text should be changed.
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
        return newText.count <= 100 // Limit to 100 characters
    }

    // MARK: - Private Helpers

    /// Clears placeholder text if the conditions are met.
    /// - Parameter textView: The UITextView being edited.
    private func clearPlaceholderTextIfNeeded(for textView: UITextView) {
        if textView == descTxtView, textView.text == "Got something fun to share? Keep it snappy – max 100 characters! 😊" {
            textView.text = ""
        }
    }

    /// Restores placeholder text if the text view is empty.
    /// - Parameter textView: The UITextView that ended editing.
    private func restorePlaceholderTextIfNeeded(for textView: UITextView) {
        if textView == descTxtView, textView.text.isEmpty {
            textView.text = "Got something fun to share? Keep it snappy – max 100 characters! 😊"
        }
    }

    /// Updates the selected description if the text view is not empty.
    /// - Parameter textView: The UITextView that ended editing.
    private func updateSelectedDescriptionIfNotEmpty(for textView: UITextView) {
        if textView == descTxtView, !textView.text.isEmpty {
            selectedDescTxtView = textView.text
        }
    }
}


extension EditPostVC {

    // MARK: - Public Methods

    /// Displays an error alert with a custom title and message.
    /// - Parameters:
    ///   - title: The title of the alert.
    ///   - msg: The message of the alert.
    func showErrorAlert(_ title: String, msg: String) {
        let alert = createAlertController(title: title, message: msg)
        present(alert, animated: true)
    }

    /// Configures and displays a loader with a progress title.
    /// - Parameter progress: The title to be displayed on the loader.
    func showSwiftLoader(withProgressTitle progress: String) {
        let config = createSwiftLoaderConfig()
        SwiftLoader.setConfig(config: config)
        SwiftLoader.show(title: progress, animated: true)
    }

    // MARK: - Private Helpers

    /// Creates and configures an alert controller.
    /// - Parameters:
    ///   - title: The title of the alert.
    ///   - message: The message of the alert.
    /// - Returns: A configured UIAlertController instance.
    private func createAlertController(title: String, message: String) -> UIAlertController {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default)
        alert.addAction(action)
        return alert
    }

    /// Creates and configures the SwiftLoader configuration.
    /// - Returns: A configured SwiftLoader.Config instance.
    private func createSwiftLoaderConfig() -> SwiftLoader.Config {
        var config = SwiftLoader.Config()
        config.size = 170
        config.backgroundColor = .clear
        config.spinnerColor = .white
        config.titleTextColor = .white
        config.spinnerLineWidth = 3.0
        config.foregroundColor = .black
        config.foregroundAlpha = 0.7
        return config
    }
}


