//
//  DeeplinkHandlerProtocol.swift
//  Stitchbox
//
//  Created by Nghiem Minh Hoang on 03/04/2023.
//

import Foundation

// MARK: - DeeplinkHandlerProtocol
// Protocol defining the requirements for handling deep links in an application.

protocol DeeplinkHandlerProtocol {
  // Determines whether the implementing handler can open the given URL.
  // - Parameter url: The URL to be evaluated.
  // - Returns: A Boolean value indicating whether the URL can be handled.
  func canOpenURL(_ url: URL) -> Bool

  // Handles the opening of the URL if it is determined to be applicable.
  // - Parameter url: The URL to be opened.
  func openURL(_ url: URL)
}
