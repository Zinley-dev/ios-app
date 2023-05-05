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
    let toolbarActions = ToolbarActions()
    var name = ""
    var short_name = ""
    var gameId = ""
    var subscriptions = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupButtons()
        global_gameId = gameId
        global_gameName = name
        
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
        
        Publishers.CombineLatest(toolbarActions.$clearAction, toolbarActions.$isClearActionDisabled)
                    .sink { [weak self] clearAction, isDisabled in
                        let barButton = UIBarButtonItem(title: "Clear", style: .plain, target: self, action: #selector(self?.clearTapped))
                        barButton.isEnabled = !isDisabled
                        barButton.tintColor = .white
                        self?.navigationItem.rightBarButtonItem = barButton
                    }
                    .store(in: &subscriptions)
    }
    
    @objc func clearTapped() {
        toolbarActions.clearAction?()
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

    @objc func onClickBack(_ sender: AnyObject) {
            if let navigationController = self.navigationController {
                navigationController.popViewController(animated: true)
            }
        }
    
    
    
}
