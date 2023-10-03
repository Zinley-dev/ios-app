//
//  InboxVC.swift
//  Stitchbox
//
//  Created by Khoi Nguyen on 12/16/22.
//

import UIKit
import SendBirdUIKit
import SendBirdSDK
import SendBirdCalls
//import SwiftEntryKit

class InboxVC: UIViewController, UITableViewDelegate, UITableViewDataSource, SBDChannelDelegate, SBDConnectionDelegate, GroupChannelsUpdateListDelegate, UINavigationBarDelegate, SBDUserEventDelegate, UINavigationControllerDelegate {
    
    deinit {
        print("InboxVC is being deallocated.")
        SBDMain.removeAllChannelDelegates()
        SBDMain.removeAllConnectionDelegates()
        SBDMain.removeAllUserEventDelegates()
    }


    @IBOutlet weak var groupChannelsTableView: UITableView!
    
    @IBOutlet weak var toastView: UIView!
    @IBOutlet weak var toastMessageLabel: UILabel!
    @IBOutlet weak var emptyLabel: UILabel!
    
    var inSearchMode = false
    var searchChannelList: [SBDGroupChannel] = []
    
    var lastUpdatedToken: String? = nil
    var limit: UInt = 20
    var refreshControl: UIRefreshControl?
    var trypingIndicatorTimer: [String : Timer] = [:]
    var lastRefreshDate: Date? // Stores the date of the last refresh
    var channelListQuery: SBDGroupChannelListQuery?
    
    var channels: [SBDGroupChannel] = []
    var toastCompleted: Bool = true
    var lastUpdatedTimestamp: Int64 = 0
    
    var deletedChannel: SBDGroupChannel!
  
    var firstLoad = true
    
    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.groupChannelsTableView.delegate = self
        self.groupChannelsTableView.dataSource = self
        
