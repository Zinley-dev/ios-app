//
//  SendBirdCall+QuickStart.swift
//  QuickStart
//
//  Created by Jaesung Lee on 2020/04/13.
//  Copyright © 2020 SendBird Inc. All rights reserved.
//

import UIKit
import SendBirdCalls


extension SendBirdCall {
    /**
     This method uses when,
     - the user makes outgoing calls from native call history("Recents")
     - the provider performs the specified end(decline) or answer call action.
     */
    static func authenticateIfNeed(completionHandler: @escaping (Error?) -> Void) {
        guard SendBirdCall.currentUser == nil else {
            completionHandler(nil)
            return
        }
        
        if _AppCoreData.userSession.value != nil {
            
            if let userUID = _AppCoreData.userDataSource.value?.userID {
                
                let params = AuthenticateParams(userId: userUID)
                SendBirdCall.authenticate(with: params) { (_, error) in
                    completionHandler(error)
                }
                
            }
            
            
        }
      
    }
    
    static func dial(with dialParams: DialParams) {
        SendBirdCall.dial(with: dialParams) { call, error in
            guard let call = call, error == nil else {
               // UIApplication.shared.showError(with: error?.localizedDescription)
                return
            }
            
            UIApplication.shared.showCallController(with: call)
        }
    }
}
