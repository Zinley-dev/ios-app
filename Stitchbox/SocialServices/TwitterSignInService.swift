//
//  TwitterSignInService.swift
//  Stitchbox
//
//  Created by Hisoft Hoangnm on 12/12/2022.
//

import Foundation
import Swifter

class TwitterSignInService: NSObject {
    private var vm: StartViewModel

    public init(vm: StartViewModel) {
        self.vm = vm
    }
}

extension TwitterSignInService: LoginCoordinatorProtocol {
    func triggerSignIn() {
      var swifter: Swifter!
      swifter = Swifter(consumerKey: Constants.Twitter.CONSUMER_KEY, consumerSecret: Constants.Twitter.CONSUMER_SECRET_KEY)
      swifter.authorize(withCallback: URL(string: Constants.Twitter.CALLBACK_URL)!, presentingFrom: self.vm.vc, success: { accessToken, _ in
        swifter.verifyAccountCredentials(includeEntities: false, skipStatus: false, includeEmail: true, success: { json in
          var twitterId = ""
          var name = ""
          var url = ""
          
          
          if let twitterIds = json["id_str"].string {
            twitterId = twitterIds
          } else {
            twitterId = "Not exists"
          }
          
          
          // Twitter Name
          if let twitterName = json["name"].string {
            name = twitterName
          } else {
            name = ""
          }
          
          
          // Twitter Profile Pic URL
          if let twitterProfilePic = json["profile_image_url_https"].string?.replacingOccurrences(of: "_normal", with: "", options: .literal, range: nil) {
            url =  twitterProfilePic
          } else {
            url = ""
          }
          
          let data = AuthResult(idToken: twitterId, providerID: nil, rawNonce: nil, accessToken: nil, name: name, email: nil, phone: nil, avatar: "")
          self.vm.completeSignIn(with: data)
          
        }) { error in
          print("ERROR: \(error.localizedDescription)")
        }
      }, failure: { _ in
        return
      })
    }
    
    func logout() {
        print("LOGUT...")
    }
    
}
