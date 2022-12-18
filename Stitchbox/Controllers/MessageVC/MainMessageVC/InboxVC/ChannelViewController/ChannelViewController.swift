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
        
        setupWithCall()
    
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
    
    /*
    override func sendUserMessage(messageParams: SBDUserMessageParams, parentMessage: SBDBaseMessage? = nil) {
        
        sendTextMessage(messageParams: messageParams)
        
    }*/
    
    /*
    override func sendFileMessage(fileData: Data?, fileName: String, mimeType: String) {
        
        
        sendMediaMess(fileData: fileData, fileName: fileName, mimeType: mimeType)
      
        
    }*/
    
    
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
