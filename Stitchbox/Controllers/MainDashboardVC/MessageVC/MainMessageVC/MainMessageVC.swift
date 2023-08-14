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
    
    deinit {
        print("MainMessageVC is being deallocated.")
    }

   // @IBOutlet weak var contentViewTopConstant: NSLayoutConstraint!
    @IBOutlet weak var buttonStackView: UIStackView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var requestBtn: UIButton!
    @IBOutlet weak var inboxBtn: UIButton!

    
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()


        settingUpLayoutNavView()
        checkCallForLayout()
        setupSearchController()
        
        // default load for 2 child views
   
        InboxVC.view.isHidden = false
        
        NotificationCenter.default.addObserver(self, selector: #selector(MainMessageVC.checkCallForLayout), name: (NSNotification.Name(rawValue: "checkCallForLayout")), object: nil)
        
        
        if let navigationController = self.navigationController {
                    navigationController.navigationBar.prefersLargeTitles = false
                    navigationController.navigationBar.isTranslucent = false
                }
         
    }

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // tabbar
        
        showMiddleBtn(vc: self)
        checkCallForLayout()
       
    
        let navigationBarAppearance = UINavigationBarAppearance()
        navigationBarAppearance.configureWithOpaqueBackground()
        navigationBarAppearance.backgroundColor = .white
        navigationBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.black]
        navigationBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.black]

        self.navigationController?.navigationBar.standardAppearance = navigationBarAppearance
        self.navigationController?.navigationBar.scrollEdgeAppearance = navigationBarAppearance
        
        guard let tabBar = self.tabBarController?.tabBar else {
            return
        }

        tabBar.isHidden = false
         
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
        self.searchController?.searchBar.text = ""
    }
 

    
    @objc func searchBarSetting(_ sender: AnyObject) {
        if searchController?.searchBar.isHidden == true {
            //buttonStackView.isHidden = true
            navigationItem.searchController = searchController
            searchController?.searchBar.isHidden = false
            
            delay(0.025) { [weak self] in
                guard let self = self else { return }
                self.searchController?.searchBar.becomeFirstResponder()
            }
            
        } else {
            //buttonStackView.isHidden = false
            navigationItem.searchController = nil
            searchController?.searchBar.isHidden = true
        }
    }

    
    @objc func openChatBot(_ sender: AnyObject) {
        if let SBCB = UIStoryboard(name: "Dashboard", bundle: nil).instantiateViewController(withIdentifier: "SB_ChatBot") as? SB_ChatBot {
            
            SBCB.hidesBottomBarWhenPushed = true
            hideMiddleBtn(vc: self)
            self.navigationController?.pushViewController(SBCB, animated: true)
            
            
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
        
        self.navigationController?.delegate = self
        navigationItem.leftBarButtonItem = nil
        navigationItem.titleView = UIView()
        navigationItem.leftBarButtonItem = self.createLeftTitleItem(text: "Messages")
        
    }
    
    
    func createLeftTitleItem(text: String) -> UIBarButtonItem {
        let titleLabel = UILabel()
        titleLabel.text = text
        titleLabel.font = FontManager.shared.roboto(.Bold, size: 18)
        titleLabel.textColor = UIColor.black
        return UIBarButtonItem.init(customView: titleLabel)
    }
        
    
    func setupWithCall() {
        let createButton = UIButton(type: .custom)
        createButton.setImage(UIImage(named: "plus-lightmode")?.resize(targetSize: CGSize(width: 22, height: 22)), for: [])
        createButton.addTarget(self, action: #selector(showCreateChannel(_:)), for: .touchUpInside)
        createButton.frame = CGRect(x: -1, y: 0, width: 30, height: 30)
        let createBarButton = UIBarButtonItem(customView: createButton)

        let searchButton = UIButton(type: .custom)
        searchButton.setImage(UIImage(named: "search-lightmode")?.resize(targetSize: CGSize(width: 22, height: 22)), for: [])
        searchButton.addTarget(self, action: #selector(searchBarSetting(_:)), for: .touchUpInside)
        searchButton.frame = CGRect(x: -1, y: 0, width: 30, height: 30)
        let searchBarButton = UIBarButtonItem(customView: searchButton)
        
        let chatbotButton = UIButton(type: .custom)
        chatbotButton.setImage(UIImage(named: "gpt_bot")?.resize(targetSize: CGSize(width: 25, height: 25)), for: [])
        chatbotButton.addTarget(self, action: #selector(openChatBot(_:)), for: .touchUpInside)
        chatbotButton.frame = CGRect(x: -1, y: 0, width: 30, height: 30)
        let chatbotBarButton = UIBarButtonItem(customView: chatbotButton)

        let voiceCallButton = UIButton(type: .custom)
        voiceCallButton.semanticContentAttribute = .forceRightToLeft
        voiceCallButton.setTitle("Join ", for: .normal)
        voiceCallButton.setTitleColor(.white, for: .normal)
        voiceCallButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        voiceCallButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 2, bottom: 0, right: -2)
        voiceCallButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: -2, bottom: 0, right: 2)
        voiceCallButton.setImage(UIImage(named: "icCallFilled"), for: [])
        voiceCallButton.addTarget(self, action: #selector(clickVoiceCallBarButton(_:)), for: .touchUpInside)
        voiceCallButton.frame = CGRect(x: 0, y: 0, width: 70, height: 30)
        voiceCallButton.backgroundColor = incomingCallGreen
        voiceCallButton.cornerRadius = 15
        let customView = UIView(frame: CGRect(x: 0, y: 0, width: 70, height: 30))
        customView.addSubview(voiceCallButton)
        voiceCallButton.center = customView.center
        let voiceCallBarButton = UIBarButtonItem(customView: customView)

        let fixedSpace = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        fixedSpace.width = 2
        voiceCallButton.shake()

        self.navigationItem.rightBarButtonItems = [searchBarButton, fixedSpace, createBarButton, fixedSpace, chatbotBarButton, fixedSpace, voiceCallBarButton]
    }



    
    func setupWithoutCall() {
        
        let createButton: UIButton = UIButton(type: .custom)
        let searchButton: UIButton = UIButton(type: .custom)
        
        // Do any additional setup after loading the view.
        createButton.setImage(UIImage(named: "plus-lightmode")?.resize(targetSize: CGSize(width: 22, height: 22)), for: [])
        createButton.addTarget(self, action: #selector(showCreateChannel(_:)), for: .touchUpInside)
        createButton.frame = CGRect(x: -1, y: 0, width: 30, height: 30)
        let createBarButton = UIBarButtonItem(customView: createButton)
      
        searchButton.setImage(UIImage(named: "search-lightmode")?.resize(targetSize: CGSize(width: 22, height: 22)), for: [])
        searchButton.addTarget(self, action: #selector(searchBarSetting(_:)), for: .touchUpInside)
        searchButton.frame = CGRect(x: -1, y: 0, width: 30, height: 30)
        
        let searchBarButton = UIBarButtonItem(customView: searchButton)
        
        let fixedSpace = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        fixedSpace.width = 2
        
        let chatbotButton = UIButton(type: .custom)
        chatbotButton.setImage(UIImage(named: "gpt_bot")?.resize(targetSize: CGSize(width: 25, height: 25)), for: [])
        chatbotButton.addTarget(self, action: #selector(openChatBot(_:)), for: .touchUpInside)
        chatbotButton.frame = CGRect(x: -1, y: 0, width: 30, height: 30)
        let chatbotBarButton = UIBarButtonItem(customView: chatbotButton)

        self.navigationItem.rightBarButtonItems = [searchBarButton, fixedSpace, createBarButton, fixedSpace, chatbotBarButton]
        
        
    }
    
    @objc func showCreateChannel(_ sender: AnyObject) {
        //CreateChannelVC
        
        if let CCV = UIStoryboard(name: "Dashboard", bundle: nil).instantiateViewController(withIdentifier: "CreateChannelVC") as? CreateChannelVC {
            
            CCV.hidesBottomBarWhenPushed = true
            hideMiddleBtn(vc: self)
            self.navigationController?.pushViewController(CCV, animated: true)
            
        }
        
       
    }

    
    func setupRequestBtn() {
        
        inboxBtn.setTitleColor(UIColor.lightGray, for: .normal)
        requestBtn.setTitleColor(UIColor.white, for: .normal)
        
        
        inboxBtn.backgroundColor = UIColor.clear
        requestBtn.backgroundColor = UIColor.secondary
        
        
        InboxVC.view.isHidden = true
        
        self.searchController?.searchBar.text = ""
    }
    

    
    @IBAction func InboxBtnPressed(_ sender: Any) {
        
       
        
    }
    
    @IBAction func requestBtnPressed(_ sender: Any) {
        
       
        
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
        
        //contentViewTopConstant.constant = 10
        
        //buttonStackView.isHidden = false
        navigationItem.searchController = nil
        searchController?.searchBar.isHidden = true
       
        if InboxVC.view.isHidden == false {
            
            InboxVC.searchChannelList.removeAll()
            InboxVC.inSearchMode = false
            InboxVC.groupChannelsTableView.reloadData()
            
            return
            
        }
        
       
        
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        
    
        //contentViewTopConstant.constant = -50
        
        if InboxVC.view.isHidden == false {
            
            InboxVC.searchChannelList = InboxVC.channels
            InboxVC.inSearchMode = true
            InboxVC.groupChannelsTableView.reloadData()
            
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

        // Check which view controller is currently visible
        if !InboxVC.view.isHidden {
            // Set the searchChannelList variable of the InboxVC to the full list of channels and reload the table view
            InboxVC.searchChannelList = InboxVC.channels
            InboxVC.groupChannelsTableView.reloadData()
        }
    }


    func searchChannels(for searchText: String) {
    
        let channels = InboxVC.channels
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
        }
        
    }


    func getChannelName(channel: SBDGroupChannel) -> String {
        guard let members = channel.members else { return "" }
        let filteredMembers = members.compactMap { $0 as? SBDMember }.filter { $0.userId != SBDMain.getCurrentUser()?.userId }
        let names = filteredMembers.prefix(3).map { $0.nickname ?? "" }
        return channel.memberCount > 3 ? "\(names.joined(separator: ","))" : names.joined(separator: ",")
    }

    
}
