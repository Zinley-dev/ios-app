//
//  BannedMemberVC.swift
//  Stitchbox
//
//  Created by Khoi Nguyen on 1/3/23.
//

import UIKit
import SendBirdUIKit
import SendBirdSDK

class BannedMemberVC: UIViewController, UINavigationControllerDelegate, UITableViewDelegate, UITableViewDataSource {
    
    
    var channel: SBDGroupChannel?
    var query: SBDBannedUserListQuery?
    let backButton: UIButton = UIButton(type: .custom)
    
    
    @IBOutlet weak var tableView: UITableView!
    
    var joinedUserIds: [String] = []
    var userList: [SBUUser] = []

    let addButton: UIButton = UIButton(type: .custom)
   
    var selectedIndexpath = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        channel?.refresh()
        setupBackButton()
        setupTableView()
        getUsers()
        
        NotificationCenter.default.addObserver(self, selector: #selector(BannedMemberVC.unbanUser), name: (NSNotification.Name(rawValue: "BannedMember-unbanUser")), object: nil)
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let navigationBarAppearance = UINavigationBarAppearance()
        navigationBarAppearance.configureWithOpaqueBackground()
        navigationBarAppearance.backgroundColor = .background
        navigationBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        navigationBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]

        self.navigationController?.navigationBar.standardAppearance = navigationBarAppearance
        self.navigationController?.navigationBar.scrollEdgeAppearance = navigationBarAppearance
        
    }
   
    func getUsers() {
        guard let channel = self.channel else { return }
        self.query = channel.createBannedUserListQuery()
        self.query?.loadNextPage { [weak self] users, error in
            guard error == nil, let users = users, let self = self else {
                // Handle error.
                Utils.showAlertController(error: error!, viewController: self!)
                return
            }
            // A list of banned users is successfully retrieved.
            let sbuUsers = users.map { SBUUser(user: $0) }
            self.userList += sbuUsers
            self.tableView.reloadData()
        }
    }


    
    func setupTableView() {
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.separatorStyle = .none
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.estimatedRowHeight = 44.0
        self.tableView.register(SBUUserCell.self, forCellReuseIdentifier: SBUUserCell.sbu_className)
        
        
    }
    
    func setupBackButton() {
    
        backButton.frame = back_frame
        backButton.contentMode = .center

        if let backImage = UIImage(named: "back_icn_white") {
            let imageSize = CGSize(width: 13, height: 23)
            let padding = UIEdgeInsets(top: (back_frame.height - imageSize.height) / 2,
                                       left: (back_frame.width - imageSize.width) / 2 - horizontalPadding,
                                       bottom: (back_frame.height - imageSize.height) / 2,
                                       right: (back_frame.width - imageSize.width) / 2 + horizontalPadding)
            backButton.imageEdgeInsets = padding
            backButton.setImage(backImage, for: [])
        }

        backButton.addTarget(self, action: #selector(onClickBack(_:)), for: .touchUpInside)
        backButton.setTitleColor(UIColor.white, for: .normal)
        navigationItem.title = "Banned Members"
        
        let backButtonBarButton = UIBarButtonItem(customView: backButton)

        self.navigationItem.leftBarButtonItem = backButtonBarButton


        
    }
    
    @objc func onClickBack(_ sender: AnyObject) {
        if let navigationController = self.navigationController {
            NotificationCenter.default.removeObserver(self, name: (NSNotification.Name(rawValue: "BannedMember-unbanUser")), object: nil)
            navigationController.popViewController(animated: true)
        }
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if userList.isEmpty {
            tableView.setEmptyMessage("No banned member")
        } else {
            tableView.restore()
        }
        return userList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let user = userList[indexPath.row]

        guard let cell = tableView.dequeueReusableCell(withIdentifier: SBUUserCell.sbu_className, for: indexPath) as? SBUUserCell else {
            return UITableViewCell()
        }

        cell.configure(type: .channelMembers, user: user, operatorMode: self.channel?.myRole == .operator)
        cell.theme = .dark
        cell.contentView.backgroundColor = self.view.backgroundColor
        cell.selectionStyle = .none
        cell.moreButton.addTarget(self, action: #selector(actionButtonPressed(sender:)), for: .touchUpInside)
        cell.moreButton.tag = indexPath.row
        cell.moreButton.setImage(user.userId == SBDMain.getCurrentUser()?.userId ? UIImage(named: "noMore") : UIImage(named: "more"), for: .normal)
        cell.theme.separateColor = .clear


        return cell
    }

    
    @objc func actionButtonPressed(sender: UIButton) {
       
        selectedIndexpath = sender.tag
       
        let UnbanUserModView = UnbanUserModView()
        UnbanUserModView.modalPresentationStyle = .custom
        UnbanUserModView.transitioningDelegate = self
    
        //setting frame
        global_presetingRate = Double(0.15)
        global_cornerRadius = 30
        
        self.present(UnbanUserModView, animated: true, completion: nil)
 
    }
    
    
    @objc func unbanUser() {
    
        channel?.unbanUser(withUserId: userList[selectedIndexpath].userId) { error in
            guard error == nil else {
                // Handle error.
               
                self.presentErrorAlert(message: "Error code: \(error!.code), \(error!.localizedDescription)")
                return
            }
            // The members are successfully registered as operators of the channel.
            self.userList.remove(at: self.selectedIndexpath)
            self.tableView.reloadData()
           
        }
        
    }

}
