//
//  Contants.swift
//  Stitchbox
//
//  Created by Nghiem Minh Hoang on 26/10/2022.
//

import Foundation

enum SocialLoginType: Int {
    case google = 1
    case facebook
    case twitter
    case apple
    case tiktok
}

struct Constants {
    struct Segue {
        static let verifyOTP = "segueToVerifyOtp"
        static let resetPassword = "segueToResetPassword"
    }

    struct URLs {
        static let baseUrl = "http://localhost:8080/systango-boilerplate-swift-mvvm.com/"
        static let loginEndPoint = "login"
        static let production = "This is the Production base url"
        static let testing = "This is the Testing base url"
        static let development = "This is the Development base url"
    }

    struct Message {
        static let invalidUrl = "Invalid Url"
        static let logoutWarning = "Are you sure you want to logout?"
    }

    struct GoogleSignIn {
        static let clientId = "56078114675-c5lhtgsgsp4bod4amsc9rlfv8b4s64j8.apps.googleusercontent.com"
    }
    struct Twitter {
      static let CONSUMER_KEY = "V6VVpnYFFfbXKjarIsulSE13I"
      static let CONSUMER_SECRET_KEY = "5s5OmzJZSR83hsnTPSqj8l0fSb84bGema8SK5uE35T5A9CkuZp"
      static let CALLBACK_URL = "twitterkit-4ob6dNOQJPIjz9DQtCiLcD8VY://"
    }
}
