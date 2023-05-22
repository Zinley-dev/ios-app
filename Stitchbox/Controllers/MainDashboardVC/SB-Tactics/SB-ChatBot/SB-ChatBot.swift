//
//  SB-ChatBot.swift
//  Stitchbox
//
//  Created by Khoi Nguyen on 4/14/23.
//

import UIKit
import SwiftUI
import Combine


class SB_ChatBot: UIViewController {

    let backButton: UIButton = UIButton(type: .custom)
    let gptButton = UIButton(type: .custom)
    let toolbarActions = ToolbarActions()
    var name = ""
    var short_name = ""
    var gameId = ""
    var subscriptions = Set<AnyCancellable>()
    var selectedGpt = ""
    let toolbar = UIToolbar()
    
    private var pickerView: UIPickerView!
    private var pickerViewBottomConstraint: NSLayoutConstraint?
    private var toolbarBottomConstraint: NSLayoutConstraint?
    private let pickerData: [String] = ["GPT 3.5", "GPT 4"]
    
    let metaToolbar: UIToolbar = {
        let tb = UIToolbar()
        tb.translatesAutoresizingMaskIntoConstraints = false
        return tb
    }()

    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupButtons()
        global_gameId = gameId
        global_gameName = name
        global_gpt = "gpt-3.5-turbo"
        selectedGpt = "GPT 3.5"
        
    
        checkforMeta()
        setupClearAndGptButtons()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let passEligible = _AppCoreData.userDataSource.value?.passEligible {
            
            if passEligible {
                
                isPro = true
                
            } else {
                
                checkPlanForToken()
                
            }
            
        } else {
            
            checkPlanForToken()
            
        }
    }
    
    func checkforMeta() {
        
        APIManager().getGamePatch(gameId: global_gameId) { result in
            switch result {
            case .success(let apiResponse):
                
                guard let data = apiResponse.body?["data"] as? [String: Any],
                     let _ = data["content"] as? String, let _ = data["originPatch"] as? String, let _ = data["patch"] as? String else {
                    Dispatch.main.async {
                        self.setupWithoutMeta()
                    }
                    return
                }
                
                Dispatch.main.async {
                    self.setupForMeta()
                }
            case .failure(let error):
                print(error)
                Dispatch.main.async {
                    self.setupWithoutMeta()
                }
            }
        }
        
    }
    
    func setupForMeta() {
        
        
        // Create SwiftUI view
        let chatBotView = ChatBotView(toolbarActions: toolbarActions)
        
        // Create Hosting Controller
        let hostingController = UIHostingController(rootView: chatBotView)
        
        // Add the toolbar to the view
        view.addSubview(metaToolbar)
        metaToolbar.barTintColor = .secondary

            // Define constraints
        NSLayoutConstraint.activate([
            metaToolbar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            metaToolbar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            metaToolbar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            metaToolbar.heightAnchor.constraint(equalToConstant: 44) // Or whatever height you want
        ])
        
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let metaButton = UIBarButtonItem(title: "View current patch", style: .plain, target: self, action: #selector(metaButtonTapped))
        metaButton.tintColor = .black

        metaToolbar.setItems([flexibleSpace, metaButton], animated: false)
        
        // Add as child view controller
        addChild(hostingController)
        view.addSubview(hostingController.view)
        
        // Configure constraints
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
                hostingController.view.topAnchor.constraint(equalTo: metaToolbar.bottomAnchor),
                hostingController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                hostingController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                hostingController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ])
        
        hostingController.didMove(toParent: self)
        
    }
    
    func setupWithoutMeta() {
        
        // Create SwiftUI view
        let chatBotView = ChatBotView(toolbarActions: toolbarActions)
        
        // Create Hosting Controller
        let hostingController = UIHostingController(rootView: chatBotView)
        
        // Add as child view controller
        addChild(hostingController)
        view.addSubview(hostingController.view)
               
        // Configure constraints
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            hostingController.view.topAnchor.constraint(equalTo: view.topAnchor),
            hostingController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
               
        hostingController.didMove(toParent: self)
        
    }
    

}

extension SB_ChatBot {
    
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
        navigationItem.title = name

        self.navigationItem.leftBarButtonItem = backButtonBarButton


        
    }

    
    func showErrorAlert(_ title: String, msg: String) {
                                                                                                                                           
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default)
        
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
        
    }


    private func setupClearAndGptButtons() {
        Publishers.CombineLatest(toolbarActions.$clearAction, toolbarActions.$isClearActionDisabled)
            .sink { [weak self] clearAction, isDisabled in
                if let clearImage = UIImage(named: "1024x") {
                    let imageSize = CGSize(width: 23, height: 23)
                    let resizedImage = clearImage.resize(targetSize: imageSize)
                    let clearButton = UIButton(type: .system)
                    clearButton.setImage(resizedImage, for: [])
                    clearButton.addTarget(self, action: #selector(self?.clearTapped), for: .touchUpInside)
                    clearButton.isEnabled = !isDisabled
                    clearButton.tintColor = .white
                    
                    self?.gptButton.setTitle(self?.selectedGpt, for: .normal) // Change to "4" if you want to represent GPT-4
                    self?.gptButton.addTarget(self, action: #selector(self?.gptTapped), for: .touchUpInside)
                    self?.gptButton.tintColor = .white
                    self?.gptButton.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .medium)
                    
                    let stackView = UIStackView(arrangedSubviews: [self!.gptButton, clearButton])
                    stackView.axis = .horizontal
                    stackView.spacing = 8
                    
                    let barButtonItem = UIBarButtonItem(customView: stackView)
                    self?.navigationItem.rightBarButtonItem = barButtonItem
                } else {
                    print("Error: Image not found.")
                }
            }
            .store(in: &subscriptions)
    }
    
}

