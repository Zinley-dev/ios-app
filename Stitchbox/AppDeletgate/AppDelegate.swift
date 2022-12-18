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

@main
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate, SBDChannelDelegate {
    
    
    var voipRegistry: PKPushRegistry?

    static let sharedInstance = UIApplication.shared.delegate as! AppDelegate

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?)
    -> Bool {
        ApplicationDelegate.shared.application(
            application,
            didFinishLaunchingWithOptions: launchOptions
        )
        
        
        sendbird_authentication()
        syncSendbirdAccount()
        attemptRegisterForNotifications(application: application)
        setupStyle()
        return true
    }
    
    func setupStyle() {
        
        SBUTheme.set(theme: .dark)
        SBUTheme.channelListTheme.navigationBarTintColor = UIColor.background
        SBUTheme.channelTheme.navigationBarTintColor = UIColor.background
        SBUTheme.channelSettingsTheme.navigationBarTintColor = UIColor.background
        
        //SBUStringSet.Empty_No_Channels = "No messages"
        SBUStringSet.User_No_Name = "Stitchbox user"
        SBUStringSet.User_Operator = "Leader"
        
        //
        SBUGlobals.UsingImageCompression = true
        SBUGlobals.imageCompressionRate = 0.65
        SBUGlobals.imageResizingSize = CGSize(width: 480, height: 480)
        
        
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
      ApplicationDelegate.shared.application(
          application,
          open: url,
          sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String,
          annotation: options[UIApplication.OpenURLOptionsKey.annotation]
      )
      return GIDSignIn.sharedInstance.handle(url)
    }
    
    
    //
    
    func sendbird_authentication() {
        
        SBDMain.initWithApplicationId(sendbird_key, useCaching: false) {
            print("initWithApplicationId: \(sendbird_key)")
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

}

