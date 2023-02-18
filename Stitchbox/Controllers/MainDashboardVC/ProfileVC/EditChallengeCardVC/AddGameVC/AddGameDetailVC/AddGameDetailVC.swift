//
//  AddGameDetailVC.swift
//  Stitchbox
//
//  Created by Khoi Nguyen on 2/17/23.
//

import UIKit

class AddGameDetailVC: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var gameSelectedImage: UIImageView!
    @IBOutlet weak var gameSelectedLbl: UILabel!
    @IBOutlet weak var contentViewHeight: NSLayoutConstraint!
    @IBOutlet weak var gameDetailsView: UIView!
    @IBOutlet weak var viewDomainBtn: UIButton!
    @IBOutlet weak var gameLinkTxtField: UITextField! {
        didSet {
            let redPlaceholderText = NSAttributedString(string: "Your stats game link",
                                                        attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
            
            gameLinkTxtField.attributedPlaceholder = redPlaceholderText
        }
    }
    @IBOutlet weak var pickYourGameTxtField: UITextField! {
        didSet {
            let redPlaceholderText = NSAttributedString(string: "Pick your game",
                                                        attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
            
            pickYourGameTxtField.attributedPlaceholder = redPlaceholderText
        }
    }
    
    var selectedName = ""
    var selectedID = ""
    let backButton: UIButton = UIButton(type: .custom)
    var selectedDomainList = [GameStatsDomainModel]()
    var suppport_game_list = [GameList]()
    var dayPicker = UIPickerView()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupButtons()
        loadGameList()
        self.dayPicker.delegate = self
        
        gameLinkTxtField.delegate = self
        gameLinkTxtField.addTarget(self, action: #selector(AddGameDetailVC.textFieldDidChange(_:)), for: .editingChanged)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        delay(0.1) {
            self.gameLinkTxtField.addUnderLine()
            self.pickYourGameTxtField.addUnderLine()
        }
      
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        self.view.endEditing(true)
    }

    @IBAction func viewAvailableDomainBtnPressed(_ sender: Any) {
        
        if !self.selectedDomainList.isEmpty {
            
            let slideVC =  GameDomainListVC()
            
            slideVC.modalPresentationStyle = .custom
            slideVC.transitioningDelegate = self
            global_presetingRate = Double(0.55)
            global_cornerRadius = 40
            slideVC.selectedDomainList = self.selectedDomainList
            
            self.present(slideVC, animated: true, completion: nil)
            
        } else {
            
            showErrorAlert("Oops!", msg: "Available domains not availble at this time")
            
        }
        

        
        
    }
    
    @IBAction func PickGameBtnPressed(_ sender: Any) {
        
        
        createDayPicker()
        pickYourGameTxtField.becomeFirstResponder()
        
    }
    
    func createDayPicker() {

        pickYourGameTxtField.inputView = dayPicker

    }
    
}

extension AddGameDetailVC {
    
    func loadGameList() {
            
        APIManager().getGames { result in
            switch result {
            case .success(let apiResponse):
                
                guard apiResponse.body?["message"] as? String == "success",
                      let data = apiResponse.body?["data"] as? [[String: Any]] else {
                    return
                }
            
                let list = data.compactMap { GameList(JSON: $0) }
                
    
                if let gameList = _AppCoreData.userDataSource.value?.challengeCard?.games, !gameList.isEmpty {
                    let gameNameSet = Set(gameList.map { $0.gameName })
                    let newGames = list.filter { !gameNameSet.contains($0.name) }
                    self.suppport_game_list += newGames
                } else {
                    self.suppport_game_list += list
                }
                
            case .failure(let error):
                print(error)
            }
        }
    }
    
}


extension AddGameDetailVC {
    
    func setupButtons() {
        
        setupBackButton()
    
    }
    
    
    func setupBackButton() {
        
        // Do any additional setup after loading the view.
        backButton.setImage(UIImage.init(named: "back_icn_white")?.resize(targetSize: CGSize(width: 13, height: 23)), for: [])
        backButton.addTarget(self, action: #selector(onClickBack(_:)), for: .touchUpInside)
        backButton.frame = back_frame
        backButton.setTitleColor(UIColor.white, for: .normal)
        backButton.setTitle("     Add Game", for: .normal)
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

extension AddGameDetailVC: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        
        return 1

    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        return suppport_game_list.count
    }
    
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        var pickerLabel: UILabel? = (view as? UILabel)
        if pickerLabel == nil {
            pickerLabel = UILabel()
            pickerLabel?.backgroundColor = UIColor.darkGray
            pickerLabel?.font = UIFont.systemFont(ofSize: 15)
            pickerLabel?.textAlignment = .center
        }
        if suppport_game_list[row].name != "" {
            pickerLabel?.text = suppport_game_list[row].name
        } else {
            pickerLabel?.text = "Error loading"
        }
        
       
     
        pickerLabel?.textColor = UIColor.white

        return pickerLabel!
    }
    
   
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        guard !suppport_game_list.isEmpty, row >= 0, row < suppport_game_list.count else {
            return
        }
        
