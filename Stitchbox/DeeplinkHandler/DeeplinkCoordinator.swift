//
//  DeeplinkCoordinator.swift
//  Stitchbox
//
//  Created by Nghiem Minh Hoang on 03/04/2023.
//

import Foundation

protocol DeeplinkCoordinatorProtocol {
  @discardableResult
  func handleURL(_ url: URL) -> Bool
}

final class DeeplinkCoordinator {
  
  let handlers: [DeeplinkHandlerProtocol]
  
  init(handlers: [DeeplinkHandlerProtocol]) {
    self.handlers = handlers
  }
}

extension DeeplinkCoordinator: DeeplinkCoordinatorProtocol {
  
  @discardableResult
  func handleURL(_ url: URL) -> Bool{
    guard let handler = handlers.first(where: { $0.canOpenURL(url) }) else {
      return false
    }
    
    handler.openURL(url)
    return true
  }
}
