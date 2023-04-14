//
//  RiotAccountModel.swift
//  Stitchbox
//
//  Created by Khoi Nguyen on 4/13/23.
//

import Foundation


class RiotAccountModel {
  
    fileprivate var _acct_id: String!
    fileprivate var _id: String!
    fileprivate var _internal_name: String!
    fileprivate var _summoner_id: String!
    fileprivate var _solo_tier_info: String!
    fileprivate var _level: Int!
    fileprivate var _name: String!
    fileprivate var _profile_image_url: String!
    fileprivate var _puuid: String!
    fileprivate var _border_image_url: String!
    fileprivate var _division: Int!
    fileprivate var _lp: Int!
    fileprivate var _tier: String!
    fileprivate var _tier_image_url: String!
    
    var tier: String! {
        get {
            if _tier == nil {
                _tier = ""
            }
            
            return _tier
        }
    }
    
    
    var tier_image_url: String! {
        get {
            if _tier_image_url == nil {
                _tier_image_url = ""
            }
            
            return _tier_image_url
        }
    }
    
    
    var lp: Int! {
        get {
            if _lp == nil {
                _lp = 0
            }
            
            return _lp
        }
    }
    

    var division: Int! {
        get {
            if _division == nil {
                _division = 0
            }
            
            return _division
        }
    }
    
    var border_image_url: String! {
        get {
            if _border_image_url == nil {
                _border_image_url = ""
            }
            
            return _border_image_url
        }
    }
    
    var puuid: String! {
        get {
            if _puuid == nil {
                _puuid = ""
            }
            
            return _puuid
        }
    }
    
    var profile_image_url: String! {
        get {
            if _profile_image_url == nil {
                _profile_image_url = ""
            }
            
            return _profile_image_url
        }
    }
  
    var name: String! {
        get {
            if _name == nil {
                _name = ""
            }
            
            return _name
        }
    }
  
    var acct_id: String! {
        get {
            if _acct_id == nil {
                _acct_id = ""
            }
            
            return _acct_id
        }
    }
    
    var id: String! {
        get {
            if _id == nil {
                _id = ""
            }
            
            return _id
        }
    }
    
    var internal_name: String! {
        get {
            if _internal_name == nil {
                _internal_name = ""
            }
            
            return _internal_name
        }
    }
    
    var summoner_id: String! {
        get {
            if _summoner_id == nil {
                _summoner_id = ""
            }
            
            return _summoner_id
        }
    }
    
    var solo_tier_info: String! {
        get {
            if _solo_tier_info == nil {
                _solo_tier_info = ""
            }
            
            return _solo_tier_info
        }
    }
    
    
    var level: Int! {
        get {
            if _level == nil {
                _level = 0
            }
            
            return _level
        }
    }
    
 
    init(riotAccountModel: Dictionary<String, Any>) {

        if let id = riotAccountModel["id"] as? String {
            self._id = id
        }
        
        if let acct_id = riotAccountModel["acct_id"] as? String {
            self._acct_id = acct_id
        }
        
        if let internal_name = riotAccountModel["internal_name"] as? String {
            self._internal_name = internal_name
        }
        
        if let level = riotAccountModel["level"] as? Int {
            self._level = level
        }
        
        if let name = riotAccountModel["name"] as? String {
            self._name = name
        }
        
        if let profile_image_url = riotAccountModel["profile_image_url"] as? String {
            self._profile_image_url = profile_image_url
        }
        
        if let puuid = riotAccountModel["puuid"] as? String {
            self._puuid = puuid
        }
        
        if let summoner_id = riotAccountModel["summoner_id"] as? String {
            self._summoner_id = summoner_id
        }
       
        
        if let solo_tier_info = riotAccountModel["solo_tier_info"] as? [String:Any] {
            
            if let border_image_url = solo_tier_info["border_image_url"] as? String {
                self._border_image_url = border_image_url
            }
            
            if let tier_image_url = solo_tier_info["tier_image_url"] as? String {
                self._tier_image_url = tier_image_url
            }
            
            if let division = solo_tier_info["division"] as? Int {
                self._division = division
            }
            
            if let tier = solo_tier_info["tier"] as? String {
                self._tier = tier
            }
            
            if let border_image_url = solo_tier_info["border_image_url"] as? String {
                self._border_image_url = border_image_url
            }
            
            if let lp = solo_tier_info["lp"] as? Int {
                self._lp = lp
            }
          
        }
    
    }

}


extension RiotAccountModel: Equatable {
    
    static func == (lhs: RiotAccountModel, rhs: RiotAccountModel) -> Bool {
        return lhs.id == rhs.id
    }
    
}
