//
//  SB-MetaVC.swift
//  Stitchbox
//
//  Created by Khoi Nguyen on 5/9/23.
//

import UIKit
import ObjectMapper

class SB_MetaVC: UIViewController {

    @IBOutlet weak var metaTxtView: UITextView!

    
    let backButton: UIButton = UIButton(type: .custom)
    var gameName = ""
    var gameId = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupButtons()
        loadMeta()
        
    }
    


}

extension SB_MetaVC {
    
    func setupButtons() {
        
        setupBackButton()
    
    }
    
    
    func setupBackButton() {
    
        backButton.frame = back_frame
        backButton.contentMode = .center

        if let backImage = UIImage(named: "back_icn_white") {
            let imageSize = CGSize(width: 13, height: 23)
            let padding = UIEdgeInsets(top: (back_frame.height - imageSize.height) / 2,
                                       left: (back_frame.width - imageSize.width) / 2 - horizontalPadding,
                                       bottom: (back_frame.height - imageSize.height) / 2,
                                       right: (back_frame.width - imageSize.width) / 2 + horizontalPadding)
            backButton.imageEdgeInsets = padding
            backButton.setImage(backImage, for: [])
        }

        backButton.addTarget(self, action: #selector(onClickBack(_:)), for: .touchUpInside)
        backButton.setTitleColor(UIColor.white, for: .normal)
        backButton.setTitle("", for: .normal)
        let backButtonBarButton = UIBarButtonItem(customView: backButton)
        navigationItem.title = gameName

        self.navigationItem.leftBarButtonItem = backButtonBarButton
        
    }

    
    func showErrorAlert(_ title: String, msg: String) {
                                                                                                                                           
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default)
        
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
        
    }

    
}

extension SB_MetaVC {
    
    @objc func onClickBack(_ sender: AnyObject) {
        if let navigationController = self.navigationController {
            navigationController.popViewController(animated: true)
        }
    }
    
}

extension SB_MetaVC {
    func loadMeta() {
        APIManager().getGamePatch(gameId: global_gameId) { result in
            switch result {
            case .success(let apiResponse):
                guard let data = apiResponse.body?["data"] as? [String: Any],
                      let content = data["content"] as? String else {
                    print("Unable to convert")
                    return
                }
                self.displayMeta(content: content)
            case .failure(let error):
                print(error)
            }
        }
    }

    func displayMeta(content: String) {
        if let data = content.data(using: .utf8) {
            
            print(content)
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: [String: [String: String]]] {
                    let metaDisplay = MetaDisplay(inputDict: json)
                    let attributedString = metaDisplay.processText()
                    DispatchQueue.main.async {
                        print(attributedString)
                        self.metaTxtView.attributedText = attributedString
                    }
                }
            } catch {
                print("Error during JSON serialization: \(error.localizedDescription)")
            }
        }
    }
    
}

