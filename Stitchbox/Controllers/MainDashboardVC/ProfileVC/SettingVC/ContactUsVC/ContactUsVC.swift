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
import RxSwift

class ContactUsVC: UIViewController, ControllerType {
    typealias ViewModelType = ContactUsViewModel
    
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
    
    let viewModel = ContactUsViewModel()
    let disposeBag = DisposeBag()
    
    
    override func viewDidLoad() {
        bindUI(with: viewModel)
        bindAction(with: viewModel)
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        setupButtons()
        setupInitialSetup()
    }
    func bindUI(with viewModel: ContactUsViewModel) {}
    
    func bindAction(with viewModel: ContactUsViewModel) {
        sendBtn.rx.tap.subscribe{
            _ in
            if self.ContactTxtView.text.count >= 35 {
                viewModel.action.submit.onNext((self.reportImg, self.ContactTxtView.text))
            }
        }.disposed(by: disposeBag)
        
        viewModel.output.successObservable.subscribe{
            result in
            DispatchQueue.main.async {
                self.navigationController?.popViewController(animated: true)
                showNote(text: "Report sent!")
            }
        }.disposed(by: disposeBag)
        
        viewModel.output.errorsObservable.subscribe{ (error) in
            DispatchQueue.main.async {
                self.showErrorAlert("Oops!", msg: error.error?.localizedDescription ?? "Unable to send report request, please try again.")
            }
        }.disposed(by: disposeBag)
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
        navigationItem.title = "Contact Us"
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
