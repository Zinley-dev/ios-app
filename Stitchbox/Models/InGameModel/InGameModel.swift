//
//  InGameModel.swift
//  Stitchbox
//
//  Created by Khoi Nguyen on 4/23/23.
//

import Foundation

class InGameModel {
    var redTeam: [Champion]
    var blueTeam: [Champion]
    var match: Match
    
    init(data: [String: Any]) {
        let redTeamData = data["red"] as? [[String: Any]] ?? []
        let blueTeamData = data["blue"] as? [[String: Any]] ?? []
        
        redTeam = redTeamData.map { Champion(data: $0) }
        blueTeam = blueTeamData.map { Champion(data: $0) }
        match = Match(data: data["match"] as? [String: Any] ?? [:])
    }
}

class Champion {
    var championName: String
    var icon: String
    var profileIcon: String
    var summoner: String
    
    init(data: [String: Any]) {
        championName = data["championName"] as? String ?? ""
        icon = data["icon"] as? String ?? ""
        profileIcon = data["profileIcon"] as? String ?? ""
        summoner = data["summoner"] as? String ?? ""
    }
}

class Match {
    var id: Int64
    var length: Int
    var mode: GameMode
    var queue: Queue
    var startTimestamp: Int64
    var type: GameType
    
    init(data: [String: Any]) {
        id = data["id"] as? Int64 ?? 0
        length = data["length"] as? Int ?? 0
        mode = GameMode(data: data["mode"] as? [String: Any] ?? [:])
        queue = Queue(data: data["queue"] as? [String: Any] ?? [:])
        startTimestamp = data["startTimestamp"] as? Int64 ?? 0
        type = GameType(data: data["type"] as? [String: Any] ?? [:])
    }
}

class GameMode {
    var description: String
    var gameMode: String
    
    init(data: [String: Any]) {
        description = data["description"] as? String ?? ""
        gameMode = data["gameMode"] as? String ?? ""
    }
}

class Queue {
    var description: String
    var map: String
    var queueId: Int
    
    init(data: [String: Any]) {
        description = data["description"] as? String ?? ""
        map = data["map"] as? String ?? ""
        queueId = data["queueId"] as? Int ?? 0
    }
}

class GameType {
    var description: String
    var gameType: String
    
    init(data: [String: Any]) {
        description = data["description"] as? String ?? ""
        gameType = data["gametype"] as? String ?? ""
    }
}

