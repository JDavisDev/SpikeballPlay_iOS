//
//  RandomPlayController.swift
//  SpikeballPlay
//
//  Created by Jordan Davis on 8/3/17.
//  Copyright © 2017 HoverSlam. All rights reserved.
//

import Foundation
import CoreData

class RPController : NSObject, NSCoding {
    
 public var playersList: [RandomPlayer]?
 public var gameList: [RandomGame]?
    
    init(playersList: [RandomPlayer], gameList: [RandomGame]) {
        self.playersList = playersList
        self.gameList = gameList
        super.init()
    }
    
    func encode(with aCoder: NSCoder) {
        guard let playersList = playersList else {
            return
        }
        
        guard let gameList = gameList else {
            return
        }
        
        aCoder.encode(playersList, forKey: "playersList")
        aCoder.encode(gameList, forKey: "gameList")
    }
    
    required init?(coder aDecoder: NSCoder) {
        guard let playerList = aDecoder.decodeObject(forKey: "playersList") as? [RandomPlayer],
            let gameList = aDecoder.decodeObject(forKey: "gameList") as? [RandomGame] else {
                return nil
        }
        
        self.playersList = playerList
        self.gameList = gameList
    }
    
    
    public func addPlayer(player: RandomPlayer) {
        playersList?.append(player)
    }
    
    func getPlayerByName(name: String) -> RandomPlayer {
        for player in playersList! {
            if player.name.trimmingCharacters(in: .whitespaces) == name.trimmingCharacters(in: .whitespaces) {
                return player
            }
        }
        
        return RandomPlayer(id: 0, name: "nil")
    }
    
    func addGame(game: RandomGame) {
        gameList?.append(game)
    }
    
    // Deletes a player from list
    public func deletePlayer(playerName: String) {
        if playersList!.count > 0 {
            // finds player by name, and uses their ID to fetch their index for list deletion
            playersList?.remove(at: getPlayerByName(name: playerName.trimmingCharacters(in: .whitespacesAndNewlines)).id - 1)
        } else {
            playersList?.removeAll()
        }
    }
    
    func isIndexUnique(index: Int) -> Bool {
        
        return true
    }

}
