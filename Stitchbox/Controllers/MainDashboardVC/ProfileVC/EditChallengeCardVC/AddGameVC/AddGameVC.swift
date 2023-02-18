//
//  AddGameVC.swift
//  Stitchbox
//
//  Created by Khoi Nguyen on 2/14/23.
//

import UIKit

class AddGameVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    let backButton: UIButton = UIButton(type: .custom)
    
    @IBOutlet weak var tableView: UITableView!
    var gameList = [Game]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupButtons()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.allowsSelection = true
        
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
        /*
        let card = paymentArr[indexPath.row]
        
        
        chargedCardID = card.Id
        cardBrand = card.Brand
        cardLast4Digits = card.Last4
        
        
        
        chargedlast4Digit = card.Last4
        chargedCardBrand = card.Brand
        
        NotificationCenter.default.post(name: (NSNotification.Name(rawValue: "setPayment")), object: nil)
        
        
        self.dismiss(animated: true, completion: nil)
        */
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 90.0
    }
    

    @objc func addGameBtnPressed() {
        
        //sendSmsNoti(Phone: "+16036179650", text: "You order is ready to pickup")
        
        if let AGDVC = UIStoryboard(name: "Dashboard", bundle: nil).instantiateViewController(withIdentifier: "AddGameDetailVC") as? AddGameDetailVC {
            
            self.navigationController?.pushViewController(AGDVC, animated: true)
            
        }
        
        //NotificationCenter.default.addObserver(self, selector: #selector(AddGameVC.refreshGameList), name: (NSNotification.Name(rawValue: "refreshGameList")), object: nil)
    
        
    }
    
    @objc func refreshGameList() {
        
        //NotificationCenter.default.removeObserver(self, name: (NSNotification.Name(rawValue: "refreshGameList")), object: nil)
        
        //loadPayment()
        
        
    }


}

extension AddGameVC {
    
    func setupButtons() {
        
        setupBackButton()
    
    }
    
    
    func setupBackButton() {
        
        // Do any additional setup after loading the view.
        backButton.setImage(UIImage.init(named: "back_icn_white")?.resize(targetSize: CGSize(width: 13, height: 23)), for: [])
        backButton.addTarget(self, action: #selector(onClickBack(_:)), for: .touchUpInside)
        backButton.frame = back_frame
        backButton.setTitleColor(UIColor.white, for: .normal)
        backButton.setTitle("     Game List", for: .normal)
        backButton.sizeToFit()
        let backButtonBarButton = UIBarButtonItem(customView: backButton)
    
        self.navigationItem.leftBarButtonItem = backButtonBarButton
       
    }
    
   
    @objc func onClickBack(_ sender: AnyObject) {
        if let navigationController = self.navigationController {
            navigationController.popViewController(animated: true)
        }
    }

    
}
