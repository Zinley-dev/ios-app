//
//  SendBirdRoomModel.swift
//  Stitchbox
//
//  Created by Khoi Nguyen on 12/19/22.
//

import Foundation

import Foundation
import RxSwift


struct SendBirdRoom : Codable {

    // MARK: - Properties
    var room_id: String
    var state: String
    
    init(JSONbody: [String?: Any]?) throws {
        
        
        if let data = JSONbody!["room"] as? [String: Any] {
            
            self.room_id = data["room_id"] as? String ?? ""
            self.state = data["state"] as? String ?? ""
            
        } else {
            
            self.room_id =  ""
            self.state =  ""
            
        }
       
   
    }
        
}
