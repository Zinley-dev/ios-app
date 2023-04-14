//
//  SB-ChatBot.swift
//  Stitchbox
//
//  Created by Khoi Nguyen on 4/14/23.
//

import UIKit

class SB_ChatBot: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextViewDelegate {

    
    let inputContainerView: UIStackView = UIStackView()
    let backButton: UIButton = UIButton(type: .custom)
    var bottomConstraint: NSLayoutConstraint!
    let chatTableView: UITableView = UITableView()
    let userInputTextView: UITextView = UITextView()
    let sendButton: UIButton = UIButton(type: .system)

    // Sample chat data
    var messages: [(String, Bool)] = [("Hello, how can I help you?", false)] // (message, isUserMessage)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupButtons()
        setupChatTableView()
        setupUserInputTextView()
        setupSendButton()
        setupInputContainerView()
        setupKeyboardNotifications()
        setupTapGestureToDismissKeyboard()
        setupLayout()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let navigationBarAppearance = UINavigationBarAppearance()
        navigationBarAppearance.configureWithOpaqueBackground()
        navigationBarAppearance.backgroundColor = .background
        navigationBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        navigationBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func setupInputContainerView() {
            inputContainerView.axis = .horizontal
            inputContainerView.spacing = 10
            inputContainerView.alignment = .center
            inputContainerView.addArrangedSubview(userInputTextView)
            inputContainerView.addArrangedSubview(sendButton)
        }
    
    func setupChatTableView() {
        chatTableView.dataSource = self
        chatTableView.delegate = self
        chatTableView.register(UITableViewCell.self, forCellReuseIdentifier: "chatCell")
        chatTableView.separatorStyle = .none
        chatTableView.rowHeight = UITableView.automaticDimension
        chatTableView.estimatedRowHeight = 44
        chatTableView.backgroundColor = .background
    }
  
    
    func setupSendButton() {
        if let sendImage = UIImage(named: "send2") {
            sendButton.setImage(sendImage, for: .normal)
        }
        sendButton.addTarget(self, action: #selector(sendButtonTapped), for: .touchUpInside)
    }
    
    func setupTapGestureToDismissKeyboard() {
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissCurrentKeyboard))
            view.addGestureRecognizer(tapGesture)
        }
    

    func setupUserInputTextView() {
            userInputTextView.layer.borderWidth = 1
            userInputTextView.layer.cornerRadius = 5
            userInputTextView.textContainerInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
            userInputTextView.delegate = self
            userInputTextView.backgroundColor = .darkGray
        }

    func setupLayout() {
            chatTableView.translatesAutoresizingMaskIntoConstraints = false
            userInputTextView.translatesAutoresizingMaskIntoConstraints = false
            sendButton.translatesAutoresizingMaskIntoConstraints = false
            inputContainerView.translatesAutoresizingMaskIntoConstraints = false

            view.addSubview(chatTableView)
            view.addSubview(inputContainerView)

            bottomConstraint = inputContainerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)

            NSLayoutConstraint.activate([
                chatTableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
                chatTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                chatTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),

                inputContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
                inputContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
                bottomConstraint,

                chatTableView.bottomAnchor.constraint(equalTo: inputContainerView.topAnchor, constant: -10),

                userInputTextView.heightAnchor.constraint(equalToConstant: 40),
                sendButton.heightAnchor.constraint(equalTo: userInputTextView.heightAnchor)
            ])
        }



        
        func setupKeyboardNotifications() {
            NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        }
    
    // UITableViewDataSource
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return messages.count
        }
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "chatCell", for: indexPath)
        let message = messages[indexPath.row]
        
        cell.textLabel?.text = message.0
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.lineBreakMode = .byWordWrapping
        
        
        if message.1 {
            cell.textLabel?.textColor = UIColor.black
            cell.textLabel?.textAlignment = .right
            cell.backgroundColor = .lightGray
        } else {
            cell.textLabel?.textColor = UIColor.white
            cell.textLabel?.textAlignment = .left
            cell.backgroundColor = .background
        }
        
        cell.selectionStyle = .none
        return cell
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
        navigationItem.title = "SB ChatBot"

        self.navigationItem.leftBarButtonItem = backButtonBarButton


        
    }

    
    func showErrorAlert(_ title: String, msg: String) {
                                                                                                                                           
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default)
        
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
        
    }

    
}

extension SB_ChatBot {
    
    @objc func onClickBack(_ sender: AnyObject) {
        if let navigationController = self.navigationController {
            navigationController.popViewController(animated: true)
        }
    }
    
    @objc func sendButtonTapped() {
           // Handle send button tap action
           
           // Add user message to chat
           if let userMessage = userInputTextView.text, !userMessage.isEmpty {
               messages.append((userMessage, true))
               chatTableView.reloadData()
               userInputTextView.text = ""
           }
           
           // Add chatbot response here
           // let chatbotResponse = ...
           // messages.append((chatbotResponse, false))
           // chatTableView.reloadData()
       }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double ?? 0.25
            let options = UIView.AnimationOptions(rawValue: notification.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt ?? 0 << 16)
            bottomConstraint.constant = -keyboardSize.height
            UIView.animate(withDuration: duration, delay: 0, options: options, animations: {
                self.view.layoutIfNeeded()
            }, completion: nil)
        }
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double ?? 0.25
        let options = UIView.AnimationOptions(rawValue: notification.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt ?? 0 << 16)
        bottomConstraint.constant = -20
        UIView.animate(withDuration: duration, delay: 0, options: options, animations: {
            self.view.layoutIfNeeded()
        }, completion: nil)
    }

    
    
    @objc func dismissCurrentKeyboard() {
        view.endEditing(true)
    }

    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
            let currentText = textView.text ?? ""
            guard let stringRange = Range(range, in: currentText) else { return false }
            let updatedText = currentText.replacingCharacters(in: stringRange, with: text)
            return updatedText.count <= 500
        }
    
}
