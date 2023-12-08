//
//  StitchDashboardVC.swift
//  Stitchbox
//
//  Created by Khoi Nguyen on 7/22/23.
//

import UIKit
import FLAnimatedImage
import AsyncDisplayKit

class StitchDashboardVC: UIViewController {
    
    let backButton: UIButton = UIButton(type: .custom)

    @IBOutlet weak var buttonStackView: UIStackView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var pendingBtn: UIButton!
    @IBOutlet weak var approvedBtn: UIButton!
    @IBOutlet weak var stitchToBtn: UIButton!
    
    @IBOutlet weak var loadingImage: FLAnimatedImageView!
    @IBOutlet weak var loadingView: UIView!
    
    
    var pendingBorder = CALayer()
    var approvedBorder = CALayer()
    var stitchToBorder = CALayer()
  
    var firstLoad = true
    var firstAnimated = false
    
    
    lazy var PendingVC: PendingVC = {
        let storyboard = UIStoryboard(name: "Dashboard", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "PendingVC") as? PendingVC
        if let controller = controller {
            self.addVCAsChildVC(childViewController: controller)
        }
        return controller!
    }()
    
    lazy var ApprovedStitchVC: ApprovedStitchVC = {
        let storyboard = UIStoryboard(name: "Dashboard", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "ApprovedStitchVC") as? ApprovedStitchVC
        if let controller = controller {
            self.addVCAsChildVC(childViewController: controller)
        }
        return controller!
    }()
    
    lazy var StitchToVC: StitchToVC = {
        let storyboard = UIStoryboard(name: "Dashboard", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "StitchToVC") as? StitchToVC
        if let controller = controller {
            self.addVCAsChildVC(childViewController: controller)
        }
        return controller!
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        initialSetup()
        setInitialButtonColors()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        prepareForAppearance()
        setupLoadingAnimation()
        manageVideoPlaybackOnAppearance()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        pauseVideoIfNeeded()
    }

    @IBAction func pendingBtnPressed(_ sender: Any) {
        updateButtonStyles(selectedButton: pendingBtn, deselectedButtons: [approvedBtn, stitchToBtn])
        updateBorders(addedTo: pendingBtn, removedFrom: [approvedBtn, stitchToBtn])
        toggleVCVisibility(show: PendingVC, hide: [ApprovedStitchVC, StitchToVC])
        manageVideoPlayback(playIn: PendingVC, pauseIn: [ApprovedStitchVC, StitchToVC])
    }
    
    @IBAction func approvedBtnPressed(_ sender: Any) {
        updateButtonStyles(selectedButton: approvedBtn, deselectedButtons: [pendingBtn, stitchToBtn])
        updateBorders(addedTo: approvedBtn, removedFrom: [pendingBtn, stitchToBtn])
        toggleVCVisibility(show: ApprovedStitchVC, hide: [PendingVC, StitchToVC])
        manageVideoPlayback(playIn: ApprovedStitchVC, pauseIn: [PendingVC, StitchToVC])
    }
    
    @IBAction func stitchToBtnPressed(_ sender: Any) {
        updateButtonStyles(selectedButton: stitchToBtn, deselectedButtons: [pendingBtn, approvedBtn])
        updateBorders(addedTo: stitchToBtn, removedFrom: [pendingBtn, approvedBtn])
        toggleVCVisibility(show: StitchToVC, hide: [PendingVC, ApprovedStitchVC])
        manageVideoPlayback(playIn: StitchToVC, pauseIn: [PendingVC, ApprovedStitchVC])
    }

}

extension StitchDashboardVC {


    // MARK: - Initial Setup

    private func initialSetup() {
        setupNavBar()
        setupLayers()
        setupBackButton()
    }

    private func setInitialButtonColors() {
        pendingBtn.setTitleColor(.black, for: .normal)
        approvedBtn.setTitleColor(.lightGray, for: .normal)
        stitchToBtn.setTitleColor(.lightGray, for: .normal)
    }

    // MARK: - View Appearance Preparation

    private func prepareForAppearance() {
        setupNavBar()
        showMiddleBtn(vc: self)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }

    private func setupLoadingAnimation() {
        if !firstAnimated {
            firstAnimated = true
            DispatchQueue.global(qos: .background).async { [weak self] in
                self?.loadGIFAnimation()
            }
            loadingView.backgroundColor = view.backgroundColor
            fadeOutLoadingView(after: 1.5)
        }
        
    }

    private func loadGIFAnimation() {
        do {
            if let path = Bundle.main.path(forResource: "fox2", ofType: "gif") {
                let gifData = try Data(contentsOf: URL(fileURLWithPath: path))
                let image = FLAnimatedImage(animatedGIFData: gifData)

                DispatchQueue.main.async { [weak self] in
                    self?.loadingImage.animatedImage = image
                }
            }
        } catch {
            print(error.localizedDescription)
        }
    }

