//
//  In-gameVC.swift
//  Stitchbox
//
//  Created by Khoi Nguyen on 4/15/23.
//

import UIKit

class In_gameVC: UIViewController, UINavigationBarDelegate, UINavigationControllerDelegate {
    
    let backButton: UIButton = UIButton(type: .custom)
    
    @IBOutlet weak var player1BlueNameLbl: UILabel!
    @IBOutlet weak var player2BlueNameLbl: UILabel!
    @IBOutlet weak var player3BlueNameLbl: UILabel!
    @IBOutlet weak var player4BlueNameLbl: UILabel!
    @IBOutlet weak var player5BlueNameLbl: UILabel!
    
    @IBOutlet weak var player1RedNameLbl: UILabel!
    @IBOutlet weak var player2RedNameLbl: UILabel!
    @IBOutlet weak var player3RedNameLbl: UILabel!
    @IBOutlet weak var player4RedNameLbl: UILabel!
    @IBOutlet weak var player5RedNameLbl: UILabel!
    
    
    @IBOutlet weak var player1BlueImage: UIImageView!
    @IBOutlet weak var player2BlueImage: UIImageView!
    @IBOutlet weak var player3BlueImage: UIImageView!
    @IBOutlet weak var player4BlueImage: UIImageView!
    @IBOutlet weak var player5BlueImage: UIImageView!
    
    @IBOutlet weak var player1RedImage: UIImageView!
    @IBOutlet weak var player2RedImage: UIImageView!
    @IBOutlet weak var player3RedImage: UIImageView!
    @IBOutlet weak var player4RedImage: UIImageView!
    @IBOutlet weak var player5RedImage: UIImageView!
    
    @IBOutlet weak var player1BlueView: UIView!
    @IBOutlet weak var player2BlueView: UIView!
    @IBOutlet weak var player3BlueView: UIView!
    @IBOutlet weak var player4BlueView: UIView!
    @IBOutlet weak var player5BlueView: UIView!
    
    @IBOutlet weak var player1RedView: UIView!
    @IBOutlet weak var player2RedView: UIView!
    @IBOutlet weak var player3RedView: UIView!
    @IBOutlet weak var player4RedView: UIView!
    @IBOutlet weak var player5RedView: UIView!
    
    var viewToParticipant: [UIView: Champion] = [:]

    @IBOutlet weak var gameTimeLbl: UILabel!
    @IBOutlet weak var gameTypeLbl: UILabel!
    
    var gameTimeTimer: Timer?
    var gameLengthInSeconds: Int = 0
      
    @IBOutlet weak var notCurrentlyInGameLbl: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupButtons()
        //loadGameInfo()
        self.calculateChampionWinRate(championName: "Ryze")
             
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        startGameTimeTimer()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopGameTimeTimer()
    }

    
}

extension In_gameVC {
    
    func setupButtons() {
        
        setupBackButton()
        setupTitle()
    
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

        self.navigationItem.leftBarButtonItem = backButtonBarButton


        
    }

    
    func setupTitle() {
    
        
        navigationItem.title = "SB-Tactics"
       
       
       
    }
    

}

extension In_gameVC {
    
    @objc func onClickBack(_ sender: AnyObject) {
        if let navigationController = self.navigationController {
            navigationController.popViewController(animated: true)
        }
       
    }
    
    
}

extension In_gameVC {

