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
    private var gradientNode: GradienView!
    private var headerView: PostHeader!
    private var sideButtonsView: ButtonSideList!
    
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
        
        gradientNode = GradienView()
        
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
        
        headerView = PostHeader()
        headerView.translatesAutoresizingMaskIntoConstraints = false
        videoView.addSubview(self.headerView)
        
        NSLayoutConstraint.activate([
            headerView.trailingAnchor.constraint(equalTo: videoView.trailingAnchor, constant: 0),
            headerView.bottomAnchor.constraint(equalTo: videoView.bottomAnchor, constant: 0),
            headerView.leadingAnchor.constraint(equalTo: videoView.leadingAnchor, constant: 0),
            headerView.topAnchor.constraint(equalTo: videoView.topAnchor, constant: 0),
            
        ])
        
        headerView.shareBtn.setImage(shareImage, for: .normal)
        headerView.saveBtn.setImage(unsaveImage, for: .normal)
        headerView.commentBtn.setImage(cmtImage, for: .normal)
        
        headerView.likeCountLbl.text = "10M"
        headerView.shareCountLbl.text = "2M"
        headerView.commentCountLbl.text = "20k"
        headerView.saveCountLbl.text = "1M"
        
        headerView.usernameLbl.text = "@StitchboxTeam"
        headerView.contentLbl.text = "Thanks for joining us! We value you. 🌟"
        headerView.usernameLbl.font = FontManager.shared.roboto(.Medium, size: 14)
        headerView.contentLbl.font = FontManager.shared.roboto(.Regular, size: 13)
        headerView.createStitchView.isHidden = true
        self.headerView.setNeedsLayout()
        self.headerView.layoutIfNeeded()
        
    }
    
    
    private func setupSideButtonsView() {
        sideButtonsView = ButtonSideList()
        sideButtonsView.backgroundColor = .clear
        sideButtonsView.translatesAutoresizingMaskIntoConstraints = false
        videoView.addSubview(sideButtonsView)
        
        sideButtonsView.statusImg.isHidden = false
        
        NSLayoutConstraint.activate([
            sideButtonsView.trailingAnchor.constraint(equalTo: videoView.trailingAnchor, constant: -8),
            sideButtonsView.bottomAnchor.constraint(equalTo: videoView.bottomAnchor, constant: -55),
            sideButtonsView.widthAnchor.constraint(equalToConstant: 55),
            sideButtonsView.heightAnchor.constraint(equalTo: videoView.heightAnchor)
        ])
        
        
        sideButtonsView.isHidden = false
        sideButtonsView.originalStack.isHidden = false
        sideButtonsView.stickStack.isHidden = true
        sideButtonsView.originalStitchCount.text = "\(formatPoints(num: Double(1000)))"
        
    }
    
    private func setupSpace(width: CGFloat) {
        
        if let buttonsView = self.headerView {
         
            let leftAndRightPadding: CGFloat = 10 * 2 // Padding for both sides
            let itemWidth: CGFloat = 65
            let numberOfItems: CGFloat = 4 // Number of items in the stack view
            let superViewWidth: CGFloat = width // Assuming this is the superview's width
            
            // Calculate the total width of items
            let totalItemWidth: CGFloat = numberOfItems * itemWidth
            
            // Calculate the total space we have left for spacing after subtracting the item widths and paddings
            let totalSpacingWidth: CGFloat = superViewWidth - totalItemWidth - leftAndRightPadding
            
            // Calculate the spacing by dividing the total space by the number of spaces (which is 3, for 4 items)
            let spacing: CGFloat = totalSpacingWidth / (numberOfItems - 1)
            
            // Set the calculated spacing
            print(width, spacing, totalItemWidth)
            buttonsView.stackView.spacing = spacing
        }
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
        
        gradientNode.isHidden = false
        headerView.isHidden = false
        sideButtonsView.isHidden = false
        
    }
    
    
    private func hideAllInfo() {
        
        gradientNode.isHidden = true
        headerView.isHidden = true
        sideButtonsView.isHidden = true
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
