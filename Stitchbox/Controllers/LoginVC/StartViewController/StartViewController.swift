//
//  ViewController.swift
//  Stitchbox
//
//  Created by Nghiem Minh Hoang on 26/10/2022.
//

import UIKit
import AVFoundation
import RxSwift
import RxCocoa
import ZSWTappableLabel
import ZSWTaggedString
import SafariServices
import AuthenticationServices
import ObjectMapper

class StartViewController: UIViewController, ControllerType, ZSWTappableLabelTapDelegate, ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {


    // MARK: - IBOutlets
    @IBOutlet weak var launchingView: UIView!
    @IBOutlet weak var blurView: UIView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var btnLetStart: UIButton!
    @IBOutlet var collectionLoginProviders: [UIButton]!
    @IBOutlet var collectionLoginStackProviders: [UIView]!
    @IBOutlet weak var logo: UIImageView!
    @IBOutlet weak var startView: UIView!
    @IBOutlet weak var termOfUseLbl: ZSWTappableLabel!
    
    // MARK: - Properties
    typealias ViewModelType = StartViewModel
    private lazy var viewModel: ViewModelType! = ViewModelType(vc: self)
    private let disposeBag = DisposeBag()
    var player: AVPlayer?
    
    // MARK: - Constants
    static let URLAttributeName = NSAttributedString.Key(rawValue: "URL")

    // MARK: - Enums
    enum LinkType: String {
        case Privacy = "Privacy"
        case TermsOfUse = "TOU"

        var URL: Foundation.URL {
            switch self {
            case .Privacy:
                return Foundation.URL(string: "https://stitchbox.net/public-policy")!
            case .TermsOfUse:
                return Foundation.URL(string: "https://stitchbox.net/term-of-use")!
            }
        }
    }

    // MARK: - Lifecycle Methods
    deinit {
        print("StartViewController is being deallocated.")
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - ASAuthorizationControllerPresentationContextProviding
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        // Assumes the window is available; consider safely unwrapping
        return self.view.window!
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Check if the user session is active
        if _AppCoreData.userSession.value == nil {
            // Sign out if no active session is found
            _AppCoreData.signOut()

            // Animate the launch view disappearance
            UIView.animate(withDuration: 0.5) {
                self.launchingView.alpha = 0
            }

            // Hide the launch view after the animation completes
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
                guard let strongSelf = self else { return }
                if strongSelf.launchingView.alpha == 0 {
                    strongSelf.launchingView.isHidden = true
                }
            }

            // Initialize the layout
            startLayout()
        } else {
            // Load the newest core data
            self.loadNewestCoreData { [weak self] in
                self?.loadSettings { [weak self] in
                    // Ensure self is still available
                    guard let strongSelf = self else { return }

                    // Logout if the global setting is not available
                    if globalSetting == nil {
                        strongSelf.logout()
                    } else {
                        // Redirect to the dashboard if the setting has been shown
                        RedirectionHelper.redirectToDashboard()
                    }
                }
            }
        }

