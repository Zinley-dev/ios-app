//
//  MainFistBumpVC.swift
//  Stitchbox
//
//  Created by Khanh Duy Nguyen on 2/6/23.
//

import UIKit
import FLAnimatedImage

class MainFistBumpVC: UIViewController, UINavigationBarDelegate, UINavigationControllerDelegate, UISearchBarDelegate {
    
    let backButton: UIButton = UIButton(type: .custom)
    
    @IBOutlet weak var fistBumpeeBtn: UIButton!
    @IBOutlet weak var fistBumperBtn: UIButton!
    @IBOutlet weak var contentView: UIView!
    
    @IBOutlet weak var contentViewTopConstant: NSLayoutConstraint!
    @IBOutlet weak var buttonStackView: UIStackView!
    
    @IBOutlet weak var loadingImage: FLAnimatedImageView!
    @IBOutlet weak var loadingView: UIView!
    
    var searchController: UISearchController?
    var showfistBumperFirst = false
    var type = ""
    var ownerID = ""
    var fistBumperCount = 0
    var fistBumpeeCount = 0
    
    lazy var fistBumperVC: FistBumperVC = {
        
        
        if let controller = UIStoryboard(name: "Dashboard", bundle: nil).instantiateViewController(withIdentifier: "FistBumperVC") as? FistBumperVC {
                    
            self.addVCAsChildVC(childViewController: controller)
            
            return controller
        } else {
            return UIViewController() as! FistBumperVC
        }
       
        
    }()
    
    lazy var fistBumpeeVC: FistBumpeeVC = {
        
        
        if let controller = UIStoryboard(name: "Dashboard", bundle: Bundle.main).instantiateViewController(withIdentifier: "FistBumpeeVC") as? FistBumpeeVC {
            
            self.addVCAsChildVC(childViewController: controller)
            
            return controller
            
        } else {
            return UIViewController() as! FistBumpeeVC
        }
                
        
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupButtons()
        if showfistBumperFirst
        {
            setupfistBumpersView()
        }
        else {
            setupfistBumpeeView()
        }
        setupSearchController()
        
        
        countFistBumpers() {
            Dispatch.main.async {
       
                self.fistBumperBtn.setTitle("\(formatPoints(num: Double(self.fistBumperCount))) FistBumpers", for: .normal)
            }
        }
        
       
        
        countFistBumpees() {
            Dispatch.main.async {
                self.fistBumpeeBtn.setTitle("\(formatPoints(num: Double(self.fistBumpeeCount))) FistBumpees", for: .normal)
            }
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        do {
            
            let path = Bundle.main.path(forResource: "fox2", ofType: "gif")!
            let gifData = try NSData(contentsOfFile: path) as Data
            let image = FLAnimatedImage(animatedGIFData: gifData)
            
            
            self.loadingImage.animatedImage = image
            
        } catch {
            print(error.localizedDescription)
        }
        
        loadingView.backgroundColor = self.view.backgroundColor
        
        
        delay(1.5) {
            
            UIView.animate(withDuration: 0.5) {
                
                self.loadingView.alpha = 0
                
            }
            
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                
                if self.loadingView.alpha == 0 {
                    
                    self.loadingView.isHidden = true
                    
                }
                
            }
            
        }
        
    }

    
    @IBAction func fistBumperBtn(_ sender: Any) {
        
        setupfistBumpersView()
        
    }
    
    @IBAction func fistBumpeeBtn(_ sender: Any) {
        
        setupfistBumpeeView()
        
    }
    
    
}

extension MainFistBumpVC {
    
