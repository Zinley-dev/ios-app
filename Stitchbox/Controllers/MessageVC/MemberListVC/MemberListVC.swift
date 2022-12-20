//
//  MemberListVC.swift
//  Stitchbox
//
//  Created by Khoi Nguyen on 12/18/22.
//

import UIKit
import SendBirdUIKit

class MemberListVC: SBUMemberListViewController {
    
    
    var joinedUserIds: [String] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
   
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBar.setValue(false, forKey: "hidesShadow")
        
    }
    
    override func showInviteUser() {
        
        if let CCV = UIStoryboard(name: "Dashboard", bundle: nil).instantiateViewController(withIdentifier: "InviteUserVC") as? InviteUserVC {
                
            for item in memberList {
                
                let uid = item.userId
                joinedUserIds.append(uid)
                
            }
            
            
            CCV.channelUrl = self.channelUrl
            CCV.joinedUserIds = joinedUserIds
            navigationController?.pushViewController(CCV, animated: true)
        }
        
        
    }
    

}

