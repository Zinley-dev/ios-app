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

    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupButtons()
        global_gameId = gameId
        global_gameName = name
        global_gpt = "gpt-3.5-turbo-0301"
        selectedGpt = "GPT 3.5"
        
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
        
        setupClearAndGptButtons()
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
                    self?.gptButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
                    
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
            global_gpt = "gpt-4-0314"
            selectedGpt = title
        } else {
            global_gpt = "gpt-3.5-turbo"
            selectedGpt = title
        }
        
        gptButton.setTitle(title, for: .normal)
        cancelPicker()
        toolbar.removeFromSuperview()
    }
    
}
