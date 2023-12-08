//
//  UploadContentManager.swift
//  Stitchbox
//
//  Created by Khoi Nguyen on 6/5/23.
//

import Foundation
import PixelSDK
import ObjectMapper

// MARK: - Upload Content Manager

/// Manages the uploading of content (videos) to the database
class UploadContentManager {
    
    // Singleton instance
    static let shared = UploadContentManager()
    
    // Private initializer to enforce singleton usage
    private init() {}
    
    /// Uploads video to the database
    /// - Parameters:
    ///   - url: URL of the video to be uploaded
    ///   - hashtagList: List of hashtags associated with the video
    ///   - selectedDescTxtView: Description text for the video
    ///   - isAllowComment: Flag to allow comments on the video
    ///   - mediaType: Type of the media (e.g., video)
    ///   - mode: Upload mode (e.g., private/public)
    ///   - origin_width: Original width of the video
    ///   - origin_height: Original height of the video
    ///   - length: Length of the video in seconds
    ///   - isAllowStitch: Flag to allow stitching of the video
    ///   - stitchId: ID for stitch reference
    func uploadVideoToDB(url: URL, hashtagList: [String], selectedDescTxtView: String, isAllowComment: Bool, mediaType: String, mode: Int, origin_width: CGFloat, origin_height: CGFloat, length: Double, isAllowStitch: Bool, stitchId: String) {
    
        // Loading video data from URL
        let data = try! Data(contentsOf: url) // Caution: force-try might lead to runtime crash
        
        // Upload the video data
        APIManager.shared.uploadVideo(video: data) { [unowned self] result in
            switch result {
            case .success(let apiResponse):
                // Verify successful upload and retrieve video info
                guard let message = apiResponse.body?["message"] as? String, message == "video uploaded successfully",
                      let data = apiResponse.body?["data"] as? [String: Any] else {
                    return
                }

                // Map the response data to VideoPostModel
                let videoInfo = Mapper<VideoPostModel>().map(JSONObject: data)
                let downloadedUrl = videoInfo?.video_url ?? ""
               
                // Write content to DB if URL is valid
                if !downloadedUrl.isEmpty {
                    self.writeContentVideoToDB(videoUrl: downloadedUrl, hashtagList: hashtagList, selectedDescTxtView: selectedDescTxtView, isAllowComment: isAllowComment, mediaType: mediaType, mode: mode, origin_width: origin_width, origin_height: origin_height, length: length, isAllowStitch: isAllowStitch, stitchId: stitchId)
                } else {
                    //print("Couldn't get video url")
                }

            case .failure(let error):
                // Handle upload failure
                global_percentComplete = 0.00
                DispatchQueue.main.async {
                    showNote(text: "Couldn't upload this video, please try again! \(error.localizedDescription)")
                }
                //print(error)
            }
        } process: { percent in
            // Update upload progress
            global_percentComplete = Double(percent)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updateProgressBar"), object: nil)
            //print("Uploading ... \(percent)%")
        }
    }
    
    /// Writes video content information to the database
    /// - Parameters: Similar to uploadVideoToDB
    private func writeContentVideoToDB(videoUrl: String, hashtagList: [String], selectedDescTxtView: String, isAllowComment: Bool, mediaType: String, mode: Int, origin_width: CGFloat, origin_height: CGFloat, length: Double, isAllowStitch: Bool, stitchId: String) {
        // Verify user data availability
        guard let userDataSource = _AppCoreData.userDataSource.value, let userUID = userDataSource.userID, !userUID.isEmpty else {
            //print("Can't get userDataSource")
            return
        }

        // Prepare video data and content post dictionary
        let videoData = ["rawUrl": videoUrl]
        var contentPost = ["content": selectedDescTxtView, "video": videoData, "tags": [userUID], "streamLink": global_fullLink, "hashtags": hashtagList] as [String : Any]
        contentPost["setting"] = ["mode": mode, "allowComment": isAllowComment, "isHashtaged": true, "isTitleGet": false, "languageCode": Locale.current.languageCode!, "mediaType": mediaType, "allowStitch": isAllowStitch]
        contentPost["metadata"] = ["width": origin_width, "height": origin_height, "length": length, "contentMode": 0]

        // Add stitch ID if available
        if !stitchId.isEmpty {
            contentPost["stitchPostId"] = stitchId
        }
        
        // Perform the creation of the post
        APIManager.shared.createPost(params: contentPost) { result in
            switch result {
            case .success(_):
                // Handle successful post creation
                //print("Posted successfully \(apiResponse)")
                needReloadPost = true // Flag to indicate the need for reloading posts

            case .failure(let error):
                // Handle failure in post creation
                //print(error)
                return
            }
        }
    }
}
