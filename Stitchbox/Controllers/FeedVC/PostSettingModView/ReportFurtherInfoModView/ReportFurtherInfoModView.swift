//
//  ReportFurtherInfo.swift
//  Stitchbox
//
//  Created by Khanh Duy Nguyen on 1/18/23.
//

import Foundation

import UIKit

class ReportFurtherInfoModView: UIViewController{
    
    
    @IBOutlet weak var skipBtn: UIButton!
    @IBOutlet weak var submitBtn: UIButton!
    @IBOutlet weak var contentReportTextfield: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    @IBAction func skipAction(_ sender: Any) {
        
        NotificationCenter.default.post(name: (NSNotification.Name(rawValue: "report-submit")), object: "")
        self.dismiss(animated: true)
        
    }
    
    @IBAction func submitAction(_ sender: Any) {
            
        NotificationCenter.default.post(name: (NSNotification.Name(rawValue: "report-submit")), object: contentReportTextfield.text)
        self.dismiss(animated: true)
        
        // show popup controller for report
        
    }
    
   //dismissUser
    
    func showErrorAlert(_ title: String, msg: String) {
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
}
