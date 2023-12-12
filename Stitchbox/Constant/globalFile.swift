//
//  globalFile.swift
//  Stitchbox
//
//  Created by Khoi Nguyen on 12/18/22.
//

import Foundation
import SendBirdSDK
import SendBirdUIKit
import SendBirdCalls
import SwiftEntryKit
import UserNotifications
import CoreMedia
import AVFAudio
import ObjectMapper
import AppTrackingTransparency
import AdSupport
import AsyncDisplayKit

// MARK: - Global Constants

let incomingCallGreen = UIColor(red: 76.0/255.0, green: 217.0/255.0, blue: 100.0/255.0, alpha: 1.0)
let hashtagPurple = UIColor(red: 88.0/255.0, green: 86.0/255.0, blue: 214.0/255.0, alpha: 1.0)
// Define an ocean blue color, similar to teal or cyan
let hashtagColor = UIColor(red: 173/255, green: 216/255, blue: 230/255, alpha: 1.0)

let alertColor = UIColor(red: 0.8, green: 0.2, blue: 0.2, alpha: 1.0)
let horizontalPadding: CGFloat = 12
let bottomValue: CGFloat = 40
let bottomValueNoHide: CGFloat = 0
let emptyimage = "https://img.freepik.com/premium-photo/gray-wall-empty-room-with-concrete-floor_53876-70804.jpg?w=1380"
let emptySB = "https://stitchbox-app-images.s3.us-east-1.amazonaws.com/adf94fba-69a1-4dc3-b934-003a04265c39.png"

// MARK: - Global Variables

var globalHasNotch = true
var mainRootId = ""
var mainSeletedId = ""
var chatbot_id = "64397f3ceff4334484bf537b"
var general_vc: UIViewController!
var general_room: Room!
var gereral_group_chanel_url: String!
var startTime = Date()
var isPro = false
var global_gpt = "gpt-3.5-turbo"
var global_presetingRate = 0.0
var global_cornerRadius = 0.0
var global_percentComplete = 0.0
var global_host = ""
var global_fullLink = ""
var selectedTabIndex = 0
var global_suppport_game_list = [GameList]()
var needRecount = false
var needReloadPost = false
var needRemove = false
var newSlogan = ""
var didChanged = false
var reloadAddedGame = false
var globalIsSound = false
var globalRegulate = false
var shouldAllowAfterInactive = true
var shouldMute: Bool?
var globalSetting: SettingModel!
var navigationControllerHeight: CGFloat = 0.0
var tabBarControllerHeight: CGFloat = 0.0

// MARK: - UI Images

let scaleFactor: CGFloat = 0.8
let saveScaleFactor: CGFloat = 0.85

let saveImageSize = CGSize(width: 16, height: 20.3125).applyingScaleFactor(saveScaleFactor)
let saveImage = UIImage(named: "saved.filled")?.resize(targetSize: saveImageSize)

let unsaveImageSize = CGSize(width: 16, height: 20.3125).applyingScaleFactor(saveScaleFactor)
let unsaveImage = UIImage(named: "save")?.resize(targetSize: unsaveImageSize)

let emptyLikeImageLMSize = CGSize(width: 25, height: 20.3125).applyingScaleFactor(scaleFactor)
let emptyLikeImageLM = UIImage(named: "heart-lightmode")?.resize(targetSize: emptyLikeImageLMSize)

let cmtImageSize = CGSize(width: 23, height: 23).applyingScaleFactor(scaleFactor)
let cmtImage = UIImage(named: "cmt")?.resize(targetSize: cmtImageSize)

let playListImageSize = CGSize(width: 25, height: 20.3125).applyingScaleFactor(scaleFactor)
let playListImage = UIImage(named: "playlist 1")?.resize(targetSize: playListImageSize)

let likeImageSize = CGSize(width: 25, height: 20.3125).applyingScaleFactor(scaleFactor)
let likeImage = UIImage(named: "liked")?.resize(targetSize: likeImageSize)

let emptyLikeImageSize = CGSize(width: 25, height: 20.3125).applyingScaleFactor(scaleFactor)
let emptyLikeImage = UIImage(named: "likeEmpty")?.resize(targetSize: emptyLikeImageSize)