        // Add a long press gesture recognizer to the table view to allow the user to leave or mute channels
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(InboxVC.longPressChannel(_:)))
        longPressGesture.minimumPressDuration = 0.5
        self.groupChannelsTableView.addGestureRecognizer(longPressGesture)
        
        // Update the badge of the tab bar item that displays the total number of unread messages
        self.updateTotalUnreadMessageCountBadge()
        
        // Load the first page of channels from the server
        loadChannelListNextPage(true)
        
        // Add self as a delegate for the SBDChannel and SBDConnection classes to handle events such as incoming messages and changes in connection status
        SBDMain.add(self as SBDChannelDelegate, identifier: self.description)
        SBDMain.add(self as SBDConnectionDelegate, identifier: self.description)
        
        // Create a refresh control and add it to the table view
        self.refreshControl = UIRefreshControl()
        self.refreshControl?.addTarget(self, action: #selector(InboxVC.refreshChannelList), for: .valueChanged)
        self.refreshControl?.tintColor = .secondary
        self.groupChannelsTableView.addSubview(self.refreshControl!)
        
        
        
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Update the layout of the table view
        self.groupChannelsTableView.layoutIfNeeded()
        
        // Set the firstLoad flag to false and return if it was previously true
        if firstLoad {
            firstLoad = false
            return
        }
        // Update the active status of the channels
        updateActiveStatus()
        
        
        // Compare the current date with the last refresh date
          let timeInterval = Date().timeIntervalSince(self.lastRefreshDate ?? Date())

          // Check if it has been more than 30 minutes (1800 seconds) since the last refresh
          if timeInterval > 1800 {
              refreshChannelList()
          }
        
    }
    
    
    // MARK: - Gesture Recognizers
    
    @objc func longPressChannel(_ recognizer: UILongPressGestureRecognizer) {
        let point = recognizer.location(in: self.groupChannelsTableView)
            guard let indexPath = self.groupChannelsTableView.indexPathForRow(at: point) else { return }
            if recognizer.state == .began {
                let channel = self.channels[indexPath.row]
                let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

                let actionLeave = UIAlertAction(title: "Leave message", style: .destructive) { [weak self] (action) in
                    channel.leave(completionHandler: { (error) in
                        if let error = error {
                            if let strongSelf = self {
                                Utils.showAlertController(error: error, viewController: strongSelf)
                            }
                            return
                        }
                    })
                }

                let actionNotificationOn = UIAlertAction(title: "Turn notification on", style: .default) { [weak self] (action) in
                    channel.setMyPushTriggerOption(.all) { error in
                        if let error = error, let strongSelf = self {
                            Utils.showAlertController(error: error, viewController: strongSelf)
                            return
                        }
                    }
                }

                let actionNotificationOff = UIAlertAction(title: "Turn notification off", style: .default) { [weak self] (action) in
                    channel.setMyPushTriggerOption(.off) { error in
                        if let error = error, let strongSelf = self {
                            Utils.showAlertController(error: error, viewController: strongSelf)
                            return
                        }
                    }
                }

                let actionCancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)

                alert.modalPresentationStyle = .popover
            
            
            if channel.myPushTriggerOption == .off {
                
                
                alert.addAction(actionNotificationOn)
                
                alert.addAction(actionLeave)
                alert.addAction(actionCancel)
                
            } else if channel.myPushTriggerOption == .all {
                
                
                alert.addAction(actionNotificationOff)
                
                alert.addAction(actionLeave)
                alert.addAction(actionCancel)
                
            } else {
                
               
                alert.addAction(actionLeave)
                alert.addAction(actionCancel)
                
                
            }
        
            
            if let presenter = alert.popoverPresentationController {
                presenter.sourceView = self.view
                presenter.sourceRect = CGRect(x: self.view.bounds.minX, y: self.view.bounds.maxY, width: 0, height: 0)
                presenter.permittedArrowDirections = []
            }
            
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    
    func updateTotalUnreadMessageCountBadge() {
        SBDMain.getTotalUnreadMessageCount { [weak self] (unreadCount, error) in
            guard let navigationController = self?.navigationController else { return }
            if error != nil {
                navigationController.tabBarItem.badgeValue = nil
                return
            }
            
            if unreadCount > 0 {
                navigationController.tabBarItem.badgeValue = String(format: "%ld", unreadCount)
            }
            else {
                navigationController.tabBarItem.badgeValue = nil
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.5) { [weak self] in
            SBDMain.getTotalUnreadMessageCount { (unreadCount, error) in
                guard let navigationController = self?.navigationController else { return }
                if error != nil {
                    navigationController.tabBarItem.badgeValue = nil
                    return
                }
                
                if unreadCount > 0 {
                    navigationController.tabBarItem.badgeValue = String(format: "%ld", unreadCount)
                }
                else {
                    navigationController.tabBarItem.badgeValue = nil
                }
            }
        }
    }

    
    func buildTypingIndicatorLabel(channel: SBDGroupChannel) -> String {
        let typingMembers = channel.getTypingUsers()
        if typingMembers == nil || typingMembers?.count == 0 {
            return ""
        }
        else {
            return "Typing"
        }
    }
    
    @objc func typingIndicatorTimeout(_ timer: Timer) {
        if let channelUrl = timer.userInfo as? [Any] {
            self.trypingIndicatorTimer[channelUrl[0] as! String]?.invalidate()
            self.trypingIndicatorTimer.removeValue(forKey: channelUrl[0] as! String)
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                if let index = self.channels.firstIndex(of: channelUrl[1] as! SBDGroupChannel) {
                    self.groupChannelsTableView.reloadRows(at:  [IndexPath(row: index, section: 0)], with: .automatic)
                }
            }
        }
    }

    
    
    // MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let userUID = _AppCoreData.userDataSource.value?.userID, userUID != "" {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "GroupChannelTableViewCell") as! GroupChannelTableViewCell
            
            let array = inSearchMode ? searchChannelList : channels
            let channel = array[indexPath.row]
            

            cell.setTimeStamp(channel: channel)

            let typingIndicatorText = self.buildTypingIndicatorLabel(channel: channel)
            let showTypingIndicator = self.trypingIndicatorTimer[channel.channelUrl] != nil && !typingIndicatorText.isEmpty

            cell.lastMessageLabel.isHidden = showTypingIndicator
            cell.typingIndicatorContainerView.isHidden = !showTypingIndicator
            cell.typingIndicatorLabel.text = typingIndicatorText

            if let lastMessage = channel.lastMessage {
                let isSender = lastMessage.sender?.userId == userUID
                let nickname = lastMessage.sender?.nickname

                if let userMessage = lastMessage as? SBDUserMessage {
                    cell.lastMessageLabel.text = isSender ? "You: \(userMessage.message)" : "\(nickname ?? ""): \(userMessage.message)"
                } else if let fileMessage = lastMessage as? SBDFileMessage {
                    let fileType = fileMessage.type.prefix(5)
                    if fileType == "image" {
                        cell.lastMessageLabel.text = isSender ? "You just sent an image" : "\(nickname ?? ""): just sent an image"
                    } else if fileType == "video" {
                        cell.lastMessageLabel.text = isSender ? "You just sent a video" : "\(nickname ?? ""): just sent a video"
                    } else if fileType == "audio" {
                        cell.lastMessageLabel.text = isSender ? "You just sent an audio file" : "\(nickname ?? ""): just sent an audio file"
                    } else {
                        cell.lastMessageLabel.text = fileMessage.name
                    }
                }
            } else {
                cell.lastMessageLabel.text = "You just have joined the channel"
            }

            if channel.unreadMessageCount > 0 {
                cell.unreadMessageCountContainerView.isHidden = false
                cell.unreadMessageCountLabel.text = (channel.unreadMessageCount > 99) ? "+99" : String(channel.unreadMessageCount)
                cell.lastMessageLabel.textColor = UIColor.black
            } else {
                cell.unreadMessageCountContainerView.isHidden = true
                cell.lastMessageLabel.textColor = UIColor.darkGray
            }

            if channel.memberCount > 2 {
                cell.memberCountContainerView.isHidden = false
                cell.memberCountWidth.constant = 18.0
                cell.memberCountLabel.text = String(channel.memberCount)
            } else {
                cell.memberCountContainerView.isHidden = true
                cell.memberCountWidth.constant = 0.0
            }

            
            let pushOption = channel.myPushTriggerOption
                        
                        switch pushOption {
                        case .all, .default, .mentionOnly:
                            cell.notiOffIconImageView.isHidden = true
                            cell.notiOffIconImageView.image = SBUIconSet.iconNotificationFilled.resize(targetSize: CGSize(width: 12, height: 12)).withTintColor(UIColor.black)
                           
                            break
                        case .off:
                            cell.notiOffIconImageView.isHidden = false
                            cell.notiOffIconImageView.image = SBUIconSet.iconNotificationOffFilled.resize(targetSize: CGSize(width: 12, height: 12)).withTintColor(UIColor.black)
                           
                            break
                        @unknown default:
                            cell.notiOffIconImageView.isHidden = true
                            cell.notiOffIconImageView.image = SBUIconSet.iconNotificationOffFilled.resize(targetSize: CGSize(width: 12, height: 12)).withTintColor(UIColor.black)
                    
                            break
                        }
            
            
            cell.frozenImageView.isHidden = !channel.isFrozen
            cell.frozenImageView.image = SBUIconSet.iconFreeze.resize(targetSize: CGSize(width: 20, height: 20)).withTintColor(UIColor.black)

            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                if let members = channel.members {
                    let filteredMembers = members.compactMap { $0 as? SBDMember }.filter { $0.userId != SBDMain.getCurrentUser()?.userId }
                    let count = filteredMembers.count
                    let updateCell = tableView.cellForRow(at: indexPath) as? GroupChannelTableViewCell
                    
                    
                    if channel.coverUrl != nil, !(channel.coverUrl?.contains("sendbird"))! {
                        
                        updateCell?.profileImagView.setImage(withCoverUrl: channel.coverUrl!)
                        
                    } else {
                        
                        if count == 0 {
                            updateCell?.profileImagView.setImage(withCoverUrl: channel.coverUrl!)
                        } else if count == 1 {
                            updateCell?.profileImagView.setImage(withCoverUrl: filteredMembers[0].profileUrl!)
                        } else if count > 1 && count < 5 {
                            updateCell?.profileImagView.users = filteredMembers
                            updateCell?.profileImagView.makeCircularWithSpacing(spacing: 1)
                        } else {
                            updateCell?.profileImagView.setImage(withCoverUrl: channel.coverUrl!)
                        }
                        
                    }
                    
                    
                    
                    if channel.name != "" && channel.name != "Group Channel" {
                        updateCell?.channelNameLabel.text = channel.name
                    } else {
                        
                        let names = filteredMembers.prefix(3).map { $0.nickname ?? "" }
                        
                        if count > 3 {
                            updateCell?.channelNameLabel.text = "\(names.joined(separator: ",")) and \(count - 3) users"
                        } else {
                            
                            updateCell?.channelNameLabel.text = names.joined(separator: ",")
                        }
                    }
                    
                    if count == 0 {
                        updateCell?.activeView.backgroundColor = .lightGray
                    } else {
                        updateCell?.activeView.backgroundColor = filteredMembers.contains(where: { $0.connectionStatus.rawValue == 1 }) ? .green : .lightGray
                    }

                    
                    
                }
            }
            
            if self.channels.count > 0 && indexPath.row == self.channels.count - 1 {
                self.loadChannelListNextPage(false)
            }
            
            
            return cell
            
            
        } else {
            return UITableViewCell()
        }
        
    }
    
    func updateActiveStatus() {
     
        // Filter the channels array to include only channels with members
        let channelsWithMembers = channels.filter { $0.members != nil }
        // Iterate over the filtered array
        for channel in channelsWithMembers {
            channel.refresh()
            // Get the members of the channel and filter out the current user
            let filteredMembers = channel.members!.compactMap { $0 as? SBDMember }.filter { $0.userId != SBDMain.getCurrentUser()?.userId }
            // Get the index of the channel in the original array
            if let index = channels.firstIndex(of: channel) {
                // Get the cell at the index of the channel
                if let updateCell = groupChannelsTableView.cellForRow(at: IndexPath(row: index, section: 0)) as? GroupChannelTableViewCell {
                    // Check if there are any active members in the channel
                    let hasActiveMember = filteredMembers.contains(where: { $0.connectionStatus.rawValue == 1 })
                    // Update the background color of the active view based on the active status of the members
                    updateCell.activeView.backgroundColor = hasActiveMember ? .green : .lightGray
                }
            }
        }
        
    }
    
    



    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let array = inSearchMode ? searchChannelList : channels
        emptyLabel.isHidden = array.count > 0
        return array.count
    }
    
    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 76
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let channel = inSearchMode ? searchChannelList[indexPath.row] : channels[indexPath.row]
        let mslp = SBDMessageListParams()
        
        let channelVC = ChannelViewController(channelUrl: channel.channelUrl, messageListParams: mslp)
        
        let nav = UINavigationController(rootViewController: channelVC)

     
        // Customize the navigation bar appearance
        nav.navigationBar.barTintColor = .white
        nav.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.black]

        nav.modalPresentationStyle = .fullScreen
 
       // self.navigationController?.pushViewController(channelVC, animated: true)
        nav.modalPresentationStyle = .fullScreen
        self.present(nav, animated: true)
         
    }

    
    func tableView(_ tableView: UITableView,
                        willDisplay cell: UITableViewCell,
                        forRowAt indexPath: IndexPath) {
        guard !channels.isEmpty, let channelListQuery = channelListQuery, channelListQuery.hasNext, indexPath.row == channels.count - Int(limit)/2 else { return }
            loadChannelListNextPage(false)
    }
    
    
    func tableView(_ tableView: UITableView,
                            trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath)
            -> UISwipeActionsConfiguration? {
                
                let index = indexPath.row
                let channel = self.channels[index]
                let size = tableView.visibleCells[0].frame.height
                let iconSize: CGFloat = 40.0
                
                let leaveAction = UIContextualAction(
                    style: .normal,
                    title: ""
                ) { action, view, actionHandler in
                    
                    self.channels[indexPath.row].leave(completionHandler: { (error) in
                        if let error = error {
                            Utils.showAlertController(error: error, viewController: self)
                            print(error.localizedDescription, error.code)
                            return
                        }
                        
                        
                    })
                    
                    actionHandler(true)
                }
                
                let leaveTypeView = UIImageView(
                    frame: CGRect(
                        x: (size-iconSize)/2,
                        y: (size-iconSize)/2,
                        width: iconSize,
                        height: iconSize
                ))
                leaveTypeView.layer.cornerRadius = iconSize/2
                leaveTypeView.backgroundColor = UIColor.normalButtonBackground
                leaveTypeView.image = SBUIconSet.iconLeave.resize(targetSize: CGSize(width: 20, height: 20)).withTintColor(UIColor.black)
                leaveTypeView.contentMode = .center
                
                leaveAction.image = leaveTypeView.asImage()
                leaveAction.backgroundColor = .white
                
                
                
                let pushOption = channel.myPushTriggerOption
                let alarmAction = UIContextualAction(
                    style: .normal,
                    title: ""
                ) { action, view, actionHandler in
                    if self.channels[indexPath.row].myPushTriggerOption == .off {
                        
                        self.channels[indexPath.row].setMyPushTriggerOption(.all) { error in
                            if let error = error {
                                Utils.showAlertController(error: error, viewController: self)
                                return
                            }
                        }
                        
                    } else {
                        
                        
                        self.channels[indexPath.row].setMyPushTriggerOption(.off) { error in
                            if let error = error {
                                Utils.showAlertController(error: error, viewController: self)
                                return
                            }
                        }
                        
                        
                    }
                            
                    actionHandler(true)
                }
                
                let alarmTypeView = UIImageView(
                    frame: CGRect(
                        x: (size-iconSize)/2,
                        y: (size-iconSize)/2,
                        width: iconSize,
                        height: iconSize
                ))
                let alarmIcon: UIImage
                
                if pushOption == .off {
                    alarmTypeView.backgroundColor = UIColor.normalButtonBackground
                    alarmIcon = SBUIconSet.iconNotificationFilled.resize(targetSize: CGSize(width: 20, height: 20)).withTintColor(UIColor.black)
                  
                    
                } else {
                    alarmTypeView.backgroundColor = UIColor.normalButtonBackground
                    alarmIcon  =  SBUIconSet.iconNotificationOffFilled.resize(targetSize: CGSize(width: 20, height: 20)).withTintColor(UIColor.black)
                }
                alarmTypeView.image = alarmIcon
                alarmTypeView.contentMode = .center
                alarmTypeView.layer.cornerRadius = iconSize/2
                
                alarmAction.image = alarmTypeView.asImage()
                alarmAction.backgroundColor = .white
                
   
                return UISwipeActionsConfiguration(actions: [leaveAction, alarmAction])
                
        }
    
    // MARK: - Load channels
    @objc func refreshChannelList() {
        self.lastRefreshDate = Date()
        self.loadChannelListNextPage(true)
    }
    
    
    func loadChannelListNextPage(_ refresh: Bool) {
        if refresh {
            channelListQuery = nil
            lastUpdatedTimestamp = Int64(Date().timeIntervalSince1970*1000)
            channels = []
            lastUpdatedToken = nil
        }
        
        if self.channelListQuery == nil {
            channelListQuery = SBDGroupChannel.createMyGroupChannelListQuery()
            channelListQuery?.order = .latestLastMessage
            channelListQuery?.memberStateFilter = .stateFilterJoinedOnly
            channelListQuery?.limit = self.limit
            channelListQuery?.includeFrozenChannel = true
            channelListQuery?.includeEmptyChannel = true
        }
        
        guard let query = self.channelListQuery, query.hasNext else {
            return
        }
        
        query.loadNextPage { [weak self] (newChannels, error) in
            guard let self = self else { return }
            
            if let error = error {
                print("Failed to load next page: \(error)")
                DispatchQueue.main.async {
                    self.refreshControl?.endRefreshing()
                }
                return
            }
            
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                if refresh {
                    self.channels.removeAll()
                }
                
                if let newChannels = newChannels {
                    self.channels += newChannels
                    self.sortChannelList(needReload: true)
                    self.lastUpdatedTimestamp = Int64(Date().timeIntervalSince1970*1000)
                }
                self.refreshControl?.endRefreshing()
            }
            
        }
    }

    
    
    func upsertChannels(_ channels: [SBDGroupChannel]?, needReload: Bool) {
        guard let newChannels = channels else { return }

            // Filter new channels based on the channel list query.
            let filteredChannels = newChannels.filter {
                self.channelListQuery?.belongs(to: $0) == true &&
                ($0.lastMessage != nil || self.channelListQuery?.includeEmptyChannel == true)
            }

            // Find the indices of the new channels in the current list of channels.
            let indices = filteredChannels.map { self.channels.firstIndex(of: $0) }

            // Create a dictionary mapping the new channels to their indices.
            let channelsDict = Dictionary(uniqueKeysWithValues: zip(filteredChannels, indices))

            // Remove the channels that are already in the list.
            let channelsToAdd = filteredChannels.filter { channelsDict[$0] == nil }

            // Add the new channels to the list.
            self.channels += channelsToAdd

            // Sort the list of channels.
            self.sortChannelList(needReload: needReload)
    }

    
    func sortChannelList(needReload: Bool) {
        let sortedChannels = channels.sorted {
            let createdAt1 = $0.lastMessage?.createdAt ?? -1
            let createdAt2 = $1.lastMessage?.createdAt ?? -1
            if createdAt1 == -1 && createdAt2 == -1 {
                return Int64($0.createdAt * 1000) > Int64($1.createdAt * 1000)
            } else {
                return createdAt1 > createdAt2
            }
        }
        channels = sortedChannels.sbu_unique()
        
        if needReload {
            DispatchQueue.main.async {
                self.groupChannelsTableView.reloadSections([0], with: .automatic)
            }
        }
        
        self.lastRefreshDate = Date()
    }

    
    
    func deleteChannel(channel: SBDGroupChannel) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            if let index = self.channels.firstIndex(of: channel as SBDGroupChannel) {
                self.channels.remove(at: index)
                self.groupChannelsTableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
            }
        }
    }
   
    
    
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return SBUChannelTheme.dark.statusBarStyle
    }
    
    func channel(_ sender: SBDBaseChannel, didReceive message: SBDBaseMessage) {
        
        guard let sender = sender as? SBDGroupChannel, channels.contains(sender) else { return }
        
        if message.customType == "SENDBIRD:AUTO_EVENT_MESSAGE" {
            
            if channels.contains(sender) {
                
                groupChannelsTableView?.reloadRows(at: [IndexPath(row: channels.firstIndex(of: sender)!, section: 0)], with: .automatic)
                
            } else {
                
                self.channels.insert(sender, at: 0)
                self.groupChannelsTableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
                
            }
              
            
        } else {
            
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                var index: Int?
                for (i, ch) in self.channels.enumerated() {
                    if ch.channelUrl == sender.channelUrl {
                        index = i
                        break
                    }
                }
                if let index = index {
                    self.channels.remove(at: index)
                    self.groupChannelsTableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: .none)
                }
                self.channels.insert(sender, at: 0)
                self.groupChannelsTableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
                self.updateTotalUnreadMessageCountBadge()
            }

            
        }
        
        checkIfShouldPushNoti(pushChannel: sender)
        
        
    }
    
    
    func checkIfShouldPushNoti(pushChannel: SBDGroupChannel) {
        // Check if push notifications are enabled for the group channel
        if pushChannel.myPushTriggerOption != .off, let lastMessage = pushChannel.lastMessage?.message {
            // Get the current view controller
            if let vc = UIViewController.currentViewController() {
                // Check the type of the current view controller
                switch vc {
                case let channelVC as ChannelViewController:
                    // Check if the channelUrl property of the view controller is the same as the channelUrl property of the group channel
                    if channelVC.channelUrl != pushChannel.channelUrl {
                        createLocalNotificationForActiveSendbirdUsers(title: "", body: lastMessage, channel: pushChannel)
                    }
                case let mainMessageVC as MainMessageVC:
                    // Check if the InboxVC view is hidden
                    if mainMessageVC.InboxVC.view.isHidden {
                        createLocalNotificationForActiveSendbirdUsers(title: "", body: lastMessage, channel: pushChannel)
                    }
                default:
                    // If the current view controller is neither a ChannelViewController nor a MainMessageVC, create a local notification
                    createLocalNotificationForActiveSendbirdUsers(title: "", body: lastMessage, channel: pushChannel)
                }
            }
        }
    }

    
    
    func channelDidUpdateTypingStatus(_ sender: SBDGroupChannel) {
        guard sender.isTyping(), let currentUser = SBDMain.getCurrentUser(), sender.getTypingUsers()?.firstIndex(of: currentUser) == nil else { return }
        let timerKey = sender.channelUrl
        invalidateTimer(for: timerKey)
        let timer = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(InboxVC.typingIndicatorTimeout(_ :)), userInfo: [timerKey, sender] as [Any], repeats: false)
        trypingIndicatorTimer[timerKey] = timer
        let index = channels.firstIndex { $0.channelUrl == sender.channelUrl }
        guard let row = index else { return }
        groupChannelsTableView.reloadRows(at: [IndexPath(row: row, section: 0)], with: .automatic)
    }
    
    func invalidateTimer(for key: String) {
        if let timer = trypingIndicatorTimer[key] {
            timer.invalidate()
            trypingIndicatorTimer[key] = nil
        }
    }

    
    func deleteChannels(channelUrls: [String]?, needReload: Bool) {
        guard let channelUrls = channelUrls else { return }
        channels = channels.filter { !channelUrls.contains($0.channelUrl) }
        sortChannelList(needReload: needReload)

    }
    
    func loadChannelChangeLogs(hasMore: Bool, token: String?) {
        guard hasMore else {
            return
        }

        var channelLogsParams = SBDGroupChannelChangeLogsParams()
        if let channelListQuery = self.channelListQuery {
            channelLogsParams = SBDGroupChannelChangeLogsParams.create(with: channelListQuery)
        }

        let getMyGroupChannelChangeLogs: (String?, SBDGroupChannelChangeLogsParams) -> Void = { [weak self] token, channelLogsParams in
            SBDMain.getMyGroupChannelChangeLogs(byToken: token, params: channelLogsParams) { updatedChannels, deletedChannelUrls, hasMore, token, error in
                if let error = error {
                    print(error.localizedDescription)
                }

                guard let self = self else { return }
                
                self.lastUpdatedToken = token
                self.upsertChannels(updatedChannels, needReload: false)
                self.deleteChannels(channelUrls: deletedChannelUrls, needReload: false)
                self.loadChannelChangeLogs(hasMore: hasMore, token: token)
            }
        }

        self.lastRefreshDate = Date()
        getMyGroupChannelChangeLogs(token, channelLogsParams)
    }


    
    
    func didSucceedReconnection() {
        self.loadChannelChangeLogs(hasMore: true, token: self.lastUpdatedToken)
    }
    
    
    func channelWasDeleted(_ channelUrl: String, channelType: SBDChannelType) {
        if channelType == .group, let deletedChannel = findDeletedChannel(channelUrl: channelUrl), channels.contains(deletedChannel) {
            deleteChannel(channel: deletedChannel)
        }
    }
    
    func findDeletedChannel(channelUrl: String) -> SBDGroupChannel? {
        if !channels.isEmpty {
            for subChannel in channels {
                if subChannel.channelUrl == channelUrl {
                    deletedChannel = subChannel
                    return deletedChannel
                }
            }
        }

        return nil
    }

    
    
    func channel(_ sender: SBDGroupChannel, userDidJoin user: SBDUser) {
        DispatchQueue.main.async {
            if !self.channels.contains(sender) {
                self.channels.insert(sender, at: 0)
                self.groupChannelsTableView?.insertRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
            } else {
                self.groupChannelsTableView?.reloadRows(at: [IndexPath(row: self.channels.firstIndex(of: sender)!, section: 0)], with: .automatic)
            }
        }
    }
    
    
    func channel(_ sender: SBDGroupChannel, userDidLeave user: SBDUser) {
        if let userUID = _AppCoreData.userDataSource.value?.userID, !userUID.isEmpty, user.userId == userUID, channels.contains(sender as SBDGroupChannel) {
            deleteChannel(channel: sender)
        } else if let index = channels.firstIndex(of: sender as SBDGroupChannel) {
            groupChannelsTableView?.reloadRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
        }
    }

    

    func channelWasChanged(_ sender: SBDBaseChannel) {
        self.sortChannelList(needReload: true)
    }

    
    func channel(_ sender: SBDBaseChannel, messageWasDeleted messageId: Int64) {
        guard let sender = sender as? SBDGroupChannel, channels.contains(sender) else { return }
        groupChannelsTableView?.reloadRows(at: [IndexPath(row: channels.firstIndex(of: sender)!, section: 0)], with: .automatic)
    }

    
    func channelWasFrozen(_ sender: SBDBaseChannel) {
        guard let sender = sender as? SBDGroupChannel, channels.contains(sender) else { return }
        groupChannelsTableView?.reloadRows(at: [IndexPath(row: channels.firstIndex(of: sender)!, section: 0)], with: .automatic)
    }

    func channelWasUnfrozen(_ sender: SBDBaseChannel) {
        guard let sender = sender as? SBDGroupChannel, channels.contains(sender) else { return }
        groupChannelsTableView?.reloadRows(at: [IndexPath(row: channels.firstIndex(of: sender)!, section: 0)], with: .automatic)
    }

    func channel(_ sender: SBDBaseChannel, userWasBanned user: SBDUser) {
        guard let sender = sender as? SBDGroupChannel, user.userId == SBUGlobals.CurrentUser?.userId else { return }
        deleteChannel(channel: sender)
    }


}
