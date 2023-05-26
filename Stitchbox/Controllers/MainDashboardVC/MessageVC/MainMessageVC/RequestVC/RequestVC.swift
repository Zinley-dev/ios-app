//
//  RequestVC.swift
//  Stitchbox
//
//  Created by Khoi Nguyen on 12/16/22.
//

import UIKit
import SendBirdUIKit
import SendBirdCalls

class RequestVC: UIViewController, UITableViewDelegate, UITableViewDataSource, SBDChannelDelegate, SBDConnectionDelegate, GroupChannelsUpdateListDelegate, UINavigationBarDelegate {

    @IBOutlet weak var groupChannelsTableView: UITableView!
    
    
    @IBOutlet weak var toastView: UIView!
    @IBOutlet weak var toastMessageLabel: UILabel!
    @IBOutlet weak var emptyLabel: UILabel!
    var limit: UInt = 20
    var refreshControl: UIRefreshControl?
   
    
    var channelListQuery: SBDGroupChannelListQuery?
    var channels: [SBDGroupChannel] = []
    var toastCompleted: Bool = true
    
    var inSearchMode = false
    var searchChannelList: [SBDGroupChannel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        SBDMain.add(self as SBDChannelDelegate, identifier: self.description)
        SBDMain.add(self as SBDConnectionDelegate, identifier: self.description)
    
        
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(InboxVC.longPressChannel(_:)))
        longPressGesture.minimumPressDuration = 1.0
        self.groupChannelsTableView.addGestureRecognizer(longPressGesture)
        
