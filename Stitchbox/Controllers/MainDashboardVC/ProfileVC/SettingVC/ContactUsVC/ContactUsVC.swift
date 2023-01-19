//
//  ContactUsVC.swift
//  Stitchbox
//
//  Created by Khoi Nguyen on 1/17/23.
//

import UIKit
import MobileCoreServices
import AVKit
import AVFoundation
import Alamofire

class ContactUsVC: UIViewController {

    let backButton: UIButton = UIButton(type: .custom)
    

    @IBOutlet weak var sendBtn: UIButton!
    @IBOutlet weak var ContactTxtView: UITextView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var reportPhotoHeight: NSLayoutConstraint!
    @IBOutlet weak var characterCountLbl: UILabel!
    
    
    var reportImg = [UIImage]()
    var reportUrl = [String]()
    var selectedIndex: Int!
    var selectedImg: UIImage!
    var isObserved: Bool!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupButtons()
        setupInitialSetup()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardShow),
                                               name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardHide),
                                               name: UIResponder.keyboardWillHideNotification, object: nil)
        
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        if isObserved == false {
            
            NotificationCenter.default.removeObserver(self, name: (NSNotification.Name(rawValue: "DeleteImg")), object: nil)
            
            
        }
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        self.view.endEditing(true)
        
    }
    
    // ibaction
    
    @IBAction func reportPhotoBtnPressed(_ sender: Any) {
        
        self.album()
        
        
    }
    
    
    @IBAction func sendBtnPressed(_ sender: Any) {
        
        if ContactTxtView.text != "   Tell us about your issues!", ContactTxtView.text.count > 35, ContactTxtView.text != "Tell us about your issues!" {
            
            //
            
            if reportImg.isEmpty {
                
                //sendSupportWithoutImage(Message: ContactTxtView.text)
                
                
            } else {
                
                //sendSupportWithImage(Message: ContactTxtView.text)
                
                
            }
            
            
        } else {
            
            showErrorAlert("Oops!", msg: "Please tell us your issues and provide us more than 35 characters description.")
            
        }
        
    }
    
    
}

extension ContactUsVC: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return reportImg.count
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ContactUsImageCell", for: indexPath) as? ContactUsImageCell {
            
            //cell.btn.addTarget(self, action: #selector(buttonSelected), for: .touchUpInside)
            let img = reportImg[indexPath.row]
            cell.closeBtn.tag = indexPath.row
            cell.closeBtn.addTarget(self, action: #selector(buttonSelected), for: .touchUpInside)
            cell.configureCell(img: img)
            return cell
            
        } else {
            
            
            return UICollectionViewCell()
            
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        selectedImg = reportImg[indexPath.row]
        selectedIndex = indexPath.row
 
        isObserved = true
        
        
        if let PVC = UIStoryboard(name: "Dashboard", bundle: nil).instantiateViewController(withIdentifier: "PhotoVC") as? PhotoVC {
            PVC.selectedImg = selectedImg
            self.navigationController?.pushViewController(PVC, animated: true)
            
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(ContactUsVC.DeleteImg), name: (NSNotification.Name(rawValue: "DeleteImg")), object: nil)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        
        return CGSize(width: 80, height: 80)
        
    }
    

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
    
        return 10.0
        
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0

    }
    
}

extension ContactUsVC: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        
        if ContactTxtView.text == "   Tell us about your issues!" {
            
            ContactTxtView.text = ""
            
        }
    }
    
    
    func textViewDidEndEditing(_ textView: UITextView) {
        
        if ContactTxtView.text == "" {
            
            ContactTxtView.text = "   Tell us about your issues!"
            
        }
        
    }
    
    
    func textViewDidChange(_ textView: UITextView) {
        
        if ContactTxtView.text != "Tell us about your issues!", ContactTxtView.text != "", ContactTxtView.text != "   Tell us about your issues!" {
            
            if ContactTxtView.text.count >= 35 {
                
                sendBtn.backgroundColor = .primary
                sendBtn.titleLabel?.textColor = .white
                
            } else {
                
                sendBtn.backgroundColor = .disableButtonBackground
                sendBtn.titleLabel?.textColor = .lightGray
                
            }

            characterCountLbl.text = "\(ContactTxtView.text.count) characters"
            
        } else {
            
            sendBtn.backgroundColor = .disableButtonBackground
            sendBtn.titleLabel?.textColor = .lightGray
            characterCountLbl.text = ""
            
            
        }
        
    }

    
}

