//
//  SB-MetaVC.swift
//  Stitchbox
//
//  Created by Khoi Nguyen on 5/9/23.
//

import UIKit
import ObjectMapper
import SafariServices

class SB_MetaVC: UIViewController {
    
    let input = """
Neeko:

* Changes: Passive, Q, W, and R

* New: Can disguise as any unit with a health bar (Cooldown -> 2 seconds). Q deals bonus damage to monsters.

* Nerfs: R's cooldown has increased to 120/105/90 seconds, magic damage reduced to 150/350/550 (+100% AP).

* Buffs: Passive's disguise doesn't break on damage. Clone from W can be repositioned and can mimic emotes.

Aatrox:

* Changes: Passive and R

* New: None

* Nerfs: None

* Buffs: Bonus Physical Damage on Passive increased to 4-12% of target's maximum health. Bonus Movement Speed on R increased to 60/80/100%.

Amumu:

* Changes: W

* New: None

* Nerfs: None

* Buffs: Flat Magic Damage per Second on W increased to 20 at all ranks.

Bel'Veth:

* Changes: Base Stats and Q

* New: Q has increased monster damage (Modification -> 140%).

* Nerfs: Attack Damage Growth decreased to 1.5.

* Buffs: None

Jinx:

* Changes: Base Stats

* New: None

* Nerfs: Attack Damage Growth decreased to 3.15.

* Buffs: None

Kayle:

* Changes: E and R

* New: None

* Nerfs: On-Hit AP Ratio on E decreased to 20% AP. Magic Damage on R decreased to 200/300/400 (+100% bonus AD)(+70% AP).

* Buffs: R's Cast Time decreased to 0.5 seconds, AoE Radius increased, Invulnerability Duration set to 2.5 seconds.

Sion:

* Changes: Passive

* New: None

* Nerfs: Health Decay on Passive increased to 2.3-24.4 (1.3 per level).

* Buffs: None

Swain:

* Changes: Q

* New: None

* Nerfs: None

* Buffs: Magic Damage on Q increased to 65/85/105/125/145 (+40% AP).

Taliyah:

* Changes: R

* New: Cast Lockout on R only occurs when Taliyah takes damage.

* Nerfs: None

* Buffs: None

Trundle:

* Changes: Base Stats

* New: None

* Nerfs: None

* Buffs: Base Attack Speed increased to 0.67. Base Mana increased to 340.

Volibear:

* Changes: W

* New: None

* Nerfs: None

* Buffs: Physical Damage and heal ratio based on missing health on W increased.

Lich Bane:

* Changes: Ability Power

* New: None

* Nerfs: None

* Buffs: Ability Power increased from 75 to 85.

Overall Meta Prediction:

* Top Lane: With Aatrox's buffs increasing his durability and chase potential, we might see a rise in sustain-oriented top laners. Champions with healing reduction or high burst could be more prevalent to counter this. Players may want to adjust their champion pool and item builds accordingly.

* Jungle: With the changes to Neeko, Trundle, Volibear, and Amumu, we might see more diversity in jungle picks. Junglers that can leverage deception and crowd control, as well as those who can clear camps quickly and sustain in the jungle, could rise in popularity. Players should practice these types of champions and be ready for potentially more aggressive jungle invasions.

* Mid Lane: Swain's buffs and Kayle's adjustments could lead to a meta favoring champions with reliable crowd control and wave clear. Champions with early lane pressure and roam potential could also be viable picks. Players should focus on improving their map awareness and roam timings.

* Bot Lane: With Jinx's nerfs, the bot lane might shift away from traditional ADCs to more versatile and mobile champions. This could also increase the importance of supports that can provide protection or engage opportunities. Players might want to experiment with unconventional bot lane picks and adapt their playstyle to a more aggressive or protective role depending on their pick.

* Support: If the bot lane meta shifts as expected, supports that can peel for their ADCs or engage effectively might become more critical. Thresh, Nautilus, or Lulu could be strong picks. Players should work on their positioning and map awareness to protect their ADCs and set up successful plays.

* Final Suggestion: As always, while adapting to the meta is important, players should also prioritize their comfort picks and personal skill set. A well-played 'off-meta' champion can often outperform a poorly played 'meta' champion. Always be ready to adapt, but don't forget to play what you enjoy and are good at.

ARAM Adjustments:

Buffs:

    * Corki: Damage Taken reduced from 95% to 90%

    * Ezreal: Damage Dealt increased from 95% to 100%

    * Karma: Damage Dealt increased from 100% to 105%

    * Tristana: Damage Dealt increased from 100% to 105%

    * Zilean: Damage Taken reduced from 95% to 90%

Nerfs:

    * Akali: Damage Dealt reduced from 110% to 105%

    * Ornn: Damage Taken increased from 105% to 110%

    * Qiyana: Damage Dealt reduced from 115% to 110%

    * Veigar:  Damage Taken increased from 105% to 110%, Damage Dealt reduced from 95% to 90%

MSI Cup Clash:

* Event Type: 8-team bracket tournaments

* Tournament Dates: First weekend on May 6th and 7th (team formation begins May 3rd), second weekend on May 13th and 14th (team formation begins May 8th)

* Premium Ticket Rewards: Players who place 1st to 5th receive a random legacy Conqueror Skin Permanent. Players who place 6th to 8th receive a legacy Conqueror Skin Shard. (JP region excluded from these rewards due to legal restrictions).

Behavioral Systems:

* New Features: In-Game Reporting, Mute Updates, Mute All and Self Mute.

In-Game Reporting:

* Ability to report players in-game to help identify and address toxic or disruptive behavior.

* Reports provide more context about when during the game the disruption occurred, improving system effectiveness.

Mute Updates:

* Mute options consolidated into a new panel, accessible through the scoreboard below the report button.

Mute All and Self Mute:

* Mute-all and self-mute controls added, located next to your own champion portrait and summoner spells.

Bugfixes & QoL Changes:

* Changes: Multiple Bugfixes

Selected Bugfixes:

* Neeko's transform function now works correctly in the jungle.

* Rift Herald's sounds can't be heard through Fog of War anymore.

* Kayle's sound effects and animations have been fixed.

* Samira's passive no longer affects Epic monsters.

* Aether Wisp correctly gives 5% move speed after death.

* Zac’s E doesn't distort enemy Zac models anymore.

* Vladimir’s Q no longer damages untargetable targets.

* Warwick’s Q doesn't over-heal with Recurve Bow anymore.

Skin Bugfixes:

* Fixed Chosen Master Yi’s disappearing lightsaber issue.

* Arcade and Bullet Angel Kai’Sa’s R indicator no longer renders under terrain.

* Fixed clipping issue with Bullet Angel Kai’Sa when slowed.

* On-hand VFX of Mecha and Storm Dragon Aurelion Sol disappear correctly now.

* Fixed persistent Recall VFX on all Volibear skins.
"""

