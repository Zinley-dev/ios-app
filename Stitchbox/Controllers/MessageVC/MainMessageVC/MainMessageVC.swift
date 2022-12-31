//
//  InboxVC.swift
//  Stitchbox
//
//  Created by Khoi Nguyen on 12/16/22.
//

import UIKit
import SendBirdSDK
import SendBirdCalls

var oldTabbarFr: CGRect = .zero


class MainMessageVC: UIViewController, UINavigationBarDelegate, UINavigationControllerDelegate, UISearchBarDelegate {

    @IBOutlet weak var contentViewTopConstant: NSLayoutConstraint!
    @IBOutlet weak var buttonStackView: UIStackView!
    @IBOutlet weak var BtnWidthConstants: NSLayoutConstraint!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var requestBtn: UIButton!
    @IBOutlet weak var inboxBtn: UIButton!
    
    let createButton: UIButton = UIButton(type: .custom)
    let searchButton: UIButton = UIButton(type: .custom)
    
    
    // setup 2 childviews
    
    var searchController: UISearchController?
    
    lazy var InboxVC: InboxVC = {
        
        
        if let controller = UIStoryboard(name: "Dashboard", bundle: nil).instantiateViewController(withIdentifier: "InboxViewController") as? InboxVC {
                    
            self.addVCAsChildVC(childViewController: controller)
            
            return controller
        } else {
            return UIViewController() as! InboxVC
        }
       
        
    }()
    
    lazy var RequestVC: RequestVC = {
        
        
        if let controller = UIStoryboard(name: "Dashboard", bundle: Bundle.main).instantiateViewController(withIdentifier: "RequestViewController") as? RequestVC {
            
    
            self.addVCAsChildVC(childViewController: controller)
            
            return controller
            
        } else {
            return UIViewController() as! RequestVC
        }
                
        
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    
        
        setupInboxBtn()
        settingUpLayoutNavView()
        checkCallForLayout()
        setupSearchController()
        
        // default load for 2 child views
        
        InboxVC.view.isHidden = false
        RequestVC.view.isHidden = true
        oldTabbarFr = self.tabBarController?.tabBar.frame ?? .zero
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(MainMessageVC.checkCallForLayout), name: (NSNotification.Name(rawValue: "checkCallForLayout")), object: nil)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        BtnWidthConstants.constant = self.view.bounds.width * (200/414)
        
