//
//  SB-ChatBot.swift
//  Stitchbox
//
//  Created by Khoi Nguyen on 4/14/23.
//

import UIKit

class SB_ChatBot: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextViewDelegate {

    
    let inputBackgroundView = UIView()
    
    let backButton: UIButton = UIButton(type: .custom)
    var bottomConstraint: NSLayoutConstraint!
    let chatTableView: UITableView = UITableView()
    let userInputTextView: UITextView = UITextView()
    let sendButton: UIButton = UIButton(type: .system)
    
    // Sample chat data
    var messages: [(String, Bool)] = [("Welcome to SB ChatBot, how can I help you?", false)] // (message, isUserMessage)
    
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
        chatTableView.register(ChatCell.self, forCellReuseIdentifier: "chatCell")
        
    }
  
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func setupInputContainerView() {
            inputBackgroundView.backgroundColor = .darkGray
            inputBackgroundView.layer.cornerRadius = 10
            inputBackgroundView.layer.shadowColor = UIColor.black.cgColor
            inputBackgroundView.layer.shadowOffset = CGSize(width: 0, height: -1)
            inputBackgroundView.layer.shadowOpacity = 0.1
            inputBackgroundView.layer.shadowRadius = 2
        }
    
    func setupChatTableView() {
        chatTableView.dataSource = self
        chatTableView.delegate = self
        chatTableView.register(UITableViewCell.self, forCellReuseIdentifier: "chatCell")
        chatTableView.separatorStyle = .none
        chatTableView.rowHeight = UITableView.automaticDimension
        chatTableView.estimatedRowHeight = 66
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
        /*
         userInputTextView.layer.borderWidth = 1
         userInputTextView.layer.borderColor = UIColor.lightGray.cgColor
         userInputTextView.layer.cornerRadius = 5
        
        */
         userInputTextView.textContainerInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
         userInputTextView.delegate = self
         userInputTextView.isScrollEnabled = false
         userInputTextView.backgroundColor = .darkGray
         userInputTextView.textColor = .white
     }

    func setupLayout() {
        chatTableView.translatesAutoresizingMaskIntoConstraints = false
        userInputTextView.translatesAutoresizingMaskIntoConstraints = false
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        inputBackgroundView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(chatTableView)
        view.addSubview(inputBackgroundView)
        view.addSubview(userInputTextView)
        view.addSubview(sendButton)

        bottomConstraint = userInputTextView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)

        NSLayoutConstraint.activate([
            chatTableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            chatTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            chatTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            inputBackgroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            inputBackgroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            inputBackgroundView.bottomAnchor.constraint(equalTo: userInputTextView.bottomAnchor, constant: 10),
            inputBackgroundView.topAnchor.constraint(equalTo: userInputTextView.topAnchor, constant: -10),

            chatTableView.bottomAnchor.constraint(equalTo: inputBackgroundView.topAnchor, constant: -10),

            userInputTextView.heightAnchor.constraint(greaterThanOrEqualToConstant: 40),
            userInputTextView.widthAnchor.constraint(greaterThanOrEqualToConstant: 100),
            userInputTextView.widthAnchor.constraint(lessThanOrEqualToConstant: view.frame.width * 0.75),
            userInputTextView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            bottomConstraint,

            sendButton.widthAnchor.constraint(equalToConstant: 44),
            sendButton.leadingAnchor.constraint(equalTo: userInputTextView.trailingAnchor, constant: 8),
            sendButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            sendButton.bottomAnchor.constraint(equalTo: userInputTextView.bottomAnchor)
        ])
        
        userInputTextView.font = UIFont.systemFont(ofSize: 13) // Set the font size here
        
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "chatCell", for: indexPath) as! ChatCell
        let message = messages[indexPath.row]

        cell.textLabel?.text = message.0
        cell.textLabel?.font = UIFont.systemFont(ofSize: 15) // Set the font size here
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.lineBreakMode = .byWordWrapping

        if message.1 { // User message
            cell.textLabel?.textColor = UIColor.black
            cell.textLabel?.textAlignment = .left
            cell.backgroundColor = .tertiary
            
            if let avatarUrl = _AppCoreData.userDataSource.value?.avatarURL, avatarUrl != "" {
                
                let url = URL(string: avatarUrl)
                cell.avatarImageView.load(url: url!, str: avatarUrl)
                 
            } else {
                
                cell.avatarImageView.image = UIImage(named: "defaultuser")
                
            }
            
            cell.avatarImageView.trailingAnchor.constraint(equalTo: cell.trailingAnchor, constant: -8).isActive = true
            cell.textLabel?.leadingAnchor.constraint(greaterThanOrEqualTo: cell.leadingAnchor, constant: 8).isActive = true
            cell.textLabel?.trailingAnchor.constraint(equalTo: cell.avatarImageView.leadingAnchor, constant: -8).isActive = true
        } else { // Chatbot message
            cell.textLabel?.textColor = UIColor.white
            cell.textLabel?.textAlignment = .left
            cell.backgroundColor = .background
            cell.avatarImageView.image = UIImage(named: "defaultuser")
            cell.avatarImageView.leadingAnchor.constraint(equalTo: cell.leadingAnchor, constant: 8).isActive = true
            cell.textLabel?.leadingAnchor.constraint(equalTo: cell.avatarImageView.trailingAnchor, constant: 8).isActive = true
            cell.textLabel?.trailingAnchor.constraint(lessThanOrEqualTo: cell.trailingAnchor, constant: -8).isActive = true
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
    
    

    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let message = messages[indexPath.row]
        
        showNote(text: "Chat copied")
        UIPasteboard.general.string = message.0
        
    }
        
    
}
