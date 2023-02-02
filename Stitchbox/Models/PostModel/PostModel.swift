//
//  PostModel.swift
//  Stitchbox
//
//  Created by Khoi Nguyen on 1/27/23.
//

import Foundation
import AlamofireImage
import Alamofire

// user, post, content. search

class PostModel {
    fileprivate var _origin_height: CGFloat!
    fileprivate var _origin_width: CGFloat!
    fileprivate var _reporting_nickname: String!
    fileprivate var _category: String!
    fileprivate var _url: String!
    fileprivate var _status: String!
    fileprivate var _mode: String!
    fileprivate var _music: String!
    fileprivate var _Mux_processed: Bool!
    fileprivate var _isReportingPlayer: Bool!
    fileprivate var _Mux_playbackID: String!
    fileprivate var _Mux_assetID: String!
    fileprivate var _Allow_comment: Bool!
    fileprivate var _userUID: String!
    fileprivate var _post_title: String!
    fileprivate var _post_id: String!
    //fileprivate var _post_time: Timestamp!
    fileprivate var _ratio: CGFloat!
    fileprivate var _hashtag_list: [String]!
    fileprivate var _backgroundBlurrImage: UIImage!
    
    var _stream_link: String!
    
    var backgroundBlurrImage: UIImage! {
        get {
            if _backgroundBlurrImage == nil {
                _backgroundBlurrImage = nil
            }
            return _backgroundBlurrImage
        }
        
    }
    
    var origin_height: CGFloat! {
        get {
            if _origin_height == nil {
                _origin_height = 0
            }
            return _origin_height
        }
        
    }
    
    var origin_width: CGFloat! {
        get {
            if _origin_width == nil {
                _origin_width = 0
            }
            return _origin_width
        }
        
    }
    
    var reporting_nickname: String! {
        get {
            if _reporting_nickname == nil {
                _reporting_nickname = ""
            }
            return _reporting_nickname
        }
        
    }

    var hashtag_list: [String]! {
        get {
            
            if _hashtag_list == nil {
                return []
            }
 
            return _hashtag_list
        }
        
    }
    
    var ratio: CGFloat! {
        get {
            if _ratio == nil {
                _ratio = 0.0
            }
            return _ratio
        }
        
    }
    
    
    var Mux_assetID: String! {
        get {
            if _Mux_assetID == nil {
                _Mux_assetID = ""
            }
            return _Mux_assetID
        }
        
    }
    
    
    var post_id: String! {
        get {
            if _post_id == nil {
                _post_id = ""
            }
            return _post_id
        }
        
    }

    var category: String! {
        get {
            if _category == nil {
                _category = ""
            }
            return _category
        }
        
    }
    
    var url: String! {
        get {
            if _url == nil {
                _url = ""
            }
            return _url
        }
        
    }
    var status: String! {
        get {
            if _status == nil {
                _status = ""
            }
            return _status
        }
        
    }
    
    var mode: String! {
        get {
            if _mode == nil {
                _mode = ""
            }
            return _mode
        }
        
    }
    
    var music: String! {
        get {
            if _music == nil {
                _music = ""
            }
            return _music
        }
        
    }
    
    var Mux_playbackID: String! {
        get {
            if _Mux_playbackID == nil {
                _Mux_playbackID = ""
            }
            return _Mux_playbackID
        }
        
    }
    
    var userUID: String! {
        get {
            if _userUID == nil {
                _userUID = ""
            }
            return _userUID
        }
        
    }
    
    var post_title: String! {
        get {
            if _post_title == nil {
                _post_title = ""
            }
            return _post_title
        }
        
    }
    
    var stream_link: String! {
        get {
            if _stream_link == nil {
                _stream_link = ""
            }
            return _stream_link
        }
        
    }
    
    var Mux_processed: Bool! {
        get {
            if _Mux_processed == nil {
                _Mux_processed = false
            }
            return _Mux_processed
        }
        
    }
    
    var Allow_comment: Bool! {
        get {
            if _Allow_comment == nil {
                _Allow_comment = false
            }
            return _Allow_comment
        }
        
    }
    
    var isReportingPlayer: Bool! {
        get {
            if _isReportingPlayer == nil {
                _isReportingPlayer = false
            }
            return _isReportingPlayer
        }
        
    }
    
    /*
    var post_time: Timestamp! {
        get {
            if _post_time == nil {
                _post_time = Timestamp.init(date: NSDate() as Date)
            }
            return _post_time
        }
    }*/

    
    init(postKey: String, Post_Model: Dictionary<String, Any>) {
        
        self._post_id = postKey
        
        if let ratio = Post_Model["ratio"] as? CGFloat {
            self._ratio = ratio
        }
        
        if let Mux_assetID = Post_Model["Mux_assetID"] as? String {
            self._Mux_assetID = Mux_assetID
        }
        
        if let url = Post_Model["url"] as? String {
            self._url = url
        }
        
        if let category = Post_Model["category"] as? String {
            self._category = category
        }
        
        if let status = Post_Model["h_status"] as? String {
            self._status = status
        }
        
        if let mode = Post_Model["mode"] as? String {
            self._mode = mode
        }
        
        if let music = Post_Model["music"] as? String {
            self._music = music
        }
        
        if let reporting_nickname = Post_Model["reporting_nickname"] as? String {
            self._reporting_nickname = reporting_nickname
        }
        
        if let Mux_playbackID = Post_Model["Mux_playbackID"] as? String {
            self._Mux_playbackID = Mux_playbackID
        }
        
        if let userUID = Post_Model["userUID"] as? String {
            self._userUID = userUID
        }
        
        if let post_title = Post_Model["highlight_title"] as? String {
            self._post_title = post_title
        }
        
        if let stream_link = Post_Model["stream_link"] as? String {
            self._stream_link = stream_link
        }
        
        if let Mux_processed = Post_Model["Mux_processed"] as? Bool {
            self._Mux_processed = Mux_processed
        }
        
        if let Allow_comment = Post_Model["Allow_comment"] as? Bool {
            self._Allow_comment = Allow_comment
        }
        
        if let isReportingPlayer = Post_Model["isReportingPlayer"] as? Bool {
            self._isReportingPlayer = isReportingPlayer
        }
        
         
        if let hashtag_list = Post_Model["hashtag_list"] as? [String] {
            self._hashtag_list = hashtag_list
        }
        
        
        if let origin_height = Post_Model["origin_height"] as? CGFloat {
            self._origin_height = origin_height
        }
        
        if let origin_width = Post_Model["origin_width"] as? CGFloat {
            self._origin_width = origin_width
        }
    
        
    }
    

    
}
