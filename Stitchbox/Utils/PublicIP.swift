//
//  PublicIP.swift
//  Stitchbox
//
//  Created by Hisoft Hoangnm on 31/03/2023.
//

import Foundation

typealias CompletionHandler = (String?, Error?) -> Void

func getPublicIPAddress(requestURL: String = "https://icanhazip.com/", completion: @escaping CompletionHandler) {
    
    guard let url: URL = URL(string: requestURL) else {
        fatalError("URL is not validate")
    }
    
    URLSession.shared.dataTask(with: url) { (data, _, error) in
        if let error = error {
            completion(nil, CustomError.error(error))
            return
        }
        guard let data = data else {
            completion(nil, CustomError.noData)
            return
        }
        guard let result = String(data: data, encoding: .utf8) else {
            completion(nil, CustomError.undecodeable)
            return
        }
        let ipAddress = String(result.filter { !" \n\t\r".contains($0) })
        completion(ipAddress, nil)
    }.resume()
}

enum CustomError: LocalizedError {
    case noData
    case error(Error)
    case undecodeable
    
    public var errorDescription: String? {
        switch self {
            case .noData:
                return "No data response."
            case .error(let err):
                return err.localizedDescription
            case .undecodeable:
                return "Data undecodeable."
        }
    }
}
