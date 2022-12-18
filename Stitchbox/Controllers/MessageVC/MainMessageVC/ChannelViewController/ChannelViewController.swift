//
//  ChannelViewController.swift
//  Stitchbox
//
//  Created by Khoi Nguyen on 12/17/22.
//

import UIKit
import SendBirdUIKit
import SendBirdCalls

class ChannelViewController: SBUChannelViewController {
    
    var getRoom: Room!
    
    var settingButton: UIButton = UIButton(type: .custom)
    var voiceCallButton: UIButton = UIButton(type: .custom)

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
        
        setupWithCall()
        
        /*
        if channel?.isHidden == false {
            
            if (channel?.members!.count)! > 2 {
                
                setupWithCall()
                
            } else {
                
                if (channel?.members!.count) == 2 {
                    
                    
                    if let selected_channel = channel {
                        
                        if selected_channel.joinedMemberCount == 2 {
                            
                            
                            for user in ((selected_channel.members)! as NSArray as! [SBDMember]) {
                                
                                if user.userId != Auth.auth().currentUser!.uid {
                                    if !global_block_list.contains(user.userId) {
                                        
                                        setupWithCall()
                                        
                                    } else {
                                        
                                        
                                        self.navigationItem.rightBarButtonItems = nil
                                        self.messageInputView.isHidden = true
                                    }
                                    
                                }
                                
                            }
                            
                            
                            
                        }
                    
                        
                    }
                    
                    
                    
                    
                }
                
                
            }
            
        }*/
        
        
    }
    
    
    func setupWithCall() {
        
        // Do any additional setup after loading the view.
        
        settingButton.setImage(UIImage(named: "img_btn_channel_settings"), for: [])
        settingButton.addTarget(self, action: #selector(showChannelSetting(_:)), for: .touchUpInside)
        settingButton.frame = CGRect(x: -1, y: 0, width: 40, height: 30)
        let settingBarButton = UIBarButtonItem(customView: settingButton)
    

        
        voiceCallButton.addTarget(self, action: #selector(clickVoiceCallBarButton(_:)), for: .touchUpInside)
        voiceCallButton.frame = CGRect(x: -1, y: 0, width: 40, height: 30)
        let voiceCallBarButton = UIBarButtonItem(customView: voiceCallButton)
      
        self.navigationItem.rightBarButtonItems = [settingBarButton, voiceCallBarButton]
        
        
        
        if let url = channelUrl {
            
            if self.voiceCallButton.currentImage == nil {
                
                self.voiceCallButton.setImage(UIImage(named: "icBarCallFilled"), for: [])
                
            } else {
                
                if self.voiceCallButton.currentImage?.isEqual(UIImage(named: "icBarCallFilled")) == false  {
                    
                    self.voiceCallButton.setImage(UIImage(named: "icBarCallFilled"), for: [])
                    
                }
                
            }
            
            //voiceCallButton.setImage(UIImage(named: "icBarCallFilled"), for: [])
            self.voiceCallButton.setTitle("", for: .normal)
            self.voiceCallButton.sizeToFit()
            self.voiceCallButton.removeAnimation()
            
            
        }
        
        
    }
    
    func showErrorAlert(_ title: String, msg: String) {
                                                                                                                                           
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        
                                                                                       
        present(alert, animated: true, completion: nil)
        
    }
    
    
    override func sendUserMessage(messageParams: SBDUserMessageParams, parentMessage: SBDBaseMessage? = nil) {
        
        sendTextMessage(messageParams: messageParams)
        
    }
    
    
    override func sendFileMessage(fileData: Data?, fileName: String, mimeType: String) {
        
        
        sendMediaMess(fileData: fileData, fileName: fileName, mimeType: mimeType)
      
        
    }
    
    
    func sendMediaMess(fileData: Data?, fileName: String, mimeType: String) {
        
        guard let fileData = fileData else { return }
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
    
    
    
    func sendTextMessage(messageParams: SBDUserMessageParams) {
        
        
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
    
    func showChannelSetting(_ sender: AnyObject) {
       
        if let selected_channel = channel {
            
            /*
            let CSV = ChannelSettingsVC(channelUrl: selected_channel.channelUrl)
            navigationController?.pushViewController(CSV, animated: true)
            */
        }
        
        
    }
    
    func clickVoiceCallBarButton(_ sender: AnyObject) {
        
        
        preProcessGroupCall()
        
           
    }
    
    
    func preProcessGroupCall() {
        
        
        
    }

   

}
