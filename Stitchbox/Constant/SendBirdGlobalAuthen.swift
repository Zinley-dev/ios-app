//
//  Constant.swift
//  Stitchbox
//
//  Created by Khoi Nguyen on 12/16/22.
//

import Foundation
import SendBirdSDK
import SendBirdCalls
import SendBirdUIKit
import UIKit

func syncSendbircAccount() {
    
    if _AppCoreData.userSession.value != nil {
        
        
        if let userUID = _AppCoreData.userDataSource.value?.userID {
            
            var loadUsername = ""
            
            if let userName = _AppCoreData.userDataSource.value?.userName {
                
                loadUsername = userName
                
            } else {
                
                loadUsername = "default"
                
                
            }
            
            print(userUID, loadUsername)
            
            if let avatarUrl = _AppCoreData.userDataSource.value?.avatarURL {
                
                SBUGlobals.CurrentUser = SBUUser(userId: userUID, nickname: loadUsername, profileUrl: avatarUrl)
                
            } else {
                
                SBUGlobals.CurrentUser = SBUUser(userId: userUID, nickname: loadUsername, profileUrl: nil)
                
                
            }
            
            let appDelegate: AppDelegate? = UIApplication.shared.delegate as? AppDelegate
            
            SBUMain.connectIfNeeded { user, error in
                if error != nil {
                    print(error!.localizedDescription)
                    
                }
                
                if let user = user {
                
                    print("SBUMain.connect: \(user)")
                    
                    SBDMain.setPushTriggerOption(.all) { err in
                        if err != nil {
                            
                            
                            print("Senbird: \(err!.localizedDescription)")
                            
                        }
                    }
                    
                    if let pushToken: Data = SBDMain.getPendingPushToken() {
                        SBDMain.registerDevicePushToken(pushToken, unique: false, completionHandler: { (status, error) in
                            guard let _: SBDError = error else {
                                print("APNS registration failed.")
                                return
                            }
                            
                            if status == .pending {
                                print("Push registration is pending.")
                            }
                            else {
                                print("APNS Token is registered.")
                            }
                        })
                    }
                    
                    
                    
                    let params = AuthenticateParams(userId: userUID)
                    
                    SendBirdCall.authenticate(with: params) { (cuser, err) in
                        
                        guard cuser != nil else {
                            // Failed
                            print("Senbird call: \(err!.localizedDescription)")
                            return
                        }
                                       
                        
                        appDelegate?.voipRegistration()
                        appDelegate?.addDirectCallSounds()
     
                    }
                    
                    SBDMain.setChannelInvitationPreferenceAutoAccept(false, completionHandler: { (error) in
                        guard error == nil else {
                            // Handle error.
                            print("Senbird Invites: \(error!.localizedDescription)")
            
                            return
                        }

                       
                    })
                    
                }
                
                
            }
            
            
            
        } else {
            print("Sendbird: Can't get userUID")
        }
        
        
    } else {
        print("Sendbird: Stitchbox authentication failed")
    }
    
}

func sendbirdLogout() {
    
    
    if _AppCoreData.userSession.value != nil {
      
                SBUMain.connect { user, error in
                    if error != nil {
                        print("Sendbird: \(error!.localizedDescription)")
        
                    } else {
                    
                        if user != nil {
                            
                            if let pushToken = SBDMain.getPendingPushToken() {
                                SBDMain.unregisterPushToken(pushToken, completionHandler: { (response, error) in
                                    /// Fixed Optional Problem(.getPendingPushToken()! -> pushToken)
                                    if error != nil {
                                        print("Sendbird: \(error!.localizedDescription)")
                                    } else {
                                        SBDMain.disconnect()
                                        print("SendBirdChat disconnect")
                                    }
                                })
                            }
                            
                            //
                            
                            SendBirdCall.unregisterVoIPPush(token: UserDefaults.standard.voipPushToken) { (error) in
                                
                                if error != nil {
                                    
                                    print(error!.localizedDescription)
                                    
                                } else {
                                    
                                    SendBirdCall.deauthenticate { err in
                                        if err != nil {
                                            
                                            print(err!.localizedDescription)
                                            
                                        }
                                    }
                                    
                                    
                                }
                                
                                print("SendBirdCall disconnect")

                                    // The VoIP push token has been unregistered successfully.
                            }
                            
                        }
                        
                    }
                    
                    SBDMain.removeAllChannelDelegates()
                    SBDMain.removeAllUserEventDelegates()
                    SBDMain.removeSessionDelegate()
                    SBDMain.removeAllUserEventDelegates()
                   
            }
                
    }
    
}
