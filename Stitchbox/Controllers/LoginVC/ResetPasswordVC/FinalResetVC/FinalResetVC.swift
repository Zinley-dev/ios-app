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
        
        nextButton.rx.tap.asObservable().subscribe { [unowned self] _ in
            guard self.isButtonEnabled else {
                return
            }
            
            // Disable the button
            self.isButtonEnabled = false
            self.nextButton.isEnabled = false
            
            DispatchQueue.main.async {
                RedirectionHelper.redirectToDashboard()
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
