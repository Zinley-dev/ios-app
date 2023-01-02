//
//  EditProfileViewController.swift
//  Stitchbox
//
//  Created by Khanh Duy Nguyen on 12/24/22.
//

import RxCocoa
import RxSwift
import EzPopup

class EditProfileViewController: UIViewController, ControllerType {
    
    
    typealias ViewModelType = EditProfileViewModel
    
    // MARK: - Properties
    private var viewModel: ViewModelType! = ViewModelType()
    private let disposeBag = DisposeBag()
    private var finishBtn: UIButton?
    
    @IBOutlet var avatar: UIImageView?
    @IBOutlet var cover: UIImageView?
    @IBOutlet var username: UITextField?
    @IBOutlet var name: UITextField?
    @IBOutlet var birthday: UITextField?
    @IBOutlet var bio: UITextField?
    @IBOutlet var email: UILabel?
    @IBOutlet var phone: UILabel?
    
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        presentLoading()
        bindUI(with: viewModel)
        bindAction(with: viewModel)
        setUpNavigationBar()
        viewModel.getAPISetting()
        
        finishBtn = UIButton(type: .custom)
        finishBtn?.setImage(UIImage(named: "checkmark"), for: .normal)
        finishBtn?.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        finishBtn?.rx.tap.subscribe(self.viewModel.action.edit).disposed(by: disposeBag)
        let item1 = UIBarButtonItem(customView: finishBtn!)
        
        self.navigationItem.setRightBarButton(item1, animated: true)
    }
    func bindUI(with viewModel: EditProfileViewModel) {
        viewModel.output.errorsObservable
            .subscribe(onNext: { (error: Error) in
                DispatchQueue.main.async {
                    if (error._code == 900) {
                        self.navigationController?.pushViewController(CreateAccountViewController.create(), animated: true)
                    } else {
                        self.presentError(error: error)
                    }
                }
            })
            .disposed(by: disposeBag)
        
        viewModel.output.successObservable
            .subscribe(onNext: { successMessage in
                switch successMessage{
                case .logout:
                    RedirectionHelper.redirectToLogin()
                case .updateState:
                    DispatchQueue.main.async {
                        self.dismiss(animated: true)
                    }
                case .other(let message):
                    DispatchQueue.main.async {
                        self.presentMessage(message: message)
                    }
                }
            })
            .disposed(by: disposeBag)
        
        viewModel.output.avatar.subscribe{avatarURL in
            if avatarURL != "" {
                    self.avatar?.downloaded(from: avatarURL)
            }
        }.disposed(by: disposeBag)
        
        viewModel.output.cover.subscribe{coverURL in
            if coverURL != "" {
                    self.cover?.downloaded(from: coverURL)
            }
        }.disposed(by: disposeBag)
        
        viewModel.output.username.subscribe{username in
            DispatchQueue.main.async {
                self.username?.text = username
            }
        }.disposed(by: disposeBag)

        viewModel.output.name.subscribe{name in
            
            DispatchQueue.main.async {
                self.name?.text = name
            }
        }.disposed(by: disposeBag)
        
        viewModel.output.birthday.subscribe{birthday in
            
            DispatchQueue.main.async {
                self.birthday?.text = birthday
            }
        }.disposed(by: disposeBag)

        viewModel.output.bio.subscribe{bio in
            
            DispatchQueue.main.async {
                self.bio?.text = bio
            }
        }.disposed(by: disposeBag)

        viewModel.output.email.subscribe{email in
            
            DispatchQueue.main.async {
                self.email?.text = email
            }
        }.disposed(by: disposeBag)
        
        viewModel.output.phone.subscribe{phone in
            
            DispatchQueue.main.async {
                self.phone?.text = phone
            }
        }.disposed(by: disposeBag)
        
        username?.rx.text.orEmpty.subscribe(viewModel.input.username).disposed(by: disposeBag)
        name?.rx.text.orEmpty.subscribe(viewModel.input.name).disposed(by: disposeBag)
        bio?.rx.text.orEmpty.subscribe(viewModel.input.bio).disposed(by: disposeBag)
        birthday?.rx.text.orEmpty.subscribe(viewModel.input.birthday).disposed(by: disposeBag)
        
    }
    
    func bindAction(with viewModel: EditProfileViewModel) {
        
    }
    
    // MARK: - UI
    @IBAction func changeProfileImage() {
        
    }
    
    @IBAction func changeCoverImage() {
        
    }
    
    @IBAction func finishEdit() {
        
    }
    
    @IBAction func resetPasswordButton() {
        
    }
    

    
    
   
    
}


#if canImport(SwiftUI) && DEBUG
import SwiftUI

struct EditProfileViewControllerRepresentable: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UIViewController {
        return UIStoryboard(name: "Dashboard", bundle: nil).instantiateViewController(withIdentifier: "EDIT")
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        
    }
    
    typealias UIViewControllerType = UIViewController;
    
}

@available(iOS 13, *)
struct EditProfileSwitchingView_Preview: PreviewProvider {
    static var previews: some View {
        // view controller using programmatic UI
        VStack{
            EditProfileViewControllerRepresentable()
        }
    }
}
#endif


extension UIImageView {
    func downloaded(from url: URL, contentMode mode: ContentMode = .scaleAspectFit) {
        contentMode = mode
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data)
                else { return }
            DispatchQueue.main.async() { [weak self] in
                self?.image = image
            }
        }.resume()
    }
    func downloaded(from link: String, contentMode mode: ContentMode = .scaleAspectFit) {
        guard let url = URL(string: link) else { return }
        downloaded(from: url, contentMode: mode)
    }
}
