//
//  InsightModel.swift
//  Stitchbox
//
//  Created by Nghiem Minh Hoang on 04/03/2023.
//


import ObjectMapper

class InnerDataModel: Mappable {
    private(set) var percent: String = ""
    private(set) var total: Int = 0
    
    required init?(map: Map) { }
    
    func mapping(map: Map) {
        percent <- map["percent"]
        total <- map["total"]
    }
}

class InsightModel: Mappable {
    private(set) var threeDay: InnerDataModel?
    private(set) var avg: InnerDataModel?
    private(set) var day: InnerDataModel?
    private(set) var week: InnerDataModel?
    
    required init?(map: Map) { }
    
    func mapping(map: Map) {
        threeDay <- map["data.3day"]
        avg <- map["data.avg"]
        day <- map["data.day"]
        week <- map["data.week"]
    }
}

