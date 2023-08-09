//
//  LogInfomationVC.swift
//  Stitchbox
//
//  Created by Khoi Nguyen on 3/21/23.
//

import UIKit
import Alamofire
import CoreLocation
import MapKit

class LogInfomationVC: UIViewController {
    
    @IBOutlet weak var countryLbl: UILabel!
    @IBOutlet weak var ispLbl: UILabel!
    @IBOutlet weak var cityLbl: UILabel!
    @IBOutlet weak var actionLbl: UILabel!
    @IBOutlet weak var timeLbl: UILabel!
    @IBOutlet weak var regionLbl: UILabel!
    @IBOutlet weak var IPLbl: UILabel!
    @IBOutlet weak var DeviceLbl: UILabel!
    @IBOutlet weak var mapView: MKMapView!

    let backButton: UIButton = UIButton(type: .custom)
    var item: UserLoginActivityModel!

    let ipApiURLString = "http://ip-api.com/json/"

    override func viewDidLoad() {
        super.viewDidLoad()

        setupButtons()
        DeviceLbl.text = item.device
        fetchLocationInformation()
        configureTimeAndAction()
    }



    private func fetchLocationInformation() {
        guard let url = URL(string: ipApiURLString)?.appendingPathComponent(item.ip) else {
            print("Invalid URL")
            return
        }

        AF.request(url, method: .get)
            .validate(statusCode: 200..<500)
            .responseJSON { responseJSON in
                switch responseJSON.result {
                    case .success(let json):
                        self.processJSON(json: json)
                    case .failure(let error):
                        print(error.localizedDescription)
                        // Consider adding user alert or other UI handling here
                }
        }
    }

    private func processJSON(json: Any) {
        if let dict = json as? Dictionary<String, Any>,
           let status = dict["status"] as? String, status == "success",
           let regionName = dict["regionName"] as? String,
           let lat = dict["lat"] as? CLLocationDegrees,
           let lon = dict["lon"] as? CLLocationDegrees,
           let query = dict["query"] as? String,
           let city = dict["city"] as? String,
           let isp = dict["isp"] as? String,
           let country = dict["country"] as? String {
            
            let location = CLLocationCoordinate2D(latitude: lat, longitude: lon)
            centerMapOnUserLocation(location: location)
            regionLbl.text = regionName
            IPLbl.text = query
            cityLbl.text = city
            ispLbl.text = isp
            countryLbl.text = country
        } else {
            IPLbl.text = item.ip
            regionLbl.text = "Private range"
            countryLbl.text = "Private range"
            cityLbl.text = "Private range"
            ispLbl.text = "Private range"
        }
    }

    private func configureTimeAndAction() {
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = "MM-dd-yyyy HH:mm:ss"
        timeLbl.text = dateFormatterGet.string(from: item.createdAt)
        actionLbl.text = item.content
    }

    func centerMapOnUserLocation(location: CLLocationCoordinate2D) {
        let region = MKCoordinateRegion(center: location, latitudinalMeters: 1000, longitudinalMeters: 1000)
        mapView.setRegion(region, animated: true)
        let annotation = MKPointAnnotation()
        annotation.coordinate = location
        mapView.removeAnnotations(mapView.annotations)
        mapView.addAnnotation(annotation)
    }
}


extension LogInfomationVC {
    
    func setupButtons() {
        
        setupBackButton()
       
    }
    
    func setupBackButton() {
    
        backButton.frame = back_frame
        backButton.contentMode = .center

        if let backImage = UIImage(named: "back-black") {
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

