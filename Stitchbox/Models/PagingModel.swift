//
//  PagingModel.swift
//  
//
//  Created by Khanh Duy Nguyen on 1/28/23.
//

import ObjectMapper

class PagingModel: Mappable {
    
    private(set) var limit: Int = 0
    private(set) var page: Int = 0
    private(set) var total: Int = 0
    
    required init?(map: Map) {
        //
    }
    
    func mapping(map: Map) {
        limit   <- map["limit"]
        page    <- map["page"]
        total   <- map["total"]
    }
    func isEndOfPage() -> Bool {
        return page + limit >= total 
    }
}
