//
//  streamingDomainModel.swift
//  Dual
//
//  Created by Khoi Nguyen on 9/13/21.
//

import Foundation

class StreamingDomainModel {
    
    fileprivate var _status: Bool!
    fileprivate var _domain: [String]!
    fileprivate var _company: String!
    fileprivate var _url: String!
    
    
    var url: String! {
        get {
            if _url == nil {
                _url = ""
            }
            return _url
        }
        
    }
    
    var domain: [String]! {
        get {
            if _domain.isEmpty {
                return _domain
            }
            
            return _domain
        }
        
    }
    
    var company: String! {
        get {
            if _company == nil {
                _company = ""
            }
            return _company
        }
        
    }
    
    var status: Bool! {
        get {
            if _status == nil {
                _status = false
            }
            return _status
        }
        
    }


    
    init(postKey: String, streamingDomainModel : Dictionary<String, Any>) {
        
    
        if let domain = streamingDomainModel["domain"] as? [String] {
            self._domain = domain
        }
        
        if let company = streamingDomainModel["company"] as? String {
            self._company = company
            
        }
        
        
        if let status = streamingDomainModel["status"] as? Bool {
            self._status = status
            
        }
        
        if let url = streamingDomainModel["url"] as? String {
            self._url = url
            
        }
    
        
    }
    
    
    
    
    
}
