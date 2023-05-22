//
//  ViewCell.swift
//  Dual
//
//  Created by Khoi Nguyen on 10/10/21.
//

import UIKit

class ViewCell: UITableViewCell {

    @IBOutlet var name: UILabel!
    @IBOutlet weak var descLbl: UILabel!
    
    var info: String!
  
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    func configureCell(_ information: String, item: PostModel, stat: Int?) {
        self.info = information
        name.text = self.info

        if let stat = stat {
            descLbl.text = String(stat)
        } else if stat == nil {
            descLbl.text = "Loading data..."
        } else {
            descLbl.text = "Data not available"
        }
    }

    

}