        self.groupChannelsTableView.delegate = self
        self.groupChannelsTableView.dataSource = self
        
        
        self.loadChannelListNextPage(true)
        
    }
    

    func showToast(message: String, completion: (() -> Void)?) {
        self.toastCompleted = false
        self.toastView.alpha = 1
        self.toastMessageLabel.text = message
        self.toastView.isHidden = false
        
        UIView.animate(withDuration: 0.5, delay: 0.5, options: .curveEaseIn, animations: {
            self.toastView.alpha = 0
        }) { (finished) in
            self.toastView.isHidden = true
            self.toastCompleted = true
            
            completion?()
        }
    }
    
    
    @objc func longPressChannel(_ recognizer: UILongPressGestureRecognizer) {
        let point = recognizer.location(in: self.groupChannelsTableView)
        guard let indexPath = self.groupChannelsTableView.indexPathForRow(at: point) else { return }
        if recognizer.state == .began {
            let channel = self.channels[indexPath.row]
            let alert = UIAlertController(title: Utils.createGroupChannelName(channel: channel), message: nil, preferredStyle: .actionSheet)
            
            let actionLeave = UIAlertAction(title: "Leave message", style: .destructive) { (action) in
                
                channel.declineInvitation(completionHandler: { (error) in
                    if let error = error {
                        Utils.showAlertController(error: error, viewController: self)
                        return
                    }
      
                })
                
            }
            
            let actionCancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            
            alert.modalPresentationStyle = .popover
            alert.addAction(actionLeave)
            alert.addAction(actionCancel)
            
            if let presenter = alert.popoverPresentationController {
                presenter.sourceView = self.view
                presenter.sourceRect = CGRect(x: self.view.bounds.minX, y: self.view.bounds.maxY, width: 0, height: 0)
                presenter.permittedArrowDirections = []
            }
            
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    
    // MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        if let userUID = _AppCoreData.userDataSource.value?.userID, userUID != "" {
            
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "GroupChannelTableViewCell") as! GroupChannelTableViewCell
            let array = inSearchMode ? searchChannelList : channels
            let channel = array[indexPath.row]

            let lastMessageDateFormatter = DateFormatter()
            let currDate = Date()
            let lastUpdatedAt: Int64 = channel.lastMessage?.createdAt != nil ? channel.lastMessage!.createdAt : Int64(channel.createdAt)
            let lastMessageDate = Date(timeIntervalSince1970: Double(lastUpdatedAt / 1000))
            let lastMessageDateComponents = Calendar.current.dateComponents([.day, .month, .year], from: lastMessageDate)
            let currDateComponents = Calendar.current.dateComponents([.day, .month, .year], from: currDate)

            /*
            if lastMessageDateComponents.year != currDateComponents.year || lastMessageDateComponents.month != currDateComponents.month || lastMessageDateComponents.day != currDateComponents.day {
                lastMessageDateFormatter.dateStyle = .short
                lastMessageDateFormatter.timeStyle = .none
                cell.lastUpdatedDateLabel.text = ""
                print(timeForChat(lastMessageDate, numericDates: true))
            } else {
                lastMessageDateFormatter.dateStyle = .none
                lastMessageDateFormatter.timeStyle = .short
                cell.lastUpdatedDateLabel.text = lastMessageDateFormatter.string(from: lastMessageDate)
                print(lastMessageDateFormatter.string(from: lastMessageDate))
            }*/

            cell.typingIndicatorContainerView.isHidden = true
            cell.notiOffIconImageView.isHidden = true

            if let inviter = channel.getInviter()?.nickname {
                cell.lastMessageLabel.text = "You was invited to join by \(inviter)"
            } else {
                cell.lastMessageLabel.text = ""
            }

            cell.unreadMessageCountContainerView.isHidden = false
            if channel.unreadMessageCount > 99 {
                cell.unreadMessageCountLabel.text = "+99"
                cell.lastMessageLabel.textColor = UIColor.white
            } else if channel.unreadMessageCount > 0 {
                cell.unreadMessageCountLabel.text = String(channel.unreadMessageCount)
                cell.lastMessageLabel.textColor = UIColor.white
            } else {
                cell.unreadMessageCountContainerView.isHidden = true
                cell.lastMessageLabel.textColor = UIColor.lightGray
            }

            if channel.memberCount <= 2 {
                cell.memberCountContainerView.isHidden = true
                cell.memberCountWidth.constant = 0.0
            } else {
                cell.memberCountContainerView.isHidden = false
                cell.memberCountWidth.constant = 18.0
                cell.memberCountLabel.text = String(channel.memberCount)
            }

            
            DispatchQueue.main.async {
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
                } else {
                    // Handle the
                    
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
        let channelVC = RequestChannelVC(channelUrl: channel.channelUrl, messageListParams: nil)
        hideMiddleBtn(vc: self)
        channelVC.shouldUnhide = true
        self.navigationController?.pushViewController(channelVC, animated: true)

        
    }
    
    func tableView(_ tableView: UITableView,
                            trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath)
            -> UISwipeActionsConfiguration? {
                
                //let index = indexPath.row
                let size = tableView.visibleCells[0].frame.height
                let iconSize: CGFloat = 40.0
                
                let hideAction = UIContextualAction(
                    style: .normal,
                    title: ""
                ) { action, view, actionHandler in
                    
                    
                     if let inviterUID = self.channels[indexPath.row].getInviter()?.userId {
                         
                         self.performAcceptAPIRequest(channel: self.channels[indexPath.row].channelUrl, inviterUID: inviterUID)
         
                     }
                    
                    actionHandler(true)
                }
                
                let hideTypeView = UIImageView(
                    frame: CGRect(
                        x: (size-iconSize)/2,
                        y: (size-iconSize)/2,
                        width: iconSize,
                        height: iconSize
                ))
                hideTypeView.layer.cornerRadius = iconSize/2
                hideTypeView.backgroundColor = .primary
                hideTypeView.image = UIImage(named: "hide3x")
                hideTypeView.contentMode = .center
                
                hideAction.image = hideTypeView.asImage()
                hideAction.backgroundColor = UIColor.background
                
                let leaveAction = UIContextualAction(
                    style: .normal,
                    title: ""
                ) { action, view, actionHandler in
                    
                    self.channels[indexPath.row].declineInvitation(completionHandler: { (error) in
                        if let error = error {
                            Utils.showAlertController(error: error, viewController: self)
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
                leaveTypeView.backgroundColor = .primary
                leaveTypeView.image = UIImage(named: "leave3x")!.resize(targetSize: CGSize(width: 20, height: 20))
                leaveTypeView.contentMode = .center
                
                leaveAction.image = leaveTypeView.asImage()
                leaveAction.backgroundColor = UIColor.background
                
                    
                return UISwipeActionsConfiguration(actions: [leaveAction, hideAction])
                
                     
        }
    
    func performAcceptAPIRequest(channel: String, inviterUID: String) {
        
        APIManager.shared.acceptSBInvitationRequest(user_id: inviterUID, channelUrl: channel) { result in
            switch result {
            case .success(let apiResponse):
                // Check if the request was successful
                guard apiResponse.body?["message"] as? String == "success" else {
                    return
                }
                
            case .failure(let error):
                print(error)
            }
        }
        
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
    
    // MARK: - Load channels
    @objc func refreshChannelList() {
        self.loadChannelListNextPage(true)
    }
    
    func loadChannelListNextPage(_ refresh: Bool) {
        if refresh {
            channelListQuery = nil
        }
        
        guard channelListQuery == nil else { return }
        
        channelListQuery = SBDGroupChannel.createMyGroupChannelListQuery()
        channelListQuery?.order = .latestLastMessage
        channelListQuery?.memberStateFilter = .stateFilterInvitedOnly
        channelListQuery?.limit = limit
        channelListQuery?.includeFrozenChannel = true
        channelListQuery?.includeEmptyChannel = true
        
        guard let query = channelListQuery, query.hasNext else { return }
        
        query.loadNextPage { channels, error in
            guard error == nil, let channels = channels else {
                DispatchQueue.main.async {
                    self.refreshControl?.endRefreshing()
                }
                return
            }
            
            DispatchQueue.main.async {
                if refresh {
                    self.channels.removeAll()
                }
                self.channels += channels
                self.sortChannelList(needReload: true)
                self.refreshControl?.endRefreshing()
            }
        }
    }

    
    /// This function sorts the channel lists.
    /// - Parameter needReload: If set to `true`, the tableview will be call reloadData.
    /// - Since: 1.2.5
    public func sortChannelList(needReload: Bool) {
       
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
    
    func updateChannels(_ channels: [SBDGroupChannel]?, needReload: Bool) {
        guard let channels = channels, let query = channelListQuery else { return }
        
        let updatedChannels = channels.filter { query.belongs(to: $0) && self.channels.contains($0) }
        self.channels = self.channels.filter { !updatedChannels.contains($0) } + updatedChannels
        sortChannelList(needReload: needReload)
    }

    
    /// This function upserts the channels.
    ///
    /// If the channels are already in the list, it is updated, otherwise it is inserted.
    /// And, after upserting the channels, a function to sort the channel list is called.
    /// - Parameters:
    ///   - channels: Channel array to upsert
    ///   - needReload: If set to `true`, the tableview will be call reloadData.
    /// - Since: 1.2.5
    func upsertChannels(_ channels: [SBDGroupChannel]?, needReload: Bool) {
        guard let channels = channels else { return }
        
        for channel in channels {
            guard self.channelListQuery?.belongs(to: channel) == true else { continue }
            let includeEmptyChannel = self.channelListQuery?.includeEmptyChannel ?? false
            guard (channel.lastMessage != nil || includeEmptyChannel) else { continue }
            guard let index = self.channels.firstIndex(of: channel) else {
                self.channels.append(channel)
                
                continue
            }
            
            self.channels.append(self.channels.remove(at: index))
                 
        }
        self.sortChannelList(needReload: needReload)
    }
    
    
    func deleteChannels(channelUrls: [String]?, needReload: Bool) {
        guard let channelUrls = channelUrls else { return }
        self.channels.removeAll(where: { channelUrls.contains($0.channelUrl) })
        sortChannelList(needReload: needReload)
    }
   
    
    // MARK: - GroupChannelsUpdateListDelegate
    func updateGroupChannelList() {
        DispatchQueue.main.async {
            self.groupChannelsTableView.reloadData()
        }
        
       
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return SBUChannelTheme.dark.statusBarStyle
    }
    
    
    func channel(_ sender: SBDGroupChannel, userDidLeave user: SBDUser) {
        guard let userUID = _AppCoreData.userDataSource.value?.userID, !userUID.isEmpty, user.userId == userUID else { return }
        deleteChannel(channel: sender)
    }


    func channel(_ sender: SBDGroupChannel, didReceiveInvitation invitees: [SBDUser]?, inviter: SBDUser?) {
        guard let userUID = _AppCoreData.userDataSource.value?.userID, !userUID.isEmpty, sender.joinedAt == 0, inviter?.userId != userUID else { return }
        DispatchQueue.main.async {
            if self.channels.count == 50 {
                self.channels.removeLast()
                self.groupChannelsTableView.deleteRows(at: [IndexPath(row: 49, section: 0)], with: .automatic)
            }
            self.channels.insert(sender, at: 0)
            self.groupChannelsTableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
        }
    }

    
    func channel(_ sender: SBDGroupChannel, userDidJoin user: SBDUser) {
        
        if let userUID = _AppCoreData.userDataSource.value?.userID, userUID != "" {
            
            if user.userId == userUID {
                
                self.deleteChannel(channel: sender)
                
            }
            
        }
        
    }
    
    func channel(_ sender: SBDGroupChannel, didDeclineInvitation invitee: SBDUser, inviter: SBDUser?) {
        
        
        if let userUID = _AppCoreData.userDataSource.value?.userID, userUID != "" {
            
            if invitee.userId == userUID {
                
                self.deleteChannel(channel: sender)
                
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

}
