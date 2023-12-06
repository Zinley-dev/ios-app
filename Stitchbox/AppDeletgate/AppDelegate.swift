//
//  AppDelegate.swift
//  Stitchbox
//
//  Created by Nghiem Minh Hoang on 26/10/2022.
//

import UIKit
import GoogleSignIn
import SendBirdSDK
import SendBirdCalls
import PushKit
import UserNotifications
import SendBirdUIKit
import PixelSDK
import UserNotifications
import OneSignal
import Sentry

@main
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate, SBDChannelDelegate {
    
    var window: UIWindow?
    var voipRegistry: PKPushRegistry?
    var volumeOutputList = [Float]() // List to track volume output levels
    static let sharedInstance = UIApplication.shared.delegate as! AppDelegate // Singleton instance of AppDelegate
    var metricsManager: AppMetrics? // Manager for app metrics
    private var audioLevel: Float = 0.0 // Private variable to track audio level

    private var previousVolume: Float = 0.0 // Stores the previous volume level
    private var outputVolumeObserver: NSKeyValueObservation? // Observer for volume changes
    private var consecutiveVolumeDownPresses: Int = 0 // Counter for consecutive volume down button presses

    /// Called when the application on first launch.
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Set up various components and services used in the app
        setupPixelSDK() // Setup for Pixel SDK
        sendbird_authentication() // Authentication for Sendbird
        syncSendbirdAccount() // Syncing Sendbird account
        attemptRegisterForNotifications(application: application) // Register for push notifications
        setupStyle() // Set up UI style
        setupOneSignal(launchOptions: launchOptions) // Setup for OneSignal
        activeSpeaker() // Method related to handling the active speaker
        setupVolumeObserver() // Set up an observer for volume changes
        sentrySetup() // Setup for Sentry
        CacheManager.shared.asyncRemoveExpiredObjects() // Clear expired objects from cache
        metricsManager = AppMetrics() // Initialize the metrics manager

        return true // Indicate successful launch
    }
    
    /// Called when the application becomes active.
    /// - Parameter application: The singleton app instance.
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Reset the application icon badge number to 0
        UIApplication.shared.applicationIconBadgeNumber = 0

        // Request an Apple review (implementation details of 'requestAppleReview' are assumed)
        requestAppleReview()

        // Clean the temporary directory (implementation details of 'cleanTemporaryDirectory' are assumed)
        cleanTemporaryDirectory()
    }

    
    /// Initializes and configures Sentry for error tracking and performance monitoring.
    func sentrySetup() {
        SentrySDK.start { options in
            // Set the Data Source Name (DSN) to tell the SDK where to send the events
            options.dsn = "https://f303994ce86f5234623d9f66dbe6f6cb@o4505682647646208.ingest.sentry.io/4505682648170496"

            // Enable debug mode for detailed logging information
            options.debug = true // Helpful for initial setup and troubleshooting

            // Configure the sample rate for tracing to capture transactions
            options.tracesSampleRate = 1.0 // Adjust as needed in production for performance

            // Additional configurations for Sentry
            options.attachViewHierarchy = true // Attach view hierarchy for better context in visual debugging
            options.enablePreWarmedAppStartTracing = true // Enables tracing for early app initialization stages
            options.enableMetricKit = true // Utilize MetricKit for enhanced performance metrics (iOS only)

            // Note: Be sure to replace the 'dsn' with your actual Sentry DSN.
            // Adjust 'tracesSampleRate' in production to balance data collection and performance.
        }
    }

    
    /// Sets up an observer to monitor changes in the device's output volume.
    private func setupVolumeObserver() {
        let audioSession = AVAudioSession.sharedInstance()
        previousVolume = audioSession.outputVolume

        // Observing the output volume property
        outputVolumeObserver = audioSession.observe(\.outputVolume) { [weak self] _, _ in
            // Handle the volume change
            self?.handleVolumeChange()
        }
    }

    /// Handles the device's volume changes.
    private func handleVolumeChange() {
        let audioSession = AVAudioSession.sharedInstance()
        let currentVolume = audioSession.outputVolume

        // Check the current volume level and respond accordingly
        if currentVolume >= 1.0 || currentVolume > previousVolume {
            consecutiveVolumeDownPresses = 0
            unmuteVideoIfNeed() // Custom function to unmute the video
        } else if currentVolume < previousVolume {
            consecutiveVolumeDownPresses += 1
            if consecutiveVolumeDownPresses >= 2 {
                // muteVideoIfNeed() // Custom function to mute the video
                consecutiveVolumeDownPresses = 0
            }
        }
        
        previousVolume = currentVolume // Update the previous volume to the current volume
    }
    
    /// Sets up OneSignal for push notifications.
    /// - Parameter launchOptions: The launch options passed on app launch.
    func setupOneSignal(launchOptions: [UIApplication.LaunchOptionsKey: Any]?) {
        // Initialize OneSignal with launch options
        OneSignal.initWithLaunchOptions(launchOptions)
        // Set the OneSignal App ID
        OneSignal.setAppId("209c3011-21c8-43ba-aff2-b2865e03aee5")
        
        // Prompt the user for push notification permissions
        OneSignal.promptForPushNotifications(userResponse: { accepted in
            print("User accepted notifications: \(accepted)")
        })
        
        // Set a handler for when notifications are opened
        OneSignal.setNotificationOpenedHandler { result in
            let notification: OSNotification = result.notification

            // Process the notification's additional data
            if let additionalData = notification.additionalData,
               let text = additionalData["data"] as? String,
               let data = self.convertStringToDictionary(text: text),
               let metadata = data["metadata"] as? String,
               let metaDataDict = self.convertStringToDictionary(text: metadata) {

                let metaDataOneSignal = OneSignalNotiModel(OneSignalNotiModel: metaDataDict)
                
                // Handle different notification templates
                switch metaDataOneSignal.template {
                case "NEW_COMMENT", "REPLY_COMMENT", "NEW_TAG":
                    if let post = metaDataOneSignal.post {
                        self.openComment(commentId: metaDataOneSignal.commentId, rootComment: metaDataOneSignal.rootComment, replyToComment: metaDataOneSignal.replyToComment, type: metaDataOneSignal.template, post: post)
                    }
                case "NEW_FISTBUMP_1", "LIKE_COMMENT", "LIKE_POST":
                    if let userId = metaDataOneSignal.userId, let username = metaDataOneSignal.username {
                        self.openUser(userId: userId, username: username)
                    }
                case "NEW_FISTBUMP_2":
                    // Placeholder for future implementation
                    print("New Fistbump")
                case "NEW_FOLLOW_1", "NEW_FOLLOW_2":
                    self.openFollow()
                case "NEW_POST":
                    self.openPost(post: metaDataOneSignal.post)
                case "NEW_STITCH", "APPROVED_STITCH", "DENIED_STITCH":
                    self.moveToStichDashboard()
                default:
                    print("Unhandled notification template")
                }
            }
        }
    }


    /// Converts a JSON string into a dictionary.
    /// - Parameter text: The JSON string to be converted.
    /// - Returns: A dictionary if the conversion is successful; otherwise, nil.
    func convertStringToDictionary(text: String) -> [String: Any]? {
        // Attempt to convert the string to Data
        if let data = text.data(using: .utf8) {
            do {
                // Attempt to serialize the JSON data into a dictionary
                let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                return json
            } catch {
                // Log the error if JSON serialization fails
                print("Error converting string to dictionary: \(error.localizedDescription)")
            }
        } else {
            // Log an error if the string cannot be converted to Data
            print("Error: String could not be converted to UTF-8 data")
        }
        return nil
    }
    
    
    /// Sets up and configures the Pixel SDK.
    private func setupPixelSDK() {
        // Initialize Pixel SDK with the provided key
        PixelSDK.setup(pixel_key)

        // Set the maximum video duration that can be handled by the SDK
        PixelSDK.shared.maxVideoDuration = 120  // 120 seconds (2 minutes)

        // Configure the primary filters by combining default standard and visual effect filters
        PixelSDK.shared.primaryFilters = PixelSDK.defaultStandardFilters + PixelSDK.defaultVisualEffectFilters

        // Additional configurations or error handling can be placed here if needed
        // Example: Check for successful setup or log configuration details
    }
    
    /// Sets up the style and appearance for SendBird UIKit components.
    private func setupStyle() {
        // Set the overall theme to light
        SBUTheme.set(theme: .light)
        
        // Customize default strings
        SBUStringSet.User_No_Name = "Stitchbox User"  // Revised to make the naming more formal
        SBUStringSet.User_Operator = "Group Leader"  // Updated for clarity

        // Global configuration for image handling
        SBUGlobals.UsingImageCompression = true
        SBUGlobals.imageCompressionRate = 0.65
        SBUGlobals.imageResizingSize = CGSize(width: 480, height: 480)

        // Component theme customization for colors
        SBUTheme.componentTheme.barItemTintColor = UIColor.black
        SBUTheme.messageCellTheme.leftBackgroundColor = .normalButtonBackground
        SBUTheme.messageCellTheme.rightBackgroundColor = UIColor(red: 53, green: 46, blue: 113)
        SBUTheme.messageCellTheme.userMessageLeftTextColor = UIColor.black
        SBUTheme.messageCellTheme.userMessageRightTextColor = UIColor.white
        SBUTheme.overlayTheme.componentTheme.backgroundColor = .white
        SBUTheme.overlayTheme.componentTheme.loadingBackgroundColor = .white
        
        // Channel theme customization
        SBUTheme.channelTheme.navigationBarTintColor = UIColor.white
        SBUTheme.channelTheme.backgroundColor = .white
        SBUTheme.channelTheme.leftBarButtonTintColor = UIColor.black
        SBUTheme.channelTheme.rightBarButtonTintColor = UIColor.black

        // Additional component theme settings
        SBUTheme.componentTheme.loadingBackgroundColor = .white
        SBUTheme.componentTheme.addReactionTintColor = UIColor.secondary
        SBUTheme.componentTheme.loadingSpinnerColor = UIColor.secondary
        
        // Message input theme
        SBUTheme.messageInputTheme.buttonTintColor = .black

        // Font customization using a custom FontManager
        SBUFontSet.body1 = FontManager.shared.roboto(.Regular, size: 16)
        SBUFontSet.body2 = FontManager.shared.roboto(.Medium, size: 14)
        SBUFontSet.body3 = FontManager.shared.roboto(.Regular, size: 14)
        SBUFontSet.caption1 = FontManager.shared.roboto(.Bold, size: 12)
        SBUFontSet.caption2 = FontManager.shared.roboto(.Regular, size: 12)
        SBUFontSet.caption3 = FontManager.shared.roboto(.Medium, size: 11)
        SBUFontSet.caption4 = FontManager.shared.roboto(.Regular, size: 11)
        SBUFontSet.button1 = FontManager.shared.roboto(.Medium, size: 18)
        SBUFontSet.button2 = FontManager.shared.roboto(.Medium, size: 16)
        SBUFontSet.button3 = FontManager.shared.roboto(.Medium, size: 14)
        SBUFontSet.h1 = FontManager.shared.roboto(.Bold, size: 18)
        SBUFontSet.h2 = FontManager.shared.roboto(.Medium, size: 18)
        SBUFontSet.h3 = FontManager.shared.roboto(.Bold, size: 16)
        SBUFontSet.subtitle1 = FontManager.shared.roboto(.Medium, size: 16)
        SBUFontSet.subtitle2 = FontManager.shared.roboto(.Regular, size: 16)
    }

    
    // MARK: UISceneSession Lifecycle
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    @available(iOS 9.0, *)
    func application(_ application: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any]) -> Bool {
        // Check if the URL scheme matches a specific scheme ('stitchbox')
        if let scheme = url.scheme, scheme.localizedCaseInsensitiveCompare("stitchbox") == .orderedSame {
            var parameters: [String: String] = [:]
            
            // Extract query parameters from the URL
            URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems?.forEach {
                parameters[$0.name] = $0.value
            }
            
            // TODO: Implement redirection or handling based on the extracted parameters
            // Example: redirect(to: view, with: parameters)
        }
        
        // Handle the URL with Google SignIn if the URL scheme does not match 'stitchbox'
        return GIDSignIn.sharedInstance.handle(url)
    }

    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        // This method is used for handling URLs in iOS versions before 9.0.
        // The implementation might vary based on specific requirements.
        // Example: return some URL handling logic or delegate handling to another SDK.
        
        return false
    }

    
    func application(_ application: UIApplication, handleOpen url: URL) -> Bool {
        // This is another legacy method for handling URLs, used before the introduction of options in iOS 9.0.
        // Similar to the above, implement URL handling logic as required.

        return false
    }

    /// Initializes and configures SendBird for use in the application.
    func sendbird_authentication() {
        // Initialize SendBird with the application ID
        SBDMain.initWithApplicationId(sendbird_key)

        // Initialize SendBird UIKit
        SBUMain.initialize(applicationId: sendbird_key) { (error) in
            if let error = error {
                // If an error occurred during initialization, print it
                print("Error initializing SendBird UIKit: \(error)")
            } else {
                // If initialization was successful, print a confirmation message
                print("SendBird UIKit initialized successfully")
            }
        }

        // Configure SendBirdCall with the application ID
        SendBirdCall.configure(appId: sendbird_key)

        // Add the current class as a delegate to SendBirdCall
        SendBirdCall.addDelegate(self, identifier: "com.mobile.gg.Stitchbox1")

        // Set the execution queue for SendBirdCall to the main queue
        SendBirdCall.executeOn(queue: DispatchQueue.main)

        // Store the SendBird application ID in user defaults
        UserDefaults.standard.designatedAppId = sendbird_key

        // Add the current class as a channel delegate to SendBird
        SBDMain.add(self as SBDChannelDelegate, identifier: self.description)
    }

    
    /// Attempts to register the application for push notifications.
    /// - Parameter application: The singleton app instance.
    private func attemptRegisterForNotifications(application: UIApplication) {
        print("Attempting to register APNS...")

        if #available(iOS 10.0, *) {
            // For iOS 10 and later, use UNUserNotificationCenter to manage notifications
            UNUserNotificationCenter.current().delegate = self

            // Define authorization options for user notifications (alert, badge, sound)
            let options: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(options: options) { (granted, err) in
                // Handle the authorization response
                if let err = err {
                    // Print any error if authorization request fails
                    print("Failed to request auth:", err)
                    return
                }
                
                if granted {
                    // Authorization granted
                    print("Auth granted.")
                } else {
                    // Authorization denied
                    print("Auth denied")
                }
            }
        } else {
            // For iOS versions earlier than 10.0, use UIUserNotificationSettings
            let notificationSettings = UIUserNotificationSettings(types: [.badge, .sound, .alert], categories: nil)
            application.registerUserNotificationSettings(notificationSettings)
        }

        // Register the app to receive remote notifications
        application.registerForRemoteNotifications()
    }
    
    
    /// Called when a notification is delivered to a foreground app.
    /// - Parameters:
    ///   - center: The singleton object that manages notification-related activities for your app.
    ///   - notification: The notification that is about to be delivered.
    ///   - completionHandler: The block to execute with the presentation option for the notification.
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // Complete with options to show the notification's badge and play a sound
        completionHandler([.badge, .sound])
    }

    
    /// Called when the app successfully registers for remote notifications.
    /// - Parameters:
    ///   - application: The singleton app instance.
    ///   - deviceToken: A token that identifies the device to Apple Push Notification Service (APNS).
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        // Log the device token
        print("Registered for notifications:", deviceToken)
        
        // Register the device push token with SendBird
        SBDMain.registerDevicePushToken(deviceToken, unique: false) { (status, error) in
            // Handle the registration result
            if error == nil {
                switch status {
                case .pending:
                    print("Push registration is pending.")
                default:
                    print("APNS Token is registered.")
                }
            } else {
                // Log any errors during registration
                print("APNS registration failed with error: \(String(describing: error))")
            }
        }
    }

    
    /// Called when the application is about to terminate.
    /// - Parameter application: The singleton app instance.
    func applicationWillTerminate(_ application: UIApplication) {
        // This method is called when the app is forcefully terminated.

        // Access the shared instance of the call manager
        let callManager = CXCallManager.shared

        // Retrieve all ongoing calls
        let ongoingCalls = callManager.currentCalls.compactMap { SendBirdCall.getCall(forUUID: $0.uuid) }
        
        ongoingCalls.forEach { directCall in
            // For each ongoing call, perform the following steps:

            // 1. End the call using SendBird's API
            directCall.end()
            
            // 2. Request to end the call via CallKit
            callManager.endCXCall(directCall)
            
            // 3. Report the call as ended to CallKit, if the UUID is valid
            if let uuid = directCall.callUUID {
                callManager.endCall(for: uuid, endedAt: Date(), reason: .none)
            }
        }

        // Note: iOS provides limited time to perform remaining tasks during app termination.
        // It's possible that some calls might fail to end.
        // As a fallback, consider registering a local notification to alert about unterminated calls.
    }

    
    /// Handles user interactions with local notifications.
    /// - Parameters:
    ///   - center: The user notification center that received the notification.
    ///   - response: The user’s response to the notification.
    ///   - completionHandler: The block to execute when you have finished processing the user’s response.
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        // Check the notification type
        if let type = response.notification.request.content.userInfo["type"] as? String, type == "sendbird_localNoti" {
            
            // Guard to ensure the user is logged in and the channel URL is present in the notification payload
            guard let userUID = _AppCoreData.userDataSource.value?.userID, !userUID.isEmpty,
                  let channelUrl = response.notification.request.content.userInfo["channel_url"] as? String else {
                completionHandler()
                return
            }
            
            // Present the chat view controller based on the channel URL from the notification
            checkAndPresendChatVC(userUID: userUID, channelUrl: channelUrl)
            completionHandler()
            
        } else if let sendbirdInfo = response.notification.request.content.userInfo["sendbird"] as? NSDictionary {
            // Handle the case where the notification contains a 'sendbird' dictionary payload
            
            // Extract user ID and channel URL from the payload
            guard let userUID = _AppCoreData.userDataSource.value?.userID, !userUID.isEmpty,
                  let channel = sendbirdInfo["channel"] as? NSDictionary,
                  let channelUrl = channel["channel_url"] as? String else {
                completionHandler()
                return
            }
            
            // Present the chat view controller based on the channel URL from the notification
            checkAndPresendChatVC(userUID: userUID, channelUrl: channelUrl)
            completionHandler()
            
        } else {
            // Handle other types of notifications or cases where the required data is not present
            completionHandler()
        }
    }
    
    func checkAndPresendChatVC(userUID: String, channelUrl: String) {
        
        // Initialize an instance of SBUUser with the current user's ID and connect to Sendbird.
        SBUGlobals.CurrentUser = SBUUser(userId: userUID)
        SBUMain.connectIfNeeded { _, error in
            // If an error occurred while connecting, print it and return.
            if let error = error {
                print(error.localizedDescription)
                return
            }
            
            // If the app is in the foreground, present a ChannelViewController with the channel URL.
            // If the app is in the background, pop the current view controller and present a ChannelViewController.
            guard let currentVC = UIViewController.currentViewController() else { return }
            if let nav = currentVC.navigationController {
                
                if let currentChatVC = currentVC as? ChannelViewController, currentChatVC.channel?.channelUrl == channelUrl {
                    currentChatVC.sortAllMessageList(needReload: true)
                } else if let currentSettingsVC = currentVC as? ChannelSettingsVC, currentSettingsVC.channel?.channelUrl == channelUrl {
                    nav.popBack(1)
                } else if let currentMemberVC = currentVC as? MemberListVC, currentMemberVC.channel?.channelUrl == channelUrl {
                    nav.popBack(2)
                } else if let currentModerationVC = currentVC as? ModerationVC, currentModerationVC.channel?.channelUrl == channelUrl {
                    nav.popBack(2)
                } else if let OperatorMemberVC = currentVC as? OperatorMemberVC, OperatorMemberVC.channel?.channelUrl == channelUrl {
                    nav.popBack(3)
                } else if let BannedMemberVC = currentVC as? BannedMemberVC, BannedMemberVC.channel?.channelUrl == channelUrl {
                    nav.popBack(3)
                } else if let MutedMemberVC = currentVC as? MutedMemberVC, MutedMemberVC.channel?.channelUrl == channelUrl {
                    nav.popBack(3)
                } else if let AddOperatorMemberVC = currentVC as? AddOperatorMemberVC, AddOperatorMemberVC.channel?.channelUrl == channelUrl {
                    nav.popBack(4)
                } else if let InviteUserVC = currentVC as? InviteUserVC, InviteUserVC.channel?.channelUrl == channelUrl {
                    nav.popBack(4)
                } else {
                    
                    self.presentChatWithoutNav(vc: currentVC, channelUrl: channelUrl)
                    
                }
                
            } else {
                self.presentChatWithoutNav(vc: currentVC, channelUrl: channelUrl)
            }
            
        }
        
        
    }

    
    
    /// Presents a chat interface for a given channel URL in a modal fashion without using the existing navigation stack.
    /// - Parameters:
    ///   - vc: The view controller from which to present the chat interface.
    ///   - channelUrl: The URL of the chat channel to be opened.
    func presentChatWithoutNav(vc: UIViewController, channelUrl: String) {
        // Initialize message list parameters (assuming 'SBDMessageListParams' is a part of a chat SDK)
        let messageListParams = SBDMessageListParams()
        
        // Initialize the chat channel view controller with the specified channel URL and message list parameters
        let channelViewController = ChannelViewController(channelUrl: channelUrl, messageListParams: messageListParams)
        
        // Create a new navigation controller with the chat channel view controller as its root
        let navigationController = UINavigationController(rootViewController: channelViewController)

        // Customize the appearance of the navigation bar
        navigationController.navigationBar.barTintColor = .white // Setting the background color to white
        navigationController.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.black] // Setting the title text color to black

        // Set the modal presentation style to full screen for both the navigation controller and its root
        navigationController.modalPresentationStyle = .fullScreen

        // Present the navigation controller modally from the provided view controller
        vc.present(navigationController, animated: true)
    }

    
    /// Navigates to the 'StitchDashboardVC' from the current view controller.
    func moveToStichDashboard() {
        // Attempt to instantiate 'StitchDashboardVC' from the 'Dashboard' storyboard
        if let stitchDashboardVC = UIStoryboard(name: "Dashboard", bundle: nil).instantiateViewController(withIdentifier: "StitchDashboardVC") as? StitchDashboardVC {
            
            // Find the currently active view controller
            if let currentViewController = UIViewController.currentViewController() {
                
                // Check if the current view controller is one of the specified types
                if currentViewController is FeedViewController || currentViewController is TrendingVC || currentViewController is MainMessageVC || currentViewController is ProfileViewController {
                    
                    // Get the navigation controller of the current view controller, if any
                    if let navigationController = currentViewController.navigationController {
                        // Specific behavior for certain view controller types
                        stitchDashboardVC.hidesBottomBarWhenPushed = true // Hides the bottom bar when pushed
                        hideMiddleBtn(vc: currentViewController.self) // Hides the middle button on the tab bar

                        // Navigate to 'StitchDashboardVC'
                        navigationController.pushViewController(stitchDashboardVC, animated: true)
                    }
                    
                } else {
                    // Behavior for other types of view controllers
                    if let navigationController = currentViewController.navigationController {
                        // Navigate to 'StitchDashboardVC' without additional UI modifications
                        navigationController.pushViewController(stitchDashboardVC, animated: true)
                    }
                }
            }
        }
    }
    
    /// Opens a view controller (`SelectedParentVC`) to display a specific post.
    /// - Parameter post: The `PostModel` representing the post to be displayed.
    func openPost(post: PostModel) {
        // Attempt to instantiate 'SelectedParentVC' from the 'Dashboard' storyboard
        if let selectedParentVC = UIStoryboard(name: "Dashboard", bundle: nil).instantiateViewController(withIdentifier: "SelectedRootPostVC") as? SelectedRootPostVC {
            
            // Find the currently active view controller
            if let currentViewController = UIViewController.currentViewController() {
                // Initialize a new UINavigationController with 'SelectedParentVC' as its root
                let navigationController = UINavigationController(rootViewController: selectedParentVC)
                
                // Set the properties of 'SelectedParentVC'
                selectedParentVC.onPresent = true // Indicates that the view controller is being presented
                selectedParentVC.posts = [post]    // Setting the post to be displayed
                selectedParentVC.startIndex = 0    // Starting index, assuming it's used to determine which post to show first

                // Set the modal presentation style and present the view controller
                navigationController.modalPresentationStyle = .fullScreen
                currentViewController.present(navigationController, animated: true, completion: nil)
            }
        }
    }

    
    /// Opens a view controller (`CommentNotificationVC`) to display a specific comment.
    /// - Parameters:
    ///   - commentId: The unique identifier of the comment.
    ///   - rootComment: The identifier of the root comment in the thread.
    ///   - replyToComment: The identifier of the comment to which this comment is a reply.
    ///   - type: The type of the comment or the context in which it is used.
    ///   - post: The post model associated with the comment.
    func openComment(commentId: String, rootComment: String, replyToComment: String, type: String, post: PostModel) {
        // Find the currently active view controller
        if let currentViewController = UIViewController.currentViewController() {
            // Initialize CommentNotificationVC
            let commentNotificationVC = CommentNotificationVC()
            
            // Set properties for the comment view controller
            commentNotificationVC.commentId = commentId
            commentNotificationVC.reply_to_cid = replyToComment
            commentNotificationVC.root_id = rootComment
            commentNotificationVC.type = type
            commentNotificationVC.post = post
            
            // Global settings for presentation
            global_presetingRate = Double(0.75) // Presumably a global variable affecting presentation rate
            global_cornerRadius = 35 // Presumably a global variable affecting corner radius

            // Customize the modal presentation style
            commentNotificationVC.modalPresentationStyle = .custom
            commentNotificationVC.transitioningDelegate = currentViewController.self
            
            // Present the view controller
            currentViewController.present(commentNotificationVC, animated: true, completion: nil)
        }
    }

    
    /// Opens the user profile view controller (`UserProfileVC`) for a specific user.
    /// - Parameters:
    ///   - userId: The unique identifier of the user.
    ///   - username: The username of the user.
    func openUser(userId: String, username: String) {
        // Attempt to instantiate 'UserProfileVC' from the 'Dashboard' storyboard
        if let userProfileVC = UIStoryboard(name: "Dashboard", bundle: nil).instantiateViewController(withIdentifier: "UserProfileVC") as? UserProfileVC {
            
            // Find the currently active view controller
            if let currentViewController = UIViewController.currentViewController() {
                // Initialize a new UINavigationController with 'UserProfileVC' as its root
                let navigationController = UINavigationController(rootViewController: userProfileVC)
                
                // Set the necessary properties of 'UserProfileVC'
                userProfileVC.onPresent = true  // Indicates that the view controller is being presented
                userProfileVC.userId = userId   // Sets the user ID
                userProfileVC.nickname = username // Sets the username

                // Customize the appearance of the navigation bar
                navigationController.navigationBar.barTintColor = .background // Setting the background color
                navigationController.navigationBar.tintColor = .white // Setting the tint color for navigation items
                navigationController.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white] // Setting the title text color
                
                // Set the modal presentation style and present the view controller
                navigationController.modalPresentationStyle = .fullScreen
                currentViewController.present(navigationController, animated: true, completion: nil)
            }
        }
    }

    
    /// Opens the `MainFollowVC` view controller.
    func openFollow() {
        // Attempt to instantiate 'MainFollowVC' from the 'Dashboard' storyboard
        if let mainFollowVC = UIStoryboard(name: "Dashboard", bundle: nil).instantiateViewController(withIdentifier: "MainFollowVC") as? MainFollowVC {
            
            // Find the currently active view controller
            if let currentViewController = UIViewController.currentViewController() {
                // Initialize a new UINavigationController with 'MainFollowVC' as its root
                let navigationController = UINavigationController(rootViewController: mainFollowVC)
                
                // Configure 'MainFollowVC' properties
                mainFollowVC.onPresent = true
                mainFollowVC.showFollowerFirst = true
                mainFollowVC.userId = _AppCoreData.userDataSource.value?.userID ?? ""
                mainFollowVC.followerCount = 0
                mainFollowVC.followingCount = 0
                
                // Customize the appearance of the navigation bar
                navigationController.navigationBar.barTintColor = .background
                navigationController.navigationBar.tintColor = .white
                navigationController.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
                
                // Present the view controller with a full-screen modal presentation style
                navigationController.modalPresentationStyle = .fullScreen
                currentViewController.present(navigationController, animated: true, completion: nil)
            }
        }
    }

    
    func cleanTemporaryDirectory() {
        let maxSizeInBytes: UInt64 = UInt64(0.5 * 1024 * 1024 * 1024)  // 0.5 GB
        do {
            try FileManager.default.maintainTmpDirectory(maxSizeInBytes: maxSizeInBytes)
        } catch {
            print("Failed to maintain tmp directory with error: \(error)")
        }
    }


    
}

