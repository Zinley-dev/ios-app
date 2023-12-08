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
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        print("SB_ChatBot is being deallocated.")
    }

    let backButton: UIButton = UIButton(type: .custom)
    let gptButton = UIButton(type: .custom)
    let toolbarActions = ToolbarActions()
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
        setupNavBar()
        presentSwiftLoader()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) { [weak self] in
            self?.setupWithoutMeta()
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
        setupNavBar()
        
        global_gpt = "gpt-3.5-turbo-16k-0613"
        selectedGpt = "GPT 3.5 turbo"
        setupClearAndGptButtons()
        
    }
    
    
    func setupNavBar() {
        
        let navigationBarAppearance = UINavigationBarAppearance()
        navigationBarAppearance.configureWithOpaqueBackground()
        navigationBarAppearance.backgroundColor = .white
        navigationBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.black]
        navigationBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.black]
        
        self.navigationController?.navigationBar.standardAppearance = navigationBarAppearance
        self.navigationController?.navigationBar.scrollEdgeAppearance = navigationBarAppearance
        
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

        if let backImage = UIImage(named: "back-black") {
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
        navigationItem.title = "SB ChatBot"

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
                if let clearImage = UIImage(named: "x-lightmode")?.resize(targetSize: CGSize(width: 15, height: 15)) {
                    let imageSize = CGSize(width: 15, height: 15)
                    let resizedImage = clearImage.resize(targetSize: imageSize)
                    let clearButton = UIButton(type: .system)
                    clearButton.tintColor = .black
                    clearButton.setImage(resizedImage, for: [])
                    clearButton.addTarget(self, action: #selector(self?.clearTapped), for: .touchUpInside)
                    clearButton.isEnabled = !isDisabled

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
            pickerLabel?.backgroundColor = UIColor.lightGray // change to light gray
            pickerLabel?.font = FontManager.shared.roboto(.Regular, size: 15)
            pickerLabel?.textAlignment = .center
        }
        if pickerData[row] != "" {
            pickerLabel?.text = pickerData[row]
        } else {
            pickerLabel?.text = "Error loading"
        }

        pickerLabel?.textColor = UIColor.black // change to black

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
    
}
