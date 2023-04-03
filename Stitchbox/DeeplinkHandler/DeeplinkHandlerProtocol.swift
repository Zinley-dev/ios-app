//
//  DeeplinkHandlerProtocol.swift
//  Stitchbox
//
//  Created by Nghiem Minh Hoang on 03/04/2023.
//

import Foundation

protocol DeeplinkHandlerProtocol {
  func canOpenURL(_ url: URL) -> Bool
  func openURL(_ url: URL)
}