    private func fadeOutLoadingView(after delaySeconds: TimeInterval) {
        delay(delaySeconds) { [weak self] in
            guard let self = self else { return }

            UIView.animate(withDuration: 0.5) {
                self.loadingView.alpha = 0
            }

            self.removeLoadingView(after: 1.5)
        }
    }

    private func removeLoadingView(after delaySeconds: TimeInterval) {
        DispatchQueue.main.asyncAfter(deadline: .now() + delaySeconds) { [weak self] in
            guard let self = self else { return }

            if self.loadingView.alpha == 0 {
                self.loadingView.isHidden = true
                self.loadingImage.stopAnimating()
                self.loadingImage.animatedImage = nil
                self.loadingImage.image = nil
                self.loadingImage.removeFromSuperview()
            }
        }
    }

    // MARK: - Video Playback Management

    /// Manages video playback when the view will appear.
    private func manageVideoPlaybackOnAppearance() {
        if firstLoad {
            firstLoad = false
        } else {
            playVideoInVisibleViewController()
        }
    }

    /// Plays video in the currently visible view controller, if applicable.
    private func playVideoInVisibleViewController() {
        if !PendingVC.view.isHidden, let currentIndex = PendingVC.currentIndex {
            PendingVC.playVideo(atIndex: currentIndex)
        } else if !StitchToVC.view.isHidden, let currentIndex = StitchToVC.currentIndex {
            StitchToVC.playVideo(atIndex: currentIndex)
        } else if !ApprovedStitchVC.view.isHidden, let currentIndex = ApprovedStitchVC.currentIndex {
            ApprovedStitchVC.playVideo(atIndex: currentIndex)
        }
    }
}


extension StitchDashboardVC {

    /// Pauses the video in the current visible view controller.
    private func pauseVideoIfNeeded() {
        if !PendingVC.view.isHidden, let currentIndex = PendingVC.currentIndex {
            PendingVC.pauseVideo(atIndex: currentIndex)
        } else if !StitchToVC.view.isHidden, let currentIndex = StitchToVC.currentIndex {
            StitchToVC.pauseVideo(atIndex: currentIndex)
        } else if !ApprovedStitchVC.view.isHidden, let currentIndex = ApprovedStitchVC.currentIndex {
            ApprovedStitchVC.pauseVideo(atIndex: currentIndex)
        }
    }
    
    /// Sets up the navigation bar appearance.
    func setupNavBar() {
        configureNavigationBarAppearance()
        navigationItem.title = "Stitch dashboard"
    }

    /// Configures the appearance of the navigation bar.
    private func configureNavigationBarAppearance() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .white
        appearance.titleTextAttributes = [.foregroundColor: UIColor.black]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.black]

        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
    }
    
    /// Sets up the bottom borders for the buttons and initial view visibility.
    func setupLayers() {
        setupButtonBorders()
        initialViewVisibilitySetup()
    }

    /// Adds bottom borders to buttons.
    private func setupButtonBorders() {
        let borderWidth = view.frame.width * (120/375)
        pendingBorder = pendingBtn.addBottomBorderWithColor(color: .secondary, height: 2.0, width: borderWidth)
        stitchToBorder = stitchToBtn.addBottomBorderWithColor(color: .secondary, height: 2.0, width: borderWidth)
        approvedBorder = approvedBtn.addBottomBorderWithColor(color: .secondary, height: 2.0, width: borderWidth)

        pendingBtn.layer.addSublayer(pendingBorder)
        stitchToBorder.removeFromSuperlayer()
        approvedBorder.removeFromSuperlayer()
    }

    /// Configures the initial visibility of the view controllers.
    private func initialViewVisibilitySetup() {
        ApprovedStitchVC.view.isHidden = true
        StitchToVC.view.isHidden = true
        PendingVC.view.isHidden = false
    }
}


extension StitchDashboardVC {


    // MARK: - Private Helper Methods

    private func updateButtonStyles(selectedButton: UIButton, deselectedButtons: [UIButton]) {
        selectedButton.setTitleColor(.black, for: .normal)
        deselectedButtons.forEach { $0.setTitleColor(.lightGray, for: .normal) }
    }

    private func updateBorders(addedTo selectedButton: UIButton, removedFrom deselectedButtons: [UIButton]) {
        let borders = [pendingBorder, approvedBorder, stitchToBorder]
        for border in borders {
            border.removeFromSuperlayer()
        }
        selectedButton.layer.addSublayer(borderForButton(selectedButton))
    }

    private func toggleVCVisibility(show visibleVC: UIViewController, hide hiddenVCs: [UIViewController]) {
        visibleVC.view.isHidden = false
        hiddenVCs.forEach { $0.view.isHidden = true }
    }

