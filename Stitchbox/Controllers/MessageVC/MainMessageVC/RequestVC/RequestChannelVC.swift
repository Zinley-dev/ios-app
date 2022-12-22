//
//  RequestChannelVC.swift
//  Stitchbox
//
//  Created by Khoi Nguyen on 12/18/22.
//

import UIKit
import SendBirdUIKit
import SendBirdCalls

class RequestChannelVC: SBUChannelViewController {

    var isUnHidden = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.rightBarButtonItem = nil
            
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
          
        self.tabBarController?.tabBar.isHidden = true
        self.tabBarController?.tabBar.frame = .zero
    }
   
    
    override func willMove(toParent parent: UIViewController?) {
        super.willMove(toParent: parent)
        
        
        if (parent != nil) {
            self.tabBarController?.tabBar.frame = .zero
            self.tabBarController?.tabBar.isHidden = true
        }
            
        
    }
    
    
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        
    }
    
    func checkIFUnhidden() {
    
        
        
        
    }
    
    func updateChannel() {
        
        
        if let userUID = _AppCoreData.userDataSource.value?.userID, userUID != "" {
            
            if let channel = self.channel, self.channel?.creator?.userId != userUID {
                
                if isUnHidden == false {
                    
                    checkIFUnhidden()
                    
                    hideChannelToadd = channel
                    
 
                    NotificationCenter.default.post(name: (NSNotification.Name(rawValue: "addHideChannel")), object: nil)
                    NotificationCenter.default.post(name: (NSNotification.Name(rawValue: "removeHideChannel")), object: nil)
                    

                    channel.setMyPushTriggerOption(.all) { error in
                        if let error = error {
                            Utils.showAlertController(error: error, viewController: self)
                            return
                        }
                    }
                    
                    isUnHidden = true
                    
                }
                
                
                
            } else if let channel = self.channel, self.channel?.joinedAt != nil {
                
                if isUnHidden == false {
                    
                    checkIFUnhidden()
                    
                    hideChannelToadd = channel
                    NotificationCenter.default.post(name: (NSNotification.Name(rawValue: "addHideChannel")), object: nil)
                    NotificationCenter.default.post(name: (NSNotification.Name(rawValue: "removeHideChannel")), object: nil)
                    
                    
                    channel.setMyPushTriggerOption(.all) { error in
                        if let error = error {
                            Utils.showAlertController(error: error, viewController: self)
                            return
                        }
                    }
                    
                    isUnHidden = true
                
                }
                
                
            }
            
        }
        
        
        
        
    }
    
    
    override func sendUserMessage(messageParams: SBDUserMessageParams, parentMessage: SBDBaseMessage? = nil) {
        
        
        if let userUID = _AppCoreData.userDataSource.value?.userID, userUID != "" {
            
            if let channel = self.channel, self.channel?.creator?.userId != userUID {
                
                
                
                acceptInvitesRequest(channel: channel.channelUrl, userUID: userUID)
                
                /*
                channel.acceptInvitation { error in
                    if let error = error {
                        Utils.showAlertController(error: error, viewController: self)
                        return
                    }
                    
                    self.sendText(messageParams: messageParams)
                }*/
                
                
            } else {
                
                sendText(messageParams: messageParams)
                
                
            }
            
        }
           
    }
    
    
    func acceptInvitesRequest(channel: String, userUID: String) {
        
        if let inviterUID = self.channel?.getInviter()?.userId {
            
            if inviterUID == userUID {
                
                performAcceptAPIRequest(channel: channel, inviterUID: "", userUID: userUID)
            
            } else {
                
                performAcceptAPIRequest(channel: channel, inviterUID: inviterUID, userUID: userUID)
                
            }
            
        } else {
            
            performAcceptAPIRequest(channel: channel, inviterUID: "", userUID: userUID)
        }
        
    }
    
    func performAcceptAPIRequest(channel: String, inviterUID: String, userUID: String) {
        
        APIManager().acceptSBInvitationRequest(user_id: userUID, channelUrl: channel) { result in
            switch result {
            case .success(let apiResponse):
                // Check if the request was successful
                guard apiResponse.body?["message"] as? String == "success",
                    let data = apiResponse.body?["data"] as? [String: Any] else {
                        return
                }
                
                print(data)
                
               
            case .failure(let error):
                print(error)
            }
        }
        
    }

    
    func sendText(messageParams: SBDUserMessageParams) {
        
        if let userUID = _AppCoreData.userDataSource.value?.userID, userUID != "" {
            
            if self.channel?.isHidden == true {
                
                if self.channel?.creator?.userId == userUID {
                    
                    messageParams.pushNotificationDeliveryOption = .suppress
                    
                }
                
            }
              
            
            let preSendMessage = self.channel?.sendUserMessage(with: messageParams)
            { [weak self] userMessage, error in
                if (error != nil) {
                    
                    SBUPendingMessageManager.shared.upsertPendingMessage(
                        channelUrl: userMessage?.channelUrl,
                        message: userMessage
                    )
                    
                 
                } else {
                    
                    SBUPendingMessageManager.shared.removePendingMessage(
                        channelUrl: userMessage?.channelUrl,
                        requestId: userMessage?.requestId
                    )
                    
                }
                
                guard let self = self else { return }
                
                if error != nil {
                    self.sortAllMessageList(needReload: true)
                    
                    return
                }
                
                guard let message = userMessage else { return }
             
                  
                self.upsertMessagesInList(messages: [message], needReload: true)
                if let channel = self.channel {
                    channel.markAsRead { err in
                        if err != nil {
                            print(err!.localizedDescription)
                        }
                    }
                }
            }
                   
            if let preSendMessage = preSendMessage,
               self.messageListParams.belongs(to: preSendMessage)
            {
                SBUPendingMessageManager.shared.upsertPendingMessage(
                    channelUrl: self.channel?.channelUrl,
                    message: preSendMessage
                )
            }
            
            self.sortAllMessageList(needReload: true)
            self.messageInputView.endTypingMode()
            self.scrollToBottom(animated: false)
            if let channel = self.channel {
                channel.endTyping()
            }
            
            updateChannel()
            
        }
        
        
        
    }
    
    override func sendFileMessage(fileData: Data?, fileName: String, mimeType: String) {
        
        
        if let userUID = _AppCoreData.userDataSource.value?.userID, userUID != "" {
            
            if let channel = self.channel, self.channel?.creator?.userId != userUID {
                      
                channel.acceptInvitation { error in
                    if let error = error {
                        Utils.showAlertController(error: error, viewController: self)
                        return
                    }
                    
                    self.sendMedia(fileData: fileData, fileName: fileName, mimeType: mimeType)
                }
                
                  
                
            } else {
                
                sendMedia(fileData: fileData, fileName: fileName, mimeType: mimeType)
                
            }
            
        }
        
        
        
        
        
        
        
        
    }
    
    func sendMedia(fileData: Data?, fileName: String, mimeType: String) {
        
        guard let fileData = fileData else { return }
        
        
        if let userUID = _AppCoreData.userDataSource.value?.userID, userUID != "" {
            

            let messageParams = SBDFileMessageParams(file: fileData)!
            messageParams.fileName = fileName
            messageParams.mimeType = mimeType
            messageParams.fileSize = UInt(fileData.count)
            
            if let image = UIImage(data: fileData) {
                let thumbnailSize = SBDThumbnailSize.make(withMaxCGSize: image.size)
                messageParams.thumbnailSizes = [thumbnailSize]
            }
            
            SBUGlobalCustomParams.fileMessageParamsSendBuilder?(messageParams)
            
            guard let channel = self.channel else { return }
            
            
            var preSendMessage: SBDFileMessage?
            preSendMessage = channel.sendFileMessage(
                with: messageParams,
                progressHandler: { bytesSent, totalBytesSent, totalBytesExpectedToSend in
                    //// If need reload cell for progress, call reload action in here.
                    guard (preSendMessage?.requestId) != nil else { return }
                    _ = CGFloat(totalBytesSent)/CGFloat(totalBytesExpectedToSend)
                   
                },
                completionHandler: { [weak self] fileMessage, error in
                    if (error != nil) {
                        if let fileMessage = fileMessage,
                           self?.messageListParams.belongs(to: fileMessage) == true
                        {
                            SBUPendingMessageManager.shared.upsertPendingMessage(
                                channelUrl: fileMessage.channelUrl,
                                message: fileMessage
                            )
                        }
                    } else {
                        SBUPendingMessageManager.shared.removePendingMessage(
                            channelUrl: fileMessage?.channelUrl,
                            requestId: fileMessage?.requestId
                        )
                    }
                    
                    guard let self = self else { return }
                    if error != nil {
                        self.sortAllMessageList(needReload: true)
                        
                        return
                    }
                    
                    guard let message = fileMessage else { return }
                    
                    
                    
                    self.upsertMessagesInList(messages: [message], needReload: true)
                    
                    if let channel = self.channel {
                        channel.markAsRead { err in
                            if err != nil {
                                print(err!.localizedDescription)
                            }
                        }
                    }
                })
            
            if let preSendMessage = preSendMessage,
               self.messageListParams.belongs(to: preSendMessage)
            {
                SBUPendingMessageManager.shared.upsertPendingMessage(
                    channelUrl: self.channel?.channelUrl,
                    message: preSendMessage
                )
                
                SBUPendingMessageManager.shared.addFileInfo(
                    requestId: preSendMessage.requestId,
                    params: messageParams
                )
            } else {
               // SBULog.info("A filtered file message has been sent.")
            }
            
            self.sortAllMessageList(needReload: true)
           
            updateChannel()
            
        }
        
        
        
    }
    

}
