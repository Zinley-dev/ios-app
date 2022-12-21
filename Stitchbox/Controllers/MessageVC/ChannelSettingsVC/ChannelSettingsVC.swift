//
//  ChannelSettingsVC.swift
//  Stitchbox
//
//  Created by Khoi Nguyen on 12/18/22.
//

import UIKit
import SendBirdUIKit

class ChannelSettingsVC: SBUChannelSettingsViewController {
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        navigationItem.titleView = createLeftTitleItem(text: "Setting")
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBar.setValue(false, forKey: "hidesShadow")
        
    }
    
    override func showMemberList() {
        // If you want to use your own MemberListViewController, you can override and customize it here.
        //MemberListVC
        
        let MLV = MemberListVC(channel: self.channel!)
        navigationController?.pushViewController(MLV, animated: true)
    }
    
    func createLeftTitleItem(text: String) -> UIView {
        let titleLabel = UILabel()
        titleLabel.text = text
        titleLabel.font = UIFont.systemFont(ofSize: 18.0, weight: .bold)
        titleLabel.textColor = SBUTheme.componentTheme.titleColor
       
        return titleLabel
    }
    


}
