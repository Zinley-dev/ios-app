//
//  FacebookSignInService.swift
//  Stitchbox
//
//  Created by Hisoft Hoangnm on 12/12/2022.
//

import Foundation

class FacebookSignInService: NSObject {
    private var vm: StartViewModel

    public init(vm: StartViewModel) {
        self.vm = vm
    }
}

extension FacebookSignInService: LoginCoordinatorProtocol {
    func triggerSignIn() {
        print("FACEBOOK LOGIN...")
        
    }
    
    func logout() {
        print("LOGUT...")
    }
    
}
