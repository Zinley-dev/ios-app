//
//  ChannelViewController.swift
//  Stitchbox
//
//  Created by Khoi Nguyen on 12/17/22.
//

import UIKit
import SendBirdUIKit
import SendBirdCalls
import ObjectMapper

class ChannelViewController: SBUChannelViewController {
    
    private lazy var CleftBarButton: UIBarButtonItem? = _leftBarButton
    private lazy var _leftBarButton: UIBarButtonItem = {
        return UIBarButtonItem(
            
            image: SBUIconSet.iconBack.resize(targetSize: CGSize(width: 25.0, height: 25.0)),
            style: .plain,
            target: self,
            action:  #selector(onClickBack)
        )
        
    }()
    
    var getRoom: Room!
    var currentRoomID = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
       
        // Do any additional setup after loading the view.
        navigationItem.rightBarButtonItem = nil
        self.callLayout()
    
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        changeTabBar(hidden: true)
        self.tabBarController?.tabBar.isTranslucent = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let url = channel?.channelUrl {
            
            getCurrentRoom(chanelUrls: url, processCall: false)
            
        } else {
            print("SB: Can't get url")
        }
    }
    
    
    func changeTabBar(hidden: Bool) {
        guard let tabBar = self.tabBarController?.tabBar else {
            return
        }

        tabBar.isHidden = hidden
    }

    
    func showErrorAlert(_ title: String, msg: String) {
        
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        
        
        present(alert, animated: true, completion: nil)
        
    }
    
    
    func showChannelSetting(_ sender: AnyObject) {
        
        if let selected_channel = channel {
            
            if let CCV = UIStoryboard(name: "Dashboard", bundle: nil).instantiateViewController(withIdentifier: "ChannelSettingsVC") as? ChannelSettingsVC {
                CCV.channel = selected_channel
                self.navigationController?.pushViewController(CCV, animated: true)
                
            }
            
        }
        
    }
    
    func clickVoiceCallBarButton(_ sender: AnyObject) {
        
        
        preProcessGroupCall()
        
        
    }
    
    
    func preProcessGroupCall() {
        
        guard let url = channel?.channelUrl else {
            self.presentErrorAlert(message: "Can't join call")
            return
        }
        
        if general_room == nil {
            getCurrentRoom(chanelUrls: url, processCall: true)
        } else {
            if gereral_group_chanel_url != url {
                do {
                    try general_room!.exit()
                    general_room?.removeAllDelegates()
                    general_room = nil
                    gereral_group_chanel_url = nil
                    getCurrentRoom(chanelUrls: url, processCall: true)
                } catch {
                    self.presentErrorAlert(message: "Multiple call at once error!")
                }
            } else {
                if let controller = UIStoryboard(name: "Dashboard", bundle: nil).instantiateViewController(withIdentifier: "GroupCallViewController") as? GroupCallViewController {
                    controller.currentRoom = general_room
                    controller.newroom = false
                    controller.currentChanelUrl = url
                    controller.modalPresentationStyle = .fullScreen
                    self.present(controller, animated: true, completion: nil)
                }
            }
        }
        
    }
    
    func getCurrentRoom(chanelUrls: String, processCall: Bool) {
        
        if self.getRoom == nil {
            
            APIManager().roomIDRequest(channelUrl: chanelUrls) { result in
                switch result {
                case .success(let apiResponse):
                    // Check if the request was successful
                    guard apiResponse.body?["message"] as? String == "success",
                        let data = apiResponse.body?["data"] as? [String: Any] else {
                            return
                    }
                    
                    // Try to create a SendBirdRoom object from the data
                    let SBRoomInfo =  Mapper<SendBirdRoom>().map(JSONObject: data)
                    self.currentRoomID = SBRoomInfo?.room_id ?? ""
                   
                    // Fetch the room from the server
                    SendBirdCall.fetchRoom(by: self.currentRoomID) { room, error in
                        // Check for errors
                        if let error = error {
                            // Handle different error codes
                            switch error.errorCode {
                            case .notAuthenticated:
                                self.reauthenticateUser(shouldAnimate: false)
                            case .participantNotInRoom, .roomDeleted:
                                do {
                                    try self.getRoom?.exit()
                                    general_room = nil
                                    gereral_group_chanel_url = nil
                                } catch {
                                    //self.presentErrorAlert(message: "Can't leave the room now!")
                                }
                            default:
                                self.presentErrorAlert(message: "Error code: \(error.errorCode.rawValue), \(error.localizedDescription)")
                            }
                            
                            return
                        }
                        
                        guard let room = room else { return }
                        self.getRoom = room
                        
                        // Call the appropriate function based on the value of processCall
                        if processCall {
                            self.processCall(currentRoomID: room.roomId, chanelUrl: chanelUrls)
                        } else {
                            self.callLayout()
                        }
                    }
                case .failure(let error):
                    print(error)
                }
            }
            
        } else {
            
            
            if processCall == true {
                
                self.processCall(currentRoomID: self.getRoom.roomId, chanelUrl: chanelUrls)
                
            } else {
                
                self.callLayout()
                
            }
            
        }
        
    }
    
    func callLayout() {
        let settingButton = UIButton(type: .custom)
        settingButton.setImage(UIImage(named: "img_btn_channel_settings"), for: [])
        settingButton.addTarget(self, action: #selector(showChannelSetting(_:)), for: .touchUpInside)
        settingButton.frame = CGRect(x: 0, y: 0, width: 40, height: 30)
        let settingBarButton = UIBarButtonItem(customView: settingButton)

        let fixedSpace = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        fixedSpace.width = 2

        let voiceCallButton: UIButton
        let voiceCallBarButton: UIBarButtonItem

        if self.getRoom != nil && self.getRoom.participants.count > 0 {
            voiceCallButton = UIButton(type: .custom)
            voiceCallButton.semanticContentAttribute = .forceRightToLeft
            voiceCallButton.setTitle("Join", for: .normal)
            voiceCallButton.setTitleColor(.white, for: .normal)
            voiceCallButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
            voiceCallButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 2, bottom: 0, right: -2)
            voiceCallButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: -2, bottom: 0, right: 2)
            voiceCallButton.setImage(UIImage(named: "icCallFilled"), for: [])
            voiceCallButton.addTarget(self, action: #selector(clickVoiceCallBarButton(_:)), for: .touchUpInside)
            voiceCallButton.frame = CGRect(x: 0, y: 0, width: 70, height: 30)
            voiceCallButton.backgroundColor = .secondary
            voiceCallButton.cornerRadius = 15

            let customView = UIView(frame: CGRect(x: 0, y: 0, width: 70, height: 30))
            customView.addSubview(voiceCallButton)
            voiceCallButton.center = customView.center
            voiceCallBarButton = UIBarButtonItem(customView: customView)
            
            voiceCallButton.shake()
            
        } else {
            voiceCallButton = UIButton(type: .custom)
            voiceCallButton.setTitle("", for: .normal)
            voiceCallButton.setImage(UIImage(named: "icCallFilled"), for: [])
            voiceCallButton.addTarget(self, action: #selector(clickVoiceCallBarButton(_:)), for: .touchUpInside)
            voiceCallButton.frame = CGRect(x: -1, y: 0, width: 30, height: 30)
            voiceCallButton.backgroundColor = .clear
            voiceCallBarButton = UIBarButtonItem(customView: voiceCallButton)
            voiceCallButton.removeAnimation()
        }

        self.navigationItem.rightBarButtonItems = [settingBarButton, fixedSpace, voiceCallBarButton]
    }


    
    
    func processCall(currentRoomID: String, chanelUrl: String) {
        if let room = self.getRoom {
            enterRoom(room: room, chanelUrl: chanelUrl)
        } else {
            SendBirdCall.fetchRoom(by: currentRoomID) { room, error in
                guard let room = room, error == nil else {
                    self.handleError(error!)
                    return
                }
                self.enterRoom(room: room, chanelUrl: chanelUrl)
            }
        }
    }
    
    private func enterRoom(room: Room, chanelUrl: String) {
        let params = Room.EnterParams(isVideoEnabled: false, isAudioEnabled: true)
        room.enter(with: params, completionHandler: { err in
            if let err = err {
                self.handleError(err)
            } else {
                if let controller = UIStoryboard(name: "Dashboard", bundle: nil).instantiateViewController(withIdentifier: "GroupCallViewController") as? GroupCallViewController {
                    
                    
                    
                    controller.currentRoom = self.getRoom
                    controller.newroom = true
                    controller.currentChanelUrl = chanelUrl
                    
                    controller.modalPresentationStyle = .fullScreen
                    
                    self.present(controller, animated: true, completion: nil)
                    
                }
            }
        })
    }
    
    private func handleError(_ error: SBCError) {
        switch error.errorCode {
        case .notAuthenticated:
            ShowNotAuthenticatedProperlyAndReAuthenticate()
        case .roomDeleted, .enteringRoomStillInProgress, .participantsLimitExceededInRoom:
            exitRoom()
        default:
            presentErrorAlert(message: "Error code: \(error.errorCode.rawValue), \(error.localizedDescription)")
        }
    }
    
    private func exitRoom() {
        do {
            try self.getRoom.exit()
            general_room = nil
            gereral_group_chanel_url = nil
        } catch {
            presentErrorAlert(message: "Unable to leave room at this time")
        }
    }
    
    
    func ShowNotAuthenticatedProperlyAndReAuthenticate() {
        
        
        let sheet = UIAlertController(title: "Your account isn't authenticated properly!", message: "You will have to re-authenticate to perform any calling function!", preferredStyle: .actionSheet)
        
        
        let Authenticate = UIAlertAction(title: "Re-authenticate", style: .default) { (alert) in
            
            
            self.reauthenticateUser(shouldAnimate: true)
            
        }
        
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (alert) in
            
        }
        
        sheet.addAction(Authenticate)
        sheet.addAction(cancel)
        
        
        self.present(sheet, animated: true, completion: nil)
        
        
        
    }
    
    func reauthenticateUser(shouldAnimate: Bool) {
        if let userUID = _AppCoreData.userDataSource.value?.userID, userUID != "" {
            if shouldAnimate {
                presentSwiftLoaderWithText(text: "Authenticating...")
            }
            SBUGlobals.CurrentUser = SBUUser(userId: userUID)
            SBUMain.connect { usr, error in
                if let error = error {
                    print(error.localizedDescription)
                } else if let user = usr {
                    let params = AuthenticateParams(userId: user.userId)
                    SendBirdCall.authenticate(with: params) { (users, error) in
                        if let error = error {
                            print(error.localizedDescription)
                        } else {
                            if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                                appDelegate.voipRegistration()
                                appDelegate.addDirectCallSounds()
                            }
                            if shouldAnimate {
                                showNote(text: "Authenticated successfully!")
                            }
                        }
                    }
                }
            }
        } else {
            presentErrorAlert(message: "Can't authenticate your account right now, please try to logout and login again.")
        }
    }

    override func willMove(toParent parent: UIViewController?) {
        if parent == nil {
            
            changeTabBar(hidden: false)
            self.tabBarController?.tabBar.isTranslucent = false
            
        }
      
    }
    
}
