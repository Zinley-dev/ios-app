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
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        bindUI(with: viewModel)
        bindAction(with: viewModel)
    }
    // MARK: - Functions
    func bindUI(with viewModel: SettingViewModel) {
        
    }
    
    func bindAction(with viewModel: SettingViewModel) {
        
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