    @IBOutlet weak var patchLbl: UILabel!
    var tableView: UITableView!

    let backButton: UIButton = UIButton(type: .custom)
    let originalButton: UIButton = UIButton(type: .custom)
    var gameName = ""
    var gameId = ""
    var originalLink = ""
    var lines = [Line]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        setupButtons()
        loadMeta()
        setupTableView()
        
    }

    func setupTableView() {
        tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(LineCell.self, forCellReuseIdentifier: "LineCell")
            
        // Set the table view style
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 44
        tableView.separatorStyle = .none
            
        // Add the table view to the view hierarchy
        view.addSubview(tableView)
            
        // Set up constraints
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: patchLbl.safeAreaLayoutGuide.bottomAnchor, constant: 16),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 8),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -8)
        ])
        tableView.backgroundColor = .clear
        tableView.allowsSelection = false
        tableView.showsVerticalScrollIndicator = false
        tableView.showsHorizontalScrollIndicator = false
    }

}

extension SB_MetaVC {
    
    func setupButtons() {
        
        setupBackButton()
        setupOriginalButton()
    
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
        navigationItem.title = gameName

        self.navigationItem.leftBarButtonItem = backButtonBarButton
        
    }
    
    func setupOriginalButton() {
    
        originalButton.frame = back_frame
        originalButton.contentMode = .center


        originalButton.addTarget(self, action: #selector(onClickLink(_:)), for: .touchUpInside)
        originalButton.setTitleColor(UIColor.white, for: .normal)
        originalButton.setTitle("Link", for: .normal)
        let originalButtonBarButton = UIBarButtonItem(customView: originalButton)

        self.navigationItem.rightBarButtonItem = originalButtonBarButton
        
    }

    
    func showErrorAlert(_ title: String, msg: String) {
                                                                                                                                           
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default)
        
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
        
    }

    
}

