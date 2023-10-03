//
//  ReachabilityManager.swift
//  Stitchbox
//
//  Created by Khoi Nguyen on 8/31/23.
//

import Reachability

class ReachabilityManager: NSObject {
    
    static let shared = ReachabilityManager()
    
    var reachability: Reachability!
    
    // Using a closure to notify changes
    var reachabilityStatusChanged: ((Reachability.Connection) -> Void)?
    
    override init() {
        super.init()
        
        do {
            reachability = try Reachability()
        } catch {
            print("Unable to initialize Reachability")
            return
        }
        
        reachability.whenReachable = { [weak self] reachability in
            self?.reachabilityStatusChanged?(reachability.connection)
        }
        
        reachability.whenUnreachable = { [weak self] _ in
            self?.reachabilityStatusChanged?(.unavailable)
        }
        
        do {
            try reachability.startNotifier()
        } catch {
            print("Unable to start Reachability notifier")
        }
    }
    
    deinit {
        reachability.stopNotifier()
    }
}

