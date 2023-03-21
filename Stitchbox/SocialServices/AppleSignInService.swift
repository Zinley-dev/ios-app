//
//  AppleSignInService.swift
//  Stitchbox
//
//  Created by Hisoft Hoangnm on 12/12/2022.
//

import Foundation
import AuthenticationServices

class AppleSignInService: NSObject {
    private var vm: StartViewModel

    public init(vm: StartViewModel) {
        self.vm = vm
    }
}

extension AppleSignInService: ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            let userIdentifier = appleIDCredential.user
            let userFirstName = appleIDCredential.fullName?.givenName
            let userLastName = appleIDCredential.fullName?.familyName
            let userEmail = appleIDCredential.email
            
            
            let data = AuthResult(idToken: userIdentifier, providerID: nil, rawNonce: nil, accessToken: nil, name: "\(userFirstName ?? "") \(userLastName ?? "")", email: userEmail, phone: nil)
            self.vm.completeSignIn(with: data)

        }
    }
    
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        print(error.localizedDescription)
    }
    
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.vm.vc.view.window!
    }
}

extension AppleSignInService: LoginCoordinatorProtocol {
    func triggerSignIn() {
        print("Apple LOGIN...")
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
                        
        let authorizationController = ASAuthorizationController(authorizationRequests: [request, ASAuthorizationPasswordProvider().createRequest()])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
        
    func logout() {
        print("LOGUT...")
    }
    
}