    func setupButtons() {
        
        setupBackButton()
        setupTitle()
        setupSearchBar()
    }
    
    
    func setupBackButton() {
        
        // Do any additional setup after loading the view.
        backButton.setImage(UIImage.init(named: "back_icn_white")?.resize(targetSize: CGSize(width: 13, height: 23)), for: [])
        backButton.addTarget(self, action: #selector(onClickBack(_:)), for: .touchUpInside)
        backButton.frame = back_frame
        backButton.setTitleColor(UIColor.white, for: .normal)
        backButton.setTitle("", for: .normal)
        backButton.sizeToFit()
        let backButtonBarButton = UIBarButtonItem(customView: backButton)
    
        self.navigationItem.leftBarButtonItem = backButtonBarButton
       
    }
    
    func setupTitle() {
        
        guard let userDataSource = _AppCoreData.userDataSource.value else {
            print("Can't get userDataSource")
            return
        }

        let loadUsername = userDataSource.userName
        if loadUsername != "" {
            self.navigationItem.title = loadUsername
        } else {
            self.navigationItem.title = "FistBump"
        }
       
       
    }
    
    func setupSearchBar() {
        
        let searchButton: UIButton = UIButton(type: .custom)

        searchButton.setImage(UIImage(named: "search"), for: [])
        searchButton.addTarget(self, action: #selector(searchBarSetting(_:)), for: .touchUpInside)
        searchButton.frame = CGRect(x: -1, y: 0, width: 30, height: 30)
        
        let searchBarButton = UIBarButtonItem(customView: searchButton)
        
        let fixedSpace = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        fixedSpace.width = 2

        self.navigationItem.rightBarButtonItem = searchBarButton
        
        
    }
    
    func setupfistBumpersView() {
        
        fistBumperBtn.setTitleColor(UIColor.white, for: .normal)
        fistBumpeeBtn.setTitleColor(UIColor.lightGray, for: .normal)
        
        
        fistBumperBtn.backgroundColor = UIColor.primary
        fistBumpeeBtn.backgroundColor = UIColor.clear
        
        
        fistBumperVC.view.isHidden = false
        fistBumpeeVC.view.isHidden = true
        
    }
    
    func setupfistBumpeeView() {
        
        fistBumperBtn.setTitleColor(UIColor.lightGray, for: .normal)
        fistBumpeeBtn.setTitleColor(UIColor.white, for: .normal)
        
        
        fistBumperBtn.backgroundColor = UIColor.clear
        fistBumpeeBtn.backgroundColor = UIColor.primary
        
        
        fistBumperVC.view.isHidden = true
        fistBumpeeVC.view.isHidden = false
        
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

 
}

extension MainFistBumpVC {
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        
        contentViewTopConstant.constant = 10
        
        buttonStackView.isHidden = false
        navigationItem.searchController = nil
        searchController?.searchBar.isHidden = true
       
        if fistBumperVC.view.isHidden == false {
            
            
            fistBumperVC.searchUserList.removeAll()
            fistBumperVC.inSearchMode = false
            fistBumperVC.tableNode.reloadData()
             
            
            return
            
        }
        
        
        if fistBumpeeVC.view.isHidden == false {
            
            
            fistBumpeeVC.searchUserList.removeAll()
            fistBumpeeVC.inSearchMode = false
            fistBumpeeVC.tableNode.reloadData()
             
            
            return
            
        }
        
        
        
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        
    
        contentViewTopConstant.constant = -50
        
        if fistBumperVC.view.isHidden == false {
            
            
            fistBumperVC.searchUserList = fistBumpeeVC.fistBumpList
            fistBumperVC.inSearchMode = true
            fistBumperVC.tableNode.reloadData()
            
            
            return
            
        }
        
        
        if fistBumpeeVC.view.isHidden == false {
            
            
            fistBumpeeVC.searchUserList = fistBumpeeVC.fistBumpList
            fistBumpeeVC.inSearchMode = true
            fistBumpeeVC.tableNode.reloadData()
             
            
            return
            
        }
 
    }
    
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText == "" {
            clearSearchResults()
        } else {
            searchUsers(for: searchText)
        }
    }

    func clearSearchResults() {
        // Clear the search results for both view controllers
        fistBumpeeVC.searchUserList.removeAll()
        fistBumperVC.searchUserList.removeAll()

        // Check which view controller is currently visible
        if !fistBumperVC.view.isHidden {
            // Set the searchUserList variable of the fistBumperVC to the full list of users and reload the table view
            fistBumperVC.searchUserList = fistBumperVC.fistBumpList
            fistBumperVC.tableNode.reloadData()
        } else if !fistBumpeeVC.view.isHidden {
            // Set the searchUserList variable of the fistBumpeeVC to the full list of users and reload the table view
            fistBumpeeVC.searchUserList = fistBumpeeVC.fistBumpList
            fistBumpeeVC.tableNode.reloadData()
        }
    }


    func searchUsers(for searchText: String) {
            
            let fistbump = !fistBumpeeVC.view.isHidden ? fistBumperVC.fistBumpList : fistBumpeeVC.fistBumpList
            
            let searchUserList = fistbump.filter { $0.userName.range(of: searchText, options: .caseInsensitive) != nil }
            
            let targetVC = !fistBumperVC.view.isHidden ? fistBumperVC : fistBumpeeVC
    
            if let updateVC = targetVC as? FistBumperVC {
                updateVC.searchUserList = searchUserList
                updateVC.tableNode.reloadData()
            } else if let updateVC = targetVC as? FistBumpeeVC {
                updateVC.searchUserList = searchUserList
                updateVC.tableNode.reloadData()
            }
        }


    
}

extension MainFistBumpVC {
    
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
    
    @objc func onClickBack(_ sender: AnyObject) {
        if let navigationController = self.navigationController {
            navigationController.popViewController(animated: true)
        }
    }
    
    
}

extension MainFistBumpVC {
    
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
    
}

extension MainFistBumpVC {
    
    
    func countFistBumpers(completed: @escaping DownloadComplete) {
        
        
        APIManager().getFistBumperCount { result in
            switch result {
            case .success(let response):
                
                print(response)
                
                guard response.body?["message"] as? String == "success",
                      let data = response.body?["count"] as? [String: Any] else {
                        completed()
                        return
                }
            
                    if let fistBumpersGet = data["total"] as? Int {
                        self.fistBumperCount = fistBumpersGet
                    } else {
                        self.fistBumperCount = 0
                    }
                    
                    completed()
                
            case .failure(let error):
                print("Error loading follower: ", error)
                completed()
               
            }
        }
        
       
    }
    
    
    func countFistBumpees(completed: @escaping DownloadComplete) {
        
        APIManager().getFistBumpeeCount { result in
            switch result {
            case .success(let response):
                
                print(response)
                
                guard response.body?["message"] as? String == "success",
                      let data = response.body?["count"] as? [String: Any] else {
                        completed()
                        return
                }
            
                    if let fistBumpeesGet = data["total"] as? Int {
                        self.fistBumpeeCount = fistBumpeesGet
                    } else {
                        self.fistBumpeeCount = 0
                    }
                    
                    completed()
                
            case .failure(let error):
                print("Error loading follower: ", error)
                completed()
               
            }
        }
        
    }
    
}
