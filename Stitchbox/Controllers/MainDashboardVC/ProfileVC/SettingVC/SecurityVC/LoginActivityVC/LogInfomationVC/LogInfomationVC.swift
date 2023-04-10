//
//  LogInfomationVC.swift
//  Stitchbox
//
//  Created by Khoi Nguyen on 3/21/23.
//

import UIKit
import GoogleMaps
import Alamofire

class LogInfomationVC: UIViewController, GMSMapViewDelegate {
    
    @IBOutlet weak var countryLbl: UILabel!
    @IBOutlet weak var ispLbl: UILabel!
    @IBOutlet weak var cityLbl: UILabel!
    @IBOutlet weak var actionLbl: UILabel!
    @IBOutlet weak var timeLbl: UILabel!
    @IBOutlet weak var regionLbl: UILabel!
    @IBOutlet weak var IPLbl: UILabel!
    @IBOutlet weak var DeviceLbl: UILabel!
    @IBOutlet weak var mapView: GMSMapView!
    
    let backButton: UIButton = UIButton(type: .custom)
    
    var marker = GMSMarker()
    
    var item: UserLoginActivityModel!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        mapView.delegate = self
        setupButtons()
        styleMap()
        DeviceLbl.text = item.device

        let urls = URL(string: "http://ip-api.com/json/")!.appendingPathComponent(item.ip)
                                  
        AF.request(urls, method: .get)
            .validate(statusCode: 200..<500)
            .responseJSON { responseJSON in
                                        
                switch responseJSON.result {
                                            
                    case .success(let json):
                                            
                        if let dict = json as? Dictionary<String, Any> {
                                                
                            if let status = dict["status"] as? String, status == "success" {
                                                    
                                if let regionName = dict["regionName"] as? String, let lat = dict["lat"] as? CLLocationDegrees, let lon = dict["lon"] as? CLLocationDegrees, let query = dict["query"] as? String, let city = dict["city"] as? String, let isp = dict["isp"] as? String, let country = dict["country"] as? String {
                                    
                                    
                                    let location = CLLocationCoordinate2D(latitude: lat, longitude: lon)
                                    self.centerMapOnUserLocation(location: location)
                                    self.regionLbl.text = regionName
                                    self.IPLbl.text = query
                                    self.cityLbl.text = city
                                    self.ispLbl.text = isp
                                    self.countryLbl.text = country
                                }
                                               

                            } else {
                                
                                self.IPLbl.text = self.item.ip
                                self.regionLbl.text = "Private range"
                                self.countryLbl.text = "Private range"
                                self.cityLbl.text = "Private range"
                                self.ispLbl.text = "Private range"
                                
                            }
                        }
                                            
                    case .failure(let error):
                      
                        print(error.localizedDescription)
                                           
                                            
              
                    }
                                        
        }
        
        
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = "MM-dd-yyyy HH:mm:ss"
        timeLbl.text = dateFormatterGet.string(from: item.createdAt)

        actionLbl.text = item.content
        
        
        
    }

    

    func centerMapOnUserLocation(location: CLLocationCoordinate2D) {
           

           // get MapView
           let camera = GMSCameraPosition.camera(withLatitude: location.latitude, longitude: location.longitude, zoom: 17)
           

           self.marker.infoWindowAnchor = CGPoint(x: 0.5, y: 0.5)
        
           marker.position = location
        
           marker.map = mapView
           mapView.camera = camera
           mapView.animate(to: camera)
           marker.appearAnimation = GMSMarkerAnimation.pop
           
           
           marker.isTappable = false
              
    }
    
    func styleMap() {
    
        do {
            // Set the map style by passing the URL of the local file.
            if let styleURL = Bundle.main.url(forResource: "customizedMap", withExtension: "json") {
                mapView.mapStyle = try GMSMapStyle(contentsOfFileURL: styleURL)
            } else {
                NSLog("Unable to find style.json")
            }
        } catch {
            NSLog("One or more of the map styles failed to load. \(error)")
        }
    
    
    
    }

}

extension LogInfomationVC {
    
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
        navigationItem.title = "Detail Information"
      
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
        let action = UIAlertAction(title: "OK", style: .default)
        
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
        
    }
    
    
}

