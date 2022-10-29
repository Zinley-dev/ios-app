//
//  EndPointType.swift
//  Stitchbox
//
//  Created by Nghiem Minh Hoang on 26/10/2022.
//

import Foundation

protocol EndPointType {
    var path: String { get }
    var module: String { get }
    var httpMethod: HTTPMethod { get }
    var task: HTTPTask { get }
    var headers: [String: String]? { get }
}
