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
import CoreMedia
import AVFAudio
import ObjectMapper

var general_room: Room!
var gereral_group_chanel_url: String!
var startTime = Date()

var global_presetingRate = 0.0
var global_cornerRadius = 0.0
var global_percentComplete = 0.0
var global_host = ""
var global_fullLink = ""
var selectedTabIndex = 0
var global_suppport_game_list = [GameList]()
var needRecount = false
var needReloadPost = false
var needRemove = false
var newSlogan = ""
var didChanged = false
var reloadAddedGame = false
var globalIsSound = false
var shouldMute: Bool?
var globalSetting: SettingModel!
var navigationControllerHeight:CGFloat = 0.0
var tabBarControllerHeight:CGFloat = 0.0
let horizontalPadding: CGFloat = 12

let data1 = StreamingDomainModel(postKey: "1", streamingDomainModel: ["company": "Stitchbox", "domain": ["stitchbox.gg"], "status": true])
let data2 = StreamingDomainModel(postKey: "2", streamingDomainModel: ["company": "YouTube Gaming", "domain": ["youtube.com, m.youtube.com"], "status": true])
let data3 = StreamingDomainModel(postKey: "3", streamingDomainModel: ["company": "Twitch", "domain": ["twitch.tv", "m.twitch.tv"], "status": true])
let data4 = StreamingDomainModel(postKey: "4", streamingDomainModel: ["company": "Facebook gaming", "domain": ["facebook.com", "m.facebook.com"], "status": true])
let data5 = StreamingDomainModel(postKey: "5", streamingDomainModel: ["company": "Bigo Live", "domain": ["bigo.tv"], "status": true])
let data6 = StreamingDomainModel(postKey: "6", streamingDomainModel: ["company": "Nonolive", "domain": ["nonolive.com"], "status": true])
let data7 = StreamingDomainModel(postKey: "7", streamingDomainModel: ["company": "Afreeca", "domain": ["afreecatv.com"], "status": true])

var emptyimage = "https://img.freepik.com/premium-photo/gray-wall-empty-room-with-concrete-floor_53876-70804.jpg?w=1380"

let xBtn = UIImage(named: "1024x")?.resize(targetSize: CGSize(width: 12, height: 12))

var streaming_domain = [data1, data2, data3, data4, data5, data6, data7]
var back_frame = CGRect(x: 0, y: 0, width: 44, height: 44)
var discord_domain = ["discordapp.com", "discord.com", "discord.co", "discord.gg", "watchanimeattheoffice.com", "dis.gd", "discord.media", "discordapp.net", "discordstatus.com" ]

let muteImage = UIImage.init(named: "3xmute")?.resize(targetSize: CGSize(width: 26, height: 26)).withRenderingMode(.alwaysOriginal)
let unmuteImage = UIImage.init(named: "3xunmute")?.resize(targetSize: CGSize(width: 26, height: 26)).withRenderingMode(.alwaysOriginal)
let speedImage = UIImage.init(named: "Speed_4x")?.resize(targetSize: CGSize(width: 25, height: 25))

typealias DownloadComplete = () -> ()

func activeSpeaker() {
    
    do {
                try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback)
                print("AVAudioSession Category Playback OK")
                do {
                    try AVAudioSession.sharedInstance().setActive(true)
                    print("AVAudioSession is Active")
                } catch {
                    print(error.localizedDescription)
                }
            } catch {
                print(error.localizedDescription)
            }
    
}

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

