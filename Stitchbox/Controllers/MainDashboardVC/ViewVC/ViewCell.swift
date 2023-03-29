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
    
    
    func configureCell(_ Information: String, item: PostModel) {
        
        self.info = Information
        name.text = self.info
        
        if self.info == "Total views" {
            loadTotalViews(item: item)
        } else if self.info == "Views in 60 mins" {
            loadTotalViewsIn60Mins(item: item)
        } else if self.info == "Views in 24 hours" {
            loadTotalViewsIn24Hours(item: item)
        } else if self.info == "Total GG!" {
            loadTotalLikes(item: item)
        } else if self.info == "GG! in 60 mins" {
           loadTotalLikesIn60Mins(item: item)
        } else if self.info == "GG! in 24 hours" {
           loadTotalLikesIn24Hours(item: item)
        }
        
        
    }
    
    func loadTotalViews(item: PostModel) {
        
       
        
        
    }
    
    func loadTotalViewsIn60Mins(item: PostModel) {
        
    
        
        
    }
    
    
    func loadTotalViewsIn24Hours(item: PostModel) {
        

        
        
    }
    
    func loadTotalLikes(item: PostModel) {
        

        
        
    }
    
    func loadTotalLikesIn60Mins(item: PostModel) {
        

        
        
    }
    
    
    func loadTotalLikesIn24Hours(item: PostModel) {
        

        
        
    }
    
    
    

}
