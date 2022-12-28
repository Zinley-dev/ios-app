//
//  FeedViewController.swift
//  Stitchbox
//
//  Created by Nghiem Minh Hoang on 26/10/2022.
//

import UIKit

class FeedViewController: UIViewController {

  @IBOutlet weak var lblHome: UILabel!
  override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        lblHome.text = _AppCoreData.userDataSource.value?.userName
        
    }
    

}
