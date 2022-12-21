//
//  GroupCallViewController.swift
//  Stitchbox
//
//  Created by Khoi Nguyen on 12/18/22.
//

import UIKit
import AVKit
import CallKit
import MediaPlayer
import SendBirdCalls
import AsyncDisplayKit
import Alamofire
import AsyncDisplayKit
import SendBirdUIKit

class GroupCallViewController: UIViewController {

    @IBOutlet weak var contentView: UIView!
    
    var currentRoom: Room?
    var newroom: Bool?
    var currentChanelUrl: String?

    @IBOutlet weak var speakerButton: UIButton! {
        
        didSet {
    
            guard let output = AVAudioSession().currentRoute.outputs.first else { return }
            
            if output.portType.rawValue == "BluetoothHFP" {
                
                self.speakerButton.setBackgroundImage(UIImage(named: "airpod"), for: .normal)
                
            } else {
                
                self.speakerButton.setBackgroundImage(.audio(output: output.portType),
                                                         for: .normal)
            }
            
        }
        
        
    }
    
    @IBOutlet weak var muteAudioButton: UIButton! {
        
        didSet {
            self.muteAudioButton.isSelected = (self.currentRoom?.localParticipant?.isAudioEnabled)!
            self.muteAudioButton.setBackgroundImage(.audio(isOn: !(self.currentRoom?.localParticipant?.isAudioEnabled)!), for: .normal)
        }
    }
    
    @IBOutlet weak var endButton: UIButton!
    
    var current_participants = [Participant]()
    
    // collection users
    var collectionNode: ASCollectionNode!

    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup
        
        if newroom == true {
            general_room = currentRoom
            gereral_group_chanel_url = currentChanelUrl
        }
        
        currentRoom?.addDelegate(self, identifier: "room")
        setupAudioOutputButton()
        
        for user in currentRoom!.participants {
            
            
            if let userUID = _AppCoreData.userDataSource.value?.userID, userUID != "" {
                
                if user.user.userId != userUID {
                    
                    current_participants.append(user)
                    
                }
                
            }
            
        }
        
        
        // add myself
        
        current_participants.insert((currentRoom?.localParticipant!)!, at: 0)
          
        // layout delegate
        
        let flowLayout = UICollectionViewFlowLayout()
        self.collectionNode = ASCollectionNode(collectionViewLayout: flowLayout)
        
        flowLayout.minimumInteritemSpacing = 5
        flowLayout.minimumLineSpacing = 5
        self.wireDelegates()
        
        self.applyStyle()
        self.collectionNode.automaticallyRelayoutOnLayoutMarginsChanges = true
        contentView.addSubview(collectionNode.view)
        
    }
    
    
    func applyStyle() {
        
        self.collectionNode.view.backgroundColor = UIColor.clear
        self.collectionNode.view.showsVerticalScrollIndicator = false
          
    }
    
    
    func wireDelegates() {
        
        self.collectionNode.delegate = self
        self.collectionNode.dataSource = self
        
    
    }
    
    override func viewWillLayoutSubviews() {
        
        super.viewWillLayoutSubviews()
        self.collectionNode.frame = contentView.bounds
    }

    @IBAction func back1BtnPressed(_ sender: Any) {
        
        currentRoom?.removeAllDelegates()
        self.dismiss(animated: true, completion: nil)
        
    }
    
    @IBAction func back2BtnPressed(_ sender: Any) {
        
        currentRoom?.removeAllDelegates()
        self.dismiss(animated: true, completion: nil)
        
    }
    
    
    @IBAction func didTapAudioOption(_ sender: UIButton) {
        sender.isSelected.toggle()
        
        self.updateLocalAudio(isEnabled: sender.isSelected)
    }
    
    @IBAction func didTapEnd() {
        self.endButton.isEnabled = false
        
        do {
            currentRoom?.removeAllDelegates()
            try currentRoom!.exit()
            
            
            //
            general_room = nil
            gereral_group_chanel_url = nil
            //
            NotificationCenter.default.post(name: (NSNotification.Name(rawValue: "checkCallForLayout")), object: nil)
            self.dismiss(animated: true, completion: nil)
            // participant has exited the room successfully.
        } catch {
            
            self.presentErrorAlert(message: "Can't leave the room now!")
           
        }
        
        
        
    }
    
}

extension GroupCallViewController {
    
    func setupAudioOutputButton() {
        
        let width = self.speakerButton.frame.width
        let height = self.speakerButton.frame.height
        let frame = CGRect(x: 0, y: 0, width: width, height: height)
    
        let routePickerView = SendBirdCall.routePickerView(frame: frame)
        self.customize(routePickerView)
        self.speakerButton.addSubview(routePickerView)
    }
    
    func customize(_ routePickerView: UIView) {
        if #available(iOS 11.0, *) {
            guard let routePickerView = routePickerView as? AVRoutePickerView else { return }
            routePickerView.activeTintColor = .clear
            routePickerView.tintColor = .clear
        } else {
            guard let volumeView = routePickerView as? MPVolumeView else { return }
            
            volumeView.showsVolumeSlider = true
            volumeView.setRouteButtonImage(nil, for: .normal)
            volumeView.routeButtonRect(forBounds: volumeView.frame)
        }
    }
    
    func updateLocalAudio(isEnabled: Bool) {
        self.muteAudioButton.setBackgroundImage(.audio(isOn: isEnabled), for: .normal)
        
        
        if isEnabled {
            currentRoom?.localParticipant?.muteMicrophone()
        } else {
            currentRoom?.localParticipant?.unmuteMicrophone()
        }
        
        
        current_participants[0] = (currentRoom?.localParticipant!)!
        collectionNode.reloadItems(at: [IndexPath(item: 0, section: 0)])
    }
    
    
}

