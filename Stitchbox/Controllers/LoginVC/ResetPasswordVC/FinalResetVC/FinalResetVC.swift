//
//  FinalResetVC.swift
//  Stitchbox
//
//  Created by Khoi Nguyen on 1/8/23.
//

import UIKit
import RxSwift

class FinalResetVC: UIViewController {
    @IBOutlet weak var nextButton: UIButton!
    
    private let disposeBag = DisposeBag()
    private var isButtonEnabled = true // Track the button state
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.rightBarButtonItem = nil
        nextButton.rx.tap.asObservable().subscribe { [weak self] _ in
            guard let self = self, self.isButtonEnabled else {
                return
            }
            
            // Disable the button
            self.isButtonEnabled = false
            self.nextButton.isEnabled = false
            
            // Call redirection and re-enable the button afterward
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                RedirectionHelper.redirectToDashboard()
                self.enableButton()
            }
        }.disposed(by: disposeBag)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        self.view.endEditing(true)
    }
    
    // Call this method after the redirection is completed to enable the button again
    private func enableButton() {
        isButtonEnabled = true
        nextButton.isEnabled = true
    }
}

