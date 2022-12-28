//
//  SendBirdUserModel.swift
//  Stitchbox
//
//  Created by Khoi Nguyen on 12/24/22.
//

import Foundation


struct SendBirdUser : Codable {

    // MARK: - Properties
    var userID: String
    var avatar: String
    var username: String
    
    init(JSONbody: [String?: Any]?) throws {
        
        if let data = JSONbody {
            

            self.userID = data["ID"] as? String ?? ""
            self.avatar = data["avatar"] as? String ?? ""
            self.username = data["username"] as? String ?? ""
            
        } else {
            
            self.userID =  ""
            self.avatar =  ""
            self.username =  ""
           
        }

   
    }
        
}
