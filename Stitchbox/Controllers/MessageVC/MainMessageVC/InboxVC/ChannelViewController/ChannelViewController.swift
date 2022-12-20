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
    
    
    var settingButton: UIButton = UIButton(type: .custom)
    var voiceCallButton: UIButton = UIButton(type: .custom)
    private lazy var CleftBarButton: UIBarButtonItem? = _leftBarButton
    private lazy var _leftBarButton: UIBarButtonItem = {
        return UIBarButtonItem(
            
            image: SBUIconSet.iconBack.resize(targetSize: CGSize(width: 25.0, height: 25.0)),
            style: .plain,
            target: self,
            action: #selector(onClickBack)
        )
        
    }()
    
    var getRoom: Room!
    var currentRoomID = ""
    var count = 0
   
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        navigationItem.rightBarButtonItem = nil
        
        settingButton.setImage(UIImage(named: "img_btn_channel_settings"), for: [])
        settingButton.addTarget(self, action: #selector(showChannelSetting(_:)), for: .touchUpInside)
        settingButton.frame = CGRect(x: -1, y: 0, width: 40, height: 30)
        let settingBarButton = UIBarButtonItem(customView: settingButton)
    

        voiceCallButton.setImage(UIImage(named: "icBarCallFilled"), for: [])
        voiceCallButton.addTarget(self, action: #selector(clickVoiceCallBarButton(_:)), for: .touchUpInside)
        voiceCallButton.frame = CGRect(x: -1, y: 0, width: 40, height: 30)
        let voiceCallBarButton = UIBarButtonItem(customView: voiceCallButton)
        
        self.voiceCallButton.setTitle("", for: .normal)
        self.voiceCallButton.sizeToFit()
        
        
        self.navigationItem.rightBarButtonItems = [settingBarButton, voiceCallBarButton]
        
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.tabBarController?.tabBar.isHidden = true
        self.tabBarController?.tabBar.frame = .zero
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let url = channel?.channelUrl {
            
            //getCurrentRoomID(chanelUrl: url, processCall: false)
            
        } else {
            print("SB: Can't get url")
        }
    }
    
    
    override func willMove(toParent parent: UIViewController?) {
        super.willMove(toParent: parent)
        
        
        if (parent != nil) {
            
            self.tabBarController?.tabBar.frame = .zero
            self.tabBarController?.tabBar.isHidden = true
        }
        
        
    }
    
    func getapi(chanelUrl: String) {
           
            APIManager().roomIDRequest(channelUrl: chanelUrl) { result in switch result {
                
            case .success(let apiResponse):
                
                if (apiResponse.body?["message"] as! String == "success") {
                    
                    if let data = apiResponse.body?["data"] as! [String: Any]? {
                        
                        self.count = self.count + 1
                        
                        do{
                            let SBRoomInfo = try SendBirdRoom(JSONbody: data)
                            // Store account to UserDefault as "userAccount"
                            print("Sendbird Room id: \(SBRoomInfo.room_id) - channelUrl: \(chanelUrl) - count \(self.count)")
               
                            
                        } catch{
                            
                           
                        }
                        
                    } else {
                        
                        print("Can't extract data")
                        
                    }
                    
                }
                
            case .failure(let error):
                
                print(error)
                
            }
        }
        
        
    }
    
    
    func showErrorAlert(_ title: String, msg: String) {
        
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        
        
        present(alert, animated: true, completion: nil)
        
    }
    
    
    func showChannelSetting(_ sender: AnyObject) {
        
        if let selected_channel = channel {
            
            let CSV = ChannelSettingsVC(channelUrl: selected_channel.channelUrl)
            navigationController?.pushViewController(CSV, animated: true)
            
        }
        
        
    }
    
    func clickVoiceCallBarButton(_ sender: AnyObject) {
        
        
        //preProcessGroupCall()
        
        if let url = channel?.channelUrl {
            
            getapi(chanelUrl: url)
            
        }
        
        
    }
    
    
    func preProcessGroupCall() {
        
        if let url = channel?.channelUrl {
            
            if general_room == nil {
                getCurrentRoomID(chanelUrl: url, processCall: true)
            } else {
                
                if gereral_group_chanel_url != url {
                    
                    do {
                        try general_room!.exit()
                        general_room?.removeAllDelegates()
                        general_room = nil
                        gereral_group_chanel_url = nil
                        
                        // participant has exited the room successfully.
                        
                        getCurrentRoomID(chanelUrl: url, processCall: true)
                        
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
            
            
            
        } else {
            
            self.presentErrorAlert(message: "Can't join call")
            
        }
        
    }
    
    func getCurrentRoomID(chanelUrl: String, processCall: Bool) {
        
        if self.getRoom == nil {
            
        
            APIManager().roomIDRequest(channelUrl: chanelUrl) { result in switch result {
                
            case .success(let apiResponse):
                
                if (apiResponse.body?["message"] as! String == "success") {
                    
                    if let data = apiResponse.body?["data"] as! [String: Any]? {
                        
                        
                        do{
                            let SBRoomInfo = try SendBirdRoom(JSONbody: data)
                            // Store account to UserDefault as "userAccount"
                            self.currentRoomID = SBRoomInfo.room_id
                            
                            
                            SendBirdCall.fetchRoom(by: self.currentRoomID) {  room, error in
                                guard let room = room, error == nil else {
                                    
                                    
                                    if error?.errorCode.rawValue == 1800303 {
                                        
                                        self.reauthenticateUser(shouldAnimated: false)
                                        
                                    } else if error?.errorCode.rawValue == 1800700 || error?.errorCode.rawValue == 1800701 || error?.errorCode.rawValue == 1400122 {
                                        
                                        do {
                                            try self.getRoom!.exit()
                                            general_room = nil
                                            gereral_group_chanel_url = nil
                                            
                                            // participant has exited the room successfully.
                                        } catch {
                                            
                                            //self.presentErrorAlert(message: "Can't leave the room now!")
                                            // SBCError.participantNotInRoom is thrown because participant has not entered the room.
                                        }
                                        
                                    } else {
                                        
                                        self.presentErrorAlert(message: "Error code: \(error!.errorCode.rawValue), \(error!.localizedDescription)")
                                        
                                        
                                    }
                                    
                                    return
                                    
                                    
                                }
                                
                              
                                self.getRoom = room
                   
                                if processCall == false {
                                    
                                    self.callLayout()
                                    
                                    
                                } else {
                                    
                                    self.processCall(currentRoomID: self.getRoom.roomId, chanelUrl: chanelUrl)
                                    
                                }
                                
                                
                            }
                            
                            
                            
                        } catch{
                            
                            self.currentRoomID = ""
                            self.getRoom = nil
                            print(error)
                        }
                        
                    } else {
                        
                        print("Can't extract data")
                        
                    }
                    
                }
                
            case .failure(let error):
                
                print(error)
                
            }
            }
            
        } else {
            
            
            if processCall == true {
                
                self.processCall(currentRoomID: self.getRoom.roomId, chanelUrl: chanelUrl)
                
            } else {
                
                self.callLayout()
                
            }
            
            
            
        }
        
        
        
    }
    
    func callLayout() {
        
        print("Sendbird count: \(self.getRoom.participants.count) - \(self.getRoom.roomId)")
        
        if self.getRoom.participants.count > 0 {
        
            
            self.voiceCallButton.setTitle("+", for: .normal)
            
            
            if self.voiceCallButton.currentImage == nil {
                
                self.voiceCallButton.setImage(UIImage(named: "icCallFilled"), for: [])
                
            } else {
                
                if self.voiceCallButton.currentImage?.isEqual(UIImage(named: "icCallFilled")) == false  {
                    
                    self.voiceCallButton.setImage(UIImage(named: "icCallFilled"), for: [])
                    
                }
                
            }
            
            //voiceCallButton.setImage(UIImage(named: "icCallFilled"), for: [])
            
            self.voiceCallButton.sizeToFit()
            self.voiceCallButton.shake()
            
        } else {
            
            
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
    
    
  
    
    func processCall(currentRoomID: String, chanelUrl: String) {
        
        if self.getRoom != nil {
            
            let params = Room.EnterParams(isVideoEnabled: false, isAudioEnabled: true)
            
            getRoom.enter(with: params, completionHandler: { err in
                if err != nil {
                    
                    
                    if err?.errorCode.rawValue == 1800303 {
                        
                        self.ShowNotAuthenticatedProperlyAndReAuthenticate()
                        
                    } else if err?.errorCode.rawValue == 1800700 || err?.errorCode.rawValue == 1800701 {
                        
                        do {
                            try self.getRoom!.exit()
                            general_room = nil
                            gereral_group_chanel_url = nil
                            
                            // participant has exited the room successfully.
                        } catch {
                            
                            
                            self.presentErrorAlert(message: "Can't leave the room now!")
                            // SBCError.participantNotInRoom is thrown because participant has not entered the room.
                        }
                        
                    } else {
                        
                        do {
                            try self.getRoom.exit()
                            general_room = nil
                            gereral_group_chanel_url = nil
                            
                            // participant has exited the room successfully.
                        } catch {
                            
                            self.presentErrorAlert(message: "Can't leave the room now!")
                            // SBCError.participantNotInRoom is thrown because participant has not entered the room.
                        }
                        
                        self.presentErrorAlert(message: "Error code: \(err!.errorCode.rawValue), \(err!.localizedDescription)")
                        
                        
                    }
                    
           
                    
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
            
            
        } else {
            
            
            SendBirdCall.fetchRoom(by: currentRoomID) { room, error in
                guard let room = room, error == nil else {
                    
                    if error?.errorCode.rawValue == 1800303 {
                        
                        self.ShowNotAuthenticatedProperlyAndReAuthenticate()
                        
                    } else if error?.errorCode.rawValue == 1800700 || error?.errorCode.rawValue == 1800701 || error?.errorCode.rawValue == 1400122 {
                        
                        do {
                            try self.getRoom!.exit()
                            general_room = nil
                            gereral_group_chanel_url = nil
                            
                            // participant has exited the room successfully.
                        } catch {
                            
                            //self.presentErrorAlert(message: "Can't leave the room now!")
                            // SBCError.participantNotInRoom is thrown because participant has not entered the room.
                        }
                        
                    } else {
                        
            
                        self.presentErrorAlert(message: "Error code: \(error!.errorCode.rawValue), \(error!.localizedDescription)")
                        
                        
                    }
                    
                    return
                    
                    
                } // Handle error.
                // `room` with the identifier `ROOM_ID` is fetched from Sendbird Server.
                

                let params = Room.EnterParams(isVideoEnabled: false, isAudioEnabled: true)
                
                room.enter(with: params, completionHandler: { err in
                    if err != nil {
                        
                        
                        if err?.errorCode.rawValue == 1800303 {
                            
                            self.ShowNotAuthenticatedProperlyAndReAuthenticate()
                            
                        } else if err?.errorCode.rawValue == 1800700 || err?.errorCode.rawValue == 1800701 {
                            
                            do {
                                try self.getRoom!.exit()
                                general_room = nil
                                gereral_group_chanel_url = nil
                                
                                // participant has exited the room successfully.
                            } catch {
                                
                                
                                self.presentErrorAlert(message: "Can't leave the room now!")
                                // SBCError.participantNotInRoom is thrown because participant has not entered the room.
                            }
                            
                        } else {
                            
                            do {
                                try room.exit()
                                general_room = nil
                                gereral_group_chanel_url = nil
                                
                                // participant has exited the room successfully.
                            } catch {
                                
                                self.presentErrorAlert(message: "Can't leave the room now!")
                                // SBCError.participantNotInRoom is thrown because participant has not entered the room.
                            }
                            
                            self.presentErrorAlert(message: "Error code: \(err!.errorCode.rawValue), \(err!.localizedDescription)")
                            
                            
                        }
                        
               
                        
                    } else {
                        
                        if let controller = UIStoryboard(name: "Dashboard", bundle: nil).instantiateViewController(withIdentifier: "GroupCallViewController") as? GroupCallViewController {
            
                            
                            
                            controller.currentRoom = room
                            controller.newroom = true
                            controller.currentChanelUrl = chanelUrl
                            
                            controller.modalPresentationStyle = .fullScreen
                            
                            self.present(controller, animated: true, completion: nil)
                            
                        }
                        
                    }
                    
                    
                    
                    
                })
                
            }
            
        }
        
        
    }
    
    func ShowNotAuthenticatedProperlyAndReAuthenticate() {
        
       
        let sheet = UIAlertController(title: "Your account isn't authenticated properly!", message: "You will have to re-authenticate to perform any calling function!", preferredStyle: .actionSheet)
        
        
        let Authenticate = UIAlertAction(title: "Re-authenticate", style: .default) { (alert) in
            
            
            self.reauthenticateUser(shouldAnimated: true)
            
        }

        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (alert) in
            
        }
        
        sheet.addAction(Authenticate)
        sheet.addAction(cancel)

        
        self.present(sheet, animated: true, completion: nil)
        
        
        
    }
    
    
    
    func reauthenticateUser(shouldAnimated: Bool) {
        
        SwiftLoader.hide()
        
        if let userUID = _AppCoreData.userDataSource.value?.userID, userUID != "" {
            
            if shouldAnimated == true {
                
                swiftLoader(text: "Authenticating...")
                
            }
        
            
            SBUGlobals.CurrentUser = SBUUser(userId: userUID)
            
            SBUMain.connect { usr, error in
                if error != nil {
                    print(error!.localizedDescription)
                }
                
                if let user = usr {
                
                    let params = AuthenticateParams(userId: user.userId)
                    
                        
                        SendBirdCall.authenticate(with: params) { (users, err) in
                            if err != nil {
                                
                                print(err!.localizedDescription)
                                return
                            }
                            // The user has been authenticated successfully and is connected to Sendbird server.
                            
                            
                            
                            let appDelegate: AppDelegate? = UIApplication.shared.delegate as? AppDelegate
                            
                           
                            appDelegate?.voipRegistration()
                            appDelegate?.addDirectCallSounds()
                            
                            
                            if shouldAnimated == true {
                                
                                SwiftLoader.hide()
                                showNote(text: "Authenticated successfully!")
                                
                            }
                            
                    }
                }
                
            }
            
        } else {
            
            self.presentErrorAlert(message: "Can't authenticate your account right now, please try to logout and login again.")
        }
        
       
        
    }

}
