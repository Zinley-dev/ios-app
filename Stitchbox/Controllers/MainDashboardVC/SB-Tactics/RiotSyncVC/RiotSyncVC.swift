//
//  RiotSyncVC.swift
//  Stitchbox
//
//  Created by Khoi Nguyen on 4/13/23.
//

import UIKit
import AsyncDisplayKit
import FLAnimatedImage

class RiotSyncVC: UIViewController, UINavigationControllerDelegate, UISearchBarDelegate, UITextFieldDelegate {
    
    var regionList = [RegionModel]()
    var searchRegion = ""
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    var searchController: UISearchController?
    var searchList = [RiotAccountModel]()
    var searchTableNode: ASTableNode!
    lazy var delayItem = workItem()
    @IBOutlet weak var contentview: UIView!
    let backButton: UIButton = UIButton(type: .custom)
    var dayPicker = UIPickerView()
    var regionName = "NA"
    
    
    @IBOutlet weak var regionTxtField: UITextField! {
        didSet {
            regionTxtField.text = "NA"
            searchRegion = "na"
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupButtons()
        setupSearchController()
        setupTableNode()
        
        self.loadRegion { (newRegions) in
            
            self.insertNewRowsInTableNode(newRegions: newRegions)
            
        }
        
        self.dayPicker.delegate = self
        
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
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardShow),
                                               name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardHide),
                                               name: UIResponder.keyboardWillHideNotification, object: nil)
        
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        self.view.endEditing(true)
        
    }
    
    func createDayPicker() {
        
        regionTxtField.inputView = dayPicker
        
    }
    
    
    @IBAction func changeRegionBtnPressed(_ sender: Any) {
        
        createDayPicker()
        regionTxtField.becomeFirstResponder()
        
    }
    
    
}


extension RiotSyncVC {
    
    func setupSearchController() {
        
        self.searchController = UISearchController(searchResultsController: nil)
        self.searchController?.obscuresBackgroundDuringPresentation = false
        self.searchController?.searchBar.delegate = self
        self.searchController?.searchBar.searchBarStyle = .minimal
        self.navigationItem.searchController = self.searchController
        self.navigationItem.hidesSearchBarWhenScrolling = false
        self.searchController?.searchBar.tintColor = .white
        self.searchController?.searchBar.searchTextField.textColor = .white
        self.searchController!.searchBar.searchTextField.attributedPlaceholder = NSAttributedString(string: "Search by your LOL username", attributes: [.foregroundColor: UIColor.lightGray])
        
    }
    
}


extension RiotSyncVC {
    
    func setupButtons() {
        self.navigationItem.title = "Sync Riot Account"
        setupBackButton()
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
        backButton.setTitle("", for: .normal)
        let backButtonBarButton = UIBarButtonItem(customView: backButton)
        
        self.navigationItem.leftBarButtonItem = backButtonBarButton
        
        
        
    }
    
    
    @objc func onClickBack(_ sender: AnyObject) {
        if let navigationController = self.navigationController {
            navigationController.popViewController(animated: true)
        }
    }
    
    
    func setupTableNode() {
        
        self.searchTableNode = ASTableNode(style: .plain)
        contentview.addSubview(searchTableNode.view)
        
        self.searchTableNode.automaticallyRelayoutOnLayoutMarginsChanges = true
        self.searchTableNode.automaticallyAdjustsContentOffset = true
        self.searchTableNode.view.backgroundColor = self.view.backgroundColor
        
        self.searchTableNode.view.translatesAutoresizingMaskIntoConstraints = false
        self.searchTableNode.view.topAnchor.constraint(equalTo: self.contentview.topAnchor, constant: 0).isActive = true
        self.searchTableNode.view.leadingAnchor.constraint(equalTo: self.contentview.leadingAnchor, constant: 0).isActive = true
        self.searchTableNode.view.trailingAnchor.constraint(equalTo: self.contentview.trailingAnchor, constant: 0).isActive = true
        self.searchTableNode.view.bottomAnchor.constraint(equalTo: self.contentview.bottomAnchor, constant: 0).isActive = true
        
        
        self.searchTableNode.delegate = self
        self.searchTableNode.dataSource = self
        
        self.applyStyle()
        
        
    }
    
    
    func applyStyle() {
        
        self.searchTableNode.view.separatorStyle = .none
        self.searchTableNode.view.separatorColor = UIColor.lightGray
        self.searchTableNode.view.isPagingEnabled = false
        self.searchTableNode.view.backgroundColor = UIColor.clear
        self.searchTableNode.view.showsVerticalScrollIndicator = false
        
    }
    
}

