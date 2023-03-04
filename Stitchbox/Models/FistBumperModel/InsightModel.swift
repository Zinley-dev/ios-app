//
//  InsightModel.swift
//  Stitchbox
//
//  Created by Nghiem Minh Hoang on 04/03/2023.
//


import ObjectMapper

class InsightModel: Mappable {

  private(set) var total3Day: Int = 0
  private(set) var totalDay: Int = 0
  private(set) var totalWeek: Int = 0
  private(set) var avg: Int = 0
  private(set) var percentDay: String = ""
  private(set) var percent3Day: String = ""
  private(set) var percentWeek: String = ""
  private(set) var percentAvg: String = ""
    
  required init?(map: Map) {
    
  }
  
  func mapping(map: ObjectMapper.Map) {
    total3Day <- map["3day.total"]
    totalDay <- map ["day.total"]
    totalWeek <- map ["week.total"]
    avg <- map["avg.total"]
    percentDay <- map["day.percent"]
    percent3Day <- map ["3day.percent"]
    percentWeek <- map ["week.percent"]
    percentAvg <- map["avg.percent"]
  }
  
  
}
