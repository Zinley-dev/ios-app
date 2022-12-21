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
                guard let output = AVAudioSession.sharedInstance().currentRoute.outputs.first else { return }
            speakerButton.setBackgroundImage(output.portType.rawValue == "BluetoothHFP" ? UIImage(named: "airpod") : .audio(output: output.portType), for: .normal)
            }
        
    }
    
    @IBOutlet weak var muteAudioButton: UIButton! {
        didSet {
                let isAudioEnabled = currentRoom?.localParticipant?.isAudioEnabled ?? false
                muteAudioButton.isSelected = isAudioEnabled
            muteAudioButton.setBackgroundImage( .audio(isOn: !isAudioEnabled), for: .normal)
            }
    }
    
    @IBOutlet weak var endButton: UIButton!
    
    var current_participants = [Participant]()
    
    // collection users
    var collectionNode: ASCollectionNode!

    

    override func viewDidLoad() {
        super.viewDidLoad()
        if newroom! {
            general_room = currentRoom
            gereral_group_chanel_url = currentChanelUrl
        }
        currentRoom?.addDelegate(self, identifier: "room")
        setupAudioOutputButton()
        current_participants = currentRoom?.participants.filter { $0.user.userId != _AppCoreData.userDataSource.value?.userID } ?? []
        current_participants.insert((currentRoom?.localParticipant!)!, at: 0)
        let flowLayout = UICollectionViewFlowLayout()
        collectionNode = ASCollectionNode(collectionViewLayout: flowLayout)
        flowLayout.minimumInteritemSpacing = 5
        flowLayout.minimumLineSpacing = 5
        wireDelegates()
        applyStyle()
        collectionNode.automaticallyRelayoutOnLayoutMarginsChanges = true
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
        endButton.isEnabled = false
            currentRoom?.removeAllDelegates()
            do {
                try currentRoom?.exit()
                general_room = nil
                gereral_group_chanel_url = nil
                NotificationCenter.default.post(name: NSNotification.Name("checkCallForLayout"), object: nil)
                dismiss(animated: true, completion: nil)
            } catch {
                presentErrorAlert(message: "Can't leave the room now!")
            }
    }
    
}

extension GroupCallViewController {
    
    func setupAudioOutputButton() {
        let width = speakerButton.frame.width
        let height = speakerButton.frame.height
        let frame = CGRect(x: 0, y: 0, width: width, height: height)
        let routePickerView = SendBirdCall.routePickerView(frame: frame)
        customize(routePickerView)
        speakerButton.addSubview(routePickerView)
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
        muteAudioButton.setBackgroundImage(.audio(isOn: isEnabled), for: .normal)
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
    func didRemoteParticipantEnter(_ participant: RemoteParticipant) {
        guard !current_participants.contains(participant) else { return }
        current_participants.insert(participant, at: 1)
        collectionNode.insertItems(at: [IndexPath(item: 1, section: 0)])
    }

    func didRemoteParticipantExit(_ participant: RemoteParticipant) {
        guard let index = current_participants.firstIndex(of: participant) else { return }
        current_participants.remove(at: index)
        collectionNode.deleteItems(at: [IndexPath(item: index, section: 0)])
    }

    func didRemoteAudioSettingsChange(_ participant: RemoteParticipant) {
        guard let index = current_participants.firstIndex(of: participant) else { return }
        current_participants[index] = participant
        collectionNode.reloadItems(at: [IndexPath(item: index, section: 0)])
    }

    func didAudioDeviceChange(_ room: Room, session: AVAudioSession, previousRoute: AVAudioSessionRouteDescription, reason: AVAudioSession.RouteChangeReason) {
        guard let output = session.currentRoute.outputs.first else { return }
        speakerButton.setBackgroundImage(.audio(output: output.portType), for: .normal)
    }

    func didReceiveError(_ error: SBCError, participant: Participant?) {
        presentErrorAlert(message: error.localizedDescription)
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
