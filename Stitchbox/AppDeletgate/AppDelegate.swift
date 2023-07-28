//
//  AppDelegate.swift
//  Stitchbox
//
//  Created by Nghiem Minh Hoang on 26/10/2022.
//

import UIKit
import FirebaseCore
import GoogleSignIn
import FBSDKCoreKit
import SendBirdSDK
import SendBirdCalls
import PushKit
import UserNotifications
import SendBirdUIKit
import PixelSDK
import UserNotifications
import TikTokOpenSDK
import OneSignal
import GooglePlaces
import GoogleMaps
import Sentry
import SwipeTransition
import SwipeTransitionAutoSwipeBack
import SwipeTransitionAutoSwipeToDismiss
import AppsFlyerLib
import AppTrackingTransparency

@main
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate, SBDChannelDelegate {
    
    var window: UIWindow?
    var voipRegistry: PKPushRegistry?
    var volumeOutputList = [Float]()
    static let sharedInstance = UIApplication.shared.delegate as! AppDelegate
    lazy var delayItem = workItem()
    private var audioLevel : Float = 0.0
    
    private var previousVolume: Float = 0.0
    private var outputVolumeObserver: NSKeyValueObservation?
    private var consecutiveVolumeDownPresses: Int = 0
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?)
    -> Bool {
        ApplicationDelegate.shared.application(
            application,
            didFinishLaunchingWithOptions: launchOptions
        )
        
        UNUserNotificationCenter.current().delegate = self
        setupPixelSDK()
        sendbird_authentication()
        registerAppsFlyer()
        
        setupPixelSDK()
        sendbird_authentication()
        syncSendbirdAccount()
        attemptRegisterForNotifications(application: application)
        setupStyle()
        setupOneSignal(launchOptions: launchOptions)
        activeSpeaker()
        setupVolumeObserver()
        sentrySetup()
        
        
        GMSServices.provideAPIKey("AIzaSyAAYuBDXTubo_qcayPX6og_MrWq9-iM_KE")
        GMSPlacesClient.provideAPIKey("AIzaSyAAYuBDXTubo_qcayPX6og_MrWq9-iM_KE")
        
        //SwipeBackConfiguration.shared = CustomSwipeBackConfiguration()
     
        return true
        
    }
    
    
    func sentrySetup() {
        
        SentrySDK.start { options in
            options.dsn = "https://3406dbc29f884019aa59d9319a12b765@o4505243020689408.ingest.sentry.io/4505243021606912"
            options.debug = true // Enabled debug when first installing is always helpful
            
            // Set tracesSampleRate to 1.0 to capture 100% of transactions for performance monitoring.
            // We recommend adjusting this value in production.
            options.tracesSampleRate = 1.0
        }
        
    }
    
    private func setupVolumeObserver() {
        let audioSession = AVAudioSession.sharedInstance()
        previousVolume = audioSession.outputVolume
        outputVolumeObserver = audioSession.observe(\.outputVolume) { [weak self] _, _ in
            self?.handleVolumeChange()
        }
    }
    
    private func handleVolumeChange() {
        let audioSession = AVAudioSession.sharedInstance()
        let currentVolume = audioSession.outputVolume
        
        if currentVolume >= 1.0 {
            consecutiveVolumeDownPresses = 0
            unmuteVideoIfNeed()
        } else if currentVolume > previousVolume {
            consecutiveVolumeDownPresses = 0
            unmuteVideoIfNeed()
        } else if currentVolume < previousVolume {
            consecutiveVolumeDownPresses += 1
            if consecutiveVolumeDownPresses >= 2 {
                // muteVideoIfNeed()
                consecutiveVolumeDownPresses = 0
            }
        }
        
        previousVolume = currentVolume
    }

    
    
    func setupOneSignal(launchOptions: [UIApplication.LaunchOptionsKey: Any]?) {
        // Initialize OneSignal
        OneSignal.initWithLaunchOptions(launchOptions)
        OneSignal.setAppId("209c3011-21c8-43ba-aff2-b2865e03aee5")
        
        // Prompt the user to allow push notifications
        OneSignal.promptForPushNotifications(userResponse: { accepted in
            print("User accepted notifications: \(accepted)")
        })
        
        
        // Set a notification opened handler
        OneSignal.setNotificationOpenedHandler { result in
            let notification: OSNotification = result.notification
            
            // Extract the additional data from the notification
            if let additionalData = notification.additionalData,
               let text = additionalData["data"] as? String,
               let data = self.convertStringToDictionary(text: text),
               let metadata = data["metadata"] as? String,
               let metaDataDict = self.convertStringToDictionary(text: metadata) {
                
                let metaDataOneSignal = OneSignalNotiModel(OneSignalNotiModel: metaDataDict)
                
                if let template = metaDataOneSignal.template{
                    
                    switch template {
                        
                    case "NEW_COMMENT":
                        if let post = metaDataOneSignal.post {
                            self.openComment(commentId: metaDataOneSignal.commentId, rootComment: metaDataOneSignal.rootComment, replyToComment: metaDataOneSignal.replyToComment, type: template, post: post)
                        }
                        
                    case "REPLY_COMMENT":
                        if let post = metaDataOneSignal.post {
                            self.openComment(commentId: metaDataOneSignal.commentId, rootComment: metaDataOneSignal.rootComment, replyToComment: metaDataOneSignal.replyToComment, type: template, post: post)
                        }
                        
                    case "NEW_FISTBUMP_1":
                        if let userId = metaDataOneSignal.userId, let username = metaDataOneSignal.username {
                            self.openUser(userId: userId, username: username)
                        }
                    case "NEW_FISTBUMP_2":
                        self.openFistBumpList()
                    case "NEW_FOLLOW_1":
                        
                        if let userId = metaDataOneSignal.userId, let username = metaDataOneSignal.username {
                            self.openUser(userId: userId, username: username)
                        }
                        
                    case "NEW_FOLLOW_2":
                        self.openFollow()
                    case "NEW_TAG":
                        if let post = metaDataOneSignal.post {
                            self.openComment(commentId: metaDataOneSignal.commentId, rootComment: metaDataOneSignal.rootComment, replyToComment: metaDataOneSignal.replyToComment, type: template, post: post)
                        }
                    case "NEW_POST":
                        self.openPost(post: metaDataOneSignal.post)
                        
                    case "LIKE_COMMENT":
                        if let userId = metaDataOneSignal.userId, let username = metaDataOneSignal.username {
                            self.openUser(userId: userId, username: username)
                        }
                    case "LIKE_POST":
                        if let userId = metaDataOneSignal.userId, let username = metaDataOneSignal.username {
                            self.openUser(userId: userId, username: username)
                        }
                    case "NEW_STITCH":
                        self.moveToStichDashboard()
                    case  "APPROVED_STITCH":
                        self.moveToStichDashboard()
                    case "DENIED_STITCH":
                        self.moveToStichDashboard()
                    default:
                        print("None")
                        
                    }
                    
                    
                }
                
            }
        }
    }

    // Helper function to convert a string to a dictionary
    func convertStringToDictionary(text: String) -> [String:Any]? {
        if let data = text.data(using: .utf8) {
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String:Any]
                return json
            } catch {
                print("Error converting string to dictionary: \(error.localizedDescription)")
            }
        }
        return nil
    }
    
    
    func setupPixelSDK() {
        
        PixelSDK.setup(pixel_key)
        PixelSDK.shared.maxVideoDuration = 120
        PixelSDK.shared.primaryFilters = PixelSDK.defaultStandardFilters + PixelSDK.defaultVisualEffectFilters
        
    }
    
    func setupStyle() {
        
        SBUTheme.set(theme: .light)
        
        //SBUStringSet.Empty_No_Channels = "No messages"
        SBUStringSet.User_No_Name = "Stitchbox user"
        SBUStringSet.User_Operator = "Leader"
        
        //
        SBUGlobals.UsingImageCompression = true
        SBUGlobals.imageCompressionRate = 0.65
        SBUGlobals.imageResizingSize = CGSize(width: 480, height: 480)
        SBUTheme.componentTheme.barItemTintColor = UIColor.black
        
        SBUTheme.messageCellTheme.leftBackgroundColor = .normalButtonBackground
        SBUTheme.messageCellTheme.rightBackgroundColor = UIColor(red: 53, green: 46, blue: 113)
        SBUTheme.messageCellTheme.userMessageLeftTextColor = UIColor.black
        SBUTheme.messageCellTheme.userMessageRightTextColor = UIColor.white
        SBUTheme.overlayTheme.componentTheme.backgroundColor = .white
        SBUTheme.overlayTheme.componentTheme.loadingBackgroundColor = .white
        
        SBUTheme.channelTheme.navigationBarTintColor = UIColor.white
        SBUTheme.channelTheme.backgroundColor = .white
        
        SBUTheme.channelTheme.leftBarButtonTintColor = UIColor.black
        SBUTheme.channelTheme.rightBarButtonTintColor = UIColor.black
        
        SBUTheme.componentTheme.loadingBackgroundColor = .white
        SBUTheme.componentTheme.addReactionTintColor = UIColor.secondary
        SBUTheme.componentTheme.loadingSpinnerColor = UIColor.secondary
        
        SBUTheme.messageInputTheme.buttonTintColor = .black

        
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
    func application(
        _ application: UIApplication,
        open url: URL,
        options: [UIApplication.OpenURLOptionsKey: Any])
    -> Bool {
        
        if let scheme = url.scheme,
           scheme.localizedCaseInsensitiveCompare("stitchbox") == .orderedSame {
            
            var parameters: [String: String] = [:]
            URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems?.forEach {
                parameters[$0.name] = $0.value
            }
            
            // TODO implement
            // redirect(to: view, with: parameters)
        }
        
        guard let sourceApplication = options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String,
              let annotation = options[UIApplication.OpenURLOptionsKey.annotation] else {
            return false
        }
        
        if TikTokOpenSDKApplicationDelegate.sharedInstance().application(application, open: url, sourceApplication: sourceApplication, annotation: annotation) {
            return true
        }
        
        ApplicationDelegate.shared.application(
            application,
            open: url,
            sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String,
            annotation: options[UIApplication.OpenURLOptionsKey.annotation]
        )
        return GIDSignIn.sharedInstance.handle(url)
    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        if TikTokOpenSDKApplicationDelegate.sharedInstance().application(application, open: url, sourceApplication: sourceApplication, annotation: annotation) {
            return true
        }
        return false
    }
    
    func application(_ application: UIApplication, handleOpen url: URL) -> Bool {
        if TikTokOpenSDKApplicationDelegate.sharedInstance().application(application, open: url, sourceApplication: nil, annotation: "") {
            return true
        }
        return false
    }
    
    
    //
    
    func sendbird_authentication() {
        
        SBDMain.initWithApplicationId(sendbird_key)
        SBUMain.initialize(applicationId: sendbird_key) { (error) in
            if let error = error {
                // An error occurred during initialization
                print("Error initializing SendBird UIKit: \(error)")
            } else {
                // Initialization was successful
                print("SendBird UIKit initialized successfully")
            }
        }
        SendBirdCall.configure(appId: sendbird_key)
        SendBirdCall.addDelegate(self, identifier: "com.mobile.gg.Stitchbox1")
        SendBirdCall.executeOn(queue: DispatchQueue.main)
        UserDefaults.standard.designatedAppId = sendbird_key
        SBDMain.add(self as SBDChannelDelegate, identifier: self.description)
        
    }
    
    private func attemptRegisterForNotifications(application: UIApplication) {
        print("Attempting to register APNS...")
        
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().delegate = self
            // user notifications auth
            // all of this works for iOS 10+
            let options: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(options: options) { (granted, err) in
                if let err = err {
                    print("Failed to request auth:", err)
                    return
                }
                
                if granted {
                    print("Auth granted.")
                    
                } else {
                    print("Auth denied")
                }
            }
        } else {
            
            let notificationSettings = UIUserNotificationSettings(types: [.badge, .sound, .alert], categories: nil)
            application.registerUserNotificationSettings(notificationSettings)
            
            
        }
        
        
        application.registerForRemoteNotifications()
        
        
    }
    
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.badge, .sound])
    }
    
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print("Registered for notifications:", deviceToken)
        
        SBDMain.registerDevicePushToken(deviceToken, unique: false) { (status, error) in
            if error == nil {
                if status == SBDPushTokenRegistrationStatus.pending {
                    print("Push registration is pending.")
                }
                else {
                    print("APNS Token is registered.")
                }
            }
            else {
                print("APNS registration failed with error: \(String(describing: error))")
            }
        }
        
        
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // This method will be called when the app is forcefully terminated.
        // End all ongoing calls in this method.
        let callManager = CXCallManager.shared
        let ongoingCalls = callManager.currentCalls.compactMap { SendBirdCall.getCall(forUUID: $0.uuid) }
        
        ongoingCalls.forEach { directCall in
            // Sendbird Calls: End call
            directCall.end()
            
            // CallKit: Request End transaction
            callManager.endCXCall(directCall)
            
            // CallKit: Report End if uuid is valid
            if let uuid = directCall.callUUID {
                callManager.endCall(for: uuid, endedAt: Date(), reason: .none)
            }
        }
        // However, because iOS gives a limited time to perform remaining tasks,
        // There might be some calls failed to be ended
        // In this case, I recommend that you register local notification to notify the unterminated calls.
    }
    
    // This method is called when a local notification is received and the user has interacted with it.
    // It presents a ChannelViewController with the channel specified in the notification.
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        // Extract the user info dictionary and the channel URL from the notification payload.
        // Return early if the user is not logged in or the required information is not present.
        
        if let type = response.notification.request.content.userInfo["type"] as? String, type == "sendbird_localNoti" {
            
            guard let userUID = _AppCoreData.userDataSource.value?.userID, !userUID.isEmpty, let channelUrl = response.notification.request.content.userInfo["channel_url"] as? String else {
                return
            }
            
            checkAndPresendChatVC(userUID: userUID, channelUrl: channelUrl)
            
            completionHandler()
            
            
        } else if ((response.notification.request.content.userInfo["sendbird"] as? NSDictionary) != nil) {
            
            guard let userUID = _AppCoreData.userDataSource.value?.userID, !userUID.isEmpty,
                  let payload = response.notification.request.content.userInfo["sendbird"] as? NSDictionary,
                  let channel = payload["channel"] as? NSDictionary,
                  let channelUrl = channel["channel_url"] as? String else {
                return
            }
            
            checkAndPresendChatVC(userUID: userUID, channelUrl: channelUrl)
            // Call the completion handler to indicate that the method has finished executing.
            completionHandler()
            
            
        } else {
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

    
    
    func presentChatWithoutNav(vc: UIViewController, channelUrl: String) {
        
        let mlsp = SBDMessageListParams()
        let channelVC = ChannelViewController(channelUrl: channelUrl, messageListParams: mlsp)
        
        
        let nav = UINavigationController(rootViewController: channelVC)

     
        // Customize the navigation bar appearance
        nav.navigationBar.barTintColor = .white
        nav.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.black]

        nav.modalPresentationStyle = .fullScreen
 
       // self.navigationController?.pushViewController(channelVC, animated: true)
        nav.modalPresentationStyle = .fullScreen
        vc.present(nav, animated: true)
        
    }

    func moveToStichDashboard() {
        
        if let PVC = UIStoryboard(name: "Dashboard", bundle: nil).instantiateViewController(withIdentifier: "StitchDashboardVC") as? StitchDashboardVC {
            
            
            if let vc = UIViewController.currentViewController() {
                
                
                if vc is FeedViewController || vc is TrendingVC || vc is MainMessageVC || vc is ProfileViewController {
                    
                    if let nav = vc.navigationController {
                        
                        PVC.hidesBottomBarWhenPushed = true
                        hideMiddleBtn(vc: vc.self)
                        nav.pushViewController(PVC, animated: true)
                        
                    }
                    
                    
                } else {
                    
                    if let nav = vc.navigationController {
                        
                        nav.pushViewController(PVC, animated: true)
                        
                    }
                    
                    
                }
                
                
                
            }
           
            
        }
      
        
    }
    
    func openFistBumpList() {

        
        
    }
    
    func openPost(post: PostModel) {
        
        if let SPVC = UIStoryboard(name: "Dashboard", bundle: nil).instantiateViewController(withIdentifier: "SelectedPostVC") as? SelectedPostVC {
            
            if let vc = UIViewController.currentViewController() {
                
                let nav = UINavigationController(rootViewController: SPVC)
                
                // Set the user ID, nickname, and onPresent properties of UPVC
                SPVC.onPresent = true
                SPVC.selectedPost = [post]
                SPVC.startIndex = 0
                
                
                // Customize the navigation bar appearance
                nav.navigationBar.barTintColor = .background
                nav.navigationBar.tintColor = .white
                nav.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
                
                nav.modalPresentationStyle = .fullScreen
                vc.present(nav, animated: true, completion: nil)
                
            }
            
            
        }
        
        
    }
    
    func openComment(commentId: String, rootComment: String, replyToComment: String, type: String, post: PostModel) {
        
        if let vc = UIViewController.currentViewController() {
            
            let slideVC = CommentNotificationVC()
            
            slideVC.commentId = commentId
            slideVC.reply_to_cid = replyToComment
            slideVC.root_id = rootComment
            slideVC.type = type
            slideVC.post = post
            
            global_presetingRate = Double(0.75)
            global_cornerRadius = 35
            
            slideVC.modalPresentationStyle = .custom
            slideVC.transitioningDelegate = vc.self
            
            vc.present(slideVC, animated: true, completion: nil)
            
            
        }
        
        
    }
    
    func openUser(userId: String, username: String) {
        
        
        if let UPVC = UIStoryboard(name: "Dashboard", bundle: nil).instantiateViewController(withIdentifier: "UserProfileVC") as? UserProfileVC {
            
            if let vc = UIViewController.currentViewController() {
                
                let nav = UINavigationController(rootViewController: UPVC)
                
                // Set the user ID, nickname, and onPresent properties of UPVC
                UPVC.onPresent = true
                UPVC.userId = userId
                UPVC.nickname = username
                
                
                // Customize the navigation bar appearance
                nav.navigationBar.barTintColor = .background
                nav.navigationBar.tintColor = .white
                nav.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
                
                nav.modalPresentationStyle = .fullScreen
                vc.present(nav, animated: true, completion: nil)
                
                
            }
            
            
        }
        
    }
    
    func openFollow() {
        
        if let MFVC = UIStoryboard(name: "Dashboard", bundle: nil).instantiateViewController(withIdentifier: "MainFollowVC") as? MainFollowVC {
            
            
            if let vc = UIViewController.currentViewController() {
                
                let nav = UINavigationController(rootViewController: MFVC)
                
                // Set the user ID, nickname, and onPresent properties of UPVC
                MFVC.onPresent = true
                MFVC.showFollowerFirst = true
                MFVC.userId = _AppCoreData.userDataSource.value?.userID ?? ""
                MFVC.followerCount = 0
                MFVC.followingCount = 0
                
                
                // Customize the navigation bar appearance
                nav.navigationBar.barTintColor = .background
                nav.navigationBar.tintColor = .white
                nav.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
                
                nav.modalPresentationStyle = .fullScreen
                vc.present(nav, animated: true, completion: nil)
                
                
            }
            
        }
        
        
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        UIApplication.shared.applicationIconBadgeNumber = 0
        requestAppleReview()
        if _AppCoreData.userDataSource.value?.userID != "" {
            requestTrackingAuthorization(userId: _AppCoreData.userDataSource.value?.userID ?? "")
        }
        
        
    }
    
    func registerAppsFlyer() {
        
        AppsFlyerLib.shared().appsFlyerDevKey = "sumV9RMiJVui7vtQoBVEx"
        AppsFlyerLib.shared().appleAppID = "1660843872"
        
    }
    
     
    
}

