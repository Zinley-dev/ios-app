//
//  SettingViewController.swift
//  Stitchbox
//
//  Created by Khanh Duy Nguyen on 12/17/22.
//


import UIKit
import RxSwift
import RxCocoa

class SettingViewController: UIViewController, ControllerType {
    
    typealias ViewModelType = SettingViewModel
    
    // MARK: - Properties
    private var viewModel: ViewModelType! = ViewModelType()
    private let disposeBag = DisposeBag()
    
    
    // MARK: - UI
    @IBOutlet var logoutButton: UIButton?
    
    @IBOutlet var allowChallengeButton: CardButton?
    @IBOutlet var autoPlaySoundButton: CardButton?
    @IBOutlet var autoMinimizeButton: CardButton?
    @IBOutlet var allowDiscordLinkButton: CardButton?
    
    
    @IBOutlet var challengeNotificationsButton: CardButton?
    @IBOutlet var commentNotificationsButton: CardButton?
    @IBOutlet var followNotificationsButton: CardButton?
    @IBOutlet var highlightNotificationsButton: CardButton?
    @IBOutlet var mentionNotificationsButton: CardButton?
    @IBOutlet var messageNotificationsButton: CardButton?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if hidesBottomBarWhenPushed {
            if self.tabBarController is DashboardTabBarController {
                print("yes")
                let tbctrl = self.tabBarController as! DashboardTabBarController
                tbctrl.button.isHidden = true
            }
        }
    }
   
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        bindUI(with: viewModel)
        bindAction(with: viewModel)
        setUpNavigationBar()
        viewModel.getAPISetting()
        presentLoading()
    }
    // MARK: - Functions
    func bindUI(with viewModel: SettingViewModel) {
        
        /*
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
            .disposed(by: disposeBag)*/
        
        viewModel.output.successObservable
            .subscribe(onNext: { successMessage in
                switch successMessage{
                case .logout:
                    RedirectionHelper.redirectToLogin()
                case .updateState:
                    DispatchQueue.main.async {
                        self.dismiss(animated: true)
                    }
                case .other:
                    break
                }
            })
            .disposed(by: disposeBag)
        
        viewModel.output.allowChallenge.subscribe{value in
            
            DispatchQueue.main.async {
                if value != self.allowChallengeButton?.switchbtn?.isOn {
                    print(value)
                    self.allowChallengeButton?.switchbtn?.setOn(value, animated: true)
                }
            }
        }.disposed(by: disposeBag)
        
        viewModel.output.autoPlaySound.subscribe{value in
            
            DispatchQueue.main.async {
                if value != self.autoPlaySoundButton?.switchbtn?.isOn {
                    print(value)
                    self.autoPlaySoundButton?.switchbtn?.setOn(value, animated: true)
                }
            }
        }.disposed(by: disposeBag)
        
        viewModel.output.autoMinimize.subscribe{value in
            
            DispatchQueue.main.async {
                if value != self.autoMinimizeButton?.switchbtn?.isOn {
                    print(value)
                    self.autoMinimizeButton?.switchbtn?.setOn(value, animated: true)
                }
            }
        }.disposed(by: disposeBag)
        
        viewModel.output.allowDiscordLink.subscribe{value in
            
            DispatchQueue.main.async {
                if value != self.allowDiscordLinkButton?.switchbtn?.isOn {
                    print(value)
                    self.allowDiscordLinkButton?.switchbtn?.setOn(value, animated: true)
                }
            }
        }.disposed(by: disposeBag)
        
        viewModel.output.challengeNotification.subscribe{value in
            
            DispatchQueue.main.async {
                if value != self.challengeNotificationsButton?.switchbtn?.isOn {
                    print(value)
                    self.challengeNotificationsButton?.switchbtn?.setOn(value, animated: true)
                }
            }
        }.disposed(by: disposeBag)
        
        viewModel.output.commentNotification.subscribe{value in
            
            DispatchQueue.main.async {
                if value != self.commentNotificationsButton?.switchbtn?.isOn {
                    print(value)
                    self.commentNotificationsButton?.switchbtn?.setOn(value, animated: true)
                }
            }
        }.disposed(by: disposeBag)
        
        viewModel.output.followNotification.subscribe{value in
            
            DispatchQueue.main.async {
                if value != self.followNotificationsButton?.switchbtn?.isOn {
                    print(value)
                    self.followNotificationsButton?.switchbtn?.setOn(value, animated: true)
                }
            }
        }.disposed(by: disposeBag)
        
        viewModel.output.highlightNotification.subscribe{value in
            
            DispatchQueue.main.async {
                if value != self.highlightNotificationsButton?.switchbtn?.isOn {
                    print(value)
                    self.highlightNotificationsButton?.switchbtn?.setOn(value, animated: true)
                }
            }
        }.disposed(by: disposeBag)
        
        viewModel.output.mentionNotification.subscribe{value in
            
            DispatchQueue.main.async {
                if value != self.mentionNotificationsButton?.switchbtn?.isOn {
                    print(value)
                    self.mentionNotificationsButton?.switchbtn?.setOn(value, animated: true)
                }
            }
        }.disposed(by: disposeBag)
        
        viewModel.output.messageNotification.subscribe{value in
            
            DispatchQueue.main.async {
                if value != self.messageNotificationsButton?.switchbtn?.isOn {
                    print(value)
                    self.messageNotificationsButton?.switchbtn?.setOn(value, animated: true)
                }
            }
        }.disposed(by: disposeBag)
        
        
    }
    
    func bindAction(with viewModel: SettingViewModel) {
        logoutButton?.rx.tap.subscribe(viewModel.action.logOutDidTap).disposed(by: disposeBag)
        
        allowChallengeButton?.switchbtn?.rx
            .isOn.changed
            .withLatestFrom((allowChallengeButton?.switchbtn?.rx.value)!)
            .subscribe{ value in
                print(value)
                viewModel.input.allowChallenge.onNext(value)
                viewModel.action.edit.onNext(())
            }
            .disposed(by: disposeBag)
        
        autoMinimizeButton?.switchbtn?.rx
            .isOn.changed
            .withLatestFrom((autoMinimizeButton?.switchbtn?.rx.value)!)
            .subscribe{ value in
                print(value)
                viewModel.input.autoMinimize.onNext(value)
                viewModel.action.edit.onNext(())
            }
            .disposed(by: disposeBag)
        
        autoPlaySoundButton?.switchbtn?.rx
            .isOn.changed //handle rigorous user switching
            .withLatestFrom((autoPlaySoundButton?.switchbtn?.rx.value)!)
            .subscribe{ value in
                print(value)
                viewModel.input.autoPlaySound.onNext(value)
                viewModel.action.edit.onNext(())
            }
            .disposed(by: disposeBag)
        
        allowDiscordLinkButton?.switchbtn?.rx
            .isOn.changed
            .withLatestFrom((allowDiscordLinkButton?.switchbtn?.rx.value)!)
            .subscribe{ value in
                print(value)
                viewModel.input.allowDiscordLink.onNext(value)
                viewModel.action.edit.onNext(())
            }
            .disposed(by: disposeBag)
        
        challengeNotificationsButton?.switchbtn?.rx
            .isOn.changed
            .withLatestFrom((challengeNotificationsButton?.switchbtn?.rx.value)!)
            .subscribe{ value in
                print(value)
                viewModel.input.challengeNotification.onNext(value)
                viewModel.action.edit.onNext(())
            }
            .disposed(by: disposeBag)
        
        commentNotificationsButton?.switchbtn?.rx
            .isOn.changed
            .withLatestFrom((commentNotificationsButton?.switchbtn?.rx.value)!)
            .subscribe{ value in
                print(value)
                viewModel.input.commentNotification.onNext(value)
                viewModel.action.edit.onNext(())
            }
            .disposed(by: disposeBag)
        
        followNotificationsButton?.switchbtn?.rx
            .isOn.changed
            .withLatestFrom((followNotificationsButton?.switchbtn?.rx.value)!)
            .subscribe{ value in
                print(value)
                viewModel.input.followNotification.onNext(value)
                viewModel.action.edit.onNext(())
            }
            .disposed(by: disposeBag)
        
        highlightNotificationsButton?.switchbtn?.rx
            .isOn.changed
            .withLatestFrom((highlightNotificationsButton?.switchbtn?.rx.value)!)
            .subscribe{ value in
                print(value)
                viewModel.input.highlightNotification.onNext(value)
                viewModel.action.edit.onNext(())
            }
            .disposed(by: disposeBag)
        
        mentionNotificationsButton?.switchbtn?.rx
            .isOn.changed
            .withLatestFrom((mentionNotificationsButton?.switchbtn?.rx.value)!)
            .subscribe{ value in
                print(value)
                viewModel.input.mentionNotification.onNext(value)
                viewModel.action.edit.onNext(())
            }
            .disposed(by: disposeBag)
        
        messageNotificationsButton?.switchbtn?.rx
            .isOn.changed
            .withLatestFrom((messageNotificationsButton?.switchbtn?.rx.value)!)
            .subscribe{ value in
                print(value)
                viewModel.input.messageNotification.onNext(value)
                viewModel.action.edit.onNext(())
            }
            .disposed(by: disposeBag)
    }
    
    
}


#if canImport(SwiftUI) && DEBUG
import SwiftUI

struct SettingViewControllerRepresentable: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UIViewController {
        return UIStoryboard(name: "Dashboard", bundle: nil).instantiateViewController(withIdentifier: "SETTING")
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        
    }
    
    typealias UIViewControllerType = UIViewController;
    
}

@available(iOS 13, *)
struct SettingSwitchingView_Preview: PreviewProvider {
    static var previews: some View {
        // view controller using programmatic UI
        VStack{
            SettingViewControllerRepresentable()
        }
    }
}
#endif

extension UIViewController {
    func setUpNavigationBar() {
        navigationController?.navigationBar.tintColor = .text
        let imgBackArrow = UIImage(named: "dropdownleft")
        navigationController?.navigationBar.backIndicatorImage = imgBackArrow
        navigationController?.navigationBar.backIndicatorTransitionMaskImage = imgBackArrow
        navigationController?.navigationBar.topItem?.title = ""
        
        
    }
}