let popupLikeImageSize = CGSize(width: 100, height: 81.25)
let popupLikeImage = UIImage(named: "likePopUp")?.resize(targetSize: popupLikeImageSize)

let xBtnSize = CGSize(width: 12, height: 12)
let xBtn = UIImage(named: "1024x")?.resize(targetSize: xBtnSize)

let muteImageSize = CGSize(width: 26, height: 26)
let muteImage = UIImage(named: "3xmute")?.resize(targetSize: muteImageSize).withRenderingMode(.alwaysOriginal)

let unmuteImageSize = CGSize(width: 26, height: 26)
let unmuteImage = UIImage(named: "3xunmute")?.resize(targetSize: unmuteImageSize).withRenderingMode(.alwaysOriginal)

let speedImageSize = CGSize(width: 25, height: 25)
let speedImage = UIImage(named: "Speed_4x")?.resize(targetSize: speedImageSize)

// Extension to apply scaling factor to CGSize.
extension CGSize {
    func applyingScaleFactor(_ factor: CGFloat) -> CGSize {
        return CGSize(width: self.width * factor, height: self.height * factor)
    }
}


var back_frame = CGRect(x: 0, y: 0, width: 44, height: 44)

// MARK: - Typealias

typealias DownloadComplete = () -> ()

// MARK: - Functions

/// Activates the speaker.
func activeSpeaker() {
    do {
        try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback)
        //print("AVAudioSession Category Playback OK")
        do {
            try AVAudioSession.sharedInstance().setActive(true)
            //print("AVAudioSession is Active")
        } catch {
            //print(error.localizedDescription)
        }
    } catch {
        //print(error.localizedDescription)
    }
}


func showNote(text: String) {
    
    var attributes = EKAttributes.topNote
    attributes.popBehavior = .animated(animation: .init(translate: .init(duration: 0.1), scale: .init(from: 1, to: 0.7, duration: 0.2)))
    attributes.entryBackground = .color(color: .noteBackground)
    attributes.shadow = .active(with: .init(color: .black, opacity: 0.5, radius: 10, offset: .zero))
    attributes.statusBar = .dark
    attributes.scroll = .enabled(swipeable: true, pullbackAnimation: .jolt)
    attributes.positionConstraints.maxSize = .init(width: .constant(value: UIScreen.main.bounds.width), height: .intrinsic)
    
    
    let style = EKProperty.LabelStyle(
        font: FontManager.shared.roboto(.Medium, size: 15),
        color: .white,
        alignment: .center
    )
    let labelContent = EKProperty.LabelContent(
        text: text,
        style: style
    )
    let contentView = EKNoteMessageView(with: labelContent)
    SwiftEntryKit.display(entry: contentView, using: attributes)
    
}

func presentSwiftLoaderWithText(text: String) {
    
    var config : SwiftLoader.Config = SwiftLoader.Config()
    config.size = 170
    
    config.backgroundColor = UIColor.clear
    config.spinnerColor = UIColor.white
    config.titleTextColor = UIColor.white
    
    
    config.spinnerLineWidth = 3.0
    config.foregroundColor = UIColor.black
    config.foregroundAlpha = 0.7
    
    
    SwiftLoader.setConfig(config: config)
    
    
    SwiftLoader.show(title: "", animated: true)
    
                                                                                                                                  
}


extension UIViewController {
    static func instantiate(from storyboard: String) -> Self {
        return UIStoryboard(name: storyboard, bundle: nil).instantiateViewController(withIdentifier: "\(self)") as! Self
    }
}

extension UIViewController: UIViewControllerTransitioningDelegate {
    public func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        PresentationController(presentedViewController: presented, presenting: presenting)
    }
}

extension UILabel {
    func textWidth() -> CGFloat {
        return UILabel.textWidth(label: self)
    }

    class func textWidth(label: UILabel) -> CGFloat {
        return textWidth(label: label, text: label.text!)
    }

    class func textWidth(label: UILabel, text: String) -> CGFloat {
        return textWidth(font: label.font, text: text)
    }

    class func textWidth(font: UIFont, text: String) -> CGFloat {
        return textSize(font: font, text: text).width
    }

