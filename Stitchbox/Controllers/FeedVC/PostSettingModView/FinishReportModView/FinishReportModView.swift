//
//  FinishReportModView.swift
//  Stitchbox
//
//  Created by Khanh Duy Nguyen on 1/18/23.
//
import UIKit

class FinishReportModView: UIViewController{
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
   //dismissUser
    
    func showErrorAlert(_ title: String, msg: String) {
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
}
