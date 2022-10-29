//
//  APIResponse.swift
//  Stitchbox
//
//  Created by Nghiem Minh Hoang on 26/10/2022.
//

import Foundation

struct APIResponse {
    var body: [String: Any]?
    var header: [String: Any]?
    var statusCode: Int?
    var errorMessage: String?
}