    // Call this function when you want to reset the timer to the initial value
    func resetGameTime() {
        stopGameTimeTimer()
        gameLengthInSeconds = 0
        gameTimeLbl.text = "00:00"
    }
    
    
    func loadGameInfo() {
        presentSwiftLoader()
        APIManager().userInGame { result in
            switch result {
            case .success(let apiResponse):
                guard let data = apiResponse.body?["data"] as? [String: Any] else {
                    DispatchQueue.main.async {
                        SwiftLoader.hide()
                        self.displayNotCurrentlyInGame()
                    }

                    return
                }
              
                let inGameModel = InGameModel(data: data)
                
                DispatchQueue.main.async {
                    SwiftLoader.hide()
                    self.updatePlayerLabels(inGameModel: inGameModel)
                    self.loadChampionImages(inGameModel: inGameModel)
                    self.updateGameLabels(inGameModel: inGameModel)
                    
                    // Add gesture recognizers to player views
                    self.addTapGestureToView(self.player1BlueView)
                    self.addTapGestureToView(self.player2BlueView)
                    self.addTapGestureToView(self.player3BlueView)
                    self.addTapGestureToView(self.player4BlueView)
                    self.addTapGestureToView(self.player5BlueView)
                    self.addTapGestureToView(self.player1RedView)
                    self.addTapGestureToView(self.player2RedView)
                    self.addTapGestureToView(self.player3RedView)
                    self.addTapGestureToView(self.player4RedView)
                    self.addTapGestureToView(self.player5RedView)

                    
                    self.calculateChampionWinRate(championName: "Ryze")
                }
              
            case .failure(let error):
                
                DispatchQueue.main.async {
                    SwiftLoader.hide()
                    self.displayNotCurrentlyInGame()
                }
                print(error)
            }
        }
    }
    
    
    func getPlayerStats(queue: String, championName: String, completion: @escaping (CurrentChampionStatsModel?) -> Void) {
        APIManager().getSummonerStat(region: "NA", name: "1122356", queue: "420") { result in
            switch result {
            case .success(let apiResponse):
                guard let data = apiResponse.body?["data"] as? [String: Any],
                      let championStats = CurrentChampionStatsModel(data: data) else {
                    completion(nil)
                    return
                }
                
                print(data)
                
                completion(championStats)
            case .failure(let error):
                print(error)
                completion(nil)
            }
        }
    }

    func calculateChampionWinRate(championName: String) {
        getPlayerStats(queue: "420", championName: championName) { championStats in
            guard let stats = championStats else {
                print("Error: Could not retrieve champion stats")
                return
            }

            let totalGamesPlayed = stats.championCount[championName] ?? 0
            let totalGamesWon = stats.championWin[championName] ?? 0

            if totalGamesPlayed > 0 {
                let winRate = Double(totalGamesWon) / Double(totalGamesPlayed) * 100
                let roundedWinRate = round(winRate * 100) / 100
                print("\(championName) has been played \(totalGamesPlayed) times with a win rate of \(roundedWinRate)%")
            } else {
                print("\(championName) has not been played")
            }
        }
    }

    
    func updatePlayerLabels(inGameModel: InGameModel) {
        if inGameModel.blueTeam.count == 5 {
            player1BlueNameLbl.text = inGameModel.blueTeam[0].summoner
            player2BlueNameLbl.text = inGameModel.blueTeam[1].summoner
            player3BlueNameLbl.text = inGameModel.blueTeam[2].summoner
            player4BlueNameLbl.text = inGameModel.blueTeam[3].summoner
            player5BlueNameLbl.text = inGameModel.blueTeam[4].summoner
        }
        
        if inGameModel.redTeam.count == 5 {
            player1RedNameLbl.text = inGameModel.redTeam[0].summoner
            player2RedNameLbl.text = inGameModel.redTeam[1].summoner
            player3RedNameLbl.text = inGameModel.redTeam[2].summoner
            player4RedNameLbl.text = inGameModel.redTeam[3].summoner
            player5RedNameLbl.text = inGameModel.redTeam[4].summoner
        }
        
        
        // Set view-to-participant mapping
            viewToParticipant = [
                player1BlueView: inGameModel.blueTeam[0],
                player2BlueView: inGameModel.blueTeam[1],
                player3BlueView: inGameModel.blueTeam[2],
                player4BlueView: inGameModel.blueTeam[3],
                player5BlueView: inGameModel.blueTeam[4],
                player1RedView: inGameModel.redTeam[0],
                player2RedView: inGameModel.redTeam[1],
                player3RedView: inGameModel.redTeam[2],
                player4RedView: inGameModel.redTeam[3],
                player5RedView: inGameModel.redTeam[4],
            ]
    }

    
    func loadChampionImages(inGameModel: InGameModel) {
        if inGameModel.blueTeam.count == 5 {
            player1BlueImage.load(url: URL(string: inGameModel.blueTeam[0].icon)!, str: inGameModel.blueTeam[0].icon)
            player2BlueImage.load(url: URL(string: inGameModel.blueTeam[1].icon)!, str: inGameModel.blueTeam[1].icon)
            player3BlueImage.load(url: URL(string: inGameModel.blueTeam[2].icon)!, str: inGameModel.blueTeam[2].icon)
            player4BlueImage.load(url: URL(string: inGameModel.blueTeam[3].icon)!, str: inGameModel.blueTeam[3].icon)
            player5BlueImage.load(url: URL(string: inGameModel.blueTeam[4].icon)!, str: inGameModel.blueTeam[4].icon)
        }

        if inGameModel.redTeam.count == 5 {
            player1RedImage.load(url: URL(string: inGameModel.redTeam[0].icon)!, str: inGameModel.redTeam[0].icon)
            player2RedImage.load(url: URL(string: inGameModel.redTeam[1].icon)!, str: inGameModel.redTeam[1].icon)
            player3RedImage.load(url: URL(string: inGameModel.redTeam[2].icon)!, str: inGameModel.redTeam[2].icon)
            player4RedImage.load(url: URL(string: inGameModel.redTeam[3].icon)!, str: inGameModel.redTeam[3].icon)
            player5RedImage.load(url: URL(string: inGameModel.redTeam[4].icon)!, str: inGameModel.redTeam[4].icon)
        }
    }