        // Setup the navigation bar
        setupNavBar()
    }

    // MARK: - Layout Initialization
    /// Initializes the UI layout and bindings.
    func startLayout() {
        // Building the user interface
        buildUI()

        // Binding UI elements
        bindingUI()

        // Setting up the terms of use label with tap delegate
        termOfUseLbl.tapDelegate = self

        // Configuring options for tagged strings in terms
        let options = ZSWTaggedStringOptions()
        options["link"] = .dynamic({ tagName, tagAttributes, stringAttributes in
            guard let typeString = tagAttributes["type"] as? String,
                  let type = LinkType(rawValue: typeString) else {
                return [NSAttributedString.Key: AnyObject]()
            }

            // Configuration for tappable links
            return [
                .tappableRegion: true,
                .tappableHighlightedBackgroundColor: UIColor.lightGray,
                .tappableHighlightedForegroundColor: UIColor.black,
                .foregroundColor: UIColor.white,
                .underlineStyle: NSUnderlineStyle.single.rawValue,
                StartViewController.URLAttributeName: type.URL
            ]
        })

        // Setting the attributed text for terms of use label
        let string = NSLocalizedString("By using any of these login option above. You agree to our <link type='TOU'>Terms of Use</link> and <link type='Privacy'>Privacy Policy</link>.", comment: "")
        termOfUseLbl.attributedText = try? ZSWTaggedString(string: string).attributedString(with: options)
    }

    // MARK: - Settings Loading
    /// Loads settings from the API and updates the application state.
    func loadSettings(completed: @escaping DownloadComplete) {
        APIManager.shared.getSettings { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .success(let apiResponse):
                guard let data = apiResponse.body else {
                    completed()
                    return
                }

                // Parsing and setting global settings
                let settings = Mapper<SettingModel>().map(JSONObject: data)
                globalSetting = settings
                globalIsSound = settings?.AutoPlaySound ?? false
                globalClear = settings?.ClearMode ?? false

                completed()

            case .failure(let error):
                print("Error loading settings: ", error)
                completed()
            }
        }
    }

    // MARK: - Core Data Loading
    /// Loads the newest core data information.
    func loadNewestCoreData(completed: @escaping DownloadComplete) {
        APIManager.shared.getme { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .success(let response):
                if let data = response.body, !data.isEmpty {
                    if let newUserData = Mapper<UserDataSource>().map(JSON: data) {
                        _AppCoreData.reset()
                        _AppCoreData.userDataSource.accept(newUserData)
                    }
                    completed()
                } else {
                    completed()
                }

            case .failure(let error):
                print("Error loading core data: ", error)
                completed()
            }
        }
    }

    // MARK: - Navigation Bar Setup
    /// Configures the appearance of the navigation bar.
    func setupNavBar() {
        let navigationBarAppearance = UINavigationBarAppearance()
        navigationBarAppearance.configureWithDefaultBackground()
        navigationBarAppearance.backgroundColor = .clear
        navigationBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        navigationBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        navigationBarAppearance.backgroundImage = UIImage()
        navigationBarAppearance.shadowImage = UIImage()
        navigationBarAppearance.shadowColor = .clear
        navigationBarAppearance.backgroundEffect = nil

        navigationController?.navigationBar.standardAppearance = navigationBarAppearance
        navigationController?.navigationBar.compactAppearance = navigationBarAppearance
        navigationController?.navigationBar.scrollEdgeAppearance = navigationBarAppearance
        navigationController?.navigationBar.isTranslucent = true

        navigationController?.setNavigationBarHidden(false, animated: true)
    }

    // MARK: - View Lifecycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if let player = player {
            player.play()
            NotificationCenter.default.addObserver(self, selector: #selector(playVideoDidReachEnd), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: player.currentItem)
        }
        setupNavBar()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        if let player = player {
            player.pause()
            NotificationCenter.default.removeObserver(self, name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: player.currentItem)
        }
    }

    // MARK: - UI Building
    /// Builds and configures the user interface elements.
    func buildUI() {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            guard let path = Bundle.main.path(forResource: "bg", ofType: ".mp4") else { return }
            self.player = AVPlayer(url: URL(fileURLWithPath: path))
            self.player?.actionAtItemEnd = .none
            let playerLayer = AVPlayerLayer(player: self.player)
            playerLayer.frame = self.view.frame
            playerLayer.videoGravity = .resizeAspectFill
            self.player?.seek(to: CMTime.zero)
            self.player?.play()
            self.player?.isMuted = true

            NotificationCenter.default.addObserver(self, selector: #selector(self.playVideoDidReachEnd), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: self.player?.currentItem)

            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.contentView.layer.insertSublayer(playerLayer, at: 0)
                self.btnLetStart.setTitle("", for: .normal)
                self.collectionLoginProviders.forEach { btn in
                    btn.setTitle("", for: .normal)
                }
            }
        }
    }

    @objc func playVideoDidReachEnd() {
        player?.seek(to: CMTime.zero)
    }

    // MARK: - Tappable Label Delegate
    /// Handles tap events on the tappable label.
    func tappableLabel(_ tappableLabel: ZSWTappableLabel, tappedAt idx: Int, withAttributes attributes: [NSAttributedString.Key : Any] = [:]) {
        guard let URL = attributes[StartViewController.URLAttributeName] as? URL else {
            return
        }

        let safariViewController = SFSafariViewController(url: URL)
        safariViewController.modalPresentationStyle = .fullScreen
        present(safariViewController, animated: true)
    }

    // MARK: - UI Binding
    /// Binds UI components to the view model.
    func bindingUI() {
        viewModel.output.errorsObservable
        .subscribe(onNext: { [weak self] error in
            DispatchQueue.main.async {
                guard let self = self else { return }
                if error._code == 401 {
                    self.navigationController?.pushViewController(LastStepViewController.create(), animated: true)
                } else {
                    self.presentError(error: error)
                }
            }
        })
        .disposed(by: disposeBag)

        viewModel.output.loginResultObservable.subscribe(onNext: { [weak self] isTrue in
            DispatchQueue.main.async {
                guard let self = self else { return }
                if isTrue {
                    self.handleLoginResult()
                }
            }
        })
        .disposed(by: disposeBag)
    }

    private func handleLoginResult() {
        RedirectionHelper.redirectToDashboard()
    }

    // Other functions...
    
    func bindUI(with viewModel: StartViewModel) {
        
    }
    
    func bindAction(with viewModel: StartViewModel) {
        
    }


  
    // MARK: - IBActions

    /// Handles the "Let's Start" button tap action.
    @IBAction func didTapLetStart(_ sender: UIButton) {
        UIView.animate(withDuration: 0.3) { [weak self] in
            self?.collectionLoginStackProviders.forEach { item in
                item.isHidden.toggle()
                item.alpha = item.isHidden ? 0 : 1
            }
        }
    }

    /// Handles the social login button tap action.
    @IBAction func didTapLogin(_ sender: UIButton) {
        guard let selected = SocialLoginType(rawValue: sender.tag) else {
            print("Can't get SocialLoginType tag number to perform")
            return
        }
        viewModel.startSignInProcess(with: selected)
    }

    /// Handles the normal login button tap action.
    @IBAction func didTapNormalLogin(_ sender: UIButton) {
        if let NLVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "NormalLoginVC") as? NormalLoginVC {
            self.navigationController?.pushViewController(NLVC, animated: true)
        }
    }

    /// Handles the Apple login button tap action.
    @IBAction func didTapAppleLogin(_ sender: UIButton) {
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]

        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }

    // MARK: - Touches Handling

    /// Handles touches began event.
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)

        guard let touch = touches.first else { return }
        let location = touch.location(in: self.view)
        
        if !termOfUseLbl.frame.contains(location) {
            UIView.animate(withDuration: 0.3) { [weak self] in
                self?.collectionLoginStackProviders.forEach { item in
                    item.isHidden.toggle()
                    item.alpha = item.isHidden ? 0 : 1
                }
            }
        }
    }


    // MARK: - Error Handling

    /// Shows an error alert.
    func showErrorAlert(_ title: String, msg: String) {
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }

    // MARK: - Logout Handling

    /// Handles the logout process.
    func logout() {
        sendbirdLogout()
        IAPManager.shared.signout()
        removeAllUserDefaults()

        delay(1) { [weak self] in
            guard let self = self else { return }

            SwiftLoader.hide()
            CacheManager.shared.clearAllCache()
            _AppCoreData.signOut()
            self.launchingView.isHidden = true
        }
    }

    // MARK: - ASAuthorizationControllerDelegate

    /// Called when the authorization controller completes with an error.
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        if error._code != 1001 {
            showErrorAlert("Oops!", msg: error.localizedDescription)
        }
    }

    /// Called when the authorization controller completes with an authorization.
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential else { return }
        let userIdentifier = appleIDCredential.user
        let userFirstName = appleIDCredential.fullName?.givenName
        let userLastName = appleIDCredential.fullName?.familyName
        let userEmail = appleIDCredential.email

        let data = AuthResult(idToken: userIdentifier, providerID: nil, rawNonce: nil, accessToken: nil, name: "\(userFirstName ?? "") \(userLastName ?? "")", email: userEmail, phone: nil, avatar: "")
        self.viewModel.completeSignIn(with: data)
    }

    
}
