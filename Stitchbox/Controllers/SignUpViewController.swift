//
//  SignUpViewController.swift
//  Stitchbox
//
//  Created by Hisoft Hoangnm on 01/12/2022.
//

import UIKit

class SignUpViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    

    func back() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func clickLoginHandle(_ sender: UIButton) {
        back()
    }

}