extension SB_ChatBot: UIPickerViewDelegate, UIPickerViewDataSource {
   
    // MARK: - UIPickerViewDataSource

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }

    // MARK: - UIPickerViewDelegate

    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        var pickerLabel: UILabel? = (view as? UILabel)
        if pickerLabel == nil {
            pickerLabel = UILabel()
            pickerLabel?.backgroundColor = UIColor.darkGray
            pickerLabel?.font = UIFont.systemFont(ofSize: 15)
            pickerLabel?.textAlignment = .center
        }
        if pickerData[row] != "" {
            pickerLabel?.text = pickerData[row]
        } else {
            pickerLabel?.text = "Error loading"
        }
        
       
     
        pickerLabel?.textColor = UIColor.white

        return pickerLabel!
    }

    
}

extension SB_ChatBot {
    
    @objc func onClickBack(_ sender: AnyObject) {
        if let navigationController = self.navigationController {
            navigationController.popViewController(animated: true)
        }
    }
    
    @objc func clearTapped() {
        toolbarActions.clearAction?()
    }
    
   
    @objc private func gptTapped() {
        pickerView = UIPickerView()
        pickerView.delegate = self
        pickerView.dataSource = self
        pickerView.backgroundColor = .white

        toolbar.sizeToFit()
        toolbar.barTintColor = .black
        toolbar.tintColor = .white

        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelPicker))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(title: "Select", style: .plain, target: self, action: #selector(donePicker))

        toolbar.setItems([cancelButton, spaceButton, doneButton], animated: false)

        // Add pickerView and toolbar to the view
        view.addSubview(pickerView)
        view.addSubview(toolbar)

        // Add constraints for pickerView and toolbar
        pickerView.translatesAutoresizingMaskIntoConstraints = false
        toolbar.translatesAutoresizingMaskIntoConstraints = false
        pickerView.backgroundColor = .background

        NSLayoutConstraint.activate([
            pickerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            pickerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            pickerView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            toolbar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            toolbar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            toolbar.bottomAnchor.constraint(equalTo: pickerView.topAnchor)
        ])
        
        self.pickerView.alpha = 1
        self.toolbar.alpha = 1
    }

    @objc private func cancelPicker() {
        
        
        UIView.animate(withDuration: 0.5) {
            
            self.pickerView.alpha = 0
            self.toolbar.alpha = 0
            
        }
        
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            
            if self.pickerView.alpha == 0 {
                
                self.pickerView.removeFromSuperview()
                self.toolbar.removeFromSuperview()
                
            }
            
        }
        
        
        
    }

    @objc private func donePicker() {
        let selectedIndex = pickerView.selectedRow(inComponent: 0)
        let title = pickerData[selectedIndex]
        
        if title == "GPT 4" {
            checkAccountStatus()
        } else {
            global_gpt = "gpt-3.5-turbo"
            selectedGpt = title
            
            gptButton.setTitle(title, for: .normal)
            cancelPicker()
            toolbar.removeFromSuperview()
        }
        
       
    }
    
    
    
    func checkAccountStatus() {
        
        if let passEligible = _AppCoreData.userDataSource.value?.passEligible {
            
            if passEligible {
                
                global_gpt = "gpt-4"
                selectedGpt = "GPT 4"
                
                gptButton.setTitle("GPT 4", for: .normal)
                cancelPicker()
                toolbar.removeFromSuperview()
                
            } else {
                
                checkPlan()
                
            }
            
        } else {
            
            checkPlan()
            
        }
        
    }
    
    func checkPlan() {
        
        IAPManager.shared.checkPermissions { result in
            if result == false {
                
                Dispatch.main.async {
                    
                    if let SVC = UIStoryboard(name: "Dashboard", bundle: nil).instantiateViewController(withIdentifier: "SubcriptionVC") as? SubcriptionVC {
                        
                        let nav = UINavigationController(rootViewController: SVC)

                        // Customize the navigation bar appearance
                        nav.navigationBar.barTintColor = .background
                        nav.navigationBar.tintColor = .white
                        nav.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]

                        nav.modalPresentationStyle = .fullScreen
                        self.present(nav, animated: true, completion: nil)
                    }
                    
                }
                
            } else {
             
                Dispatch.main.async {
                
                    global_gpt = "gpt-4"
                    self.selectedGpt = "GPT 4"
                    
                    self.gptButton.setTitle("GPT 4", for: .normal)
                    self.cancelPicker()
                    self.toolbar.removeFromSuperview()
                    
                }
  
            }
        }
        
        
    }
    
    
    func checkPlanForToken() {
        
        IAPManager.shared.checkPermissions { result in
            if result == false {
                
                isPro = false
                self.checkTokenLimit()
                
            } else {
             
                isPro = true
  
            }
        }
        
        
    }
    
    
    @objc func metaButtonTapped() {
        // Code for button 1
        
        if let SBMVC = UIStoryboard(name: "Dashboard", bundle: nil).instantiateViewController(withIdentifier: "SB_MetaVC") as? SB_MetaVC {
            
            SBMVC.gameId = self.gameId
            SBMVC.gameName = self.name
            self.navigationController?.pushViewController(SBMVC, animated: true)
            
        }
       
    }
    
    
    func checkTokenLimit() {
        
        APIManager().getUsedToken { result in
            switch result {
            case .success(let apiResponse):
   
                if let data = apiResponse.body, let remainToken = data["remainToken"] as? Int {
                    
                    if remainToken > 0 {
                        isTokenLimit = false
                    } else {
                        isTokenLimit = true
                    }
                    
                } else {
                    isTokenLimit = true
                }
              
            case .failure(let error):
                
                isTokenLimit = true
                print(error)
                
            }
        }
        
    }

  
}
