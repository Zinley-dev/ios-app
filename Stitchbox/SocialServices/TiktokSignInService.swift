//
//  TiktokSignInService.swift
//  Stitchbox
//
//  Created by Hisoft Hoangnm on 12/12/2022.
//

import Foundation


class TiktokSignInService: NSObject {
    private var vm: StartViewModel

    public init(vm: StartViewModel) {
        self.vm = vm
    }
}

extension TiktokSignInService: LoginCoordinatorProtocol {
    func triggerSignIn() {
      
    }
        
    func logout() {
        print("LOGUT...")
    }
    
}
