//
//  RandomPlayController.swift
//  SpikeballPlay
//
//  Created by Jordan Davis on 8/3/17.
//  Copyright © 2017 HoverSlam. All rights reserved.
//

import Foundation


class RPController {
    
    static var playersList = [RandomPlayer]()
    static var gameList = [RandomGame]()
    
    public func addPlayer(player: RandomPlayer) {
        RPController.playersList.append(player)
    }
    
    static func getPlayerByName(name: String) -> RandomPlayer {
        for player in playersList {
            if player.name == name {
                return player
            }
        }
        
        return RandomPlayer(id: 0, name: "nil")
    }
    
    static func addGame(game: RandomGame) {
        RPController.gameList.append(game)
    }
    
    // Deletes a player from list
    public func deletePlayer(playerName: String) {
        if RPController.playersList.count > 0 {
            // finds player by name, and uses their ID to fetch their index for list deletion
            RPController.playersList.remove(at: RPController.getPlayerByName(
            name: playerName.trimmingCharacters(in: .whitespacesAndNewlines)).id - 1)
        } else {
            RPController.playersList.removeAll()
        }
    }
    
    func isIndexUnique(index: Int) -> Bool {
        
        return true
    }

}