extension RiotSyncVC: ASTableDataSource, ASTableDelegate {
    
    func shouldBatchFetch(for tableNode: ASTableNode) -> Bool {
        return false
    }
    
    func tableNode(_ tableNode: ASTableNode, constrainedSizeForRowAt indexPath: IndexPath) -> ASSizeRange {
        
        let width = UIScreen.main.bounds.size.width;
        
        let min = CGSize(width: width, height: 40);
        let max = CGSize(width: width, height: 1000);
        return ASSizeRangeMake(min, max);
        
    }
    
    func tableNode(_ tableNode: ASTableNode, numberOfRowsInSection section: Int) -> Int {
        
        return searchList.count
        
    }
    
    func tableNode(_ tableNode: ASTableNode, nodeBlockForRowAt indexPath: IndexPath) -> ASCellNodeBlock {
        if tableNode == searchTableNode {
            
            let item = searchList[indexPath.row]
            return {
                let node = RiotSearchNode(with: item)
                node.neverShowPlaceholders = true
                node.debugName = "Node \(indexPath.row)"
                return node
            }
            
        } else {
            return { ASCellNode() }
        }
    }
    
    
    func tableNode(_ tableNode: ASTableNode, didSelectRowAt indexPath: IndexPath) {
        
        let account = searchList[indexPath.row]
        self.view.endEditing(true)
        self.searchController?.searchBar.endEditing(true)
        syncRiotAccount(account: account)
        
        
    }
    
    
    func syncRiotAccount(account: RiotAccountModel) {
        
        if let username = _AppCoreData.userDataSource.value?.userName, let name = account.name {
            
            let alert = UIAlertController(title: "Hey \(username)!", message: "Please confirm if \(name) is your account. We will sync this account with SB-Tactics by default. You can change this anytime in the settings.", preferredStyle: UIAlertController.Style.actionSheet)
            
            // add the actions (buttons)
            alert.addAction(UIAlertAction(title: "Confirm to sync", style: UIAlertAction.Style.default, handler: { action in
                
                self.finalSyncAccount(account: account)
                
            }))
            
            alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil))
            
            self.present(alert, animated: true, completion: nil)
            
        }
        
        
    }
    
    func finalSyncAccount(account: RiotAccountModel) {
        
        presentSwiftLoader()
        
        let data = ["riotUsername": account.name!, "riotAccountId": account.acct_id!, "riotId": String(account.id ?? 0), "riotPuuid": account.puuid!, "riotLevel": account.level!, "riotSummonerId": account.summoner_id!, "riotProfileImage": account.profile_image_url!, "tier": account.tier!, "division": String(account.division ?? 0), "tierImage": account.tier_image_url!, "region": regionName, "lp": account.lp ?? 0] as [String : Any]
        
        
        APIManager.shared.confirmRiot(params: data) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let apiResponse):
                
                guard apiResponse.body?["message"] as? String == "success" else {
                    return
                }
                
                
                DispatchQueue.main {
                    
                    
                    reloadGlobalUserInformation()
                    
                    if let SBPVC = UIStoryboard(name: "Dashboard", bundle: nil).instantiateViewController(withIdentifier: "SB_ProfileVC") as? SB_ProfileVC {
                        
                        delay(1.5) {
                            SwiftLoader.hide()
                            self.navigationController?.pushViewController(SBPVC, animated: true)
                            self.navigationController?.viewControllers.remove(at: 1)
                        }
                        
                    }
                    
                }
                
            case .failure(let error):
                
                DispatchQueue.main {
                    print(error)
                    SwiftLoader.hide()
                    self.showErrorAlert("Oops!", msg: error.localizedDescription)
                }
                
            }
        }
        
    }
    
    
}