    class func textHeight(withWidth width: CGFloat, font: UIFont, text: String) -> CGFloat {
        return textSize(font: font, text: text, width: width).height
    }

    class func textSize(font: UIFont, text: String, extra: CGSize) -> CGSize {
        var size = textSize(font: font, text: text)
        size.width = size.width + extra.width
        size.height = size.height + extra.height
        return size
    }

    class func textSize(font: UIFont, text: String, width: CGFloat = .greatestFiniteMagnitude, height: CGFloat = .greatestFiniteMagnitude) -> CGSize {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: width, height: height))
        label.numberOfLines = 0
        label.font = font
        label.text = text
        label.sizeToFit()
        return label.frame.size
    }

    class func countLines(font: UIFont, text: String, width: CGFloat, height: CGFloat = .greatestFiniteMagnitude) -> Int {
        // Call self.layoutIfNeeded() if your view uses auto layout
        let myText = text as NSString

        let rect = CGSize(width: width, height: height)
        let labelSize = myText.boundingRect(with: rect, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)

        return Int(ceil(CGFloat(labelSize.height) / font.lineHeight))
    }

    func countLines(width: CGFloat = .greatestFiniteMagnitude, height: CGFloat = .greatestFiniteMagnitude) -> Int {
        // Call self.layoutIfNeeded() if your view uses auto layout
        let myText = (self.text ?? "") as NSString

        let rect = CGSize(width: width, height: height)
        let labelSize = myText.boundingRect(with: rect, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: self.font!], context: nil)

        return Int(ceil(CGFloat(labelSize.height) / self.font.lineHeight))
    }
}


// MARK: - Avatar Processing

/// Processes avatar updates for a given SendBird group channel.
/// - Parameters:
///   - channel: The SendBird group channel to update.
///   - image: The new image for the avatar.
func processUpdateAvatar(channel: SBDGroupChannel, image: UIImage) {
    APIManager.shared.uploadImage(image: image) { result in
        switch result {
        case .success(let apiResponse):
            guard apiResponse.body?["message"] as? String == "avatar uploaded successfully",
                  let url = apiResponse.body?["url"] as? String else {
                    return
            }
            
            // Update SBDGroupChannelParams with new cover URL
            let param = SBDGroupChannelParams()
            param.coverUrl = url
            
            channel.update(with: param) { _, error in
                if let error = error {
                    //print(error.localizedDescription, error.code)
                    return
                }
                // Handle successful update, if needed
            }

        case .failure(_):
            //print(error.localizedDescription)
            return
        }
    }
}

// MARK: - Local Notifications

/// Creates and schedules a local notification for active SendBird users.
/// - Parameters:
///   - title: Title of the notification.
///   - body: Body text of the notification.
///   - channel: The SendBird group channel associated with the notification.
func createLocalNotificationForActiveSendbirdUsers(title: String, body: String, channel: SBDGroupChannel) {
    // Request permission to display notifications
    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
        if granted {
            //print("Notification permissions granted")
        } else {
            //print("Notification permissions not granted")
        }
    }

    let content = UNMutableNotificationContent()
    content.title = title
    content.body = body
    content.sound = UNNotificationSound.default
    content.userInfo = ["type": "sendbird_localNoti", "channel_url": channel.channelUrl]

    // Create and add a notification request
    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.05, repeats: false)
    let request = UNNotificationRequest(identifier: "notification", content: content, trigger: trigger)
    UNUserNotificationCenter.current().add(request) { error in
        if let error = error {
            //print(error.localizedDescription)
        } else {
            //print("Notification scheduled")
        }
    }
}

// MARK: - UI Extensions

// Extension for UICollectionReusableView to provide a default reuseIdentifier
extension UICollectionReusableView {
    static var reuseIdentifier: String {
        return String(describing: Self.self)
    }
}

// Extension for UITextView to calculate new height based on content
extension UITextView {
    func newHeight(withBaseHeight baseHeight: CGFloat) -> CGFloat {
        let fixedWidth = frame.size.width
        let newSize = sizeThatFits(CGSize(width: fixedWidth, height: .greatestFiniteMagnitude))
        return max(newSize.height, baseHeight)
    }
}

// MARK: - Image Saving

