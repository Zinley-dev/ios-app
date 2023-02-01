//
//  globalFile.swift
//  Stitchbox
//
//  Created by Khoi Nguyen on 12/18/22.
//

import Foundation
import SendBirdSDK
import SendBirdUIKit
import SendBirdCalls
import SwiftEntryKit
import UserNotifications


var general_room: Room!
var gereral_group_chanel_url: String!
var startTime = Date()

var global_presetingRate = 0.0
var global_cornerRadius = 0.0
var global_percentComplete = 0.0
var global_host = ""
var global_fullLink = ""
var selectedTabIndex = 0

 let data1 = StreamingDomainModel(postKey: "1", streamingDomainModel: ["company": "Stitch", "domain": ["stitchbox.gg"], "status": true])
 let data2 = StreamingDomainModel(postKey: "2", streamingDomainModel: ["company": "YouTube Gaming", "domain": ["youtube.com, m.youtube.com"], "status": true])
 let data3 = StreamingDomainModel(postKey: "3", streamingDomainModel: ["company": "Twitch", "domain": ["twitch.tv", "m.twitch.tv"], "status": true])
 let data4 = StreamingDomainModel(postKey: "4", streamingDomainModel: ["company": "Facebook gaming", "domain": ["facebook.com", "m.facebook.com"], "status": true])
 let data5 = StreamingDomainModel(postKey: "5", streamingDomainModel: ["company": "Bigo Live", "domain": ["bigo.tv"], "status": true])
 let data6 = StreamingDomainModel(postKey: "6", streamingDomainModel: ["company": "Nonolive", "domain": ["nonolive.com"], "status": true])
 let data7 = StreamingDomainModel(postKey: "7", streamingDomainModel: ["company": "Afreeca", "domain": ["afreecatv.com"], "status": true])
 

var streaming_domain = [data1, data2, data3, data4, data5, data6, data7]


typealias DownloadComplete = () -> ()


func showNote(text: String) {
    
    var attributes = EKAttributes.topNote
    attributes.popBehavior = .animated(animation: .init(translate: .init(duration: 0.1), scale: .init(from: 1, to: 0.7, duration: 0.2)))
    attributes.entryBackground = .color(color: .musicBackground)
    attributes.shadow = .active(with: .init(color: .black, opacity: 0.5, radius: 10, offset: .zero))
    attributes.statusBar = .dark
    attributes.scroll = .enabled(swipeable: true, pullbackAnimation: .jolt)
    attributes.positionConstraints.maxSize = .init(width: .constant(value: UIScreen.main.bounds.width), height: .intrinsic)
    
    
    let style = EKProperty.LabelStyle(
        font: UIFont.systemFont(ofSize: 15, weight: UIFont.Weight.medium),
        color: .white,
        alignment: .center
    )
    let labelContent = EKProperty.LabelContent(
        text: text,
        style: style
    )
    let contentView = EKNoteMessageView(with: labelContent)
    SwiftEntryKit.display(entry: contentView, using: attributes)
    
}

func swiftLoader(text: String) {
    
    var config : SwiftLoader.Config = SwiftLoader.Config()
    config.size = 170
    
    config.backgroundColor = UIColor.clear
    config.spinnerColor = UIColor.white
    config.titleTextColor = UIColor.white
    
    
    config.spinnerLineWidth = 3.0
    config.foregroundColor = UIColor.black
    config.foregroundAlpha = 0.7
    
    
    SwiftLoader.setConfig(config: config)
    
    
    SwiftLoader.show(title: "", animated: true)
    
                                                                                                                                  
}


extension UIViewController {
    static func instantiate(from storyboard: String) -> Self {
        return UIStoryboard(name: storyboard, bundle: nil).instantiateViewController(withIdentifier: "\(self)") as! Self
    }
}

extension UIViewController: UIViewControllerTransitioningDelegate {
    public func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        PresentationController(presentedViewController: presented, presenting: presenting)
    }
}

extension UILabel {
    func textWidth() -> CGFloat {
        return UILabel.textWidth(label: self)
    }

    class func textWidth(label: UILabel) -> CGFloat {
        return textWidth(label: label, text: label.text!)
    }

    class func textWidth(label: UILabel, text: String) -> CGFloat {
        return textWidth(font: label.font, text: text)
    }

