//
//  AppDelegate+SendBirdCallsDelegates.swift
//  QuickStart
//
//  Copyright © 2020 SendBird, Inc. All rights reserved..
//

import UIKit
import CallKit
import PushKit
import SendBirdCalls
import AsyncDisplayKit


// MARK: - Sendbird Calls Delegates
extension AppDelegate: SendBirdCallDelegate, DirectCallDelegate {
    // MARK: SendBirdCallDelegate
    // Handles incoming call. Please refer to `AppDelegate+VoIP.swift` file
    func didStartRinging(_ call: DirectCall) {
        call.delegate = self // To receive call event through `DirectCallDelegate`
        
        guard let uuid = call.callUUID else { return }
        guard CXCallManager.shared.shouldProcessCall(for: uuid) else { return }  // Should be cross-checked with state to prevent weird event processings
        
        // Use CXProvider to report the incoming call to the system
        // Construct a CXCallUpdate describing the incoming call, including the caller.
        let name = call.caller?.nickname ?? "Unknown"
        let update = CXCallUpdate()
        update.remoteHandle = CXHandle(type: .generic, value: name)
        update.hasVideo = false
        update.localizedCallerName = call.caller?.nickname ?? "Unknown"
        
        if SendBirdCall.getOngoingCallCount() > 1 {
            // Allow only one ongoing call.
            CXCallManager.shared.reportIncomingCall(with: uuid, update: update) { _ in
                CXCallManager.shared.endCall(for: uuid, endedAt: Date(), reason: .declined)
            }
            call.end()
        } else {
            // Report the incoming call to the system
            CXCallManager.shared.reportIncomingCall(with: uuid, update: update)
        }
    }
    
    // MARK: DirectCallDelegate
    func didConnect(_ call: DirectCall) {
        
        CXCallManager.shared.connectedCall(call)
        
    }
    
    func didEnd(_ call: DirectCall) {
             
        //guard let enderId = call.endedBy?.userId, let myId = SendBirdCall.currentUser?.userId, enderId != myId else { return }
        CXCallManager.shared.endCXCall(call)
        NotificationCenter.default.post(name: (NSNotification.Name(rawValue: "checkCallForLayout")), object: nil)
      
        
    }
    
    func didEstablish(_ call: DirectCall) {
        
      
        
    }
    
    func didRemoteAudioSettingsChange(_ call: DirectCall) {
        
      
        
    }
    
    func didAudioDeviceChange(_ call: DirectCall, session: AVAudioSession, previousRoute: AVAudioSessionRouteDescription, reason: AVAudioSession.RouteChangeReason) {
        
        
       
        
    }
}
