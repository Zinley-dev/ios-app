//
//  UploadContentManager.swift
//  Stitchbox
//
//  Created by Khoi Nguyen on 6/5/23.
//

import Foundation
import PixelSDK
import ObjectMapper

class UploadContentManager {
    
    static let shared = UploadContentManager()
    private init() {}
    
    
    func uploadImageToDB(image: UIImage, hashtagList: [String], selectedDescTxtView: String, isAllowComment: Bool, mediaType: String, mode: Int, origin_width: CGFloat, origin_height: CGFloat, length: Double = 0, isAllowStitch: Bool, stitchId: String) {
        
        APIManager.shared.uploadImage(image: image) { [unowned self] result in
    
            switch result {
            case .success(let apiResponse):
                
                guard apiResponse.body?["message"] as? String == "avatar uploaded successfully",
                      let url = apiResponse.body?["url"] as? String  else {
                        return
                }
                
                self.writeContentImageToDB(imageUrl: url, hashtagList: hashtagList, selectedDescTxtView: selectedDescTxtView, isAllowComment: isAllowComment, mediaType: mediaType, mode: mode, origin_width: origin_width, origin_height: origin_height, length: length, isAllowStitch: isAllowStitch, stitchId: stitchId)


            case .failure(let error):
                print(error)
            }
            
            
        }
        
        
    }
    
    
    
    func uploadVideoToDB(url: URL, hashtagList: [String], selectedDescTxtView: String, isAllowComment: Bool, mediaType: String, mode: Int, origin_width: CGFloat, origin_height: CGFloat, length: Double, isAllowStitch: Bool, stitchId: String) {
    
        let data = try! Data(contentsOf: url)
        
        APIManager.shared.uploadVideo(video: data) { [unowned self] result in
          
            switch result {
            case .success(let apiResponse):
            
                
                guard apiResponse.body?["message"] as? String == "video uploaded successfully",
                    let data = apiResponse.body?["data"] as? [String: Any] else {
                        return
                }
                

                // Try to create a SendBirdRoom object from the data
                let videoInfo =  Mapper<VideoPostModel>().map(JSONObject: data)
                let downloadedUrl = videoInfo?.video_url ?? ""
               
                if downloadedUrl != "" {
                    self.writeContentVideoToDB(videoUrl: downloadedUrl, hashtagList: hashtagList, selectedDescTxtView: selectedDescTxtView, isAllowComment: isAllowComment, mediaType: mediaType, mode: mode, origin_width: origin_width, origin_height: origin_height, length: length, isAllowStitch: isAllowStitch, stitchId: stitchId)
                } else {
                    print("Couldn't get video url")
                }
                

            case .failure(let error):
                global_percentComplete = 0.00
                print(error)
            }
            
        } process: { percent in
            global_percentComplete = Double(percent)
            NotificationCenter.default.post(name: (NSNotification.Name(rawValue: "updateProgressBar")), object: nil)
            print("Uploading ... \(percent)%")
        }

    }
    
    
   private func writeContentImageToDB(imageUrl: String, hashtagList: [String], selectedDescTxtView: String, isAllowComment: Bool, mediaType: String, mode: Int, origin_width: CGFloat, origin_height: CGFloat, length: Double, isAllowStitch: Bool, stitchId: String) {
        
        guard let userDataSource = _AppCoreData.userDataSource.value, let userUID = userDataSource.userID, userUID != "" else {
            print("Can't get userDataSource")
            return
        }

        let loadUsername = userDataSource.userName
        
        var contentPost = [String: Any]()
        
        
        
        var update_hashtaglist = [String]()
        

        contentPost = ["content": selectedDescTxtView, "images": [imageUrl], "tags": [userUID], "hashtags": update_hashtaglist, "streamLink": global_fullLink]
        contentPost["setting"] = ["mode": mode as Any, "allowComment": isAllowComment, "isHashtaged": true, "isTitleGet": false, "languageCode": Locale.current.languageCode!, "mediaType": mediaType, "allowStitch": isAllowStitch]
        contentPost["metadata"] = ["width": origin_width, "height": origin_height, "length": length, "contentMode": 0]
       
       if stitchId != "" {
           contentPost["stitchId"] = stitchId
       }
        
        APIManager.shared.createPost(params: contentPost) { result in
          

            switch result {
            case .success(let apiResponse):
                
                print("Posted successfully \(apiResponse)")
                needReloadPost = true

            case .failure(let error):
                print(error)
            }
        }
        
       
    }
    
    
    
    private func writeContentVideoToDB(videoUrl: String, hashtagList: [String], selectedDescTxtView: String, isAllowComment: Bool, mediaType: String, mode: Int, origin_width: CGFloat, origin_height: CGFloat, length: Double, isAllowStitch: Bool, stitchId: String) {
 
        guard let userDataSource = _AppCoreData.userDataSource.value, let userUID = userDataSource.userID, userUID != "" else {
            print("Can't get userDataSource")
            return
        }
        
        
        let videoData =  ["rawUrl": videoUrl]
        
        var contentPost = [String: Any]()
        
        
        contentPost = ["content": selectedDescTxtView, "video": videoData, "tags": [userUID], "streamLink": global_fullLink, "hashtags": hashtagList]
        contentPost["setting"] = ["mode": mode as Any, "allowComment": isAllowComment, "isHashtaged": true, "isTitleGet": false, "languageCode": Locale.current.languageCode!, "mediaType": mediaType, "allowStitch": isAllowStitch]
        contentPost["metadata"] = ["width": origin_width, "height": origin_height, "length": length, "contentMode": 0]
        
        if stitchId != "" {
            contentPost["stitchId"] = stitchId
        }
        
        APIManager.shared.createPost(params: contentPost) {  result in
           
            switch result {
            case .success(let apiResponse):
                
                print("Posted successfully \(apiResponse)")
                needReloadPost = true

            case .failure(let error):
                print(error)
            }
        }

        
    }
    
}
