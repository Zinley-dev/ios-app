//
//  SearchViewController.swift
//  Stitchbox
//
//  Created by Hisoft Hoangnm on 29/12/2022.
//

import UIKit

class SearchViewController: UIViewController {

  @IBOutlet weak var searchBar: UISearchBar!
  
  override func viewDidLoad() {
      super.viewDidLoad()
    let searchField = searchBar.value(forKey: "searchField") as? UITextField

    
    if let field = searchField {
      field.textColor = .white
      field.backgroundColor = .darkGray
      field.rightView?.tintColor = .white
      field.leftView?.tintColor = .white
      
      let placeholderString = NSAttributedString(string: "Search", attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
      field.attributedPlaceholder = placeholderString
    }
    
    
      searchBar.tintColor = .white
      searchBar.barTintColor = .white
    
      navigationItem.titleView = searchBar
  }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        self.view.endEditing(true)
        
    }
}
