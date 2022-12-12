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
                    }
                }
    }
    
    func logout() {
        print("LOGUT...")
    }
    
}