/// A helper class to save images to the photo album.
class ImageSaver: NSObject {
    func writeToPhotoAlbum(image: UIImage) {
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(saveCompleted), nil)
    }

    @objc private func saveCompleted(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        // Implement handling of the save completion, e.g., show a notification
        showNote(text: "Save finished!")
    }
}

// MARK: - SwiftLoader Presentation

/// Presents a loading indicator using SwiftLoader.
func presentSwiftLoader() {
    var config = SwiftLoader.Config()
    config.size = 170
    config.backgroundColor = UIColor.clear
    config.spinnerColor = UIColor.white
    config.titleTextColor = UIColor.white
    config.spinnerLineWidth = 3.0
    config.foregroundColor = UIColor.black
    config.foregroundAlpha = 0.7
    
    SwiftLoader.setConfig(config: config)
    SwiftLoader.show(title: "", animated: true)
}


// MARK: - Tab Bar Button Visibility

/// Hides the middle button on a DashboardTabBarController.
/// - Parameter vc: The view controller whose tab bar controller needs modification.
func hideMiddleBtn(vc: UIViewController) {
    (vc.tabBarController as? DashboardTabBarController)?.actionButton.isHidden = true
}

/// Shows the middle button on a DashboardTabBarController.
/// - Parameter vc: The view controller whose tab bar controller needs modification.
func showMiddleBtn(vc: UIViewController) {
    (vc.tabBarController as? DashboardTabBarController)?.actionButton.isHidden = false
}

// MARK: - 2FA (Two Factor Authentication) Handling

/// Turns on 2FA for email if the current view controller is `TwoFactorAuthVC`.
func turnOn2FAForEmail() {
    update2FASetting(isOn: true, isEmail: true)
}

/// Turns on 2FA for phone if the current view controller is `TwoFactorAuthVC`.
func turnOn2FAForPhone() {
    update2FASetting(isOn: true, isEmail: false)
}

/// Turns off 2FA for email if the current view controller is `TwoFactorAuthVC`.
func turnOff2FAForEmail() {
    update2FASetting(isOn: false, isEmail: true)
}

/// Turns off 2FA for phone if the current view controller is `TwoFactorAuthVC`.
func turnOff2FAForPhone() {
    update2FASetting(isOn: false, isEmail: false)
}

/// Updates the 2FA settings for either email or phone.
/// - Parameters:
///   - isOn: A boolean indicating whether to turn on or off the setting.
///   - isEmail: A boolean to determine if the setting is for email or phone.
private func update2FASetting(isOn: Bool, isEmail: Bool) {
    if let vc = UIViewController.currentViewController() as? TwoFactorAuthVC {
        if isEmail {
            vc.isEmail = isOn
            vc.EmailSwitch.setOn(isOn, animated: true)
        } else {
            vc.isPhone = isOn
            vc.PhoneSwitch.setOn(isOn, animated: true)
        }
    }
}

// MARK: - Date Transformation

/// Transforms a JSON value into a `Date`.
/// - Parameter value: The JSON value to be transformed.
/// - Returns: A `Date` object or `nil` if transformation is not possible.
func transformFromJSON(_ value: Any?) -> Date? {
    guard let strValue = value as? String else { return nil }
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
    return formatter.date(from: strValue)
}

// MARK: - Safe Collection Access

extension Collection {
    /// Safely access elements of the collection.
    /// - Parameter index: The index of the element to access.
    /// - Returns: The element at the given index if it exists, otherwise `nil`.
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}



/// Reloads global user information by fetching it from the API.
func reloadGlobalUserInformation() {
    APIManager.shared.getme { result in
        handleUserInformationResult(result)
    }
}

/// Handles the result of the user information API call.
/// - Parameter result: The result of the API call, containing either the response or an error.
private func handleUserInformationResult(_ result: Result) {
    switch result {
    case .success(let response):
        updateUserInformation(with: response)
    case .failure(_):
        return
    }
}

/// Updates user information using the API response.
/// - Parameter response: The response from the user information API call.
private func updateUserInformation(with response: APIResponse) {
    guard let data = response.body, !data.isEmpty else {
        //print("No data available or data is empty in API response")
        return
    }

    if let newUserData = Mapper<UserDataSource>().map(JSON: data) {
        updateAppCoreData(with: newUserData)
    } else {
        //print("Failed to map API response to UserDataSource")
    }
}