    private func manageVideoPlayback(playIn playingVC: UIViewController, pauseIn pausedVCs: [UIViewController]) {
        
        if let vc = playingVC as? PendingVC {
            vc.playVideo(atIndex: vc.currentIndex!)
        } else if let vc = playingVC as? ApprovedStitchVC {
            vc.playVideo(atIndex: vc.currentIndex!)
        } else if let vc = playingVC as? StitchToVC {
            vc.playVideo(atIndex: vc.currentIndex!)
        }
        
        for pauseVC in pausedVCs {
            if let vc = playingVC as? PendingVC {
                vc.pauseVideo(atIndex: vc.currentIndex!)
            } else if let vc = pauseVC as? ApprovedStitchVC {
                vc.pauseVideo(atIndex: vc.currentIndex!)
            } else if let vc = pauseVC as? StitchToVC {
                vc.pauseVideo(atIndex: vc.currentIndex!)
            }
        }
        
    }

    private func borderForButton(_ button: UIButton) -> CALayer {
        switch button {
        case pendingBtn: return pendingBorder
        case approvedBtn: return approvedBorder
        case stitchToBtn: return stitchToBorder
        default: return CALayer()
        }
    }
}

protocol VideoPlayable {
    var currentIndex: Int? { get set }
    func playVideo(atIndex index: Int)
    func pauseVideo(atIndex index: Int)
}


extension StitchDashboardVC {
    
    /// Adds a child view controller to the current view controller.
    /// - Parameter childViewController: The child view controller to add.
    func addVCAsChildVC(childViewController: UIViewController) {
        // Add child view controller
        addChild(childViewController)

        // Add child view as subview
        contentView.addSubview(childViewController.view)

        // Configure the child view
        configureChildView(childViewController.view)
        
        // Notify the child view controller
        childViewController.didMove(toParent: self)
    }
    
    /// Removes a child view controller from the current view controller.
    /// - Parameter childViewController: The child view controller to remove.
    func removeVCAsChildVC(childViewController: UIViewController) {
        // Notify the child view controller
        childViewController.willMove(toParent: nil)

        // Remove the child view from the superview
        childViewController.view.removeFromSuperview()

        // Remove the child view controller
        childViewController.removeFromParent()
    }

    // MARK: - Private Helper Methods

    /// Configures the frame and autoresizing mask of the child view.
    /// - Parameter childView: The view of the child view controller.
    private func configureChildView(_ childView: UIView) {
        childView.frame = contentView.bounds
        childView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }
}


extension StitchDashboardVC {
    
    // MARK: - Setup Methods

    /// Sets up the UI buttons in the view controller.
    func setupButtons() {
        setupBackButton()
    }
    
    /// Configures the back button with appropriate styling and action.
    func setupBackButton() {
        configureBackButtonFrameAndContentMode()
        configureBackButtonImage()
        addButtonActionAndStyles()
        addBackButtonToNavigationBar()
    }

    // MARK: - Error Handling

    /// Displays an error alert with the provided title and message.
    /// - Parameters:
    ///   - title: The title of the alert.
    ///   - msg: The message of the alert.
    func showErrorAlert(_ title: String, msg: String) {
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    // MARK: - Private Helper Methods

    private func configureBackButtonFrameAndContentMode() {
        backButton.frame = back_frame
        backButton.contentMode = .center
    }

    private func configureBackButtonImage() {
        guard let backImage = UIImage(named: "back-black") else { return }
        let imageSize = CGSize(width: 13, height: 23)
        let padding = UIEdgeInsets(top: (back_frame.height - imageSize.height) / 2,
                                   left: (back_frame.width - imageSize.width) / 2 - horizontalPadding,
                                   bottom: (back_frame.height - imageSize.height) / 2,
                                   right: (back_frame.width - imageSize.width) / 2 + horizontalPadding)
        backButton.imageEdgeInsets = padding
        backButton.setImage(backImage, for: [])
    }

    private func addButtonActionAndStyles() {
        backButton.addTarget(self, action: #selector(onClickBack(_:)), for: .touchUpInside)
        backButton.setTitleColor(.white, for: .normal)
        backButton.setTitle("", for: .normal)
    }

    private func addBackButtonToNavigationBar() {
        let backButtonBarButton = UIBarButtonItem(customView: backButton)
        navigationItem.title = "Pending stitches"
        navigationItem.leftBarButtonItem = backButtonBarButton
    }
}

extension StitchDashboardVC {
    
    // MARK: - Actions

    /// Handles the action when the back button is clicked.
    @objc func onClickBack(_ sender: AnyObject) {
        navigationController?.popViewController(animated: true)
    }
}