    class func textWidth(font: UIFont, text: String) -> CGFloat {
        return textSize(font: font, text: text).width
    }

    class func textHeight(withWidth width: CGFloat, font: UIFont, text: String) -> CGFloat {
        return textSize(font: font, text: text, width: width).height
    }

    class func textSize(font: UIFont, text: String, extra: CGSize) -> CGSize {
        var size = textSize(font: font, text: text)
        size.width = size.width + extra.width
        size.height = size.height + extra.height
        return size
    }

    class func textSize(font: UIFont, text: String, width: CGFloat = .greatestFiniteMagnitude, height: CGFloat = .greatestFiniteMagnitude) -> CGSize {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: width, height: height))
        label.numberOfLines = 0
        label.font = font
        label.text = text
        label.sizeToFit()
        return label.frame.size
    }

    class func countLines(font: UIFont, text: String, width: CGFloat, height: CGFloat = .greatestFiniteMagnitude) -> Int {
        // Call self.layoutIfNeeded() if your view uses auto layout
        let myText = text as NSString

        let rect = CGSize(width: width, height: height)
        let labelSize = myText.boundingRect(with: rect, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)

        return Int(ceil(CGFloat(labelSize.height) / font.lineHeight))
    }

    func countLines(width: CGFloat = .greatestFiniteMagnitude, height: CGFloat = .greatestFiniteMagnitude) -> Int {
        // Call self.layoutIfNeeded() if your view uses auto layout
        let myText = (self.text ?? "") as NSString

        let rect = CGSize(width: width, height: height)
        let labelSize = myText.boundingRect(with: rect, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: self.font!], context: nil)

        return Int(ceil(CGFloat(labelSize.height) / self.font.lineHeight))
    }
}


func processUpdateAvatar(channel: SBDGroupChannel, image: UIImage) {
    
    
    APIManager().uploadImage(image: image) { result in
        
        switch result {
        case .success(let apiResponse):
            
            guard apiResponse.body?["message"] as? String == "avatar uploaded successfully",
                  let url = apiResponse.body?["url"] as? String  else {
                    return
            }
            
           
            // update SBDGroupChannelParams()
            let param = SBDGroupChannelParams()
            param.coverUrl = url
            
            channel.update(with: param) { _, error in
                if let error = error {
                    print(error.localizedDescription, error.code)
                    return
                }
            }


        case .failure(let error):
            print(error)
        }
        
        
    }
    
}

func createLocalNotificationForActiveSendbirdUsers(title: String, body: String, channel: SBDGroupChannel) {
    
    // Request permission to display notifications
    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { (granted, error) in
        if granted {
            print("Notification permissions granted")
        } else {
            print("Notification permissions not granted")
        }
    }

    // Define the notification content
    let content = UNMutableNotificationContent()
    content.title = title
    content.body = body
    content.sound = UNNotificationSound.default

    // Add the message text and channel to the userInfo dictionary
    content.userInfo = ["type": "sendbird_localNoti", "channel_url": channel.channelUrl]

    // Create a trigger for the notification
    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.05, repeats: false)
    
    // Create a request for the notification
    let request = UNNotificationRequest(identifier: "notification", content: content, trigger: trigger)

    // Add the request to the notification center
    UNUserNotificationCenter.current().add(request) { (error) in
        if error != nil {
            print(error?.localizedDescription)
        } else {
            print("Notification scheduled")
        }
    }

}

extension UICollectionReusableView {
    static var reuseIdentifier: String {
        return String(describing: Self.self)
    }
}


func check_Url(host: String) -> Bool {
    return streaming_domain.contains { $0.domain.contains(host) }
}

extension UITextView {
    
    /**
     Calculates if new textview height (based on content) is larger than a base height
     
     - parameter baseHeight: The base or minimum height
     
     - returns: The new height
     */
    func newHeight(withBaseHeight baseHeight: CGFloat) -> CGFloat {
        
        // Calculate the required size of the textview
        let fixedWidth = frame.size.width
        let newSize = sizeThatFits(CGSize(width: fixedWidth, height: .greatestFiniteMagnitude))
        var newFrame = frame
        
        // Height is always >= the base height, so calculate the possible new height
        let height: CGFloat = newSize.height > baseHeight ? newSize.height : baseHeight
        newFrame.size = CGSize(width: max(newSize.width, fixedWidth), height: height)
        
        return newFrame.height
    }
}
