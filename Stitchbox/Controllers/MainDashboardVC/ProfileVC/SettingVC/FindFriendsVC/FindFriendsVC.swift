//
//  FindFriendsVC.swift
//  Stitchbox
//
//  Created by Khoi Nguyen on 1/17/23.
//

import UIKit
import Contacts
import ContactsUI
import FLAnimatedImage
import AsyncDisplayKit
import MessageUI

class FindFriendsVC: UIViewController, MFMessageComposeViewControllerDelegate {

    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var loadingView: UIView!
    
    let backButton: UIButton = UIButton(type: .custom)
    var contactLists = [FindFriendsModel]()
    var tableNode: ASTableNode!
    
    required init?(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
        self.tableNode = ASTableNode(style: .plain)
        self.wireDelegates()
  
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupButtons()
        setupTableNode()
        checkIfContactPermissionGranted()
        
    }
    
    @IBAction func syncContactBtnPressed(_ sender: Any) {
        
        fetchContacts()
        
    }
    
}

extension FindFriendsVC {
    
    func setupTableNode() {
        
        contentView.addSubview(tableNode.view)
        
        self.tableNode.view.translatesAutoresizingMaskIntoConstraints = false
        self.tableNode.view.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 0).isActive = true
        self.tableNode.view.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 0).isActive = true
        self.tableNode.view.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: 0).isActive = true
        self.tableNode.view.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: 0).isActive = true

        // Do any additional setup after loading the view.
        
        self.applyStyle()
        
        
    }
    
    func applyStyle() {
        
        self.tableNode.view.separatorStyle = .none
        self.tableNode.view.separatorColor = UIColor.lightGray
        self.tableNode.view.isPagingEnabled = false
        self.tableNode.view.backgroundColor = UIColor.clear
        self.tableNode.view.showsVerticalScrollIndicator = false
         
    }
    
    func wireDelegates() {
        
        self.tableNode.delegate = self
        self.tableNode.dataSource = self
        
    }
    
}


extension FindFriendsVC {
    
    
    func checkIfContactPermissionGranted() {
        
        let authorizationStatus = CNContactStore.authorizationStatus(for: .contacts)
        
        if authorizationStatus == .authorized {
            
            loadingView.isHidden = true
            fetchContacts()
            
        }
        
    }
    
    func fetchContacts() {
        let store = CNContactStore()
        store.requestAccess(for: .contacts) { (granted, error) in
            if let error = error {
                print("failed to request access", error)
                if error._code == 100 {
                    self.showErrorAlert("Oops!", msg: "You have denied to grant permission to access contacts before. Please turn it on manually in your phone settings.")
                }
                return
            }
            if granted {
                self.loadingView.isHidden = true
                let keys = [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactPhoneNumbersKey, CNContactImageDataKey, CNContactImageDataAvailableKey]
                let request = CNContactFetchRequest(keysToFetch: keys as [CNKeyDescriptor])
                do {
                    DispatchQueue.global().async {
                        do {
                            try store.enumerateContacts(with: request, usingBlock: { (contact, stopPointer) in
                                if contact.phoneNumbers.first?.value.stringValue != nil {
                                    var dict = ["firstName": contact.givenName, "familyName": contact.familyName, "phoneNumber": contact.phoneNumbers.first?.value.stringValue.stringByRemovingWhitespaces.replacingOccurrences(of: "(", with: "").replacingOccurrences(of: ")", with: "").replacingOccurrences(of: "-", with: "")] as? [String: Any]
                                    if contact.imageDataAvailable {
                                        dict!.updateValue(contact.imageData!, forKey: "imageData")
                                    }
                                    let contactList = FindFriendsModel(FindFriendsModel: dict! as Dictionary<String, Any>)
                                    contactList._isIn = false
                                    self.contactLists.append(contactList)
                                    
                                }
                            })
                            
                            DispatchQueue.main.async {
                                self.tableNode.reloadData()
                            }
                        } catch let error {
                            print("Failed to enumerate contact", error)
                        }
                    }
                }
            } else {
                print("access denied")
            }
        }
    }


    

    
    
}

extension FindFriendsVC {
    
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
        navigationItem.title = "Find Friends"
        let backButtonBarButton = UIBarButtonItem(customView: backButton)

        self.navigationItem.leftBarButtonItem = backButtonBarButton


        
    }

    
    @objc func onClickBack(_ sender: AnyObject) {
        if let navigationController = self.navigationController {
            navigationController.popViewController(animated: true)
        }
    }
    
    
}


extension FindFriendsVC: ASTableDelegate {

    func tableNode(_ tableNode: ASTableNode, constrainedSizeForRowAt indexPath: IndexPath) -> ASSizeRange {
        
        let width = UIScreen.main.bounds.size.width;
        
        let min = CGSize(width: width, height: 40);
        let max = CGSize(width: width, height: 1000);
        return ASSizeRangeMake(min, max);
           
    }
    
    
    func shouldBatchFetch(for tableNode: ASTableNode) -> Bool {
        
        return false
        
    }
    
       
}

extension FindFriendsVC: ASTableDataSource {
    
    func tableNode(_ tableNode: ASTableNode, numberOfRowsInSection section: Int) -> Int {
        
        
        if self.contactLists.count == 0 {
            
            tableNode.view.setEmptyMessage("No user")
            
        } else {
            tableNode.view.restore()
        }
        
        
        return self.contactLists.count
        
        
    }
    
    func tableNode(_ tableNode: ASTableNode, nodeBlockForRowAt indexPath: IndexPath) -> ASCellNodeBlock {
        
     
        let user = self.contactLists[indexPath.row]
       
        return {
            var node: FindFriendsNode!
            
            node = FindFriendsNode(with: user)
            node.neverShowPlaceholders = true
            node.debugName = "Node \(indexPath.row)"
            
            return node
        }
        
    }
    
    func tableNode(_ tableNode: ASTableNode, didSelectRowAt indexPath: IndexPath) {
        
        
        
        if contactLists[indexPath.row]._userUID != nil {
            
            
            
        } else {
            
            if let phoneNumber = contactLists[indexPath.row].phoneNumber  {
                
                guard let userDataSource = _AppCoreData.userDataSource.value, let userUID = userDataSource.userID, userUID != "" else {
                    print("Sendbird: Can't get userUID")
                    return
                }
                
                
                let composeVC = MFMessageComposeViewController()
                composeVC.messageComposeDelegate = self

                // Configure the fields of the interface.
                composeVC.recipients = [phoneNumber]
                composeVC.body = "[Stitchbox] I am \(userDataSource.userName ?? "") on Stitchbox. To download the app and stay connected with your gaming friends. tap:https://apps.apple.com/us/app/stitchbox/id1660843872"

                // Present the view controller modally.
                if MFMessageComposeViewController.canSendText() {
                    self.present(composeVC, animated: true, completion: nil)
                } else {
                    print("Can't send messages.")
                
                }
                
            }
            
        }
    }
        
}

extension FindFriendsVC {
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        
        
        switch result {
            case .cancelled:
                //showNote(text: "Invitation cancelled.")
                break
            case .sent:
                showNote(text: "Thank you, your invitation has been sent.")
                break
            case .failed:
                showNote(text: "Thank you, but your invitation is failed to send.")
                break
            default:
                break
        }
        
        controller.dismiss(animated: true)
        
    }
    
}

extension FindFriendsVC {
    
    func showErrorAlert(_ title: String, msg: String) {
                                                                                                                                           
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        
                                                                                       
        present(alert, animated: true, completion: nil)
        
    }
    
}
