//
//  AppleSignInService.swift
//  Stitchbox
//
//  Created by Hisoft Hoangnm on 12/12/2022.
//

import Foundation

class AppleSignInService: NSObject {
    private var vm: StartViewModel

    public init(vm: StartViewModel) {
        self.vm = vm
    }
}

extension AppleSignInService: LoginCoordinatorProtocol {
    func triggerSignIn() {
        print("Apple LOGIN...")
    }
        
    func logout() {
        print("LOGUT...")
    }
    
}
