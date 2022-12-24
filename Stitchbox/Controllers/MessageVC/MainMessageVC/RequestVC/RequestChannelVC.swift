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
    

    override func sendUserMessage(messageParams: SBDUserMessageParams, parentMessage: SBDBaseMessage? = nil) {
        guard let userUID = _AppCoreData.userDataSource.value?.userID, !userUID.isEmpty, let channel = self.channel, channel.creator?.userId != userUID else {
            sendText(messageParams: messageParams)
            return
        }
        
        guard channel.joinedAt != 0 else {
            acceptInvitesRequest(channel: channel.channelUrl, userUID: userUID, messageParams: messageParams, isText: true, fileData: nil, fileName: nil, mimeType: nil)
            return
        }
        
        sendText(messageParams: messageParams)
    }

    
    
    func acceptInvitesRequest(channel: String, userUID: String, messageParams: SBDUserMessageParams?, isText: Bool, fileData: Data?, fileName: String?, mimeType: String?) {
        let inviterUID = self.channel?.getInviter()?.userId ?? ""
        performAcceptAPIRequest(channel: channel, inviterUID: inviterUID, userUID: userUID, messageParams: messageParams, isText: isText, fileData: fileData, fileName: fileName, mimeType: mimeType)
    }

    
    func performAcceptAPIRequest(channel: String, inviterUID: String, userUID: String, messageParams: SBDUserMessageParams?, isText: Bool, fileData: Data?, fileName: String?, mimeType: String?) {
        
        APIManager().acceptSBInvitationRequest(user_id: inviterUID, channelUrl: channel) { result in
            switch result {
            case .success(let apiResponse):
                // Check if the request was successful
                guard apiResponse.body?["message"] as? String == "success" else {
                        return
                }
                
                DispatchQueue.main.async {
                    if isText {
                        self.sendText(messageParams: messageParams!)
                    } else {
                        self.sendMedia(fileData: fileData, fileName: fileName!, mimeType: mimeType!)
                    }
                    
                }
                
            
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
            
          
        }
        
        
        
    }
    
    override func sendFileMessage(fileData: Data?, fileName: String, mimeType: String) {
        
        guard let userUID = _AppCoreData.userDataSource.value?.userID, !userUID.isEmpty, let channel = self.channel, channel.creator?.userId != userUID else {
            sendMedia(fileData: fileData, fileName: fileName, mimeType: mimeType)
            return
        }
        
        guard channel.joinedAt != 0 else {
            acceptInvitesRequest(channel: channel.channelUrl, userUID: userUID, messageParams: nil, isText: false, fileData: fileData, fileName: fileName, mimeType: mimeType)
            return
        }
        
        sendMedia(fileData: fileData, fileName: fileName, mimeType: mimeType)
 
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
           
           
        }
        
        
        
    }
    

}
