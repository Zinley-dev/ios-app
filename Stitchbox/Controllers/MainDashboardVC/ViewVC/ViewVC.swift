//
//  ViewVC.swift
//  Dual
//
//  Created by Khoi Nguyen on 10/9/21.
//

import UIKit

class ViewVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    let backButton: UIButton = UIButton(type: .custom)
    var selected_item: PostModel!
    
    var stats: Stats? {
        didSet {
            tableView.reloadData()
        }
    }

    struct setting {
       let name : String
       var items : [String]
    }
   
    var window: UIWindow?
    
    var sections = [setting(name:"Views", items: ["Total views", "Views in 60 mins", "Views in 24 hours"]), setting(name:"GG!", items: ["Total GG!","GG! in 60 mins", "GG! in 24 hours"])]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupButtons()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.allowsSelection = false
      
        
        loadPostStats()
    }
    
    func loadPostStats() {
        APIManager.shared.getPostStats(postId: selected_item.id) { result in
            switch result {
            case .success(let apiResponse):
                guard let dataDictionary = apiResponse.body?["data"] as? [String: Any] else {
                    print("Couldn't cast")
                    return
                }
                do {
                    let data = try JSONSerialization.data(withJSONObject: dataDictionary, options: .fragmentsAllowed)
                    let decoder = JSONDecoder()
                    let stats = try decoder.decode(Stats.self, from: data)
                    DispatchQueue.main.async {
                        self.stats = stats
                    }
                } catch {
                    print("Error decoding JSON: \(error)")
                }
            case .failure(let error):
                print(error)
            }
        }
    }


    
    func numberOfSections(in tableView: UITableView) -> Int {
         return self.sections.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.sections[section].name
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
         
        (view as! UITableViewHeaderFooterView).contentView.backgroundColor = UIColor.background
        (view as! UITableViewHeaderFooterView).textLabel?.textColor = UIColor.white
        
        if let frame = (view as! UITableViewHeaderFooterView).textLabel?.frame {
            
            (view as! UITableViewHeaderFooterView).textLabel?.frame = CGRect(x: -15, y: 0, width: frame.width, height: frame.height)
            
        }
       
        
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.sections[section].items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let i = self.sections[indexPath.section].items
        let item = i[indexPath.row]

        if let cell = tableView.dequeueReusableCell(withIdentifier: "ViewCell") as? ViewCell {
            var stat: Int?
            switch indexPath.section {
            case 0: // "Views"
                switch indexPath.row {
                case 0:
                    stat = stats?.view.total
                case 1:
                    stat = stats?.view.totalInHour
                case 2:
                    stat = stats?.view.totalInDay
                default:
                    break
                }
            case 1: // "GG!"
                switch indexPath.row {
                case 0:
                    stat = stats?.like.total
                case 1:
                    stat = stats?.like.totalInHour
                case 2:
                    stat = stats?.like.totalInDay
                default:
                    break
                }
            default:
                break
            }
            cell.configureCell(item, item: selected_item, stat: stat)
            return cell
        } else {
            return ViewCell()
        }
    }



    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 55
        
    }
    
    // func show error alert
    
    func showErrorAlert(_ title: String, msg: String) {
                                                                                                                                           
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        
                                                                                       
        present(alert, animated: true, completion: nil)
        
    }
    
    func swiftLoader() {
        
        var config : SwiftLoader.Config = SwiftLoader.Config()
        config.size = 170
        
        config.backgroundColor = UIColor.clear
        config.spinnerColor = UIColor.white
        config.titleTextColor = UIColor.white
        
        
        config.spinnerLineWidth = 3.0
        config.foregroundColor = UIColor.black
        config.foregroundAlpha = 0.7
        
        
        SwiftLoader.setConfig(config: config)
        
        
        SwiftLoader.show(title: "", animated: true)
        
                                                                                                                                      
        
    }

}

extension ViewVC {
    
    func setupButtons() {
        
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
        navigationItem.title = "Post Statistics"

        self.navigationItem.leftBarButtonItem = backButtonBarButton


        
    }

    @objc func onClickBack(_ sender: AnyObject) {
        
        if let navigationController = self.navigationController {
            navigationController.popViewController(animated: true)
        }
       
    }
    
    
}