extension RiotSyncVC {
    
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if searchText != "" {
            delayItem.perform(after: 0.35) {
                
                self.search(for: searchText)
                
            }
        }
    }
    
    
    func search(for searchText: String) {
        
        APIManager.shared.searchUserRiot(region: searchRegion, username: searchText) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let apiResponse):
                
                guard let data = apiResponse.body?["data"] as? [[String: Any]] else {
                    return
                }
                
                if !data.isEmpty {
                    
                    var newSearchList = [RiotAccountModel]()
                    
                    for item in data {
                        newSearchList.append(RiotAccountModel(riotAccountModel: item))
                    }
                    
                    self.searchList = newSearchList
                    DispatchQueue.main.async {
                        self.searchTableNode.reloadData()
                    }
                    
                }
                
            case .failure(let error):
                
                print(error)
                
            }
        }
        
    }
    
    
}

extension RiotSyncVC {
    
    func loadRegion(block: @escaping ([[String: Any]]) -> Void) {
        
        APIManager.shared.getSupportedRegion { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let apiResponse):
                
                guard let data = apiResponse.body?["data"] as? [[String: Any]] else {
                    let item = [[String: Any]]()
                    DispatchQueue.main.async {
                        block(item)
                    }
                    return
                }
                
                if !data.isEmpty {
                    print("Successfully retrieved \(data.count) regions.")
                    let items = data
                    DispatchQueue.main.async {
                        block(items)
                    }
                } else {
                    
                    let item = [[String: Any]]()
                    DispatchQueue.main.async {
                        block(item)
                    }
                }
                
            case .failure(let error):
                print(error)
                let item = [[String: Any]]()
                DispatchQueue.main.async {
                    block(item)
                }
            }
        }
        
        
    }
    
    
    func insertNewRowsInTableNode(newRegions: [[String: Any]]) {
        
        guard newRegions.count > 0 else {
            return
        }
        
        var items = [RegionModel]()
        
        for i in newRegions {
            
            let item = RegionModel(regionModel: i)
            items.append(item)
            
        }
        
        self.regionList.append(contentsOf: items)
        
    }
    
}



extension RiotSyncVC: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        
        return 1
        
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        return regionList.count
    }
    
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        
        var pickerLabel: UILabel? = (view as? UILabel)
        if pickerLabel == nil {
            pickerLabel = UILabel()
            pickerLabel?.backgroundColor = UIColor.darkGray
            pickerLabel?.font = UIFont.systemFont(ofSize: 15)
            pickerLabel?.textAlignment = .center
        }
        if let name = regionList[row].name {
            pickerLabel?.text = name
        } else {
            pickerLabel?.text = "Error loading"
        }
        
        pickerLabel?.textColor = UIColor.white
        
        return pickerLabel!
    }
    
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        if regionList[row].name != nil {
            
            regionTxtField.text = regionList[row].name
            searchRegion = regionList[row].shortName
            regionName = regionList[row].name
        }
        
        
    }
    
    func showErrorAlert(_ title: String, msg: String) {
        
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        
        
        present(alert, animated: true, completion: nil)
        
    }
    
}


extension RiotSyncVC {
    
    @objc func handleKeyboardShow(notification: Notification) {
        
        bottomConstraint.constant = 300
        
        
    }
    
    @objc func handleKeyboardHide(notification: Notification) {
        
        bottomConstraint.constant = 0
        
    }
    
}
