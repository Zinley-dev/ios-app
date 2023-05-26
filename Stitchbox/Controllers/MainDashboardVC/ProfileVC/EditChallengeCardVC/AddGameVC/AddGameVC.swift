//
//  AddGameVC.swift
//  Stitchbox
//
//  Created by Khoi Nguyen on 2/14/23.
//

import UIKit
import SendBirdUIKit
import ObjectMapper

class AddGameVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    let backButton: UIButton = UIButton(type: .custom)
    
    @IBOutlet weak var tableView: UITableView!
    var gameList = [Game]()
   
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupButtons()
        startTableView()
        reloadAddedGame = false
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if reloadAddedGame {
            reloadAddedGame = false
            APIManager.shared.getme { result in
                switch result {
                case .success(let response):
                    
                    if let data = response.body {
                        
                        if !data.isEmpty {
                            
                            if let newUserData = Mapper<UserDataSource>().map(JSON: data) {
                                _AppCoreData.reset()
                                _AppCoreData.userDataSource.accept(newUserData)
                                Dispatch.main.async {
                                    self.tableView.reloadData()
                                }
                                
                            }
                          
                        }
                        
                    }
                    
                    
                case .failure(let error):
                    print("Error loading profile: ", error)
                  
                }
            }
        
            
        }
        
    }
    
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
    
        return 1
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if gameList.count < 4 {
            return gameList.count + 1
        }
        
        
        return gameList.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if gameList.count < 4 {
            
            if indexPath.row < gameList.count {
               
               let game = gameList[indexPath.row]
               
               if let cell = tableView.dequeueReusableCell(withIdentifier: "GameCell") as? GameCell {
                   
                   cell.configureCell(game)
                   return cell
                   
               } else {
                   
                   return GameCell()
                   
               }
               
            } else {
                
                if let cell = tableView.dequeueReusableCell(withIdentifier: "addNewGameCell") as? addNewGameCell {

                    cell.addGameBtn.addTarget(self, action: #selector(AddGameVC.addGameBtnPressed), for: .touchUpInside)
                    return cell
                    
                    
                } else {
                    
                    return addNewGameCell()
                    
                }
            }
            
        } else {
            
            let game = gameList[indexPath.row]
            
            if let cell = tableView.dequeueReusableCell(withIdentifier: "GameCell") as? GameCell {
                
                cell.configureCell(game)
                
                return cell
                
            } else {
                
                return GameCell()
                
            }
            
            
        }
        
        
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        if let AGDVC = UIStoryboard(name: "Dashboard", bundle: nil).instantiateViewController(withIdentifier: "AddGameDetailVC") as? AddGameDetailVC {
            
            
            if let gameList = _AppCoreData.userDataSource.value?.challengeCard?.games, !gameList.isEmpty {
               
                AGDVC.index = indexPath.row
                
            } else {
               
                AGDVC.index = 0
                
            }
            
            
            AGDVC.mode = "Update"
            AGDVC.selectedGame = gameList[indexPath.row]
            self.navigationController?.pushViewController(AGDVC, animated: true)
            
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 90.0
    }
    
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        if indexPath.row < 4 {
            
            if gameList.count == 0 {
                return nil
            } else if gameList.count == 1,indexPath.row == 1 {
                return nil
            } else if gameList.count == 2,indexPath.row == 2 {
                return nil
            } else if gameList.count == 3,indexPath.row == 3 {
                return nil
            } else {
                
                let size = tableView.visibleCells[0].frame.height
                let iconSize: CGFloat = 35.0
                
                let removeAction = UIContextualAction(
                    style: .normal,
                    title: ""
                ) { action, view, actionHandler in
                    
                    APIManager.shared.deleteGameForCard(gameId: self.gameList[indexPath.row].gameId) { result in
                        switch result {
                        case .success(_):
                            DispatchQueue.main.async {
                                self.gameList.remove(at: indexPath.row)
                                self.tableView.deleteRows(at: [IndexPath(row: indexPath.row, section: 0)], with: .automatic)
                                showNote(text: "Game removed!")
                            }
                           
                        case .failure(_):
                            DispatchQueue.main.async {
                                showNote(text: "Unable to remove game!")
                            }
                            
                        }
                    }
                    
                    actionHandler(true)
                }
                
                let removeView = UIImageView(
                    frame: CGRect(
                        x: (size-iconSize)/2,
                        y: (size-iconSize)/2,
                        width: iconSize,
                        height: iconSize
                ))
                //removeView.layer.borderColor = UIColor.white.cgColor
                removeView.layer.masksToBounds = true
                //removeView.layer.borderWidth = 1
                removeView.layer.cornerRadius = iconSize/2
                removeView.backgroundColor =  .secondary
                removeView.image = xBtn
                removeView.contentMode = .center
                
                removeAction.image = removeView.asImage()
                removeAction.backgroundColor = .background
               
                
                return UISwipeActionsConfiguration(actions: [removeAction])
                
            }
            
            
            
        } else {
            return nil
        }
        
        
        
        
        
    }
    

    @objc func addGameBtnPressed() {
   
        if let AGDVC = UIStoryboard(name: "Dashboard", bundle: nil).instantiateViewController(withIdentifier: "AddGameDetailVC") as? AddGameDetailVC {
            
            
            if let gameList = _AppCoreData.userDataSource.value?.challengeCard?.games, !gameList.isEmpty {
               
                AGDVC.index = gameList.count - 1
                
            } else {
               
                AGDVC.index = 0
                
            }
            
            
            AGDVC.mode = "Add"
            self.navigationController?.pushViewController(AGDVC, animated: true)
            
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(AddGameVC.refreshGameList), name: (NSNotification.Name(rawValue: "refreshGameList")), object: nil)
    
        
    }
    
    @objc func refreshGameList() {
        
        NotificationCenter.default.removeObserver(self, name: (NSNotification.Name(rawValue: "refreshGameList")), object: nil)
        
    }
    
    func startTableView() {
        
    
        tableView.delegate = self
        tableView.dataSource = self
        tableView.allowsSelection = true

        
    }


}

extension AddGameVC {
    
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
        navigationItem.title = "Game List"
        let backButtonBarButton = UIBarButtonItem(customView: backButton)

        self.navigationItem.leftBarButtonItem = backButtonBarButton


        
    }

    @objc func onClickBack(_ sender: AnyObject) {
        if let navigationController = self.navigationController {
            navigationController.popViewController(animated: true)
        }
    }

    
}
