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

    @IBOutlet weak var timeLbl: UILabel!
    @IBOutlet weak var contentView: UIView!
    
    var currentRoom: Room?
    var newroom: Bool?
    var currentChanelUrl: String?
    private var callTimer: Timer?

    @IBOutlet weak var speakerButton: UIButton!
    
    @IBOutlet weak var muteAudioButton: UIButton! {
        didSet {
                let isAudioEnabled = currentRoom?.localParticipant?.isAudioEnabled ?? false
                muteAudioButton.isSelected = isAudioEnabled
                print("Audio: \(isAudioEnabled)")
                muteAudioButton.setBackgroundImage( .audio(isOn: !isAudioEnabled), for: .normal)
            }
    }
    
    @IBOutlet weak var endButton: UIButton!
    
    var current_participants = [Participant]()
    
    // collection users
    var collectionNode: ASCollectionNode!
    let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        return formatter
    }()

    

    override func viewDidLoad() {
            super.viewDidLoad()
        
            print(self.navigationController?.navigationBar.frame.height)
        
            if newroom! {
                general_room = currentRoom
                gereral_group_chanel_url = currentChanelUrl
                startTime = Date()
                delay(1) {
                    self.checkCurrentAudio()
                }
                

                
            } else {
                
                setupSpeaker()
                
            }
                
           
            currentRoom?.addDelegate(self, identifier: "room")
            setupAudioOutputButton()
            current_participants = currentRoom?.participants.filter { $0.user.userId != _AppCoreData.userDataSource.value?.userID } ?? []
            current_participants.insert((currentRoom?.localParticipant!)!, at: 0)
            let flowLayout = UICollectionViewFlowLayout()
            collectionNode = ASCollectionNode(collectionViewLayout: flowLayout)
            flowLayout.minimumInteritemSpacing = 5
            flowLayout.minimumLineSpacing = 5
        
        //
            collectionNode.backgroundColor = UIColor.red
            wireDelegates()
            applyStyle()
            collectionNode.automaticallyRelayoutOnLayoutMarginsChanges = true
            contentView.addSubview(collectionNode.view)
            startCallDurationTimer()
            
        }
    


    func checkCurrentAudio() {
        let audioSession = AVAudioSession.sharedInstance()

        // Get the current audio route
        let currentRoute = audioSession.currentRoute

        // Check if the outputs array of the current route includes a .headphones type
        if currentRoute.outputs.contains(where: { $0.portType == .headphones }) {
            // Headphones are connected, use the headphones as the audio output
            do {
                try audioSession.setCategory(.playAndRecord, mode: .voiceChat, options: [.allowBluetooth, .allowBluetoothA2DP])
                try audioSession.overrideOutputAudioPort(.none)
                //setupSpeaker()
            } catch {
                print("Failed to set audio route to headphones: \(error)")
            }
        } else {
            // Headphones are not connected, use the speaker as the audio output
            do {
                try audioSession.setCategory(.playAndRecord, mode: .voiceChat, options: [.allowBluetooth, .allowBluetoothA2DP])
                try audioSession.overrideOutputAudioPort(.speaker)
                //setupSpeaker()
            } catch {
                print("Failed to set audio route to speaker: \(error)")
            }
        }
    }

    
    func setupSpeaker() {
        
        guard let output = AVAudioSession.sharedInstance().currentRoute.outputs.first else { return }
        speakerButton.setBackgroundImage(output.portType.rawValue == "BluetoothHFP" ? UIImage(named: "airpod") : .audio(output: output.portType), for: .normal)
        
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
        
        stopCallDurationTimer()
        currentRoom?.removeAllDelegates()
        self.dismiss(animated: true, completion: nil)
        
    }
    
    @IBAction func back2BtnPressed(_ sender: Any) {
        
        stopCallDurationTimer()
        currentRoom?.removeAllDelegates()
        self.dismiss(animated: true, completion: nil)
        
    }
    
    
    @IBAction func didTapAudioOption(_ sender: UIButton) {
        // Get the current audio enabled state for the local participant
        if let isAudioEnabled = currentRoom?.localParticipant?.isAudioEnabled {
            // Update the mute button image based on the current audio enabled state
            muteAudioButton.setBackgroundImage(.audio(isOn: isAudioEnabled), for: .normal)
            // If audio is enabled, mute the microphone
            if isAudioEnabled {
                currentRoom?.localParticipant?.muteMicrophone()
            // If audio is disabled, unmute the microphone
            } else {
                currentRoom?.localParticipant?.unmuteMicrophone()
            }
            // Update the first element in the current participants array with the updated local participant
            current_participants[0] = currentRoom!.localParticipant!
            // Reload the collection view to reflect the change in audio status for the local participant
            collectionNode.reloadItems(at: [IndexPath(item: 0, section: 0)])
        }
    }


    
    @IBAction func didTapEnd() {
        endButton.isEnabled = false
            currentRoom?.removeAllDelegates()
            do {
                try currentRoom?.exit()
                timeLbl.text = "Ending"
                stopCallDurationTimer()
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
        print(output.portType.rawValue)
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

// MARK: - SendBirdCalls: Groupcall duration
extension GroupCallViewController {
    func startCallDurationTimer() {
        // Get the current time and store it as the start time
           
           
           // Create a timer that updates the duration display every second
           callTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] timer in
               // Get the current time
               let currentTime = Date()
               
               // Calculate the duration by subtracting the start time from the current time
               let duration = currentTime.timeIntervalSince(startTime)
               
               // Update the duration display using the duration
               self?.updateDurationDisplay(duration: duration)
           }
    }
    
    func updateDurationDisplay(duration: TimeInterval) {
        // Use a DateComponentsFormatter to format the duration as HH:mm:ss
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.unitsStyle = .positional
        formatter.zeroFormattingBehavior = .pad
        let durationString = formatter.string(from: duration)
        
        // Update the duration label with the formatted duration
        timeLbl.text = durationString
    }

    func stopCallDurationTimer() {
        callTimer?.invalidate()
        callTimer = nil
    }


}