func presentSwiftLoaderWithText(text: String) {
    
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



func pauseVideoIfNeed(pauseIndex: Int) {
  
    if let vc = UIViewController.currentViewController() {
         
        if vc is SelectedPostVC {
            
            if let update1 = vc as? SelectedPostVC {
                
                if let cell = update1.collectionNode.nodeForItem(at: IndexPath(row: pauseIndex, section: 0)) as? PostNode {
                    
                    if cell.sideButtonView != nil {
                        cell.sideButtonView.soundBtn.setImage(muteImage, for: .normal)
                        
                        if !cell.buttonsView.streamView.isHidden {
                            
                            cell.buttonsView.streamView.stopSpin()
                            
                        }
                    }
                    
                    cell.videoNode.player?.seek(to: CMTime.zero)
                    cell.videoNode.pause()
                    
                }
                
            }
            
        } else if vc is FeedViewController {
            
            if let update1 = vc as? FeedViewController {
                
                if let cell = update1.collectionNode.nodeForItem(at: IndexPath(row: pauseIndex, section: 0)) as? PostNode {
                    
                    if cell.sideButtonView != nil {
                        cell.sideButtonView.soundBtn.setImage(muteImage, for: .normal)
                        
                        if !cell.buttonsView.streamView.isHidden {
                            
                            cell.buttonsView.streamView.stopSpin()
                            
                        }
                    }
                    
                    cell.videoNode.player?.seek(to: CMTime.zero)
                    cell.videoNode.pause()
                    
                }
                
            }
            
        } else if vc is PostListWithHashtagVC {
            
            if let update1 = vc as? PostListWithHashtagVC {
                
                if let cell = update1.collectionNode.nodeForItem(at: IndexPath(row: pauseIndex, section: 0)) as? PostNode {
                    
                    if cell.sideButtonView != nil {
                        cell.sideButtonView.soundBtn.setImage(muteImage, for: .normal)
                        
                        if !cell.buttonsView.streamView.isHidden {
                            
                            cell.buttonsView.streamView.stopSpin()
                            
                        }
                    }
                    
                    cell.videoNode.player?.seek(to: CMTime.zero)
                    cell.videoNode.pause()
                    
                }
                
            }
            
        } else if vc is MainSearchVC {
            
            if let update1 = vc as? MainSearchVC {
                
                if let cell = update1.PostSearchVC.collectionNode.nodeForItem(at: IndexPath(row: pauseIndex, section: 0)) as? PostNode {
                    
                    if cell.sideButtonView != nil {
                        cell.sideButtonView.soundBtn.setImage(muteImage, for: .normal)
                        
                        if !cell.buttonsView.streamView.isHidden {
                            
                            cell.buttonsView.streamView.stopSpin()
                            
                        }
                    }
                    
                    cell.videoNode.player?.seek(to: CMTime.zero)
                    cell.videoNode.pause()
                    
                }
                
            }
            
        } else if vc is ReelVC {
            
            if let update1 = vc as? ReelVC {
                
                if let cell = update1.collectionNode.nodeForItem(at: IndexPath(row: pauseIndex, section: 0)) as? ReelNode {
                    
                    if cell.buttonsView != nil {
                        
                        
                        if !cell.buttonsView.streamView.isHidden {
                            
                            cell.buttonsView.streamView.stopSpin()
                            
                        }
                    }
                    
                    cell.videoNode.player?.seek(to: CMTime.zero)
                    cell.videoNode.pause()
                    
                }
                
            }
            
        }
             
        
    }
}


func playVideoIfNeed(playIndex: Int) {
  
    if let vc = UIViewController.currentViewController() {
         
        if vc is SelectedPostVC {
            
            if let update1 = vc as? SelectedPostVC {
                
                if let cell = update1.collectionNode.nodeForItem(at: IndexPath(row: playIndex, section: 0)) as? PostNode {
                    
                    if !cell.videoNode.isPlaying() {
                        
                        if !cell.buttonsView.streamView.isHidden {
                            
                            cell.buttonsView.streamView.spin()
                            
                        }
                        
                        if let muteStatus = shouldMute {
                            
                            if cell.sideButtonView != nil {
                                
                                if muteStatus {
                                    cell.sideButtonView.soundBtn.setImage(muteImage, for: .normal)
                                } else {
                                    cell.sideButtonView.soundBtn.setImage(unmuteImage, for: .normal)
                                }
                            }
                           
                            if muteStatus {
                                cell.videoNode.muted = true
                            } else {
                                cell.videoNode.muted = false
                            }
                            
                            cell.videoNode.play()
                            
                        } else {
                            
                            if cell.sideButtonView != nil {
                                
                                if globalIsSound {
                                    cell.sideButtonView.soundBtn.setImage(unmuteImage, for: .normal)
                                } else {
                                    cell.sideButtonView.soundBtn.setImage(muteImage, for: .normal)
                                }
                            }
                           
                            if globalIsSound {
                                cell.videoNode.muted = false
                            } else {
                                cell.videoNode.muted = true
                            }
                            
                            cell.videoNode.play()
                            
                        }
                        
                        
                        
                      
                    }
                    
                }
                
            }
            
        } else if vc is FeedViewController {
            
            if let update1 = vc as? FeedViewController {
                
                if let cell = update1.collectionNode.nodeForItem(at: IndexPath(row: playIndex, section: 0)) as? PostNode {
                    
                    if !cell.videoNode.isPlaying() {
                        
                        if !cell.buttonsView.streamView.isHidden {
                            
                            cell.buttonsView.streamView.spin()
                            
                        }
                        
                        if let muteStatus = shouldMute {
                            
                            if cell.sideButtonView != nil {
                                
                                if muteStatus {
                                    cell.sideButtonView.soundBtn.setImage(muteImage, for: .normal)
                                } else {
                                    cell.sideButtonView.soundBtn.setImage(unmuteImage, for: .normal)
                                }
                            }
                           
                            if muteStatus {
                                cell.videoNode.muted = true
                            } else {
                                cell.videoNode.muted = false
                            }
                            
                            cell.videoNode.play()
                            
                        } else {
                            
                            if cell.sideButtonView != nil {
                                
                                if globalIsSound {
                                    cell.sideButtonView.soundBtn.setImage(unmuteImage, for: .normal)
                                } else {
                                    cell.sideButtonView.soundBtn.setImage(muteImage, for: .normal)
                                }
                            }
                           
                            if globalIsSound {
                                cell.videoNode.muted = false
                            } else {
                                cell.videoNode.muted = true
                            }
                            
                            cell.videoNode.play()
                            
                        }
                    
                    }
                    
                }
                
            }
            
        } else if vc is PostListWithHashtagVC {
            
            if let update1 = vc as? PostListWithHashtagVC {
                
                if let cell = update1.collectionNode.nodeForItem(at: IndexPath(row: playIndex, section: 0)) as? PostNode {
                    
                    if !cell.videoNode.isPlaying() {
                        
                        if !cell.buttonsView.streamView.isHidden {
                            
                            cell.buttonsView.streamView.spin()
                            
                        }
            
                        if let muteStatus = shouldMute {
                            
                            if cell.sideButtonView != nil {
                                
                                if muteStatus {
                                    cell.sideButtonView.soundBtn.setImage(muteImage, for: .normal)
                                } else {
                                    cell.sideButtonView.soundBtn.setImage(unmuteImage, for: .normal)
                                }
                            }
                           
                            if muteStatus {
                                cell.videoNode.muted = true
                            } else {
                                cell.videoNode.muted = false
                            }
                            
                            cell.videoNode.play()
                            
                        } else {
                            
                            if cell.sideButtonView != nil {
                                
                                if globalIsSound {
                                    cell.sideButtonView.soundBtn.setImage(unmuteImage, for: .normal)
                                } else {
                                    cell.sideButtonView.soundBtn.setImage(muteImage, for: .normal)
                                }
                            }
                           
                            if globalIsSound {
                                cell.videoNode.muted = false
                            } else {
                                cell.videoNode.muted = true
                            }
                            
                            cell.videoNode.play()
                            
                        }
                    
                    }
                    
                }
                
            }
            
        } else if vc is MainSearchVC {
            
            if let update1 = vc as? MainSearchVC {
                
                if let cell = update1.PostSearchVC.collectionNode.nodeForItem(at: IndexPath(row: playIndex, section: 0)) as? PostNode {
                    
                    if !cell.videoNode.isPlaying() {
                        
                        
                        if !cell.buttonsView.streamView.isHidden {
                            
                            cell.buttonsView.streamView.spin()
                            
                        }
                        
                        if let muteStatus = shouldMute {
                            
                            if cell.sideButtonView != nil {
                                
                                if muteStatus {
                                    cell.sideButtonView.soundBtn.setImage(muteImage, for: .normal)
                                } else {
                                    cell.sideButtonView.soundBtn.setImage(unmuteImage, for: .normal)
                                }
                            }
                           
                            if muteStatus {
                                cell.videoNode.muted = true
                            } else {
                                cell.videoNode.muted = false
                            }
                            
                            cell.videoNode.play()
                            
                        } else {
                            
                            if cell.sideButtonView != nil {
                                
                                if globalIsSound {
                                    cell.sideButtonView.soundBtn.setImage(unmuteImage, for: .normal)
                                } else {
                                    cell.sideButtonView.soundBtn.setImage(muteImage, for: .normal)
                                }
                            }
                           
                            if globalIsSound {
                                cell.videoNode.muted = false
                            } else {
                                cell.videoNode.muted = true
                            }
                            
                            cell.videoNode.play()
                            
                        }
                    
                    }
                    
                }
                
            }
            
        }  else if vc is ReelVC {
            
            if let update1 = vc as? ReelVC {
                
                if let cell = update1.collectionNode.nodeForItem(at: IndexPath(row: playIndex, section: 0)) as? ReelNode {
                    
                    if !cell.videoNode.isPlaying() {
                        
                        
                        if !cell.buttonsView.streamView.isHidden {
                            
                            cell.buttonsView.streamView.spin()
                            
                        }
            
                        if let muteStatus = shouldMute {
                        
                           
                            if muteStatus {
                                cell.videoNode.muted = true
                            } else {
                                cell.videoNode.muted = false
                            }
                            
                            cell.videoNode.play()
                            
                        } else {
                            

                            if globalIsSound {
                                cell.videoNode.muted = false
                            } else {
                                cell.videoNode.muted = true
                            }
                            
                            cell.videoNode.play()
                            
                        }
                    
                    }
                    
                }
                
            }
            
        }
             
        
    }
}

class ImageSaver: NSObject {
    func writeToPhotoAlbum(image: UIImage) {
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(saveCompleted), nil)
    }

    @objc func saveCompleted(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        showNote(text: "Save finished!")
    }
}


