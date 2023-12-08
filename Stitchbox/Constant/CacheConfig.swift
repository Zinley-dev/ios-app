//
//  CacheConfig.swift
//  Stitchbox
//
//  Created by Khoi Nguyen on 12/17/22.
//

import Cache

final class CacheManager {

    private var dataStorage: Storage<Data>?
    private var imageStorage: Storage<UIImage>?
    static let shared = CacheManager()

    private let defaultExpiry: Expiry = .date(Date().addingTimeInterval(1800))
    
    private init() {
        do {
            let disksConfig = DiskConfig(name: "Mix")
            let memoryConfig = MemoryConfig()

            dataStorage = try Storage(
                diskConfig: disksConfig,
                memoryConfig: memoryConfig,
                transformer: TransformerFactory.forData()
            )

            if let dataStorage = dataStorage {
                imageStorage = dataStorage.transformImage()
            }

        } catch {
            //print("Failed to create storage: \(error)")
        }
    }

    func storeData(forKey key: String, data: Data) {
        
        dataStorage?.async.setObject(data, forKey: key, expiry: defaultExpiry, completion: { result in
            switch result {
            case .value:
                //print("Data cached successfully.")
                return
            case .error(let error):
                //print("Failed to cache data: \(error)")
                return
            }
        })
    }

    func fetchData(forKey key: String, completion: @escaping (Data?) -> Void) {
        dataStorage?.async.object(forKey: key, completion: { [weak self] result in
            switch result {
            case .value(let data):
                completion(data)
            case .error:
                completion(nil)
            }
        })
    }

    func storeImage(forKey key: String, image: UIImage) {
        imageStorage?.async.setObject(image, forKey: key, expiry: defaultExpiry, completion: { result in
            switch result {
            case .value:
                //print("Image cached successfully.")
                return
            case .error(let error):
                //print("Failed to cache image: \(error)")
                return
            }
        })
    }

    func fetchImage(forKey key: String, completion: @escaping (UIImage?) -> Void) {
        imageStorage?.async.object(forKey: key, completion: { result in
            switch result {
            case .value(let image):
                completion(image)
            case .error:
                completion(nil)
            }
        })
    }
    
    func hasImage(forKey key: String, completion: @escaping (Bool) -> Void) {
        imageStorage?.async.object(forKey: key, completion: { result in
            switch result {
            case .value:
                completion(true)
            case .error:
                completion(false)
            }
        })
    }
    
    func asyncRemoveExpiredObjects() {
        dataStorage?.async.removeExpiredObjects() { result in
            switch result {
            case .value:
                //print("Expired data removal completes")
                return
            case .error(let error):
                //print("Data: \(error)")
                return
            }
        }

        imageStorage?.async.removeExpiredObjects() { result in
            switch result {
            case .value:
                //print("Expired image removal completes")
                return
            case .error(let error):
                //print("Image: \(error)")
                return
            }
        }
    }
    
    func clearAllCache() {
        // Clearing data cache
        dataStorage?.async.removeAll { result in
            switch result {
            case .value:
                //print("All data cache cleared.")
                return
            case .error(let error):
                //print("Failed to clear data cache: \(error)")
                return
                
            }
            
        }
        
        imageStorage?.async.removeAll { [weak self] result in
            switch result {
            case .value:
                //print("All image cache cleared.")
                return
            case .error(let error):
                //print("Failed to clear image cache: \(error)")
                return
            }
            
        }

    }


}

