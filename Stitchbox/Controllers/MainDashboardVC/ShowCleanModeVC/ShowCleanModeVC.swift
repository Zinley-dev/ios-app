//
//  ShowCleanModeVC.swift
//  Stitchbox
//
//  Created by Khoi Nguyen on 8/11/23.
//

import UIKit
import AsyncDisplayKit

class ShowCleanModeVC: UIViewController {
    
    deinit {
        //view.gestureRecognizers?.forEach(view.removeGestureRecognizer)
        print("ShowCleanModeVC is being deallocated.")
    }

    @IBOutlet weak var videoView: UIView!
    @IBOutlet weak var ClearSwitch: UISwitch!
    var isClearMode = false
    var muxPlaybackId = "UGzRce5Jy9lymhq5wk02mAdEQXwafvncFd4NdIqnVVVY"
    @IBOutlet weak var mainViewWidth: NSLayoutConstraint!
    @IBOutlet weak var mainStackWidth: NSLayoutConstraint!
    
    private var videoNode: ASVideoNode!
    private var gradientNode: GradientView!
    private var headerView: PostHeader!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupVideoiews()
        setupGradientView()
        setupHeader()
        setupSideButtonsView()
        
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        videoNode.pause()
        
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        let newWidth = self.videoNode.frame.height / 16 * 9
        mainViewWidth.constant = newWidth
        setupSpace(width: newWidth)
        mainStackWidth.constant = newWidth
        
    }
    
    private func setupVideoiews() {
        
        videoNode = ASVideoNode()
        videoNode.view.translatesAutoresizingMaskIntoConstraints = false
        videoView.addSubview(videoNode.view)
        
        videoNode.contentMode = .scaleAspectFill
        videoNode.gravity = AVLayerVideoGravity.resizeAspectFill.rawValue
     
        NSLayoutConstraint.activate([
            videoNode.view.trailingAnchor.constraint(equalTo: videoView.trailingAnchor, constant: 0),
            videoNode.view.bottomAnchor.constraint(equalTo: videoView.bottomAnchor, constant: 0),
            videoNode.view.leadingAnchor.constraint(equalTo: videoView.leadingAnchor, constant: 0),
            videoNode.view.topAnchor.constraint(equalTo: videoView.topAnchor, constant: 0),
        ])
        
        videoNode.url = getThumbnailURL()
        videoNode.asset = AVAsset(url: getVideoURL()!)
        videoNode.player?.automaticallyWaitsToMinimizeStalling = true
        videoNode.shouldAutoplay = false
        videoNode.shouldAutorepeat = true
        videoNode.muted = true
        videoNode.play()
        
    }
    
    
    private func setupGradientView() {
        
        gradientNode = GradientView()
        
        //gradientNode.isLayerBacked = true
        gradientNode.isOpaque = false
        
        gradientNode.view.translatesAutoresizingMaskIntoConstraints = false
        videoView.addSubview(gradientNode.view)
        
        NSLayoutConstraint.activate([
            gradientNode.view.trailingAnchor.constraint(equalTo: videoView.trailingAnchor, constant: 0),
            gradientNode.view.bottomAnchor.constraint(equalTo: videoView.bottomAnchor, constant: 0),
            gradientNode.view.leadingAnchor.constraint(equalTo: videoView.leadingAnchor, constant: 0),
            gradientNode.view.topAnchor.constraint(equalTo: videoView.topAnchor, constant: 0),
            
        ])
        
    }
    
    private func setupHeader() {
        
        
    }
    
    
    private func setupSideButtonsView() {
       
        
    }
    
    private func setupSpace(width: CGFloat) {
        
      
    }

    @IBAction func ClearSwitchPressed(_ sender: Any) {
        
        var params = ["clearMode": false]
        
        if isClearMode {
            
            params = ["clearMode": false]
            isClearMode = false
            globalClear = false
            
            showAllInfo()
            
        } else {
            
            params = ["clearMode": true]
            isClearMode = true
            globalClear = true
            
            hideAllInfo()
            
        }
        
        
        APIManager.shared.updateSettings(params: params) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(_):
                print("Setting API update success")
                reloadGlobalSettings()
                
            case.failure(let error):
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    self.showErrorAlert("Oops!", msg: "Cannot update user's setting information \(error.localizedDescription)")
                }
            }
        }
        
    }
    
    private func showAllInfo() {
      
        
    }
    
    
    private func hideAllInfo() {
       
    }
    
    func showErrorAlert(_ title: String, msg: String) {
        
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        
        
        present(alert, animated: true, completion: nil)
        
    }
    
    
    @IBAction func nextBtnPressed(_ sender: Any) {
        
        videoNode.pause()
        videoNode.asset = nil
        videoNode.url = nil
        RedirectionHelper.redirectToDashboard()
        
    }
    
    func getThumbnailURL() -> URL? {
        let urlString = "https://image.mux.com/\(muxPlaybackId)/thumbnail.jpg?time=0"
        
        return URL(string: urlString)
    }
    
    func getVideoURL() -> URL? {
        let urlString = "https://stream.mux.com/\(muxPlaybackId).m3u8"
        return URL(string: urlString)
    }


}