/// Updates the app's core data with the new user data.
/// - Parameter userData: The new user data to update.
private func updateAppCoreData(with userData: UserDataSource) {
    _AppCoreData.reset()
    _AppCoreData.userDataSource.accept(userData)
    syncSendbirdAccount()
}



/// Reloads global settings by fetching them from the API.
func reloadGlobalSettings() {
    APIManager.shared.getSettings { result in
        handleSettingsResult(result)
    }
}

/// Handles the result of the settings API call.
/// - Parameter result: The result of the API call, containing either the API response or an error.
private func handleSettingsResult(_ result: Result) {
    switch result {
    case .success(let apiResponse):
        updateGlobalSettings(from: apiResponse)
    case .failure(let error):
        handleSettingsError(error)
    }
}

/// Updates global settings using the API response.
/// - Parameter apiResponse: The response from the settings API call.
private func updateGlobalSettings(from apiResponse: APIResponse) {
    guard let data = apiResponse.body else {
        print("No data available in API response")
        return
    }

    if let settings = Mapper<SettingModel>().map(JSONObject: data) {
        globalSetting = settings
    } else {
        print("Failed to map API response to SettingModel")
    }
}

/// Handles errors that occur during the settings API call.
/// - Parameter error: The error returned by the API call.
private func handleSettingsError(_ error: Error) {
    print("Error fetching settings: \(error)")
}


func unmuteVideoIfNeed() {
    guard let vc = UIViewController.currentViewController() else { return }

    switch vc {
    case let feedVC as FeedViewController:
        unmuteVideoForFeedViewController(feedVC)
    case let selectedRootVC as SelectedRootPostVC:
        unmuteVideoForSelectedRootPostVC(selectedRootVC)
    case let previewVC as PreviewVC:
        unmuteVideoForPreviewVC(previewVC)
    case let stitchDashboardVC as StitchDashboardVC:
        unmuteVideoForStitchDashboardVC(stitchDashboardVC)
    default:
        break
    }
}

private func unmuteVideoForFeedViewController(_ vc: FeedViewController) {
    guard let currentIndex = vc.currentIndex,
          let cell = vc.collectionNode.nodeForItem(at: IndexPath(row: currentIndex, section: 0)) as? RootNode else { return }

    cell.unmuteVideo()
    shouldMute = false
}

private func unmuteVideoForSelectedRootPostVC(_ vc: SelectedRootPostVC) {
    guard let currentIndex = vc.currentIndex,
          let cell = vc.collectionNode.nodeForItem(at: IndexPath(row: currentIndex, section: 0)) as? RootNode else { return }

    cell.unmuteVideo()
    shouldMute = false
}

private func unmuteVideoForPreviewVC(_ vc: PreviewVC) {
    guard let currentIndex = vc.currentIndex,
          let cell = vc.collectionNode.nodeForItem(at: IndexPath(row: currentIndex, section: 0)) as? VideoNode else { return }

    cell.unmuteVideo()
    shouldMute = false
}

private func unmuteVideoForStitchDashboardVC(_ vc: StitchDashboardVC) {
    if !vc.PendingVC.view.isHidden {
        unmuteVideoForPendingVC(vc.PendingVC)
    } else if !vc.StitchToVC.view.isHidden {
        unmuteVideoForStitchToVC(vc.StitchToVC)
    } else if !vc.ApprovedStitchVC.view.isHidden {
        unmuteVideoForApprovedStitchVC(vc.ApprovedStitchVC)
    }
}

private func unmuteVideoForPendingVC(_ vc: PendingVC) {
    guard let currentIndex = vc.currentIndex,
          let cell = vc.waitCollectionNode.nodeForItem(at: IndexPath(row: currentIndex, section: 0)) as? PendingNode else { return }

    cell.unmuteVideo()
    shouldMute = false
}

private func unmuteVideoForStitchToVC(_ vc: StitchToVC) {
    guard let currentIndex = vc.currentIndex,
          let cell = vc.waitCollectionNode.nodeForItem(at: IndexPath(row: currentIndex, section: 0)) as? StitchControlForRemoveNode else { return }

    cell.unmuteVideo()
    shouldMute = false
}

