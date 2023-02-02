//
//  AreYouSureVC.swift
//  Stitchbox
//
//  Created by Nguyen Vo Thuan on 2/1/23.
//

import UIKit

class AreYouSureVC: UIViewController {

    @IBOutlet weak var backgroundView: UIView!
    
    @IBOutlet weak var popView: UIView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
        // Do any additional setup after loading the view.
    }
    
    func setUpUI() {
        popView.layer.cornerRadius = 10
    }

    @IBAction func showPopupView(_ sender: Any) {
        
        if popView.isHidden {
            
            backgroundView.isHidden = false
            popView.alpha = 1.0
            
            UIView.transition(with: popView, duration: 0.5) {
                
                self.popView.isHidden = false
                
            }
            
        }
        
    }
    
    
    @IBAction func unfollowBtnPressed(_ sender: Any) {
        print("Unfollow")
        
    }
    
    @IBAction func cancelBtnPressed(_ sender: Any) {
        print("Cancel")
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        if !popView.isHidden {
            
            let touch = touches.first
        
            guard let location = touch?.location(in: view) else {return}
            
            if !popView.frame.contains(location) {
                
                dismissPopupView()
                
            } else {
                
                print("Popview frame contains location \(location)")
                
            }
            
        }
        // conflict lists
        // uiscrollview
        // uitableview
        // uicollectionview
        // tap gesture regconizer
        
    }
    
    func dismissPopupView() {
        
        UIView.animate(withDuration: 0.3, animations: {
            self.popView.alpha = 0
        }) { (finished) in
            self.popView.isHidden = finished
            self.backgroundView.isHidden = true
        }
        
    }

}