        self.tabBarController?.tabBar.isHidden = false
        self.tabBarController?.tabBar.frame = oldTabbarFr
        
        
        checkCallForLayout()
     
    }
    
    
    func setupSearchController() {
        self.searchController = UISearchController(searchResultsController: nil)
        self.searchController?.obscuresBackgroundDuringPresentation = false
        self.searchController?.searchBar.delegate = self
        self.searchController?.searchBar.searchBarStyle = .minimal
        self.navigationItem.searchController = self.searchController
        self.navigationItem.hidesSearchBarWhenScrolling = false
        self.searchController?.searchBar.tintColor = .white
        self.searchController?.searchBar.searchTextField.textColor = .white
        self.searchController!.searchBar.searchTextField.attributedPlaceholder = NSAttributedString(string: "Search", attributes: [.foregroundColor: UIColor.lightGray])
        self.searchController!.searchBar.searchTextField.leftView?.tintColor = .lightGray
        self.searchController?.searchBar.isUserInteractionEnabled = true
        self.navigationItem.searchController = nil
        self.searchController?.searchBar.isHidden = true
    }
 

    
    @objc func searchBarSetting(_ sender: AnyObject) {
        if searchController?.searchBar.isHidden == true {
            buttonStackView.isHidden = true
            navigationItem.searchController = searchController
            searchController?.searchBar.isHidden = false
            
            delay(0.025) {
                self.searchController?.searchBar.becomeFirstResponder()
            }
            
        } else {
            buttonStackView.isHidden = false
            navigationItem.searchController = nil
            searchController?.searchBar.isHidden = true
        }
    }

    //
     
    @objc func checkCallForLayout() {
        
        if general_room != nil {
            
            
            setupWithCall()
            
            
        } else {
            
            setupWithoutCall()
            
        }
        
        
    }
    
    // setting up navigation bar
    

    func settingUpLayoutNavView() {
        
        navigationItem.leftBarButtonItem = nil
        navigationItem.titleView = UIView()
        navigationItem.leftBarButtonItem = self.createLeftTitleItem(text: "Messages")
        
    }
    
    
    func createLeftTitleItem(text: String) -> UIBarButtonItem {
        let titleLabel = UILabel()
        titleLabel.text = text
        titleLabel.font = UIFont.boldSystemFont(ofSize: 18)
        titleLabel.textColor = UIColor.white
        return UIBarButtonItem.init(customView: titleLabel)
    }
        
    
    func position(for bar: UIBarPositioning) -> UIBarPosition {
        return .topAttached
    }
    
    func setupWithCall() {
        
        // Do any additional setup after loading the view.
        createButton.setImage(UIImage(named: "4x_add"), for: [])
        createButton.addTarget(self, action: #selector(showCreateChannel(_:)), for: .touchUpInside)
        createButton.frame = CGRect(x: -1, y: 0, width: 30, height: 30)
        let createBarButton = UIBarButtonItem(customView: createButton)
        
        createButton.setTitle("", for: .normal)
        createButton.sizeToFit()
        
        searchButton.setImage(UIImage(named: "search"), for: [])
        searchButton.addTarget(self, action: #selector(searchBarSetting(_:)), for: .touchUpInside)
        searchButton.frame = CGRect(x: -1, y: 0, width: 30, height: 30)
        let searchBarButton = UIBarButtonItem(customView: searchButton)
    

        
        let voiceCallButton: UIButton = UIButton(type: .custom)
        voiceCallButton.setImage(UIImage(named: "icCallFilled"), for: [])
        voiceCallButton.addTarget(self, action: #selector(clickVoiceCallBarButton(_:)), for: .touchUpInside)
        voiceCallButton.frame = CGRect(x: -1, y: 0, width: 30, height: 30)
        voiceCallButton.cornerRadius = 15
        voiceCallButton.backgroundColor = .secondary
        let voiceCallBarButton = UIBarButtonItem(customView: voiceCallButton)
        
        
        self.navigationItem.rightBarButtonItems = [searchBarButton, createBarButton, voiceCallBarButton]
       
    }
    
    func setupWithoutCall() {
        
        // Do any additional setup after loading the view.
        createButton.setImage(UIImage(named: "4x_add"), for: [])
        createButton.addTarget(self, action: #selector(showCreateChannel(_:)), for: .touchUpInside)
        createButton.frame = CGRect(x: -1, y: 0, width: 30, height: 30)
        let createBarButton = UIBarButtonItem(customView: createButton)
        
        createButton.setTitle("", for: .normal)
        createButton.sizeToFit()
        
        
        searchButton.setImage(UIImage(named: "search"), for: [])
        searchButton.addTarget(self, action: #selector(searchBarSetting(_:)), for: .touchUpInside)
        searchButton.frame = CGRect(x: -1, y: 0, width: 30, height: 30)
        let searchBarButton = UIBarButtonItem(customView: searchButton)
        

        self.navigationItem.rightBarButtonItems = [searchBarButton, createBarButton]
        
        
    }
    
    @objc func showCreateChannel(_ sender: AnyObject) {
        //CreateChannelVC
        
        if let CCV = UIStoryboard(name: "Dashboard", bundle: nil).instantiateViewController(withIdentifier: "CreateChannelVC") as? CreateChannelVC {
             
            self.navigationController?.pushViewController(CCV, animated: true)
            
        }
        
       
    }
    
    // Buttons controll
    
    func setupInboxBtn() {
        
        inboxBtn.setTitleColor(UIColor.white, for: .normal)
        requestBtn.setTitleColor(UIColor.lightGray, for: .normal)
        
        
        inboxBtn.backgroundColor = UIColor.primary
        requestBtn.backgroundColor = UIColor.clear
        
        
        InboxVC.view.isHidden = false
        RequestVC.view.isHidden = true
        
        self.searchController?.searchBar.text = ""
        
        
    }
    
    func setupRequestBtn() {
        
        inboxBtn.setTitleColor(UIColor.lightGray, for: .normal)
        requestBtn.setTitleColor(UIColor.white, for: .normal)
        
        
        inboxBtn.backgroundColor = UIColor.clear
        requestBtn.backgroundColor = UIColor.primary
        
        
        InboxVC.view.isHidden = true
        RequestVC.view.isHidden = false
        
        self.searchController?.searchBar.text = ""
    }
    

    
    @IBAction func InboxBtnPressed(_ sender: Any) {
        
        setupInboxBtn()
        
    }
    
    @IBAction func requestBtnPressed(_ sender: Any) {
        
        setupRequestBtn()
        
    }
    
    // addChildVC Function
    
    func addVCAsChildVC(childViewController: UIViewController) {
        
        addChild(childViewController)
        contentView.addSubview(childViewController.view)
        
        childViewController.view.frame = contentView.bounds
        childViewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        childViewController.didMove(toParent: self)
        
        
    }
    
    func removeVCAsChildVC(childViewController: UIViewController) {
        
        childViewController.willMove(toParent: nil)
        childViewController.view.removeFromSuperview()
        childViewController.removeFromParent()
    }
    
    
    @objc func clickVoiceCallBarButton(_ sender: AnyObject) {
        guard let room = general_room else {
            setupWithoutCall()
            return
        }

        let controller = GroupCallViewController.instantiate(from: "Dashboard")
        controller.currentRoom = room
        controller.newroom = false
        controller.currentChanelUrl = gereral_group_chanel_url
        present(controller, animated: true, completion: nil)
    }

    // searchbar delegate
    
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        
        contentViewTopConstant.constant = 10
        
        buttonStackView.isHidden = false
        navigationItem.searchController = nil
        searchController?.searchBar.isHidden = true
       
        if InboxVC.view.isHidden == false {
            
            InboxVC.searchChannelList.removeAll()
            InboxVC.inSearchMode = false
            InboxVC.groupChannelsTableView.reloadData()
            
            return
            
        }
        
        
        if RequestVC.view.isHidden == false {
            
            RequestVC.searchChannelList.removeAll()
            RequestVC.inSearchMode = false
            RequestVC.groupChannelsTableView.reloadData()
            
            return
            
        }
        
        
        
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        
    
        contentViewTopConstant.constant = -50
        
        if InboxVC.view.isHidden == false {
            
            InboxVC.searchChannelList = InboxVC.channels
            InboxVC.inSearchMode = true
            InboxVC.groupChannelsTableView.reloadData()
            
            return
            
        }
        
        
        if RequestVC.view.isHidden == false {
            
            RequestVC.searchChannelList = RequestVC.channels
            RequestVC.inSearchMode = true
            RequestVC.groupChannelsTableView.reloadData()
            
            return
            
        }
 
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText == "" {
            clearSearchResults()
        } else {
            searchChannels(for: searchText)
        }
    }

    func clearSearchResults() {
        // Clear the search results for both view controllers
        InboxVC.searchChannelList.removeAll()
        RequestVC.searchChannelList.removeAll()

        // Check which view controller is currently visible
        if !InboxVC.view.isHidden {
            // Set the searchChannelList variable of the InboxVC to the full list of channels and reload the table view
            InboxVC.searchChannelList = InboxVC.channels
            InboxVC.groupChannelsTableView.reloadData()
        } else if !RequestVC.view.isHidden {
            // Set the searchChannelList variable of the RequestVC to the full list of channels and reload the table view
            RequestVC.searchChannelList = RequestVC.channels
            RequestVC.groupChannelsTableView.reloadData()
        }
    }


    func searchChannels(for searchText: String) {
        let channels = !InboxVC.view.isHidden ? InboxVC.channels : RequestVC.channels
        let searchChannelList = channels.filter { channel in
            let finalChannelName = channel.name != "" && channel.name != "Group Channel" ? channel.name : getChannelName(channel: channel)
            return finalChannelName.range(of: searchText, options: .caseInsensitive) != nil ||
                   (channel.lastMessage?.message.range(of: searchText, options: .caseInsensitive) != nil) ||
                   (channel.getInviter()?.nickname?.range(of: searchText, options: .caseInsensitive) != nil) ||
                   (channel.lastPinnedMessage?.message.range(of: searchText, options: .caseInsensitive) != nil)
        }

        if !InboxVC.view.isHidden {
            InboxVC.searchChannelList = searchChannelList
            InboxVC.groupChannelsTableView.reloadData()
        } else {
            RequestVC.searchChannelList = searchChannelList
            RequestVC.groupChannelsTableView.reloadData()
        }
    }


    func getChannelName(channel: SBDGroupChannel) -> String {
        guard let members = channel.members else { return "" }
        let filteredMembers = members.compactMap { $0 as? SBDMember }.filter { $0.userId != SBDMain.getCurrentUser()?.userId }
        let names = filteredMembers.prefix(3).map { $0.nickname ?? "" }
        return channel.memberCount > 3 ? "\(names.joined(separator: ","))" : names.joined(separator: ",")
    }

    
}
