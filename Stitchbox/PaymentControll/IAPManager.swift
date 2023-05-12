//
//  IAPManager.swift
//  Stitchbox
//
//  Created by Khoi Nguyen on 5/11/23.
//

import Foundation
import Qonversion

class IAPManager {
    
    var offerings: Qonversion.Offerings!
    static let shared = IAPManager()
    private init() {}
    
    func configure() {
        
        guard let userDataSource = _AppCoreData.userDataSource.value, let userUID = userDataSource.userID, userUID != "" else {
            print("Sendbird: Can't get userUID")
            return
        }
        
        let config = Qonversion.Configuration(projectKey: "NTQCaNySQ0GHbt6xsWrQPM0VlohWmjCO", launchMode: .subscriptionManagement)
        Qonversion.initWithConfig(config)
        Qonversion.shared().setProperty(.userID, value: userUID)
    }
    
    func checkPermissions() {
        Qonversion.shared().checkEntitlements { (entitlements, error) in
          if let error = error {
            // handle error
              print(error.localizedDescription)
            return
          }
          
          if let premium: Qonversion.Entitlement = entitlements["Stitchbox_Pro"], premium.isActive {
            switch premium.renewState {
              case .willRenew, .nonRenewable:
                print("willRenew")
                // .willRenew is the state of an auto-renewable subscription
                // .nonRenewable is the state of consumable/non-consumable IAPs that could unlock lifetime access
                break
              case .billingIssue:
                print("billingIssue")
                // Grace period: entitlement is active, but there was some billing issue.
                // Prompt the user to update the payment method.
                break
              case .cancelled:
                print("cancelled")
                // The user has turned off auto-renewal for the subscription, but the subscription has not expired yet.
                // Prompt the user to resubscribe with a special offer.
                break
              default: break
            }
          }
        }
    }
    
    func purchase(product: Qonversion.Product) {
        
        Qonversion.shared().purchaseProduct(product) { (entitlements, error, isCancelled) in
        
            if error != nil {
                print(error?.localizedDescription)
            } else {
                print(entitlements)
            }
            
          
        }
    
    }
    
    func restorePurchase() {
        
    }
    
    func displayProduct() {
        Qonversion.shared().offerings { (offerings, error) in
          if let products = offerings?.main?.products {
              
              for item in products {
                  print(item.storeID, item.duration, item.trialDuration)
              }
    
          }
        }
    }
    
    
    func checkTrialIntroEligibility() {
    
        Qonversion.shared().checkTrialIntroEligibility(["Silver"]) { (result, error) in
            if error != nil {
                print(error?.localizedDescription)
            }
            
            for each in result {
                print(each.key, each.value)
            }
            
        }
        
    }
    

}


