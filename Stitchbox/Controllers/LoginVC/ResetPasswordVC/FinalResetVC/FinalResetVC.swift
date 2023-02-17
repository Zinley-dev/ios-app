//
//  FinalResetVC.swift
//  Stitchbox
//
//  Created by Khoi Nguyen on 1/8/23.
//

import UIKit
import RxSwift

class FinalResetVC: UIViewController {
    
    
    @IBOutlet weak var nextButton: SButton!

    private let disposeBag = DisposeBag()
    override func viewDidLoad() {
        super.viewDidLoad()
      
        nextButton.rx.tap.asObservable().subscribe { _ in
          DispatchQueue.main.async {
            RedirectionHelper.redirectToDashboard()
          }
        }.disposed(by: disposeBag)
      
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        self.view.endEditing(true)
    }

}
