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
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        bindUI(with: viewModel)
        bindAction(with: viewModel)
        setUpNavigationBar()
        
    }
    
    // MARK: - Functions
    func bindUI(with viewModel: SettingViewModel) {
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
                case .other:
                    break
                }
            })
            .disposed(by: disposeBag)
    }
    
    func bindAction(with viewModel: SettingViewModel) {
        logoutButton?.rx.tap.subscribe(viewModel.action.logOutDidTap).disposed(by: disposeBag)
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
