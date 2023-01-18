//
//  ReportModView.swift
//  Stitchbox
//
//  Created by Khanh Duy Nguyen on 1/18/23.
//

import UIKit

class ReportModView: UIViewController{
    
    
    @IBOutlet weak var wrongCategoryBtn: UIButton!
    @IBOutlet weak var spamBtn: UIButton!
    @IBOutlet weak var wrongPlayerBtn: UIButton!
    @IBOutlet weak var nudityBtn: UIButton!
    @IBOutlet weak var hateSpeechBtn: UIButton!
    @IBOutlet weak var violenceBtn: UIButton!
    @IBOutlet weak var bullyBtn: UIButton!
    @IBOutlet weak var intellectualViolationBtn: UIButton!
    @IBOutlet weak var illegalStuffBtn: UIButton!
    @IBOutlet weak var falseInfoBtn: UIButton!
    
    var isMute: Bool?
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    @IBAction func wrongCategoryAction(_ sender: Any) {
        NotificationCenter.default.post(name: (NSNotification.Name(rawValue: "report-wrongCategory")), object: nil)
        self.dismiss(animated: true)
    }
    @IBAction func spamAction(_ sender: Any) {
        NotificationCenter.default.post(name: (NSNotification.Name(rawValue: "report-spam")), object: nil)
        self.dismiss(animated: true)
    }
    @IBAction func wrongPlayerAction(_ sender: Any) {
        NotificationCenter.default.post(name: (NSNotification.Name(rawValue: "report-wrongPlayer")), object: nil)
        self.dismiss(animated: true)
    }
    @IBAction func nudityAction(_ sender: Any) {
        NotificationCenter.default.post(name: (NSNotification.Name(rawValue: "report-nudity")), object: nil)
        self.dismiss(animated: true)
    }
    @IBAction func hateSpeechAction(_ sender: Any) {
        NotificationCenter.default.post(name: (NSNotification.Name(rawValue: "report-hateSpeech")), object: nil)
        self.dismiss(animated: true)
    }
    @IBAction func violenceAction(_ sender: Any) {
        NotificationCenter.default.post(name: (NSNotification.Name(rawValue: "report-violence")), object: nil)
        self.dismiss(animated: true)
    }
    @IBAction func bullyAction(_ sender: Any) {
        NotificationCenter.default.post(name: (NSNotification.Name(rawValue: "report-bully")), object: nil)
        self.dismiss(animated: true)
    }
    @IBAction func intellectualViolationAction(_ sender: Any) {
        NotificationCenter.default.post(name: (NSNotification.Name(rawValue: "report-intellectualViolation")), object: nil)
        self.dismiss(animated: true)
    }
    @IBAction func illegalStuffAction(_ sender: Any) {
        NotificationCenter.default.post(name: (NSNotification.Name(rawValue: "report-illegalStuff")), object: nil)
        self.dismiss(animated: true)
    }
    @IBAction func falseInfoAction(_ sender: Any) {
        NotificationCenter.default.post(name: (NSNotification.Name(rawValue: "report-falseInfo")), object: nil)
        self.dismiss(animated: true)
    }
    
   //dismissUser
    
    func showErrorAlert(_ title: String, msg: String) {
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
}
