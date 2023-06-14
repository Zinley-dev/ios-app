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

func syncSendbirdAccount() {
    
    guard _AppCoreData.userSession.value != nil else {
        print("Sendbird: Stitchbox authentication failed")
        return
    }
    
    guard let userDataSource = _AppCoreData.userDataSource.value, let userUID = userDataSource.userID, userUID != "" else {
        print("Sendbird: Can't get userUID")
        return
    }
    
    let loadUsername = userDataSource.userName ?? "default"
    let avatarUrl = userDataSource.avatarURL
    
    if avatarUrl != "" {
        let sbuUser = SBUUser(userId: userUID, nickname: loadUsername, profileUrl: avatarUrl)
        SBUGlobals.CurrentUser = sbuUser
    } else {
        let sbuUser = SBUUser(userId: userUID, nickname: loadUsername, profileUrl: emptySB)
        SBUGlobals.CurrentUser = sbuUser
    }
    
  
    SBUMain.connectIfNeeded { user, error in
        if let error = error {
            print("SBUMain.connect:", error.localizedDescription)
            return
        }

        guard let _ = user else {
            print("SBUMain.connect: no user")
            return
        }

        SBDMain.setPushTriggerOption(.all) { error in
            if let error = error {
                print("Senbird:", error.localizedDescription)
            }
        }

        if let pushToken = SBDMain.getPendingPushToken() {
            SBDMain.registerDevicePushToken(pushToken, unique: false) { status, error in
                guard error == nil else {
                    print("APNS registration failed.")
                    return
                }

                if status == .pending {
                    print("Push registration is pending.")
                } else {
                    print("APNS Token is registered.")
                }
            }
        } else {
            // No pending push token.
        }

        SBDMain.setChannelInvitationPreferenceAutoAccept(true) { error in
            guard error == nil else {
                print("Senbird Invites:", error!.localizedDescription)
                return
            }

            let params = AuthenticateParams(userId: userUID)
            SendBirdCall.authenticate(with: params) { cuser, err in
                guard cuser != nil else {
                    // Failed
                    print("Senbird call:", err!.localizedDescription)
                    return
                }

                let appDelegate = UIApplication.shared.delegate as? AppDelegate
                appDelegate?.voipRegistration()
                appDelegate?.addDirectCallSounds()
            }
        }
    }
}


func sendbirdLogout() {
    guard _AppCoreData.userSession.value != nil else {
        print("Sendbird: Stitchbox authentication failed")
        return
    }
    SBUMain.connect { user, error in
        if let error = error {
            print("Sendbird: \(error.localizedDescription)")
            return
        }

        guard user != nil else {
            print("Sendbird: Failed to get user")
            return
        }

        if let pushToken = SBDMain.getPendingPushToken() {
            SBDMain.unregisterPushToken(pushToken, completionHandler: { (response, error) in
                if let error = error {
                    print("Sendbird: \(error.localizedDescription)")
                } else {
                    SBDMain.disconnect()
                    print("SendBirdChat disconnect")
                }
            })
        }

        SendBirdCall.unregisterVoIPPush(token: UserDefaults.standard.voipPushToken) { error in
            if let error = error {
                print(error.localizedDescription)
            } else {
                SendBirdCall.deauthenticate { error in
                    if let error = error {
                        print(error.localizedDescription)
                    }
                }
                print("SendBirdCall disconnect")
            }
        }

        SBDMain.removeAllChannelDelegates()
        SBDMain.removeAllUserEventDelegates()
        SBDMain.removeSessionDelegate()
        SBDMain.removeAllUserEventDelegates()
        
        SBUMain.disconnect {
            
        }
        
    }
}


func checkForChannelInvitation(channelUrl: String, user_ids: [String]) {
    
    
    APIManager.shared.channelCheckForInviation(userIds: user_ids, channelUrl: channelUrl) { result in
        switch result {
        case .success(let apiResponse):
            // Check if the request was successful
            guard apiResponse.body?["message"] as? String == "success",
                let data = apiResponse.body?["data"] as? [String: Any] else {
                    return
            }
            
            print(data)
            
           
        case .failure(let error):
            print(error)
        }
    }
    
    
}

