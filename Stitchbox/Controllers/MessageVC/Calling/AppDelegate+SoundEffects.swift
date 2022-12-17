//
//  AppDelegate+SoundEffects.swift
//  QuickStart
//
//  Created by Jaesung Lee on 2020/07/30.
//  Copyright © 2020 SendBird Inc. All rights reserved.
//

import SendBirdCalls

// MARK: DirectCall sound effects
// If you use CallKit framework, you have to set ringing sound by using `CXProviderConfiguration.ringtoneSound`. See `CXProvider+QuickStart.swift` file.
// If you use CallKit framework, you must implement `CXProviderDelegate.provider(_:didActivate:)` and `CXProviderDelegate.provider(_:didDeactivate:)`
extension AppDelegate {
    func addDirectCallSounds() {
        SendBirdCall.addDirectCallSound("Ringing.mp3", forType: .ringing)
        SendBirdCall.addDirectCallSound("Dialing.mp3", forType: .dialing)
        SendBirdCall.addDirectCallSound("ConnectionLost.mp3", forType: .reconnecting)
        SendBirdCall.addDirectCallSound("ConnectionRestored.mp3", forType: .reconnected)
    }
}