        let selectedGame = suppport_game_list[row]
        guard !selectedGame.name.isEmpty, selectedGame.name != "Other" else {
            return
        }
        
        print(selectedGame.domains)
        
        selectedDomainList = selectedGame.domains.enumerated().map { GameStatsDomainModel(postKey: String($0.offset + 1), GameStatsDomainModel: ["id": String($0.offset + 1), "domain": $0.element]) }
        
        pickYourGameTxtField.text = selectedGame.name
        gameSelectedLbl.text = selectedGame.name
        gameSelectedImage.load(url: URL(string: selectedGame.cover)!, str: selectedGame.cover)
        viewDomainBtn.setTitleColor(.white, for: .normal)
        contentViewHeight.constant = 300
        gameDetailsView.isHidden = false
        selectedName = selectedGame.name
        selectedID = selectedGame._id
        
        if let text = gameLinkTxtField.text, text != "" {
            
            if verifyUrl(urlString: text) == true {
                
                createSaveBtn()
                
            } else {
                
                self.navigationItem.rightBarButtonItem = nil
                
            }
            
        } else {
            
            self.navigationItem.rightBarButtonItem = nil
            
        }
        
        
    }

    
    func streamError() {
        
        let alert = UIAlertController(title: "Oops!", message: "Your current stats link isn't supported now, do you want to view available stats link list for \(selectedName) ?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in

            let slideVC =  GameDomainListVC()
            
            slideVC.modalPresentationStyle = .custom
            slideVC.transitioningDelegate = self
            global_presetingRate = Double(0.55)
            global_cornerRadius = 40
            slideVC.selectedDomainList = self.selectedDomainList
            
            self.present(slideVC, animated: true, completion: nil)
            
            
        }))

        self.present(alert, animated: true)
        
        
    }
    
    func showErrorAlert(_ title: String, msg: String) {
        
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        
        
        present(alert, animated: true, completion: nil)
        
    }
    
    func createSaveBtn() {
      
        let createButton = UIButton(type: .custom)
        createButton.addTarget(self, action: #selector(onClickSave(_:)), for: .touchUpInside)
        createButton.semanticContentAttribute = .forceRightToLeft
        createButton.setTitle("Save", for: .normal)
        createButton.setTitleColor(.white, for: .normal)
        createButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        createButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 2, bottom: 0, right: -2)
        createButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: -2, bottom: 0, right: 2)
        createButton.frame = CGRect(x: 0, y: 0, width: 80, height: 30)
        createButton.backgroundColor = .primary
        createButton.cornerRadius = 15
        let customView = UIView(frame: CGRect(x: 0, y: 0, width: 80, height: 30))
        customView.addSubview(createButton)
        createButton.center = customView.center
        let createBarButton = UIBarButtonItem(customView: customView)

        let fixedSpace = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        fixedSpace.width = 2
      
        self.navigationItem.rightBarButtonItem = createBarButton
         
    }
    
    
    @objc func onClickSave(_ sender: AnyObject) {
        guard let text = gameLinkTxtField.text, !text.isEmpty, !selectedID.isEmpty else {
            showErrorAlert("Oops", msg: "Please make sure all your input is correct or we can't verify your url")
            return
        }
        
        guard let currentGame = suppport_game_list.first(where: { $0._id == selectedID }) else {
            showErrorAlert("Oops", msg: "Please make sure all your input is correct or we can't verify your url")
            return
        }
        
        if currentGame.domains.contains(text) {
            print("Adding new game")
        } else {
            streamError()
        }
    }



}

extension AddGameDetailVC {
    
    @objc func textFieldDidChange(_ textField: UITextField) {

        if let text = gameLinkTxtField.text, text != "", selectedName != "" {
            
            if verifyUrl(urlString: text) == true {
                
                createSaveBtn()
                
            } else {
                
                self.navigationItem.rightBarButtonItem = nil
                
            }
            
        } else {
            
            self.navigationItem.rightBarButtonItem = nil
            
        }
        
    }
    
    
}
