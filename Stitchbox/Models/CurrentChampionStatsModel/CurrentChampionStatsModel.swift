//
//  CurrentChampionStatsModel.swift
//  Stitchbox
//
//  Created by Khoi Nguyen on 4/25/23.
//

import Foundation

struct CurrentChampionStatsModel {
    let winRate: Int
    let mostChampion: String
    let championWin: [String: Int]
    let championCount: [String: Int]
    let mostChampionWinRate: Double
    let puuid: String
}

extension CurrentChampionStatsModel {
    init?(data: [String: Any]) {
        guard let winRate = data["winRate"] as? Int,
              let mostChampion = data["mostChampion"] as? String,
              let mostChampionWinRate = data["mostChampionWinRate"] as? Double,
              let puuid = data["puuid"] as? String,
              let championCount = data["championCount"] as? [String: Int],
              let championWin = data["championWin"] as? [String: Int] else {
            return nil
        }

        self.winRate = winRate
        self.mostChampion = mostChampion
        self.mostChampionWinRate = mostChampionWinRate
        self.puuid = puuid
        self.championCount = championCount
        self.championWin = championWin
    }

}