private func unmuteVideoForApprovedStitchVC(_ vc: ApprovedStitchVC) {
    guard let currentIndex = vc.currentIndex,
          let cell = vc.waitCollectionNode.nodeForItem(at: IndexPath(row: currentIndex, section: 0)) as? StitchControlForRemoveNode else { return }

    cell.unmuteVideo()
    shouldMute = false
}



func resetViewForVideo(cell: VideoNode) {
    
    if cell.isViewed == true {
        
        let currentTime = NSDate().timeIntervalSince1970
        
        let change = currentTime - cell.lastViewTimestamp
        
        if change > 30.0 {
            
            cell.isViewed = false
            cell.time = 0
        
        }
        
    }
    
    
}


// MARK: - UIView Extension for Spinning Animation
extension UIView {

    // Static variable to associate each UIView instance with its original transform.
    private static var originalTransformKey: UInt8 = 0

    // Computed property to store and retrieve the original transform of the view.
    private var originalTransform: CGAffineTransform? {
        get {
            objc_getAssociatedObject(self, &UIView.originalTransformKey) as? CGAffineTransform
        }
        set {
            objc_setAssociatedObject(self, &UIView.originalTransformKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    /// Adds a continuous spinning animation to the view.
    /// - Parameter duration: Duration of one complete spin. Default is 3.5 seconds.
    func spin(duration: Double = 3.5) {
        if originalTransform == nil {
            originalTransform = self.transform
        }
        
        let rotation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotation.toValue = NSNumber(value: Double.pi * 2)
        rotation.duration = duration
        rotation.repeatCount = .infinity
        
        self.layer.add(rotation, forKey: "spinAnimation")
    }
    
    /// Stops the spinning animation and resets the view to its original transform.
    func stopSpin() {
        self.layer.removeAnimation(forKey: "spinAnimation")
        if let original = originalTransform {
            self.transform = original
        }
    }
}

// MARK: - Delayed Pan Gesture Recognizer
class DelayedPanGestureRecognizer: UIPanGestureRecognizer {

    private var touchDownTime: Date?
    private let delayTime: TimeInterval = 0.25

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event!)
        touchDownTime = Date()
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event!)
        
        if let downTime = touchDownTime, Date().timeIntervalSince(downTime) < delayTime {
            state = .failed
        }
    }
}

// MARK: - Password Generation
func generateRandomPassword() -> String {
    let numbers = Array("0123456789")
    let upperCase = Array("ABCDEFGHIJKLMNOPQRSTUVWXYZ")
    let lowerCase = Array("abcdefghijklmnopqrstuvwxyz")
    let specialChars = Array("!@#$%^&*()_+-=[]{}|;:,.<>?/`~")
    
    var characters = [Character]()
    
    characters.append(contentsOf: [numbers, upperCase, lowerCase, specialChars].compactMap { $0.randomElement() })
    
    for _ in 4...8 {
        characters.append((numbers + upperCase + lowerCase + specialChars).randomElement()!)
    }
    
    characters.shuffle()
    
    return "sbrpwdfnu-" + String(characters)
}

// MARK: - Review Request Logic
func requestAppleReview() {
    guard let userCreation = _AppCoreData.userDataSource.value?.createdAt else { return }

    let currentDate = Date()
    let calendar = Calendar.current
    let daysSinceCreation = calendar.dateComponents([.day], from: userCreation, to: currentDate).day ?? 0

    if daysSinceCreation >= 1, let lastRequest = UserDefaults.standard.object(forKey: "lastReviewRequestDate") as? Date {
        let monthsSinceLast = calendar.dateComponents([.month], from: lastRequest, to: currentDate).month ?? 0
        if monthsSinceLast >= 1 {
            requestReviewAndUpdateDate(currentDate)
        }
    } else {
        requestReviewAndUpdateDate(currentDate)
    }
}

private func requestReviewAndUpdateDate(_ currentDate: Date) {
    if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
        AppStoreReviewManager.requestReviewIfAppropriate(inScene: scene)
        UserDefaults.standard.set(currentDate, forKey: "lastReviewRequestDate")
    }
}

