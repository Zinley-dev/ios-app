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

@main
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate, SBDChannelDelegate {
    
    var window: UIWindow?
    var voipRegistry: PKPushRegistry?

    static let sharedInstance = UIApplication.shared.delegate as! AppDelegate
    private var audioLevel : Float = 0.0
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?)
    -> Bool {
        ApplicationDelegate.shared.application(
            application,
            didFinishLaunchingWithOptions: launchOptions
        )
        TikTokOpenSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        UNUserNotificationCenter.current().delegate = self
        
        setupPixelSDK()
        sendbird_authentication()
        syncSendbirdAccount()
        attemptRegisterForNotifications(application: application)
        setupStyle()
        setupOneSignal(launchOptions: launchOptions)
        getGameList()
        activeSpeaker()
        //listenVolumeButton()
        
        GMSServices.provideAPIKey("AIzaSyAAYuBDXTubo_qcayPX6og_MrWq9-iM_KE")
        GMSPlacesClient.provideAPIKey("AIzaSyAAYuBDXTubo_qcayPX6og_MrWq9-iM_KE")
        
        return true
    }
    
    func listenVolumeButton(){
        
         let audioSession = AVAudioSession.sharedInstance()
         do {
              try audioSession.setActive(true, options: [])
         audioSession.addObserver(self, forKeyPath: "outputVolume",
                                  options: NSKeyValueObservingOptions.new, context: nil)
              audioLevel = audioSession.outputVolume
         } catch {
              print("Error")
         }
    }
  
    func setupOneSignal(launchOptions: [UIApplication.LaunchOptionsKey: Any]?) {
      // OneSignal initialization
      OneSignal.initWithLaunchOptions(launchOptions)
      OneSignal.setAppId("209c3011-21c8-43ba-aff2-b2865e03aee5")
      
      // promptForPushNotifications will show the native iOS notification permission prompt.
      // We recommend removing the following code and instead using an In-App Message to prompt for notification permission (See step 8)
      OneSignal.promptForPushNotifications(userResponse: { accepted in
        print("User accepted notifications: \(accepted)")
      })
    }

    func setupPixelSDK() {
        
        PixelSDK.setup(pixel_key)
        PixelSDK.shared.maxVideoDuration = 180
        PixelSDK.shared.primaryFilters = PixelSDK.defaultStandardFilters + PixelSDK.defaultVisualEffectFilters
        
    }
    
    func setupStyle() {
        
        SBUTheme.set(theme: .dark)
        
        
        SBUTheme.channelListTheme.navigationBarTintColor = UIColor.background
        
        
        //SBUStringSet.Empty_No_Channels = "No messages"
        SBUStringSet.User_No_Name = "Stitchbox user"
        SBUStringSet.User_Operator = "Leader"
        
        //
        SBUGlobals.UsingImageCompression = true
        SBUGlobals.imageCompressionRate = 0.65
        SBUGlobals.imageResizingSize = CGSize(width: 480, height: 480)
        SBUTheme.componentTheme.barItemTintColor = UIColor.white
        
        
        SBUTheme.messageCellTheme.leftBackgroundColor = UIColor.darkGray
        SBUTheme.messageCellTheme.rightBackgroundColor = UIColor.primary
        SBUTheme.messageCellTheme.userMessageLeftTextColor = UIColor.white
        SBUTheme.messageCellTheme.userMessageRightTextColor = UIColor.white
        SBUTheme.messageCellTheme.userMessageLeftEditTextColor = UIColor.white
        SBUTheme.messageCellTheme.userMessageRightEditTextColor = UIColor.white
        SBUTheme.messageInputTheme.backgroundColor = UIColor.black
        SBUTheme.messageInputTheme.buttonTintColor = UIColor.white
        
        
        SBUTheme.channelSettingsTheme.navigationBarTintColor = UIColor.background
        SBUTheme.channelSettingsTheme.rightBarButtonTintColor = UIColor.white
        SBUTheme.channelSettingsTheme.leftBarButtonTintColor = UIColor.white
        SBUTheme.channelSettingsTheme.cellArrowIconTintColor = UIColor.white
        SBUTheme.channelSettingsTheme.cellSwitchColor = UIColor.secondary
        SBUTheme.channelSettingsTheme.cellTypeIconTintColor = UIColor.white
        SBUTheme.channelSettingsTheme.backgroundColor = UIColor(red: 51/255, green: 51/255, blue: 51/255, alpha: 1.0)
        
        
        SBUTheme.userListTheme.navigationBarTintColor = UIColor.background
        
        
        SBUTheme.messageSearchTheme.backgroundColor = UIColor(red: 51/255, green: 51/255, blue: 51/255, alpha: 1.0)
        SBUTheme.userListTheme.statusBarStyle = .lightContent
        
        SBUTheme.overlayTheme.componentTheme.backgroundColor = UIColor(red: 51/255, green: 51/255, blue: 51/255, alpha: 1.0)
        SBUTheme.overlayTheme.componentTheme.loadingBackgroundColor = UIColor(red: 51/255, green: 51/255, blue: 51/255, alpha: 1.0)
        
        SBUTheme.userProfileTheme.backgroundColor = UIColor(red: 51/255, green: 51/255, blue: 51/255, alpha: 1.0)
        SBUTheme.userProfileTheme.usernameTextColor = UIColor.white
        SBUTheme.messageSearchResultCellTheme.backgroundColor = UIColor(red: 51/255, green: 51/255, blue: 51/255, alpha: 1.0)
        
        SBUTheme.userCellTheme.backgroundColor = UIColor(red: 51/255, green: 51/255, blue: 51/255, alpha: 1.0)
        
        
        SBUTheme.channelTheme.navigationBarTintColor = UIColor.background
        SBUTheme.channelTheme.backgroundColor = UIColor(red: 51/255, green: 51/255, blue: 51/255, alpha: 1.0)
        
        SBUTheme.channelTheme.leftBarButtonTintColor = UIColor.white
        SBUTheme.channelTheme.rightBarButtonTintColor = UIColor.white
        
        SBUTheme.componentTheme.loadingBackgroundColor = UIColor(red: 51/255, green: 51/255, blue: 51/255, alpha: 1.0)
        SBUTheme.componentTheme.addReactionTintColor = UIColor.secondary
        SBUTheme.componentTheme.loadingSpinnerColor = UIColor.secondary
       
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
           scheme.localizedCaseInsensitiveCompare("stitchbox") == .orderedSame,
           let view = url.host {
          
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
        completionHandler([.alert, .sound])
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
                    self.presentChatWithNav(nav: nav, channelUrl: channelUrl)
                }
                
            } else {
                self.presentChatWithoutNav(vc: currentVC, channelUrl: channelUrl)
            }

            
            
        }
        
        
    }
    
    func presentChatWithNav(nav: UINavigationController, channelUrl: String) {
        
        let mlsp = SBDMessageListParams()
        let channelVC = ChannelViewController(channelUrl: channelUrl, messageListParams: mlsp)
        nav.pushViewController(channelVC, animated: true)
        
    }
    
    func presentChatWithoutNav(vc: UIViewController, channelUrl: String) {
        
        let mlsp = SBDMessageListParams()
        let channelVC = ChannelViewController(channelUrl: channelUrl, messageListParams: mlsp)
        let navigationController = UINavigationController(rootViewController: channelVC)
        navigationController.modalPresentationStyle = .fullScreen
        vc.present(navigationController, animated: true, completion: nil)
        
    }
    
    func getGameList() {
        
        global_suppport_game_list.removeAll()
        
        APIManager().getGames { result in
            switch result {
            case .success(let apiResponse):
                
                guard apiResponse.body?["message"] as? String == "success",
                      let data = apiResponse.body?["data"] as? [[String: Any]] else {
                   
                    return
                }
            
                let list = data.compactMap { GameList(JSON: $0) }
                global_suppport_game_list += list
                
            case .failure(let error):
                print(error)
                
            }
        }
        
    }
    

    
}