    func updateGameLabels(inGameModel: InGameModel) {
        
        gameLengthInSeconds = inGameModel.match.length + 180 // Add 180 seconds (3 minutes) to the initial value
            let minutes = gameLengthInSeconds / 60
            let seconds = gameLengthInSeconds % 60
            gameTimeLbl.text = String(format: "%02d:%02d", minutes, seconds)

            gameTypeLbl.text = inGameModel.match.queue.description
                
            startGameTimeTimer()
    }



    func startGameTimeTimer() {
        
        if notCurrentlyInGameLbl.isHidden, gameLengthInSeconds != 0 {
            
            gameTimeTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateGameTime), userInfo: nil, repeats: true)
        
        }
        
    }
    

    func stopGameTimeTimer() {
        gameTimeTimer?.invalidate()
        gameTimeTimer = nil
    }

    @objc func updateGameTime() {
        gameLengthInSeconds += 1
        let minutes = gameLengthInSeconds / 60
        let seconds = gameLengthInSeconds % 60
        gameTimeLbl.text = String(format: "%02d:%02d", minutes, seconds)
    }

    
    func displayNotCurrentlyInGame() {
        notCurrentlyInGameLbl.isHidden = false
    }
    
    
    func addTapGestureToView(_ view: UIView) {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(viewTapped(_:)))
        view.addGestureRecognizer(tapGesture)
    }

    @objc func viewTapped(_ sender: UITapGestureRecognizer) {
        if let tappedView = sender.view {
            // Deselect all views
            deselectAllPlayerViews()

            // Select the tapped view
            tappedView.backgroundColor = .musicBackgroundDark
            if let participant = viewToParticipant[tappedView] {
               
                let url = "https://app.mobalytics.gg/lol/champions/\(participant.championName.lowercased())"
                print(url)
                  
            }
        }
    }
    
    func deselectAllPlayerViews() {
        let playerViews = [
            player1BlueView, player2BlueView, player3BlueView, player4BlueView, player5BlueView,
            player1RedView, player2RedView, player3RedView, player4RedView, player5RedView
        ]

        for view in playerViews {
            view?.backgroundColor = .clear
        }
    }
    
}
