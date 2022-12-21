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
    
    init(JSONbody: [String?: Any]?) throws {
        
        if let data = JSONbody {
            
            self.room_id = data["room"] as? String ?? ""
            
        } else {
            
            self.room_id =  ""
           
        }

   
    }
        
}
