//
//  TiktokSignInService.swift
//  Stitchbox
//
//  Created by Hisoft Hoangnm on 12/12/2022.
//

import Foundation
import TikTokOpenSDK

class TiktokSignInService: NSObject {
    private var vm: StartViewModel

    public init(vm: StartViewModel) {
        self.vm = vm
    }
}

extension TiktokSignInService: LoginCoordinatorProtocol {
    func triggerSignIn() {
        print("Tiktok LOGIN...")
      /* STEP 1: Create the request and set permissions */
      let scopes = "user.info.basic" // list your scopes
      let scopesSet = NSOrderedSet(array:[scopes])
      let request = TikTokOpenSDKAuthRequest()
      request.permissions = scopesSet

      /* STEP 2: Send the request */
      request.send(self.vm.vc, completion: { resp -> Void in
        /* STEP 3: Parse and handle the response */
        if resp.errCode == .success {
          let responseCode = resp.code
          // Upload response code to your server and obtain user access token
          
        } else {
          return
        }
      })
    }
        
    func logout() {
        print("LOGUT...")
    }
    
}
