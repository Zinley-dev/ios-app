//
//  FistBumpedStatVC.swift
//  Stitchbox
//
//  Created by Khoi Nguyen on 1/19/23.
//

import UIKit
import ObjectMapper


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
  
  var insightData: InsightModel!
  
    let backButton: UIButton = UIButton(type: .custom)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupButtons()
        
    }
    override func viewWillAppear(_ animated: Bool) {
      super.viewWillAppear(animated)
      
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
      swiftLoader()
      APIManager().getInsightOverview(userID: _AppCoreData.userDataSource.value?.userID ?? "") { result in
        SwiftLoader.hide()
        switch result {
          case .success(let apiResponse):
            
            guard let data = apiResponse.body else {
              return
            }
            
            self.insightData =  Mapper<InsightModel>().map(JSONObject: data)
            
            DispatchQueue.main {
              self.processDefaultData()
            }
            
          case .failure(let error):
            
            DispatchQueue.main {
              self.showErrorAlert("Oops!", msg: "Unable to retrieve your setting \(error.localizedDescription)")
            }
            
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
        
        // Do any additional setup after loading the view.
        backButton.setImage(UIImage.init(named: "back_icn_white")?.resize(targetSize: CGSize(width: 13, height: 23)), for: [])
        backButton.addTarget(self, action: #selector(onClickBack(_:)), for: .touchUpInside)
        backButton.frame = back_frame
        backButton.setTitleColor(UIColor.white, for: .normal)
        backButton.setTitle("     Fistbump Stats", for: .normal)
        backButton.sizeToFit()
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
