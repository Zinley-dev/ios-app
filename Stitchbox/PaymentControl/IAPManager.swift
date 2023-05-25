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
    
    func checkPermissions(completion: @escaping (Bool) -> Void) {
    
        Qonversion.shared().checkEntitlements { (entitlements, error) in
          if let error = error {
            // handle error
            print(error.localizedDescription)
            completion(false)
            return
          }
            
            if entitlements.isEmpty {
                completion(false)
            } else {
                
                if let premium: Qonversion.Entitlement = entitlements["Stitchbox_Pro"], premium.isActive {
                    completion(true)
                 
                } else {
                    completion(false)
                }
                
            }
            
        }
        
    }
    
    func purchase(product: Qonversion.Product, completion: @escaping (Bool) -> Void) {
        
        Qonversion.shared().purchaseProduct(product) { (entitlements, error, isCancelled) in
          if let premium: Qonversion.Entitlement = entitlements["Stitchbox_Pro"], premium.isActive {
            // Flow for success state
              completion(true)
          } else {
              completion(false)
          }
        }
    
    }
    
    func restorePurchase() {
        
    }
    
    func displayProduct(completion: @escaping ([Qonversion.Product]) -> Void) {
        Qonversion.shared().offerings { (offerings, error) in
          if let products = offerings?.main?.products {
              
              completion(products)
            
          }
        }
    }
    
    
    func checkTrialIntroEligibility() {
    
        Qonversion.shared().checkTrialIntroEligibility(["anually", "pro_6months", "pro_monthly"]) { (result, error) in
            if error != nil {
                print(error?.localizedDescription)
            }
            
            for each in result {
                print(each.key, each.value)
            }
            
        }
        
    }
    

}


