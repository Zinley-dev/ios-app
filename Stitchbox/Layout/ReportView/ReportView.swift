//
//  reportView.swift
//  Dual
//
//  Created by Khoi Nguyen on 1/16/21.
//

import UIKit

// MARK: - ReportView Class
// This class represents a view controller for reporting users, posts, or comments in an application.
class ReportView: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextViewDelegate {
    
    // MARK: - Outlets
    @IBOutlet weak var descriptionView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var Cpview: UIView!
    @IBOutlet weak var descriptionTxtView: UITextView!
    @IBOutlet weak var report_title: UILabel!
    
    // MARK: - Properties
    var user_report = false
    var post_report = false
    var comment_report = false
    
    var postId = ""
    var userId = ""
    var commentId = ""
    var reason = ""
    
    // Lists of reasons for reporting users, posts, and comments.
    let user_report_list = ["Pretend to be someone", "Fake Account", "Fake Name", "Posting Inappropriate Things", "Bullying or harassment", "Intellectual property violation", "Sale of illegal or regulated stuffs", "Scam or fraud", "False information"]
    let post_report_list = ["Wrong category", "It's spam", "Reporting wrong player", "Nudity or sexual activity", "Hate speech or symbols", "Violence or dangerous behaviors", "Bullying or harassment", "Intellectual property violation", "Sale of illegal or regulated stuffs", "False information"]
    let comment_report_list = ["Wrong category", "It's spam", "Nudity or sexual activity", "Hate speech or symbols", "Violence or dangerous behaviors", "Bullying or harassment", "Intellectual property violation", "Sale of illegal or regulated stuffs", "False information"]
    
    // MARK: - View Lifecycle
    // Called after the controller's view is loaded into memory.
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "reportCell", bundle: nil), forCellReuseIdentifier: "reportCell")
        descriptionTxtView.delegate = self
        updateReportTitle()
    }
    
    // Updates the title based on the type of report.
    private func updateReportTitle() {
        if user_report {
            report_title.text = "Why are you reporting this account?"
        } else if post_report {
            report_title.text = "Why are you reporting this post?"
        } else if comment_report {
            report_title.text = "Why are you reporting this comment?"
        }
    }
    
    // MARK: - UITextViewDelegate
    func textViewDidBeginEditing(_ textView: UITextView) {
        if descriptionTxtView.text == "Please provide us more detail about your report!" {
            descriptionTxtView.text = ""
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if descriptionTxtView.text.isEmpty {
            descriptionTxtView.text = "Please provide us more detail about your report!"
        }
    }
    
    // MARK: - UITableViewDataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if user_report {
            return user_report_list.count
        } else if post_report {
            return post_report_list.count
        } else if comment_report {
            return comment_report_list.count
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var item: String?
        
        // Determine which list of reasons to use based on the report type.
        if user_report {
            item = user_report_list[indexPath.row]
        } else if post_report {
            item = post_report_list[indexPath.row]
        } else if comment_report {
            item = comment_report_list[indexPath.row]
        }
        
        // Dequeue and configure the cell.
        if let cell = tableView.dequeueReusableCell(withIdentifier: "ReportCell") as? ReportCell {
            cell.cellConfigured(report: item!)
            return cell
        } else {
            return UITableViewCell()
        }
    }
    
    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Set the reason for the report based on the selected row.
        if user_report {
            reason = user_report_list[indexPath.row]
        } else if post_report {
            reason = post_report_list[indexPath.row]
        } else if comment_report {
            reason = comment_report_list[indexPath.row]
        }
        
        // Update UI based on selection.
        tableView.isHidden = true
        descriptionView.isHidden = false
    }
    
    // Dismisses the keyboard when the user taps outside of a text field.
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        view.endEditing(true)
    }
    
    // MARK: - Actions
    // Action for the skip button.
    @IBAction func SkipBtnPressed(_ sender: Any) {
        // Logic for handling the skip action.
    }
    
    // Action for the submit button.
    @IBAction func SubmitBtnPressed(_ sender: Any) {
        // Logic for handling the submit action.
    }
    
    // Shows an alert with a title and message.
    func showErrorAlert(_ title: String, msg: String) {
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
}