extension GroupCallViewController: RoomDelegate {
    // MARK: Required Methods
    
    // Called when a remote participant has entered the room.
    func didRemoteParticipantEnter(_ participant: RemoteParticipant) {
        
        if !current_participants.contains(participant) {
            
            current_participants.insert(participant, at: 1)
            collectionNode.insertItems(at: [IndexPath(item: 1, section: 0)])
            
        }
        
    }
    

    // Called when a remote participant has exited the room.
    func didRemoteParticipantExit(_ participant: RemoteParticipant) {
        
        
        if current_participants.contains(participant)  {
            
            let index = getIndexOfParticipannt(participant: participant)
            current_participants.removeObject(participant)
            collectionNode.deleteItems(at: [IndexPath(item: index, section: 0)])
            
           
            
        }
        
        
    }
        
    
    func didRemoteAudioSettingsChange(_ participant: RemoteParticipant) {
        //self.updateRemoteAudio(isEnabled: participant.isAudioEnabled)
        
        if current_participants.contains(participant) {
            
            let id = getIndexOfParticipannt(participant: participant)
            
            current_participants[id] = participant
            
            collectionNode.reloadItems(at: [IndexPath(item: id, section: 0)])
            
        }
        
        
    }
    
    func getIndexOfParticipannt(participant: Participant) -> Int {
        
        var count = 0
        
        for user in current_participants {
            
            if user.user.userId == participant.user.userId {
                
                break
            }
            
            count += 1
            
        }
        
        return count
        
        
    }
    func didAudioDeviceChange(_ room: Room, session: AVAudioSession, previousRoute: AVAudioSessionRouteDescription, reason: AVAudioSession.RouteChangeReason) {
    
        guard let output = session.currentRoute.outputs.first else { return }
        
        if output.portType.rawValue == "BluetoothHFP" {
            
            self.speakerButton.setBackgroundImage(UIImage(named: "airpod"), for: .normal)
            
        } else {
            self.speakerButton.setBackgroundImage(.audio(output: output.portType),
                                                     for: .normal)
        }
        
    }
    
    func didReceiveError(_ error: SBCError, participant: Participant?) {
            // Clear resources for group calls.
        
        self.presentErrorAlert(message: error.localizedDescription)
    }

}


extension GroupCallViewController: ASCollectionDelegate {
    
    func shouldBatchFetch(for collectionNode: ASCollectionNode) -> Bool {
        
        return false
    }
    
    func collectionNode(_ collectionNode: ASCollectionNode, constrainedSizeForItemAt indexPath: IndexPath) -> ASSizeRange {
        
        let min = CGSize(width: contentView.frame.width/2 - 3, height: contentView.frame.width/2);
        let max = CGSize(width: contentView.frame.width/2 - 3, height: contentView.frame.width/2);
        return ASSizeRangeMake(min, max);
        
        
    }
    
}

extension GroupCallViewController: ASCollectionDataSource {
    
    
    func numberOfSections(in collectionNode: ASCollectionNode) -> Int {
        return 1
    }
    
    func collectionNode(_ collectionNode: ASCollectionNode, numberOfItemsInSection section: Int) -> Int {
        return current_participants.count
    }
    
    func collectionNode(_ collectionNode: ASCollectionNode, nodeForItemAt indexPath: IndexPath) -> ASCellNode {
        
        
        let participant = self.current_participants[indexPath.row]
        
        let node = GroupNode(with: participant)
        node.neverShowPlaceholders = true
        node.debugName = "Node \(indexPath.row)"
        
        return node
                
    }
    
    func collectionNode(_ collectionNode: ASCollectionNode, didSelectItemAt indexPath: IndexPath) {
        
        
        if let userUID = _AppCoreData.userDataSource.value?.userID, userUID != "" {
            
            let user = current_participants[indexPath.row]
            
            if user.user.userId != userUID {
                
                let sheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
                
                
                let chat = UIAlertAction(title: "Chat", style: .default) { (alert) in
                    
                    self.chat(user: user)
                    
                    
                }

                
                let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (alert) in
                    
                }
                
                sheet.addAction(chat)
                sheet.addAction(cancel)

                
                self.present(sheet, animated: true, completion: nil)
                
            }
            
            
        }
         
        
    }
    
    func chat(user: Participant) {
        
        
        if let userUID = _AppCoreData.userDataSource.value?.userID, userUID != "" {
            
            let channelParams = SBDGroupChannelParams()
            channelParams.isDistinct = true
            channelParams.addUserId(user.user.userId)
            channelParams.addUserId(userUID)
            
            
            SBDGroupChannel.createChannel(with: channelParams) { (groupChannel, err) in
                if err != nil {
                    print(err!.localizedDescription)
                }
                
                let channelVC = ChannelViewController(
                    channelUrl: groupChannel!.channelUrl,
                    messageListParams: nil
                )
                            
                let navigationController = UINavigationController(rootViewController: channelVC)
                navigationController.modalPresentationStyle = .fullScreen
                self.present(navigationController, animated: true, completion: nil)
                
           
            }
            
        }
        
        
    }

}
