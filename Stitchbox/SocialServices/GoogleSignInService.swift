//
//  GoogleSignInService.swift
//  Stitchbox
//
//  Created by Hisoft Hoangnm on 12/12/2022.
//

import Foundation
import GoogleSignIn

class GoogleSignInService: NSObject {
    private var vm: StartViewModel

    public init(vm: StartViewModel) {
        self.vm = vm
    }
}

extension GoogleSignInService: LoginCoordinatorProtocol {

    func triggerSignIn() {
        let signInConfig = GIDConfiguration(clientID: Constants.GoogleSignIn.clientId)
        
        
        GIDSignIn.sharedInstance.configuration = signInConfig
        
        GIDSignIn.sharedInstance.signIn(withPresenting: vm.vc){ signInResult, error in
            guard error == nil else { return }
            guard let info = signInResult else { return }
            
            if let profiledata = info.user.profile {
                print("PROFILE DATA \(profiledata)")
                let userId : String = info.user.userID ?? ""
                let givenName : String = profiledata.givenName ?? ""
                let familyName : String = profiledata.familyName ?? ""
                let email : String = profiledata.email
                
                if let imgurl = profiledata.imageURL(withDimension: 100) {
                    let absoluteurl : String = imgurl.absoluteString
                    
                    let data = AuthResult(idToken: userId, providerID: nil, rawNonce: nil, accessToken: nil, name: "\(familyName) \(givenName)", email: email, phone: nil, avatar: absoluteurl)
                    print("DATA --> \(data.idToken)")
                    print("DATA --> \(data.name)")
                    print("DATA --> \(data.email)")
                    print("DATA --> \(data.avatar)")
                    self.vm.completeSignIn(with: data)
                }
            }
            
            // If sign in succeeded, display the app's main content View.
        }

    }
    
    func logout() {
        GIDSignIn.sharedInstance.signOut()
    }
}
