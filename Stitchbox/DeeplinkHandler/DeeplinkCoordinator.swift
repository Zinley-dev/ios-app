//
//  DeeplinkCoordinator.swift
//  Stitchbox
//
//  Created by Nghiem Minh Hoang on 03/04/2023.
//

import Foundation

// MARK: - DeeplinkCoordinatorProtocol
// Defines a protocol for coordinating deep link handling.
protocol DeeplinkCoordinatorProtocol {
  // Processes a given URL and returns a Boolean indicating whether the URL was handled.
  @discardableResult
  func handleURL(_ url: URL) -> Bool
}

// MARK: - DeeplinkCoordinator Class
// Manages a collection of deep link handlers and delegates URL handling to them.
final class DeeplinkCoordinator {
  
  // Array of handlers that conform to DeeplinkHandlerProtocol.
  let handlers: [DeeplinkHandlerProtocol]
  
  // Initializes with a given array of deep link handlers.
  init(handlers: [DeeplinkHandlerProtocol]) {
    self.handlers = handlers
  }
}

// MARK: - DeeplinkCoordinatorProtocol Extension
// Extends DeeplinkCoordinator to conform to DeeplinkCoordinatorProtocol.
extension DeeplinkCoordinator: DeeplinkCoordinatorProtocol {
  
  // Processes the given URL by delegating to the appropriate handler.
  @discardableResult
  func handleURL(_ url: URL) -> Bool {
    // Find the first handler capable of opening the URL.
    guard let handler = handlers.first(where: { $0.canOpenURL(url) }) else {
      return false
    }
    
    // Ask the handler to open the URL.
    handler.openURL(url)
    return true
  }
}

