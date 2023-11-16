//
//  reportCell.swift
//  Dual
//
//  Created by Khoi Nguyen on 1/16/21.
//

import UIKit

// MARK: - ReportCell Class
// This class represents a custom UITableViewCell for displaying a report.

class ReportCell: UITableViewCell {

    // MARK: - Outlets
    // Outlet for the label that displays the report text.
    @IBOutlet weak var reportLbl: UILabel!
    
    // MARK: - Initialization
    // Called when the cell is loaded from a nib or storyboard.
    override func awakeFromNib() {
        super.awakeFromNib()
        // Perform any additional setup after loading the view, typically from a nib.
    }

    // Called when the cell is selected or deselected.
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state, if needed.
    }
    
    // MARK: - Cell Configuration
    // Configures the cell with a report string.
    func cellConfigured(report: String) {
        reportLbl.text = report
    }
    
}
