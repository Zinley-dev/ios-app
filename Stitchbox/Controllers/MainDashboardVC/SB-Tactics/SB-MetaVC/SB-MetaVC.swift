//
//  SB-MetaVC.swift
//  Stitchbox
//
//  Created by Khoi Nguyen on 5/9/23.
//

import UIKit
import ObjectMapper
import SafariServices

var test = """
Neeko:

* Changes: Passive, Q, W, and R

* New: Can disguise as any unit with a health bar (Cooldown -> 2 seconds). Q deals bonus damage to monsters.

* Nerfs: R's cooldown has increased to 120/105/90 seconds, magic damage reduced to 150/350/550 (+100% AP).

* Buffs: Passive's disguise doesn't break on damage. Clone from W can be repositioned and can mimic emotes.

Aatrox:

* Changes: Passive and R

* New: None

* Nerfs: None

* Buffs: Bonus Physical Damage on Passive increased to 4-12% of target's maximum health. Bonus Movement Speed on R increased to 60/80/100%.
"""

class SB_MetaVC: UIViewController {
    
    @IBOutlet weak var patchLbl: UILabel!
    var tableView: UITableView!

    let backButton: UIButton = UIButton(type: .custom)
    let originalButton: UIButton = UIButton(type: .custom)
    var gameName = ""
    var gameId = ""
    var originalLink = ""
    var lines = [Line]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        setupButtons()
        loadMeta()
        setupTableView()
        
    }

    func setupTableView() {
        tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(LineCell.self, forCellReuseIdentifier: "LineCell")
            
        // Set the table view style
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 44
        tableView.separatorStyle = .none
            
        // Add the table view to the view hierarchy
        view.addSubview(tableView)
            
        // Set up constraints
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: patchLbl.safeAreaLayoutGuide.bottomAnchor, constant: 16),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 8),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -8)
        ])
        tableView.backgroundColor = .clear
        tableView.allowsSelection = false
        tableView.showsVerticalScrollIndicator = false
        tableView.showsHorizontalScrollIndicator = false
    }

}

extension SB_MetaVC {
    
    func setupButtons() {
        
        setupBackButton()
        setupOriginalButton()
    
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
        navigationItem.title = gameName

        self.navigationItem.leftBarButtonItem = backButtonBarButton
        
    }
    
    func setupOriginalButton() {
    
        originalButton.frame = back_frame
        originalButton.contentMode = .center


        originalButton.addTarget(self, action: #selector(onClickLink(_:)), for: .touchUpInside)
        originalButton.setTitleColor(UIColor.white, for: .normal)
        originalButton.setTitle("Link", for: .normal)
        let originalButtonBarButton = UIBarButtonItem(customView: originalButton)

        self.navigationItem.rightBarButtonItem = originalButtonBarButton
        
    }

    
    func showErrorAlert(_ title: String, msg: String) {
                                                                                                                                           
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default)
        
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
        
    }

    
}

extension SB_MetaVC {
    
    @objc func onClickBack(_ sender: AnyObject) {
        if let navigationController = self.navigationController {
            navigationController.popViewController(animated: true)
        }
    }
    
    @objc func onClickLink(_ sender: AnyObject) {
        // originalLink is a non-optional String
        guard let url = URL(string: originalLink) else {
            return
        }

        let safariViewController = SFSafariViewController(url: url)
        safariViewController.modalPresentationStyle = .fullScreen
        self.present(safariViewController, animated: true)
    }

    
}

extension SB_MetaVC {
    func loadMeta() {
        
        APIManager.shared.getGamePatch(gameId: global_gameId) { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .success(let apiResponse):
                
                guard let data = apiResponse.body?["data"] as? [String: Any],
                      let content = data["content"] as? String, let originPatch = data["originPatch"] as? String, let patch = data["patch"] as? String else {
                    print("Unable to convert")
                    return
                }
                
                Dispatch.main.async {
                    self.patchLbl.text = "Patch: \(patch)"
                }
                
                print(content)
                self.originalLink = originPatch
                self.displayMeta(content: content)
            case .failure(let error):
                print(error)
            }
        }
    }

    func displayMeta(content: String) {
        
        let firstLevelKeyAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.boldSystemFont(ofSize: 16),
            .foregroundColor: UIColor.cyan,
            .kern: 1
        ]
        let secondLevelKeyAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.boldSystemFont(ofSize: 14),
            .foregroundColor: UIColor.secondary,
            .kern: 1
        ]

        let valueAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 14),
            .foregroundColor: UIColor.white,
            .kern: 1
        ]
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            
            let lines = content.components(separatedBy: "\n")
            var newLines: [Line] = []
            
            for line in lines {
                var lineContent: [NSAttributedString] = []
                
                if line.contains(":") {
                    let components = line.components(separatedBy: ":")
                    let key = components[0].trimmingCharacters(in: .whitespacesAndNewlines)
                    let value = components[1].trimmingCharacters(in: .whitespacesAndNewlines)
                    
                    var keyAttributes: [NSAttributedString.Key: Any]
                    keyAttributes = line.trimmingCharacters(in: .whitespacesAndNewlines).hasPrefix("*") ? secondLevelKeyAttributes : firstLevelKeyAttributes
                    let attributedKey = NSAttributedString(string: "\(key): ", attributes: keyAttributes)
                    let attributedValue = NSAttributedString(string: value, attributes: valueAttributes)

                    lineContent.append(attributedKey)
                    lineContent.append(attributedValue)
                } else {
                    let attributes: [NSAttributedString.Key: Any] = [
                        .font: UIFont.systemFont(ofSize: 14),
                        .foregroundColor: UIColor.white,
                        .kern: 1
                    ]
                    let attributedString = NSAttributedString(string: line, attributes: attributes)
                    lineContent.append(attributedString)
                }
                
                newLines.append(Line(content: lineContent))
            }
            
            DispatchQueue.main.async {
                self.lines = newLines
                self.tableView.reloadData()
            }
        }
    }


}


extension SB_MetaVC: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return lines.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LineCell", for: indexPath) as! LineCell
        cell.backgroundColor = .clear
        cell.configure(with: lines[indexPath.row])
        return cell
    }

}



struct Line {
    let content: [NSAttributedString]
}



