//
//  FacebookSignInService.swift
//  Stitchbox
//
//  Created by Hisoft Hoangnm on 12/12/2022.
//

import Foundation
import FBSDKLoginKit

class FacebookSignInService: NSObject {
    private var vm: StartViewModel

    public init(vm: StartViewModel) {
        self.vm = vm
    }
}

extension FacebookSignInService: LoginCoordinatorProtocol {
    func triggerSignIn() {
        print("FACEBOOK LOGIN...")
        let loginManager = LoginManager()
        loginManager.logIn(permissions: ["public_profile"], from: vm.vc) { result, error in
            if let error = error {
                print("Encountered Erorr: \(error)")
            } else if let result = result, result.isCancelled {
                print("Cancelled")
            } else {
                print("Logged In")
                let userId = Profile.current?.userID
                let email = Profile.current?.email ?? ""
                let name = "\(Profile.current?.firstName ?? "") \(Profile.current?.lastName ?? "")"
                let data = AuthResult(idToken: userId, providerID: nil, rawNonce: nil, accessToken: nil, name: name, email: email, phone: nil)
                self.vm.completeSignIn(with: data)
            }
        }
    }
    
    func logout() {
        print("LOGUT...")
    }
    
}
