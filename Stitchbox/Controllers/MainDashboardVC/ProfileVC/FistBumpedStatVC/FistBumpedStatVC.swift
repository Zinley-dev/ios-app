//
//  FistBumpedStatVC.swift
//  Stitchbox
//
//  Created by Khoi Nguyen on 1/19/23.
//

import UIKit
import ObjectMapper
import FLAnimatedImage


class FistBumpedStatVC: UIViewController {

  @IBOutlet weak var avgLbl: UILabel!
  @IBOutlet weak var totalWeekLbl: UILabel!
  @IBOutlet weak var total3DayLbl: UILabel!
  @IBOutlet weak var totalDayLbl: UILabel!
  @IBOutlet weak var percentDay: UILabel!
  @IBOutlet weak var percent3DayLbl: UILabel!
  @IBOutlet weak var percentWeekLbl: UILabel!
  @IBOutlet weak var fistBumpListBtn: UIButton!
  @IBOutlet weak var percentAvgLbl: UILabel!
  @IBOutlet weak var fromLbl: UILabel!
  
    
  @IBOutlet weak var loadingImage: FLAnimatedImageView!
  @IBOutlet weak var loadingView: UIView!
    
  var insightData: InsightModel!
  
    let backButton: UIButton = UIButton(type: .custom)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupButtons()
        
    }
    override func viewWillAppear(_ animated: Bool) {
      super.viewWillAppear(animated)
        
        
        do {
            
            let path = Bundle.main.path(forResource: "fox2", ofType: "gif")!
            let gifData = try NSData(contentsOfFile: path) as Data
            let image = FLAnimatedImage(animatedGIFData: gifData)
            
            
            self.loadingImage.animatedImage = image
            
        } catch {
            print(error.localizedDescription)
        }
        
        loadingView.backgroundColor = self.view.backgroundColor
      
      loadInsightData()
      
      let formatter = DateFormatter()
      formatter.dateFormat = "MMM dd"
      
      let currentDateTime = Date()
      let last7Days = currentDateTime.addedBy(minutes: -(7 * 24 * 60))
      
      fromLbl.text = "from \(formatter.string(from: last7Days)) - \(formatter.string(from: currentDateTime))"
      
    }

}

extension FistBumpedStatVC {
    
    func setupButtons() {
        setupBackButton()
        fistBumpListBtn.titleLabel?.textColor = .white
    
    }
    
    func loadInsightData() {
      
      APIManager().getInsightOverview(userID: _AppCoreData.userDataSource.value?.userID ?? "") { result in
        
        switch result {
          case .success(let apiResponse):
            
            guard let data = apiResponse.body else {
              return
            }
            
            self.insightData =  Mapper<InsightModel>().map(JSONObject: data)
            
            DispatchQueue.main {
              self.processDefaultData()
              self.hideView()
            }
            
          case .failure(let error):
            
         
            
            DispatchQueue.main {
              self.hideView()
              self.showErrorAlert("Oops!", msg: "Unable to retrieve your setting \(error.localizedDescription)")
            }
            
        }
      }
    }
    
    func hideView() {
        
        UIView.animate(withDuration: 0.5) {
            
            self.loadingView.alpha = 0
            
        }
        
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            
            if self.loadingView.alpha == 0 {
                
                self.loadingView.isHidden = true
                
            }
            
        }
        
        
    }
    
    
  
    func processDefaultData() {
      if self.insightData != nil {
        self.totalDayLbl.text = String(self.insightData.totalDay)
        self.total3DayLbl.text = String(self.insightData.total3Day)
        self.totalWeekLbl.text = String(self.insightData.totalWeek)
        self.avgLbl.text = String(self.insightData.avg)
        
        self.percentDay.text = self.insightData.percentDay
        self.percent3DayLbl.text = self.insightData.percent3Day
        self.percentWeekLbl.text = self.insightData.percentWeek
        self.percentAvgLbl.text = self.insightData.percentAvg
      }
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
        navigationItem.title = "Fistbump Stats"
        let backButtonBarButton = UIBarButtonItem(customView: backButton)

        self.navigationItem.leftBarButtonItem = backButtonBarButton


        
    }

   
    @objc func onClickBack(_ sender: AnyObject) {
        if let navigationController = self.navigationController {
            navigationController.popViewController(animated: true)
        }
    }

  func showErrorAlert(_ title: String, msg: String) {
    
    let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
    let action = UIAlertAction(title: "OK", style: .default, handler: nil)
    alert.addAction(action)
    
    
    present(alert, animated: true, completion: nil)
    
  }
  
  func swiftLoader() {
    
    var config : SwiftLoader.Config = SwiftLoader.Config()
    config.size = 170
    
    config.backgroundColor = UIColor.clear
    config.spinnerColor = UIColor.white
    config.titleTextColor = UIColor.white
    
    
    config.spinnerLineWidth = 3.0
    config.foregroundColor = UIColor.clear
    config.foregroundAlpha = 0.7
    
    
    SwiftLoader.setConfig(config: config)
    
    
    SwiftLoader.show(title: "", animated: true)
    
    
    
  }
    
}
