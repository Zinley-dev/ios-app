//
//  reportView.swift
//  Dual
//
//  Created by Khoi Nguyen on 1/16/21.
//

import UIKit

class reportView: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextViewDelegate {
    
    @IBOutlet weak var descriptionView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var Cpview: UIView!
    @IBOutlet weak var descriptionTxtView: UITextView!
    
    @IBOutlet weak var report_title: UILabel!
    
    var user_report = false
    var video_report = false
    var comment_report = false
    var challenge_report = false
    
    var highlight_id = ""
    var challenge_id = ""
    var user_id = ""
    var comment_id = ""
    var reason = ""
    
    
    //
    
    let user_report_list = ["Pretent to be somone", "Fake Account", "Fake Name", "Posting Inappropriate Things", "Bullying or harrasment", "Intellectual property violation","Sale of illegal or regulated stuffs", "Scam or fraud", "False information"]
    
    let video_report_list = ["Wrong category", "It's spam", "Reporting wrong player", "Nudity or sexual activity", "Hate speech or symbols", "Violence or dangerous behaviors", "Bullying or harrasment", "Intellectual property violation","Sale of illegal or regulated stuffs", "False information"]
    
    let comment_report_list = ["Wrong category", "It's spam", "Nudity or sexual activity", "Hate speech or symbols", "Violence or dangerous behaviors", "Bullying or harrasment", "Intellectual property violation","Sale of illegal or regulated stuffs", "False information"]
    
    let challenge_report_list = ["Wrong category", "It's spam", "Nudity or sexual activity", "Hate speech or symbols", "Violence or dangerous behaviors", "Bullying or harrasment", "Intellectual property violation","Sale of illegal or regulated stuffs", "False information"]

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        tableView.delegate = self
        tableView.dataSource = self
        
        if user_report == true {
            
            report_title.text = "Why are you reporting this account?"
            
        } else if video_report == true {
            
            report_title.text = "Why are you reporting this post?"
            
        } else if comment_report == true {
            
            report_title.text = "Why are you reporting this comment?"
            
        } else if challenge_report == true {
            
            report_title.text = "Why are you reporting this challenge?"
            
        }
        
        
        self.tableView.register(UINib(nibName: "reportCell", bundle: nil), forCellReuseIdentifier: "reportCell")
        
        descriptionTxtView.delegate = self
        
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        
        if descriptionTxtView.text == "Please provide us more detail about your report!" {
            
            descriptionTxtView.text = ""
            
        }
    }
    
    
    func textViewDidEndEditing(_ textView: UITextView) {
        
        if descriptionTxtView.text == "" {
            
            descriptionTxtView.text = "Please provide us more detail about your report!"
            
        }
        
    }
    

    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if user_report == true {
            return user_report_list.count
        } else if video_report == true {
            return video_report_list.count
        } else if comment_report == true {
            return comment_report_list.count
        } else if challenge_report == true {
            return challenge_report_list.count
        } else {
            return 0
        }
        
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var item: String?
        
        if user_report == true {
            item = user_report_list[indexPath.row]
        } else if video_report == true {
            item = video_report_list[indexPath.row]
        } else if comment_report == true {
            item = comment_report_list[indexPath.row]
        } else if challenge_report == true {
            item = challenge_report_list[indexPath.row]
        } else {
            item = ""
        }
             
        if let cell = tableView.dequeueReusableCell(withIdentifier: "reportCell") as? reportCell {
            
            
            
            cell.cellConfigured(report: item!)
            return cell
            
            
        } else {
            
            return UITableViewCell()
            
        }
       
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    
        if user_report == true {
            reason = user_report_list[indexPath.row]
        } else if video_report == true {
            reason = video_report_list[indexPath.row]
        } else if comment_report == true {
            reason = comment_report_list[indexPath.row]
        } else if challenge_report == true {
            reason = challenge_report_list[indexPath.row]
        }
                
        tableView.isHidden = true
        descriptionView.isHidden = false
        
        
    }

    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        self.view.endEditing(true)
        
    }
    
    @IBAction func SkipBtnPressed(_ sender: Any) {
        
        /*
        var data = [String:Any]()
        
        if reason != "" {
            
            let device = UIDevice().type.rawValue
            
            data = ["userUID": Auth.auth().currentUser!.uid, "reason": reason, "timeStamp": FieldValue.serverTimestamp(), "Device": device, "description": "nil", "status": "Pending"] as [String : Any]
            
        } else {
            
            self.showErrorAlert("Oops!", msg: "Please dismiss and try again.")
            
        }
        
        let db = DataService.instance.mainFireStoreRef
        var ref: CollectionReference!
        
        if user_report == true {
            ref = db.collection("user_report")
            data.updateValue(user_id, forKey: "reported_userUID")
        } else if video_report == true {
            ref = db.collection("video_report")
            data.updateValue(highlight_id, forKey: "highlight_id")
        } else if comment_report == true {
            ref = db.collection("comment_report")
            data.updateValue(comment_id, forKey: "comment_id")
        } else if challenge_report == true {
            ref = db.collection("challenge_report")
            data.updateValue(challenge_id, forKey: "challenge_id")
        }
        
        
        ref.addDocument(data: data) { err in
            
            if err != nil {
                
                self.showErrorAlert("Oops!", msg: err!.localizedDescription)
                
            } else {
                
                self.view.endEditing(true)
                self.tableView.isHidden = true
                self.descriptionView.isHidden = true
                self.Cpview.isHidden = false
                
            }
        }
        */
        
        self.view.endEditing(true)
        self.tableView.isHidden = true
        self.descriptionView.isHidden = true
        self.Cpview.isHidden = false
        
    }
    
    @IBAction func SubmitBtnPressed(_ sender: Any) {
        
        /*
        if let text = descriptionTxtView.text, text != "", text != "Please provide us more detail about your report!", text.count > 20 {
            
            var data = [String:Any]()
            
            if reason != "" {
                
                let device = UIDevice().type.rawValue
                
                data = ["userUID": Auth.auth().currentUser!.uid, "reason": reason, "timeStamp": FieldValue.serverTimestamp(), "Device": device, "description": text, "status": "Pending"] as [String : Any]
                
            } else {
                
                self.showErrorAlert("Oops!", msg: "Please dismiss and try again.")
                
                
            }
            
            let db = DataService.instance.mainFireStoreRef
            var ref: CollectionReference!
            
            if user_report == true {
                ref = db.collection("user_report")
                data.updateValue(user_id, forKey: "reported_userUID")
            } else if video_report == true {
                ref = db.collection("video_report")
                data.updateValue(highlight_id, forKey: "highlight_id")
            } else if comment_report == true {
                ref = db.collection("comment_report")
                data.updateValue(comment_id, forKey: "comment_id")
            } else if challenge_report == true {
                ref = db.collection("challenge_report")
                data.updateValue(challenge_id, forKey: "challenge_id")
            }
            
            
            ref.addDocument(data: data) { err in
                
                if err != nil {
                    
                    self.showErrorAlert("Oops!", msg: err!.localizedDescription)
                    
                } else {
                    
                    self.view.endEditing(true)
                    self.tableView.isHidden = true
                    self.descriptionView.isHidden = true
                    self.Cpview.isHidden = false
                    
                }
            }
            
        } else {
            
            self.showErrorAlert("Oops!", msg: "Please enter your report description, your description need to have more than 20 characters.")
            
            
        }
        
        */
        
    }
    
    
    func showErrorAlert(_ title: String, msg: String) {
                                                                                                                                           
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        
                                                                                       
        present(alert, animated: true, completion: nil)
        
    }
}
