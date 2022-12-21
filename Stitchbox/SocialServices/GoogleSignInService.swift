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

        GIDSignIn.sharedInstance.signIn(with: signInConfig, presenting: vm.vc) { user, error in
            guard error == nil else { return }
            guard let user = user else { return }

            if let profiledata = user.profile {
                
                let userId : String = user.userID ?? ""
                let givenName : String = profiledata.givenName ?? ""
                let familyName : String = profiledata.familyName ?? ""
                let email : String = profiledata.email
                
                if let imgurl = user.profile?.imageURL(withDimension: 100) {
                    let absoluteurl : String = imgurl.absoluteString
                    
                    let data = AuthResult(idToken: userId, providerID: nil, rawNonce: nil, accessToken: nil, name: "\(familyName) \(givenName)", email: email, phone: nil)
                    self.vm.completeSignIn(with: data)
                }
            }
        }
    }
    
    func logout() {
        GIDSignIn.sharedInstance.signOut()
    }
}
