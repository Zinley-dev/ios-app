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

    @IBOutlet weak var groupChannelsTableView: UITableView!
    
    @IBOutlet weak var toastView: UIView!
    @IBOutlet weak var toastMessageLabel: UILabel!
    @IBOutlet weak var emptyLabel: UILabel!
    
    var lastUpdatedToken: String? = nil
    var limit: UInt = 20
    var refreshControl: UIRefreshControl?
    var trypingIndicatorTimer: [String : Timer] = [:]
    
    var channelListQuery: SBDGroupChannelListQuery?
    
    var channels: [SBDGroupChannel] = []
    var toastCompleted: Bool = true
    var lastUpdatedTimestamp: Int64 = 0
    
    var deletedChannel: SBDGroupChannel!
  
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.groupChannelsTableView.delegate = self
        self.groupChannelsTableView.dataSource = self
        
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(InboxVC.longPressChannel(_:)))
        longPressGesture.minimumPressDuration = 0.5
        self.groupChannelsTableView.addGestureRecognizer(longPressGesture)
        
        self.updateTotalUnreadMessageCountBadge()
        
        self.loadChannelListNextPage(true)
        
        SBDMain.add(self as SBDChannelDelegate, identifier: self.description)
        SBDMain.add(self as SBDConnectionDelegate, identifier: self.description)
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl?.addTarget(self, action: #selector(InboxVC.refreshChannelList), for: .valueChanged)
        NotificationCenter.default.addObserver(self, selector: #selector(InboxVC.addHideChannel), name: (NSNotification.Name(rawValue: "addHideChannel")), object: nil)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.groupChannelsTableView.layoutIfNeeded()
        
        
    }
    
    
    @objc func longPressChannel(_ recognizer: UILongPressGestureRecognizer) {
        let point = recognizer.location(in: self.groupChannelsTableView)
        guard let indexPath = self.groupChannelsTableView.indexPathForRow(at: point) else { return }
        if recognizer.state == .began {
            let channel = self.channels[indexPath.row]
            let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            
            let actionLeave = UIAlertAction(title: "Leave message", style: .destructive) { (action) in
                channel.leave(completionHandler: { (error) in
                    if let error = error {
                        Utils.showAlertController(error: error, viewController: self)
                        return
                    }
                })
            }
            
        
            let actionNotificationOn = UIAlertAction(title: "Turn notification on", style: .default) { (action) in
               channel.setMyPushTriggerOption(.all) { error in
                    if let error = error {
                        Utils.showAlertController(error: error, viewController: self)
                        return
                    }
                }
            }
            
            let actionNotificationOff = UIAlertAction(title: "Turn notification off", style: .default) { (action) in
                channel.setMyPushTriggerOption(.off) { error in
                    if let error = error {
                        Utils.showAlertController(error: error, viewController: self)
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
        SBDMain.getTotalUnreadMessageCount { (unreadCount, error) in
            guard let navigationController = self.navigationController else { return }
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
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.5) {
            SBDMain.getTotalUnreadMessageCount { (unreadCount, error) in
                guard let navigationController = self.navigationController else { return }
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
            DispatchQueue.main.async {
                
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
            let channel = self.channels[indexPath.row]
            
            cell.setTimeStamp(channel: channel)
            
            
            let typingIndicatorText = self.buildTypingIndicatorLabel(channel: channel)
            let timer = self.trypingIndicatorTimer[channel.channelUrl]
            var showTypingIndicator = false
            if timer != nil && typingIndicatorText.count > 0 {
                showTypingIndicator = true
            }
            
            if showTypingIndicator {
                cell.lastMessageLabel.isHidden = true
                cell.typingIndicatorContainerView.isHidden = false
                cell.typingIndicatorLabel.text = typingIndicatorText
            }
            else {
                cell.lastMessageLabel.isHidden = false
                cell.typingIndicatorContainerView.isHidden = true
                if channel.lastMessage != nil {
                    if channel.lastMessage is SBDUserMessage {
                        let lastMessage = channel.lastMessage as! SBDUserMessage
                        
                        if channel.lastMessage?.sender?.userId == userUID {
                            
                            cell.lastMessageLabel.text = "You: \(lastMessage.message)"
                            
                        } else {
                            
                            if let nickname = channel.lastMessage?.sender?.nickname {
                                
                                cell.lastMessageLabel.text = "\(nickname): \(lastMessage.message)"
                                
                            }
                            
                            
                            
                        }
                        
                        
                    }
                    else if channel.lastMessage is SBDFileMessage {
                        let lastMessage = channel.lastMessage as! SBDFileMessage
                        if lastMessage.type.hasPrefix("image") {
                            
                            if channel.lastMessage?.sender?.userId == userUID {
                                
                                cell.lastMessageLabel.text = "You just sent an image"
                                
                            } else {
                                
                                if let nickname = channel.lastMessage?.sender?.nickname {
                                    
                                    cell.lastMessageLabel.text = "\(nickname): just sent an image"
                                }
                                
                                
                                
                            }
                            
                           
                        }
                        else if lastMessage.type.hasPrefix("video") {
                            
                            if channel.lastMessage?.sender?.userId == userUID {
                                
                                cell.lastMessageLabel.text = "You just sent a video"
                                
                            } else {
                                
                                if let nickname = channel.lastMessage?.sender?.nickname {
                                    
                                    
                                    cell.lastMessageLabel.text = "\(nickname): just sent a video"
                                   
                                    
                                }
                                
                                
                                
                            }
                            
                        }
                        else if lastMessage.type.hasPrefix("audio") {
                            
                            if channel.lastMessage?.sender?.userId == userUID {
                                

                                cell.lastMessageLabel.text = "You just sent an audio"
                                
                            } else {
                                
                                if let nickname = channel.lastMessage?.sender?.nickname {
                                    
                                    
                                    cell.lastMessageLabel.text = "\(nickname): just sent an audio"
                                   
                                    
                                }
                                
                                
                                
                            }
                            
                        }
                       
                    }
                    else if  channel.lastMessage is SBDAdminMessage{
                        let lastMessage = channel.lastMessage as! SBDAdminMessage
                        cell.lastMessageLabel.text = lastMessage.message
                    }
                }
                else {
                    cell.lastMessageLabel.text = "System: The message is created"
                }
            }
            
            cell.unreadMessageCountContainerView.isHidden = false
            if channel.unreadMessageCount > 99 {
                cell.unreadMessageCountLabel.text = "+99"
            }
            else if channel.unreadMessageCount > 0 {
                cell.unreadMessageCountLabel.text = String(channel.unreadMessageCount)
            }
            else {
                cell.unreadMessageCountContainerView.isHidden = true
            }
            
            if channel.memberCount <= 2 {
                cell.memberCountContainerView.isHidden = true
                cell.memberCountWidth.constant = 0.0
            }
            else {
                cell.memberCountContainerView.isHidden = false
                cell.memberCountWidth.constant = 18.0
                cell.memberCountLabel.text = String(channel.memberCount)
            }
            
            let pushOption = channel.myPushTriggerOption
            
            switch pushOption {
            case .all, .default, .mentionOnly:
                cell.notiOffIconImageView.isHidden = true
                break
            case .off:
                cell.notiOffIconImageView.isHidden = false
                break
            @unknown default:
                cell.notiOffIconImageView.isHidden = true
                break
            }

            
            if channel.isFrozen == true {
                
                cell.frozenImageView.isHidden = false
                
            } else {
                
                cell.frozenImageView.isHidden = true
            }
            
            
            DispatchQueue.main.async {
                var members: [SBDUser] = []
                var count = 0
                if let channelMembers = channel.members as? [SBDMember], let currentUser = SBDMain.getCurrentUser() {
                    for member in channelMembers {
                        if member.userId == currentUser.userId {
                            continue
                        }
                        members.append(member)
                        count += 1
                       
                    }
                }
                
                
                if let updateCell = tableView.cellForRow(at: indexPath) as? GroupChannelTableViewCell {
                    
                    
                    if channel.channelUrl.contains("challenge") {
                        
                        if let coverUrl = channel.coverUrl, coverUrl != "" {
                         
                            updateCell.profileImagView.setImage(withCoverUrl: coverUrl, shouldGetGame: true)
                            
                        }
                        
                        
                    } else {
                        
                        if members.count == 0 {
                            
                            if let coverUrl = channel.coverUrl, coverUrl != "" {
                                
                                updateCell.profileImagView.setImage(withCoverUrl: coverUrl, shouldGetGame: false)
                                
                            }
                            
                        } else if members.count == 1 {
                            
                            updateCell.profileImagView.setImage(withCoverUrl: members[0].profileUrl!, shouldGetGame: false)
                            
                        } else if members.count > 1 && members.count < 5{
                            
                            updateCell.profileImagView.users = members
                            updateCell.profileImagView.makeCircularWithSpacing(spacing: 1)
                            
                        } else {
                            
                            if let coverUrl = channel.coverUrl, coverUrl != "" {
                                
                                updateCell.profileImagView.setImage(withCoverUrl: coverUrl, shouldGetGame: false)
                                
                            }
                            
                        }
                        
                    }
                    
                    
                    
                    //
                    
                    // groupname
                    
                    if channel.name != "" && channel.name != "Group Channel" {
                        
                        updateCell.channelNameLabel.text = channel.name
                        
                    } else {
                        
                        if members.count == 0 {
                            
                            updateCell.channelNameLabel.text = "No members"
                            
                        } else if members.count == 1 {
                            
                            updateCell.channelNameLabel.text = members[0].nickname
                            
                            
                        } else if members.count > 1 {
                            
                            var count = 0
                            var name = [String]()
                            for user in members {
                                name.append(user.nickname!)
                                count += 1
                                if count == 3 {
                                    break
                                }
                            }
                            
                            
                            if members.count - name.count > 0 {
                                
                                let text = name.joined(separator: ",")
                                updateCell.channelNameLabel.text = "\(text) and \(members.count - name.count) users"
                                
                            } else {
                                
                                
                                let text = name.joined(separator: ",")
                                updateCell.channelNameLabel.text = text
                                
                            }
                
                        }
                        
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
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        
        if self.channels.count == 0 && self.toastCompleted {
            self.emptyLabel.isHidden = false
        }
        else {
            self.emptyLabel.isHidden = true
        }
        
        return self.channels.count
    }
    
    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 76
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let channel = self.channels[indexPath.row]
        let channelUrl = channel.channelUrl
        
        let channelVC = ChannelViewController(
            channelUrl: channelUrl,
            messageListParams: nil
        
        )
        
        
        self.navigationController?.pushViewController(channelVC, animated: true)
        
        
    }
   
    
    func tableView(_ tableView: UITableView,
                        willDisplay cell: UITableViewCell,
                        forRowAt indexPath: IndexPath) {
        if self.channels.count > 0,
            self.channelListQuery?.hasNext == true,
            indexPath.row == (self.channels.count - Int(self.limit)/2),
            self.channelListQuery != nil {
            
            self.loadChannelListNextPage(false)
        }
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
                leaveTypeView.backgroundColor = SBUTheme.channelListTheme.notificationOffBackgroundColor
                leaveTypeView.image = UIImage(named: "leave3x")
                leaveTypeView.contentMode = .center
                
                leaveAction.image = leaveTypeView.asImage()
                leaveAction.backgroundColor = UIColor.background
                
                
                
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
                    alarmTypeView.backgroundColor = SBUTheme.channelListTheme.notificationOnBackgroundColor
                    alarmIcon = UIImage(named: "Noti3x")!
                } else {
                    alarmTypeView.backgroundColor = SBUTheme.channelListTheme.notificationOffBackgroundColor
                    alarmIcon  = UIImage(named: "muted")!
                }
                alarmTypeView.image = alarmIcon
                alarmTypeView.contentMode = .center
                alarmTypeView.layer.cornerRadius = iconSize/2
                
                alarmAction.image = alarmTypeView.asImage()
                alarmAction.backgroundColor = UIColor.background
                
   
                return UISwipeActionsConfiguration(actions: [leaveAction, alarmAction])
                
        }
    
    // MARK: - Load channels
    @objc func refreshChannelList() {
        self.loadChannelListNextPage(true)
    }
    
    
    func loadChannelListNextPage(_ refresh: Bool) {
        if refresh {
            self.channelListQuery = nil
            self.lastUpdatedTimestamp = Int64(Date().timeIntervalSince1970*1000)
            self.channels = []
            self.lastUpdatedToken = nil
        }
        
        if self.channelListQuery == nil {
            self.channelListQuery = SBDGroupChannel.createMyGroupChannelListQuery()
            self.channelListQuery?.order = .latestLastMessage
            self.channelListQuery?.memberStateFilter = .stateFilterJoinedOnly
            self.channelListQuery?.limit = self.limit
            self.channelListQuery?.includeFrozenChannel = true
            self.channelListQuery?.includeEmptyChannel = true
            
           
            
        }
        
        if self.channelListQuery?.hasNext == false {
            return
        }
        
        self.channelListQuery?.loadNextPage(completionHandler: { (newChannels, error) in
            if error != nil {
                
                DispatchQueue.main.async {
                    self.refreshControl?.endRefreshing()
                }
                
                return
            }
            
            DispatchQueue.main.async {
                if refresh {
                    self.channels.removeAll()
                }
                           
                self.channels += newChannels!
                self.sortChannelList(needReload: true)
                self.lastUpdatedTimestamp = Int64(Date().timeIntervalSince1970*1000)
                self.refreshControl?.endRefreshing()
            }
        })
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
    }

    
    
    func deleteChannel(channel: SBDGroupChannel) {
        DispatchQueue.main.async {
            if let index = self.channels.firstIndex(of: channel as SBDGroupChannel) {
                self.channels.remove(at: index)
                self.groupChannelsTableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
            }
        }
    }
   
    
    
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return SBUChannelTheme.dark.statusBarStyle
    }
    
    // MARK: - SBDChannelDelegate
    func channel(_ sender: SBDBaseChannel, didReceive message: SBDBaseMessage) {
        
        DispatchQueue.main.async {
            
            if sender is SBDGroupChannel {
                var hasChannelInList = false
                var index = 0
                
                for ch in self.channels {
                    
                    if ch.channelUrl == sender.channelUrl {
                        self.channels.removeObject(ch)
                        self.groupChannelsTableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: .none)
                       
                        self.channels.insert(sender as! SBDGroupChannel, at: 0)
                        self.groupChannelsTableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
                        
                       
                        self.updateTotalUnreadMessageCountBadge()
                        
                        hasChannelInList = true
                        break
                    }
                    
                    index += 1
                }
                
                if hasChannelInList == false {
                    if self.shouldAddToList(channel: sender as! SBDGroupChannel) == true {
                        
                        self.channels.insert(sender as! SBDGroupChannel, at: 0)
                        self.groupChannelsTableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
                        
                        self.updateTotalUnreadMessageCountBadge()
                        
                    }
                }
            }
            
        }
        
        
    }
    

    
    func shouldAddToList(channel: SBDGroupChannel) -> Bool {
        
        return true
        
       
        
    }
    
    func channelDidUpdateTypingStatus(_ sender: SBDGroupChannel) {
        
        if sender.isTyping() == true {
            
            if sender.getTypingUsers()?.firstIndex(of: SBDMain.getCurrentUser()!) == nil {
                
                if let timer = self.trypingIndicatorTimer[sender.channelUrl] {
                    timer.invalidate()
                }
                
                let timer = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(InboxVC.typingIndicatorTimeout(_ :)), userInfo: [sender.channelUrl, sender], repeats: false)
                self.trypingIndicatorTimer[sender.channelUrl] = timer
                
                DispatchQueue.main.async {
                    
                    if let index = self.channels.firstIndex(of: sender as SBDGroupChannel) {
                        self.groupChannelsTableView.reloadRows(at:  [IndexPath(row: index, section: 0)], with: .automatic)
                    }
                    
                }
                
            }
 
        
        }
        
    }
    
    func deleteChannels(channelUrls: [String]?, needReload: Bool) {
        guard let channelUrls = channelUrls else { return }
        
        var toBeDeleteIndexes: [Int] = []
        
        for channelUrl in channelUrls {
            if let index = self.channels.firstIndex(where: { $0.channelUrl == channelUrl }) {
                toBeDeleteIndexes.append(index)
            }
        }
        
        // for remove from last
        let sortedIndexes = toBeDeleteIndexes.sorted().reversed()
        
        for toBeDeleteIdx in sortedIndexes {
            self.channels.remove(at: toBeDeleteIdx)
        }
        
        self.sortChannelList(needReload: needReload)
    }
    
    func loadChannelChangeLogs(hasMore: Bool, token: String?) {
        guard hasMore else {
            self.sortChannelList(needReload: true)
            return
        }
        
        var channelLogsParams = SBDGroupChannelChangeLogsParams()
        if let channelListQuery = self.channelListQuery {
            channelLogsParams = SBDGroupChannelChangeLogsParams.create(with: channelListQuery)
        }
        
        
        if let token = token {
            
            SBDMain.getMyGroupChannelChangeLogs(
                byToken: token,
                params: channelLogsParams
            ){ [weak self] updatedChannels, deletedChannelUrls, hasMore, token, error in
                guard let self = self else { return }
                
                
                if let error = error {
                    print(error.localizedDescription)
                }
                
                self.lastUpdatedToken = token
                
                self.upsertChannels(updatedChannels, needReload: false)
                self.deleteChannels(channelUrls: deletedChannelUrls, needReload: false)
                
                self.loadChannelChangeLogs(hasMore: hasMore, token: token)
            }
        }
        else {

            SBDMain.getMyGroupChannelChangeLogs(
                byTimestamp: self.lastUpdatedTimestamp,
                params: channelLogsParams
            ) { [weak self] updatedChannels, deletedChannelUrls, hasMore, token, error in
                guard let self = self else { return }
                
                
                if let error = error {
                    print(error.localizedDescription)
                }
                
                self.lastUpdatedToken = token
                
                
                
                self.upsertChannels(updatedChannels, needReload: false)
                self.deleteChannels(channelUrls: deletedChannelUrls, needReload: false)
                
                self.loadChannelChangeLogs(hasMore: hasMore, token: token)
            }
        }
    }
    
    
    func didSucceedReconnection() {
        self.loadChannelChangeLogs(hasMore: true, token: self.lastUpdatedToken)
    }
    
    
    func channelWasDeleted(_ channelUrl: String, channelType: SBDChannelType) {
        
        if findDeletedChannel(channelUrl: channelUrl) == true, deletedChannel != nil {
            if self.channels.contains(deletedChannel) {
                self.deleteChannel(channel: deletedChannel)
            }
        }
        
    }
    
    func findDeletedChannel(channelUrl: String) -> Bool {
        
        if self.channels.isEmpty != true {
            
            for subChannel in self.channels {
                if subChannel.channelUrl == channelUrl {
                    deletedChannel = subChannel
                    return true
                }
            }
            
            return false
            
        } else {
            return false
        }
        
     
        
    }
    
    @objc func addHideChannel() {
        
        if hideChannelToadd != nil {
            
            DispatchQueue.main.async {
                if self.channels.firstIndex(of: hideChannelToadd!) == nil {
                    
                    self.channels.insert(hideChannelToadd!, at: 0)
                    self.groupChannelsTableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
                   
                    
                    
                    
                }
                
            }
            
            
        }
        

        
    }
    
    
    func channel(_ sender: SBDGroupChannel, userDidJoin user: SBDUser) {
        DispatchQueue.main.async {
            
            let index = self.channels.firstIndex(of: sender)
                    if index == nil {
                        // Channel is not in the list.
                        if self.shouldAddToList(channel: sender) {
                            // Add channel to the list and table view.
                            self.channels.insert(sender, at: 0)
                            self.groupChannelsTableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
                        }
                    } else {
                        // Channel is already in the list.
                        self.groupChannelsTableView.reloadRows(at: [IndexPath(row: index!, section: 0)], with: .automatic)
                    }
            
        }
        

    }
    
    
    func channel(_ sender: SBDGroupChannel, userDidLeave user: SBDUser) {
        
        
        if let userUID = _AppCoreData.userDataSource.value?.userID, userUID != "" {
            
            if user.userId == userUID {
                
                self.deleteChannel(channel: sender)
                
            } else {
                
                if let index = self.channels.firstIndex(of: sender as SBDGroupChannel) {
                    self.groupChannelsTableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
                }
                
                
            }
            
            
        }
        
    }
    

    func channelWasChanged(_ sender: SBDBaseChannel) {
       
        //guard let channel = sender as? SBDGroupChannel else { return }
        guard let channel = sender as? SBDGroupChannel else { return }
        DispatchQueue.main.async {
            if let index = self.channels.firstIndex(of: channel as SBDGroupChannel) {
                self.groupChannelsTableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
            }
        }
       
    }
    
    func channel(_ sender: SBDBaseChannel, messageWasDeleted messageId: Int64) {
        
        guard let channel = sender as? SBDGroupChannel else { return }
        DispatchQueue.main.async {
            if let index = self.channels.firstIndex(of: channel as SBDGroupChannel) {
                self.groupChannelsTableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
            }
        }
        
    }
    
    func channelWasFrozen(_ sender: SBDBaseChannel) {
        guard let channel = sender as? SBDGroupChannel else { return }
        DispatchQueue.main.async {
            if let index = self.channels.firstIndex(of: channel as SBDGroupChannel) {
                self.groupChannelsTableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
            }
        }
        
    }
    
    func channelWasUnfrozen(_ sender: SBDBaseChannel) {
        guard let channel = sender as? SBDGroupChannel else { return }
        DispatchQueue.main.async {
            if let index = self.channels.firstIndex(of: channel as SBDGroupChannel) {
                self.groupChannelsTableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
            }
        }
    }
    
    func channel(_ sender: SBDBaseChannel, userWasBanned user: SBDUser) {
        if user.userId == SBUGlobals.CurrentUser?.userId {
            guard let channel = sender as? SBDGroupChannel else { return }
            self.deleteChannel(channel: channel)
        }
    }


}
