//
//  CacheConfig.swift
//  Stitchbox
//
//  Created by Khoi Nguyen on 12/17/22.
//


import Alamofire
import Foundation
import Cache
import UIKit


let disksConfig = DiskConfig(name: "Mix")

let dataStorage = try! Storage(
  diskConfig: disksConfig,
  memoryConfig: MemoryConfig(),
  transformer: TransformerFactory.forData()
)
let imageStorage = dataStorage.transformImage()