extension SB_MetaVC {
    
    @objc func onClickBack(_ sender: AnyObject) {
        if let navigationController = self.navigationController {
            navigationController.popViewController(animated: true)
        }
    }
    
    @objc func onClickLink(_ sender: AnyObject) {
        // originalLink is a non-optional String
        guard let url = URL(string: originalLink) else {
            return
        }

        let safariViewController = SFSafariViewController(url: url)
        safariViewController.modalPresentationStyle = .fullScreen
        self.present(safariViewController, animated: true)
    }

    
}

extension SB_MetaVC {
    func loadMeta() {
        
        APIManager().getGamePatch(gameId: global_gameId) { result in
            switch result {
            case .success(let apiResponse):
                
                guard let data = apiResponse.body?["data"] as? [String: Any],
                      let content = data["content"] as? String, let originPatch = data["originPatch"] as? String, let patch = data["patch"] as? String else {
                    print("Unable to convert")
                    return
                }
                
                Dispatch.main.async {
                    self.patchLbl.text = "Patch: \(patch)"
                }
                self.originalLink = originPatch
                self.displayMeta(content: self.input)
            case .failure(let error):
                print(error)
            }
        }
    }

    func displayMeta(content: String) {
            
        let firstLevelKeyAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.boldSystemFont(ofSize: 16),
            .foregroundColor: UIColor.cyan,
            .kern: 1
        ]
        let secondLevelKeyAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.boldSystemFont(ofSize: 14),
            .foregroundColor: UIColor.secondary,
            .kern: 1
        ]
        let topKeyAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.boldSystemFont(ofSize: 18),
            .foregroundColor: UIColor.red,
            .kern: 1
        ]
        let valueAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 14),
            .foregroundColor: UIColor.white,
            .kern: 1
        ]
            
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
                
            let lines = content.components(separatedBy: "\n")
            var newLines: [Line] = []
                
            for line in lines {
                var lineContent: [NSAttributedString] = []
                    
                if line.contains(":") {
                    let components = line.components(separatedBy: ":")
                    let key = components[0].trimmingCharacters(in: .whitespacesAndNewlines)
                    let value = components[1].trimmingCharacters(in: .whitespacesAndNewlines)
                        
                    var keyAttributes: [NSAttributedString.Key: Any]
                    if line.trimmingCharacters(in: .whitespacesAndNewlines).hasPrefix("*") {
                        keyAttributes = secondLevelKeyAttributes
                    } else {
                        keyAttributes = firstLevelKeyAttributes
                    }
                    let attributedKey = NSAttributedString(string: "\(key): ", attributes: keyAttributes)
                    let attributedValue = NSAttributedString(string: value, attributes: valueAttributes)

                    lineContent.append(attributedKey)
                    lineContent.append(attributedValue)
                } else if !line.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    let attributes: [NSAttributedString.Key: Any] = topKeyAttributes
                    let attributedString = NSAttributedString(string: line, attributes: attributes)
                    lineContent.append(attributedString)
                }
                    
                newLines.append(Line(content: lineContent))
            }
                
            DispatchQueue.main.async {
                self.lines = newLines
                self.tableView.reloadData()
            }
        }
    }



}


extension SB_MetaVC: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return lines.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LineCell", for: indexPath) as! LineCell
        cell.backgroundColor = .clear
        cell.configure(with: lines[indexPath.row])
        return cell
    }

}



struct Line {
    let content: [NSAttributedString]
}



