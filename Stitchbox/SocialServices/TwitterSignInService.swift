//
//  TwitterSignInService.swift
//  Stitchbox
//
//  Created by Hisoft Hoangnm on 12/12/2022.
//

import Foundation

class TwitterSignInService: NSObject {
    private var vm: StartViewModel

    public init(vm: StartViewModel) {
        self.vm = vm
    }
}

extension TwitterSignInService: LoginCoordinatorProtocol {
    func triggerSignIn() {
        print("Twitter LOGIN...")
    }
    
    func logout() {
        print("LOGUT...")
    }
    
}