extension ContactUsVC {
    
    @objc func handleKeyboardShow(notification: Notification) {
    
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
              
          
            
            UIView.animate(withDuration: 0, delay: 0, options: .curveEaseOut, animations:  {
                self.view.layoutIfNeeded()
            }, completion: { (completed) in
                
            })
        }
    }
    
    
    @objc func handleKeyboardHide(notification: Notification) {
        
      

        UIView.animate(withDuration: 0, delay: 0, options: .curveEaseOut, animations:  {
            self.view.layoutIfNeeded()
        }, completion: { (completed) in
            
        })
        
    }
    
    @objc func buttonSelected(sender: UIButton) {
        
        reportImg.remove(at: sender.tag)
        if reportImg.isEmpty {
            reportPhotoHeight.constant = 0
        } else {
            reportPhotoHeight.constant = 80
        }
        
        //
        self.collectionView.reloadData()
        
    }
    
    @objc func DeleteImg() {
        
        NotificationCenter.default.removeObserver(self, name: (NSNotification.Name(rawValue: "DeleteImg")), object: nil)
        isObserved = false
        if let index = selectedIndex {
            
            
            reportImg.remove(at: index)
            if reportImg.isEmpty {
                reportPhotoHeight.constant = 0
            } else {
                reportPhotoHeight.constant = 80
            }
            self.collectionView.reloadData()
            
        }
    
    }
    

    
}

extension ContactUsVC {
    
    func setupInitialSetup() {
        
        ContactTxtView.delegate = self
        ContactTxtView.text = "   Tell us about your issues!"
        reportPhotoHeight.constant = 0
        
        // delegate
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
    }
    
    func setupButtons() {
        
        setupBackButton()
       
        
    }
    
    
    func setupBackButton() {
        
        
        // Do any additional setup after loading the view.
        backButton.setImage(UIImage.init(named: "back_icn_white")?.resize(targetSize: CGSize(width: 13, height: 23)), for: [])
        backButton.addTarget(self, action: #selector(onClickBack(_:)), for: .touchUpInside)
        backButton.frame = CGRect(x: -10, y: 0, width: 15, height: 25)
        backButton.setTitleColor(UIColor.white, for: .normal)
        backButton.setTitle("     Contact Us", for: .normal)
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

extension ContactUsVC {
    
    func album() {
        
        self.getMediaFrom(kUTTypeImage as String)
       
    }
    
    func camera() {
        
        self.getMediaCamera(kUTTypeImage as String)
        
    }
    
    // get media
    
    func getMediaFrom(_ type: String) {
        
        let mediaPicker = UIImagePickerController()
        mediaPicker.delegate = self
        mediaPicker.allowsEditing = true
        mediaPicker.mediaTypes = [type as String]
        self.present(mediaPicker, animated: true, completion: nil)
    }
    
    func getMediaCamera(_ type: String) {
           
        let mediaPicker = UIImagePickerController()
        mediaPicker.delegate = self
        mediaPicker.allowsEditing = true
        mediaPicker.mediaTypes = [type as String] //UIImagePickerController.availableMediaTypes(for: .camera)!
        mediaPicker.sourceType = .camera
        self.present(mediaPicker, animated: true, completion: nil)
        
    }
    
    func getImage(image: UIImage) {
        
        reportImg.append(image)
        reportPhotoHeight.constant = 80.0
        collectionView.reloadData()
        
    }
    
}

extension ContactUsVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        
        if let editedImage = info[.editedImage] as? UIImage {
            getImage(image: editedImage)
        } else if let originalImage =
            info[.originalImage] as? UIImage {
            getImage(image: originalImage)
        }
        
        view.endEditing(true)
        self.dismiss(animated: true, completion: nil)
    }
    
    
}


extension ContactUsVC {
    
    func showErrorAlert(_ title: String, msg: String) {
                                                                                                                                           
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        
                                                                                       
        present(alert, animated: true, completion: nil)
        
    }
    
}
