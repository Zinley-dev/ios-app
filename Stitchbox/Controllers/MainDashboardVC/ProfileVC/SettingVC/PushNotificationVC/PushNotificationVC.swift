//
//  PushNotificationVC.swift
//  Stitchbox
//
//  Created by Khoi Nguyen on 1/17/23.
//

import UIKit
import RxSwift
import RxCocoa

class PushNotificationVC: UIViewController, ControllerType {
    typealias ViewModelType = SettingViewModel
    
    let backButton: UIButton = UIButton(type: .custom)
    
    @IBOutlet weak var PostsSwitch: UISwitch!
    @IBOutlet weak var CommentSwitch: UISwitch!
    @IBOutlet weak var MentionSwitch: UISwitch!
    @IBOutlet weak var FollowSwitch: UISwitch!
    @IBOutlet weak var MessageSwitch: UISwitch!
    
    let viewModel = SettingViewModel()
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        bindUI(with: viewModel)
        bindAction(with: viewModel)
        viewModel.getAPISetting()
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupButtons()
       
    }
    override func viewWillDisappear(_ animated: Bool) {
        viewModel.action.submitChange.on(.next(Void()))
    }
    func bindUI(with viewModel: SettingViewModel) {
        (PostsSwitch.rx.isOn <-> viewModel.input.postsNotification).disposed(by: disposeBag)
        (CommentSwitch.rx.isOn <-> viewModel.input.commentNotification).disposed(by: disposeBag)
        (MentionSwitch.rx.isOn <-> viewModel.input.mentionNotification).disposed(by: disposeBag)
        (FollowSwitch.rx.isOn <-> viewModel.input.followNotification).disposed(by: disposeBag)
        (MessageSwitch.rx.isOn <-> viewModel.input.messageNotification).disposed(by: disposeBag)
    }
    
    func bindAction(with viewModel: SettingViewModel) {}

    
    @IBAction func PostsSwitchPressed(_ sender: Any) {
        
        
        
    }
    
    @IBAction func CommentSwitchPressed(_ sender: Any) {
        
        
        
    }
    
    @IBAction func MentionSwitchPressed(_ sender: Any) {
        
        
        
    }
    
    @IBAction func FollowSwitchPressed(_ sender: Any) {
        
        
        
    }
    
    @IBAction func MessageSwitchPressed(_ sender: Any) {
        
        
        
    }


}


extension PushNotificationVC {
    
    func setupButtons() {
        
        setupBackButton()
        
    }
    
    
    func setupBackButton() {
        
        
        // Do any additional setup after loading the view.
        backButton.setImage(UIImage.init(named: "back_icn_white")?.resize(targetSize: CGSize(width: 13, height: 23)), for: [])
        backButton.addTarget(self, action: #selector(onClickBack(_:)), for: .touchUpInside)
        backButton.frame = CGRect(x: -10, y: 0, width: 15, height: 25)
        backButton.setTitleColor(UIColor.white, for: .normal)
        backButton.setTitle("     Push Notification", for: .normal)
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
