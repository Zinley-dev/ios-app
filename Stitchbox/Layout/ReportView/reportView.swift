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
    var post_report = false
    var comment_report = false
    var challenge_report = false
    
    var postId = ""
    var userId = ""
    var commentId = ""
    var reason = ""
    
    //
    
    let user_report_list = ["Pretent to be somone", "Fake Account", "Fake Name", "Posting Inappropriate Things", "Bullying or harrasment", "Intellectual property violation","Sale of illegal or regulated stuffs", "Scam or fraud", "False information"]
    
    let post_report_list = ["Wrong category", "It's spam", "Reporting wrong player", "Nudity or sexual activity", "Hate speech or symbols", "Violence or dangerous behaviors", "Bullying or harrasment", "Intellectual property violation","Sale of illegal or regulated stuffs", "False information"]
    
    let comment_report_list = ["Wrong category", "It's spam", "Nudity or sexual activity", "Hate speech or symbols", "Violence or dangerous behaviors", "Bullying or harrasment", "Intellectual property violation","Sale of illegal or regulated stuffs", "False information"]
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        tableView.delegate = self
        tableView.dataSource = self
        
        if user_report == true {
            
            report_title.text = "Why are you reporting this account?"
            
        } else if post_report == true {
            
            report_title.text = "Why are you reporting this post?"
            
        } else if comment_report == true {
            
            report_title.text = "Why are you reporting this comment?"
            
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
        } else if post_report == true {
            return post_report_list.count
        } else if comment_report == true {
            return comment_report_list.count
        } else {
            return 0
        }
        
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var item: String?
        
        if user_report == true {
            item = user_report_list[indexPath.row]
        } else if post_report == true {
            item = post_report_list[indexPath.row]
        } else if comment_report == true {
            item = comment_report_list[indexPath.row]
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
        } else if post_report == true {
            reason = post_report_list[indexPath.row]
        } else if comment_report == true {
            reason = comment_report_list[indexPath.row]
        }
                
        tableView.isHidden = true
        descriptionView.isHidden = false
        
        
    }

    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        self.view.endEditing(true)
        
    }
    
    @IBAction func SkipBtnPressed(_ sender: Any) {

        if reason != "" {
            
            var type = ""
            var reportId = ""
            
            if user_report == true {
                type = "USER"
                reportId = userId
            } else if post_report == true {
                type = "POST"
                reportId = postId
            } else if comment_report == true {
                type = "COMMENT"
                reportId = commentId
            }
            
            presentSwiftLoader()
            
          
            
            APIManager.shared.report(type: type, reason: reason, note: "", reportId: reportId) { [weak self] result in
                guard let self = self else { return }

                switch result {
                case .success(_):
                   
                    Dispatch.main.async {
                        SwiftLoader.hide()
                       
                        Dispatch.main.async {
                            self.view.endEditing(true)
                            self.tableView.isHidden = true
                            self.descriptionView.isHidden = true
                            self.Cpview.isHidden = false
                        }
                    }
                    
                  case .failure(let error):
                    Dispatch.main.async {
                        print(error)
                        SwiftLoader.hide()
                        self.showErrorAlert("Oops!", msg: "\(error.localizedDescription)")
                    }
                }
            }
            
        } else {
            
            self.showErrorAlert("Oops!", msg: "Please dismiss and try again.")
            
        }
        
       
        
    }
    
    @IBAction func SubmitBtnPressed(_ sender: Any) {
        
        
        if let text = descriptionTxtView.text, text != "", text != "Please provide us more detail about your report!", text.count > 20 {
        
            if reason != "" {
                
                var type = ""
                var reportId = ""
                
                if user_report == true {
                    type = "USER"
                    reportId = userId
                } else if post_report == true {
                    type = "POST"
                    reportId = postId
                } else if comment_report == true {
                    type = "COMMENT"
                    reportId = commentId
                }
                
                presentSwiftLoader()
                
                APIManager.shared.report(type: type, reason: reason, note: text, reportId: reportId) { [weak self] result in
                    guard let self = self else { return }

                    switch result {
                    case .success(_):
                       
                        Dispatch.main.async {
                            SwiftLoader.hide()
                           
                            Dispatch.main.async {
                                self.view.endEditing(true)
                                self.tableView.isHidden = true
                                self.descriptionView.isHidden = true
                                self.Cpview.isHidden = false
                            }
                        }
                        
                      case .failure(let error):
                        print(error)
                        Dispatch.main.async {
                            SwiftLoader.hide()
                            self.showErrorAlert("Oops!", msg: "\(error.localizedDescription)")
                        }
                    }
                }
               
                
            } else {
                
                self.showErrorAlert("Oops!", msg: "Please dismiss and try again.")
                
            }
            
            
        } else {
            
            self.showErrorAlert("Oops!", msg: "Please enter your report description, your description need to have more than 20 characters.")
            
            
        }
        
        
        
    }
    
    
    func showErrorAlert(_ title: String, msg: String) {
                                                                                                                                           
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        
                                                                                       
        present(alert, animated: true, completion: nil)
        
    }
}
