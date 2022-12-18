//
//  GroupChannelTableViewCell.swift
//  SendBird-iOS
//
//  Created by Jed Gyeong on 10/12/18.
//  Copyright © 2018 SendBird. All rights reserved.
//

import UIKit
import FLAnimatedImage
import Alamofire
import SendBirdSDK


class GroupChannelTableViewCell: UITableViewCell {
    
    @IBOutlet weak var channelNameLabel: UILabel!
    @IBOutlet weak var memberCountContainerView: UIView!
    @IBOutlet weak var memberCountLabel: UILabel!
    @IBOutlet weak var lastUpdatedDateLabel: UILabel!
    @IBOutlet weak var notiOffIconImageView: UIImageView!
    @IBOutlet weak var frozenImageView: UIImageView!
    @IBOutlet weak var lastMessageLabel: UILabel!
    @IBOutlet weak var unreadMessageCountContainerView: UIView!
    @IBOutlet weak var unreadMessageCountLabel: UILabel!
    @IBOutlet weak var typingIndicatorContainerView: UIView!
    @IBOutlet weak var typingIndicatorImageView: FLAnimatedImageView!
    @IBOutlet weak var typingIndicatorLabel: UILabel!
    @IBOutlet weak var profileImagView: ProfileImageView!
    @IBOutlet weak var memberCountWidth: NSLayoutConstraint!
    
    var selectedChannel: SBDGroupChannel?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        do {
            let path = Bundle.main.path(forResource: "loading_typing", ofType: "gif")!
            let gifData = try NSData(contentsOfFile: path) as Data
            let image = FLAnimatedImage(animatedGIFData: gifData)
            self.typingIndicatorImageView.animatedImage = image
            self.typingIndicatorContainerView.isHidden = true
            self.lastMessageLabel.isHidden = false
        } catch {
            print(error.localizedDescription)
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    func setTimeStamp(channel: SBDGroupChannel) {
        
        self.selectedChannel = channel
        
        let lastMessageDateFormatter = DateFormatter()
        var lastUpdatedAt: Date?
        
        /// Marking Date on the Group Channel List
        if channel.lastMessage != nil {
            lastUpdatedAt = Date(timeIntervalSince1970: Double((channel.lastMessage?.createdAt)! / 1000))
        } else {
            lastUpdatedAt = Date(timeIntervalSince1970: Double(channel.createdAt))
        }
        
        let currDate = Date()
        
        let lastMessageDateComponents = Calendar.current.dateComponents([.day, .month, .year], from: lastUpdatedAt!)
        let currDateComponents = Calendar.current.dateComponents([.day, .month, .year], from: currDate)
        
        if lastMessageDateComponents.year != currDateComponents.year || lastMessageDateComponents.month != currDateComponents.month || lastMessageDateComponents.day != currDateComponents.day {
            lastMessageDateFormatter.dateStyle = .short
            lastMessageDateFormatter.timeStyle = .none
            self.lastUpdatedDateLabel.text = timeForChat(lastUpdatedAt!, numericDates: true)
        }
        else {
            lastMessageDateFormatter.dateStyle = .none
            lastMessageDateFormatter.timeStyle = .short
            self.lastUpdatedDateLabel.text = lastMessageDateFormatter.string(from: lastUpdatedAt!)
        }
        
        
        Timer.scheduledTimer(timeInterval: 360, target: self, selector: #selector(GroupChannelTableViewCell.updateTimeStamp), userInfo: nil, repeats: true)
        
    }
    
    
    @objc func updateTimeStamp() {
        
        if selectedChannel != nil {
            
            let lastMessageDateFormatter = DateFormatter()
            var lastUpdatedAt: Date?
            
            /// Marking Date on the Group Channel List
            if selectedChannel!.lastMessage != nil {
                lastUpdatedAt = Date(timeIntervalSince1970: Double((selectedChannel!.lastMessage?.createdAt)! / 1000))
            } else {
                lastUpdatedAt = Date(timeIntervalSince1970: Double(selectedChannel!.createdAt))
            }
            
            let currDate = Date()
            
            let lastMessageDateComponents = Calendar.current.dateComponents([.day, .month, .year], from: lastUpdatedAt!)
            let currDateComponents = Calendar.current.dateComponents([.day, .month, .year], from: currDate)
            
            if lastMessageDateComponents.year != currDateComponents.year || lastMessageDateComponents.month != currDateComponents.month || lastMessageDateComponents.day != currDateComponents.day {
                lastMessageDateFormatter.dateStyle = .short
                lastMessageDateFormatter.timeStyle = .none
                self.lastUpdatedDateLabel.text = timeForChat(lastUpdatedAt!, numericDates: true)
            }
            else {
                lastMessageDateFormatter.dateStyle = .none
                lastMessageDateFormatter.timeStyle = .short
                self.lastUpdatedDateLabel.text = lastMessageDateFormatter.string(from: lastUpdatedAt!)
            }
            
        }
        
        
        
        
    }
    
}