func presentSwiftLoader() {
    
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


func discord_verify(host: String) -> Bool  {
    
    if discord_domain.contains(host) {
        return true
    }
    
    return false
}


func hideMiddleBtn(vc: UIViewController) {
    
    if let tabbar = vc.tabBarController as? DashboardTabBarController {
        tabbar.button.isHidden = true
    }
    
}


func showMiddleBtn(vc: UIViewController) {
    
    if let tabbar = vc.tabBarController as? DashboardTabBarController {
        tabbar.button.isHidden = false
    }
    
}

func turnOn2FAForEmail() {
    
    if let vc = UIViewController.currentViewController() {
         
        if vc is TwoFactorAuthVC {
            
            if let update1 = vc as? TwoFactorAuthVC {
                update1.isEmail = true
                update1.EmailSwitch.setOn(true, animated: true)
            }
            
        }
             
        
    }
    
}

func turnOn2FAForPhone() {
    
    if let vc = UIViewController.currentViewController() {
         
        if vc is TwoFactorAuthVC {
            
            if let update1 = vc as? TwoFactorAuthVC {
                update1.isPhone = true
                update1.PhoneSwitch.setOn(true, animated: true)
            }
            
        }
             
        
    }
    
}

func turnOff2FAForEmail() {
    
    if let vc = UIViewController.currentViewController() {
         
        if vc is TwoFactorAuthVC {
            
            if let update1 = vc as? TwoFactorAuthVC {
                update1.isEmail = false
                update1.EmailSwitch.setOn(false, animated: true)
            }
            
        }
             
        
    }
    
}

func turnOff2FAForPhone() {
    
    if let vc = UIViewController.currentViewController() {
         
        if vc is TwoFactorAuthVC {
            
            if let update1 = vc as? TwoFactorAuthVC {
                update1.isPhone = false
                update1.PhoneSwitch.setOn(false, animated: true)
            }
            
        }
             
        
    }
    
}


func transformFromJSON(_ value: Any?) -> Date? {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
    
    guard let strValue = value as? String else { return nil }
    return formatter.date(from: strValue)
}

extension Collection {
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}


func reloadGlobalUserInformation() {

    APIManager().getme { result in
        switch result {
        case .success(let response):
            
            if let data = response.body {
                
                if !data.isEmpty {

                    if let newUserData = Mapper<UserDataSource>().map(JSON: data) {
                        _AppCoreData.reset()
                        _AppCoreData.userDataSource.accept(newUserData)
                        syncSendbirdAccount()
                    } 
                  
                }
                
            }
            
            
        case .failure(let error):
            print("Error loading profile: ", error)
          
        }
    }
    
}


func reloadGlobalSettings() {
    
    APIManager().getSettings { result in
        switch result {
        case .success(let apiResponse):
            
            guard let data = apiResponse.body else {
                    return
            }

            globalSetting =  Mapper<SettingModel>().map(JSONObject: data)
           
      
        case .failure(let error):
        
            print(error)
           
        }
    }
    
}

func unmuteVideoIfNeed() {
  
    if let vc = UIViewController.currentViewController() {
         
        if vc is FeedViewController {
            
            if let update1 = vc as? FeedViewController {
                
                if update1.newPlayingIndex != nil {
                    
                    if let cell = update1.collectionNode.nodeForItem(at: IndexPath(row: update1.newPlayingIndex!, section: 0)) as? PostNode {
                        
                        if cell.videoNode.isPlaying() {
                            
                            cell.videoNode.muted = false
                            shouldMute = false
                            
                            if cell.sideButtonView != nil {
                                cell.sideButtonView.soundBtn.setImage(unmuteImage, for: .normal)
                            }
                            
                        }
                        
                    }
                    
                }
                
               
                
            }
            
        } else if vc is SelectedPostVC {
            
            if let update1 = vc as? SelectedPostVC {
                
                if update1.newPlayingIndex != nil {
                    
                    if let cell = update1.collectionNode.nodeForItem(at: IndexPath(row: update1.newPlayingIndex!, section: 0)) as? PostNode {
                        
                        if cell.videoNode.isPlaying() {
                            
                            cell.videoNode.muted = false
                            shouldMute = false
                            
                            if cell.sideButtonView != nil {
                                cell.sideButtonView.soundBtn.setImage(unmuteImage, for: .normal)
                            }
                            
                        }
                        
                    }
                    
                }
                
               
                
            }
            
        } else if vc is MainSearchVC {
            
            if let update1 = vc as? MainSearchVC {
                
                if update1.PostSearchVC.newPlayingIndex != nil {
                    
                    if let cell = update1.PostSearchVC.collectionNode.nodeForItem(at: IndexPath(row: update1.PostSearchVC.newPlayingIndex!, section: 0)) as? PostNode {
                        
                        if cell.videoNode.isPlaying() {
                            
                            cell.videoNode.muted = false
                            shouldMute = false
                            
                            if cell.sideButtonView != nil {
                                cell.sideButtonView.soundBtn.setImage(unmuteImage, for: .normal)
                            }
                            
                        }
                        
                    }
                    
                }
                
               
                
            }
            
        } else if vc is PostListWithHashtagVC {
            
            if let update1 = vc as? PostListWithHashtagVC {
                
                if update1.newPlayingIndex != nil {
                    
                    if let cell = update1.collectionNode.nodeForItem(at: IndexPath(row: update1.newPlayingIndex!, section: 0)) as? PostNode {
                        
                        if cell.videoNode.isPlaying() {
                            
                            cell.videoNode.muted = false
                            shouldMute = false
                            
                            if cell.sideButtonView != nil {
                                cell.sideButtonView.soundBtn.setImage(unmuteImage, for: .normal)
                            }
                            
                        }
                        
                    }
                    
                }
                
               
                
            }
            
        } else if vc is ReelVC {
            
            if let update1 = vc as? ReelVC {
                
                if update1.newPlayingIndex != nil {
                    
                    if let cell = update1.collectionNode.nodeForItem(at: IndexPath(row: update1.newPlayingIndex!, section: 0)) as? ReelNode {
                        
                        if cell.videoNode.isPlaying() {
                            
                            cell.soundProcess()
                            
                        }
                        
                    }
                    
                }
                
               
                
            }
            
        }
             
        
    }
    
}


func muteVideoIfNeed() {
  
    if let vc = UIViewController.currentViewController() {
         
        if vc is FeedViewController {
            
            if let update1 = vc as? FeedViewController {
                
                if update1.newPlayingIndex != nil {
                    
                    if let cell = update1.collectionNode.nodeForItem(at: IndexPath(row: update1.newPlayingIndex!, section: 0)) as? PostNode {
                        
                        if cell.videoNode.isPlaying() {
                            
                            cell.videoNode.muted = true
                            shouldMute = true
                            
                            if cell.sideButtonView != nil {
                                cell.sideButtonView.soundBtn.setImage(muteImage, for: .normal)
                            }
                            
                        }
                        
                    }
                    
                }
                
               
                
            }
            
        } else if vc is SelectedPostVC {
            
            if let update1 = vc as? SelectedPostVC {
                
                if update1.newPlayingIndex != nil {
                    
                    if let cell = update1.collectionNode.nodeForItem(at: IndexPath(row: update1.newPlayingIndex!, section: 0)) as? PostNode {
                        
                        if cell.videoNode.isPlaying() {
                            
                            cell.videoNode.muted = true
                            shouldMute = true
                            
                            if cell.sideButtonView != nil {
                                cell.sideButtonView.soundBtn.setImage(muteImage, for: .normal)
                            }
                            
                        }
                        
                    }
                    
                }
                
               
                
            }
            
        } else if vc is MainSearchVC {
            
            if let update1 = vc as? MainSearchVC {
                
                if update1.PostSearchVC.newPlayingIndex != nil {
                    
                    if let cell = update1.PostSearchVC.collectionNode.nodeForItem(at: IndexPath(row: update1.PostSearchVC.newPlayingIndex!, section: 0)) as? PostNode {
                        
                        if cell.videoNode.isPlaying() {
                            
                            cell.videoNode.muted = true
                            shouldMute = true
                            
                            if cell.sideButtonView != nil {
                                cell.sideButtonView.soundBtn.setImage(muteImage, for: .normal)
                            }
                            
                        }
                        
                    }
                    
                }
                
               
                
            }
            
        } else if vc is PostListWithHashtagVC {
            
            if let update1 = vc as? PostListWithHashtagVC {
                
                if update1.newPlayingIndex != nil {
                    
                    if let cell = update1.collectionNode.nodeForItem(at: IndexPath(row: update1.newPlayingIndex!, section: 0)) as? PostNode {
                        
                        if cell.videoNode.isPlaying() {
                            
                            cell.videoNode.muted = true
                            shouldMute = true
                            
                            if cell.sideButtonView != nil {
                                cell.sideButtonView.soundBtn.setImage(muteImage, for: .normal)
                            }
                            
                        }
                        
                    }
                    
                }
                
               
                
            }
            
        } else if vc is ReelVC {
            
            if let update1 = vc as? ReelVC {
                
                if update1.newPlayingIndex != nil {
                    
                    if let cell = update1.collectionNode.nodeForItem(at: IndexPath(row: update1.newPlayingIndex!, section: 0)) as? ReelNode {
                        
                        if cell.videoNode.isPlaying() {
                            
                            cell.soundProcess()
                            
                        }
                        
                    }
                    
                }
                
               
                
            }
            
        }
             
        
    }
    
}

func resetView(cell: PostNode) {
    
    if cell.isViewed == true {
        
        let currentTime = NSDate().timeIntervalSince1970
        
        let change = currentTime - cell.last_view_timestamp
        
        if change > 30.0 {
            
            cell.isViewed = false
            cell.time = 0
        
        }
        
    }
    
    
}

func resetViewForReel(cell: ReelNode) {
    
    if cell.isViewed == true {
        
        let currentTime = NSDate().timeIntervalSince1970
        
        let change = currentTime - cell.last_view_timestamp
        
        if change > 30.0 {
            
            cell.isViewed = false
            cell.time = 0
        
        }
        
    }
    
    
}

extension UIView {
    private static var originalTransformKey: UInt8 = 0
    
    private var originalTransform: CGAffineTransform? {
        get {
            return objc_getAssociatedObject(self, &UIView.originalTransformKey) as? CGAffineTransform
        }
        set(newValue) {
            objc_setAssociatedObject(self, &UIView.originalTransformKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    func spin(duration: Double = 3.5) {
        if originalTransform == nil {
            originalTransform = self.transform
        }
        
        let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotationAnimation.toValue = NSNumber(value: Double.pi * 2)
        rotationAnimation.duration = duration
        rotationAnimation.repeatCount = .infinity
        
        self.layer.add(rotationAnimation, forKey: "spinAnimation")
    }
    
    func stopSpin() {
        self.layer.removeAnimation(forKey: "spinAnimation")
        if let originalTransform = originalTransform {
            self.transform = originalTransform
        }
    }
}


func presentStreamingIntro() {
    
    if let SIVC = UIStoryboard(name: "Dashboard", bundle: nil).instantiateViewController(withIdentifier: "StreamingIntroVC") as? StreamingIntroVC {
        
        if let vc = UIViewController.currentViewController() {
            
            let nav = UINavigationController(rootViewController: SIVC)

            // Customize the navigation bar appearance
            nav.navigationBar.barTintColor = .background
            nav.navigationBar.tintColor = .white
            nav.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]

            nav.modalPresentationStyle = .fullScreen
            vc.present(nav, animated: true, completion: nil)


        }
    }
    
    
}


class DelayedPanGestureRecognizer: UIPanGestureRecognizer {
    private var touchDownTime: Date?
    private let delayTime: TimeInterval = 0.25 // Set the delay time to 0.25 seconds
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesBegan(touches, with: event)
        
        touchDownTime = Date()
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesMoved(touches, with: event)
        
        if let touchDownTime = touchDownTime,
           Date().timeIntervalSince(touchDownTime) < delayTime {
            state = .failed // Delay recognition of the pan gesture until the user has held their finger down for at least delayTime
        }
    }
}
