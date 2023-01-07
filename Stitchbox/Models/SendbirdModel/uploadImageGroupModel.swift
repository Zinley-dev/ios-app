//
//  uploadImageGroupModel.swift
//  Stitchbox
//
//  Created by Khoi Nguyen on 1/4/23.
//

import Foundation

struct uploadImageGroupModel : Codable {

    // MARK: - Properties
    var url: String
    
    init(JSONbody: [String?: Any]?) throws {
        
        print(JSONbody)
        
        if let data = JSONbody {
            
            self.url = data["url"] as? String ?? ""
            
        } else {
            
            self.url =  ""
           
        }

   
    }
        
}
