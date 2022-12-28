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
    
    override func showInviteUser() {
       // Get a reference to the invite user view controller
       guard let inviteUserVC = UIStoryboard(name: "Dashboard", bundle: nil).instantiateViewController(withIdentifier: "InviteUserVC") as? InviteUserVC else { return }

       // Add the user IDs of the members in the memberList array to the joinedUserIds array
       let joinedUserIds = memberList.map { $0.userId }

       // Set the channelUrl and joinedUserIds properties of the invite user view controller
       inviteUserVC.channelUrl = self.channelUrl
       inviteUserVC.joinedUserIds = joinedUserIds

       // Push the invite user view controller onto the navigation stack
       navigationController?.pushViewController(inviteUserVC, animated: true)
    }

    

}

