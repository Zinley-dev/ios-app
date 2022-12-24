//
//  ProfileViewController.swift
//  Stitchbox
//
//  Created by Hisoft Hoangnm on 15/12/2022.
//

import UIKit

class ProfileViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

  @IBAction func tapedSignOut(_ sender: Any) {
    _AppCoreData.signOut()
    sendbirdLogout()
    RedirectionHelper.redirectToLogin()
  }
  /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
