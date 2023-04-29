//
//  CurrentChampionStatsModel.swift
//  Stitchbox
//
//  Created by Khoi Nguyen on 4/25/23.
//

import Foundation

struct CurrentChampionStatsModel {
    let championWin: [String: Int]
    let championCount: [String: Int]
    let puuid: String
}

extension CurrentChampionStatsModel {
    init?(data: [String: Any]) {
        guard let puuid = data["puuid"] as? String,
              let championCount = data["championCount"] as? [String: Int],
              let championWin = data["championWin"] as? [String: Int] else {
            return nil
        }

        self.puuid = puuid
        self.championCount = championCount
        self.championWin = championWin
    }
}