// MARK: - UserDefaults Management
func removeAllUserDefaults() {
    UserDefaults.standard.dictionaryRepresentation().keys.forEach {
        UserDefaults.standard.removeObject(forKey: $0)
    }
}

// MARK: - UIView Extension for Auto Layout
extension UIView {

    /// Pins the view to the edges of its superview using Auto Layout constraints.
    func pinToSuperviewEdges() {
        guard let superview = superview else { return }
        translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            topAnchor.constraint(equalTo: superview.topAnchor),
            bottomAnchor.constraint(equalTo: superview.bottomAnchor),
            leadingAnchor.constraint(equalTo: superview.leadingAnchor),
            trailingAnchor.constraint(equalTo: superview.trailingAnchor)
        ])
    }
}



/// A UIView subclass with a shadow effect.
class ShadowedView: UIView {
    
    /// Overrides the layoutSubviews method to apply shadow properties.
    override func layoutSubviews() {
        super.layoutSubviews()
        configureShadow()
    }

    /// Configures the shadow properties for the view.
    private func configureShadow() {
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.5
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowRadius = 5
        layer.masksToBounds = false
    }
}

extension UITabBarController {
    
    /// Changes the visibility of the tab bar.
    /// - Parameters:
    ///   - hidden: A Boolean indicating whether the tab bar should be hidden.
    ///   - animated: A Boolean indicating whether this change should be animated.
    func changeTabBarVisibility(hidden: Bool, animated: Bool) {
        guard tabBar.isHidden != hidden else { return }

        let duration: TimeInterval = animated ? 0.25 : 0.0
        adjustTabBarVisibility(hidden, withDuration: duration)
    }

    /// Adjusts the visibility of the tab bar with animation.
    /// - Parameters:
    ///   - hidden: A Boolean indicating the target visibility state.
    ///   - duration: The duration of the animation.
    private func adjustTabBarVisibility(_ hidden: Bool, withDuration duration: TimeInterval) {
        if hidden {
            animateTabBar(toAlpha: 0, duration: duration) { [weak self] in
                self?.tabBar.isHidden = true
                self?.tabBar.alpha = 1 // Reset alpha for next unhide
            }
        } else {
            tabBar.isHidden = false
            tabBar.alpha = 0
            animateTabBar(toAlpha: 1, duration: duration)
        }
    }

    /// Animates the tab bar's alpha transition.
    /// - Parameters:
    ///   - alpha: The target alpha value.
    ///   - duration: The duration of the animation.
    ///   - completion: An optional completion handler.
    private func animateTabBar(toAlpha alpha: CGFloat, duration: TimeInterval, completion: (() -> Void)? = nil) {
        UIView.animate(withDuration: duration, animations: {
            self.tabBar.alpha = alpha
        }, completion: { _ in
            completion?()
        })
    }
}

protocol PostManaging {
    var editeddPost: PostModel? { get }
    var posts: [PostModel] { get set }
    var collectionNode: ASCollectionNode { get } // Replace with your collection node type
}

/// Requests user authorization for tracking and handles the response.
func requestTrackingAuthorization() {
    ATTrackingManager.requestTrackingAuthorization { status in
        handleTrackingAuthorization(status: status)
    }
}

func handleTrackingAuthorization(status: ATTrackingManager.AuthorizationStatus) {
    switch status {
    case .authorized:
        let idfa = ASIdentifierManager.shared().advertisingIdentifier.uuidString
        print("IDFA: \(idfa)")
    case .denied:
        print("Tracking denied")
    case .restricted:
        print("Tracking restricted")
    case .notDetermined:
        print("Tracking not determined")
        // Prompt the user again for tracking permission
        requestTrackingAuthorization()
    @unknown default:
        print("Unknown tracking status")
        // Prompt the user again as the status is unknown
        requestTrackingAuthorization()
    }
}


extension UIDevice {
    /// Returns `true` if the device has a notch
    var ifHasNotch: Bool {
        guard #available(iOS 13.0, *),
              let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first(where: { $0.isKeyWindow }) else {
                  return false
              }
        
        return window.safeAreaInsets.top >= 44
    }
}

