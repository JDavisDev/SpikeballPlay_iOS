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
    
    public func getFourRandomPlayers() -> [Int] {
        // return four integers for the positions
        // since I'm not using 0 as an id, I can send back player id
        var returnArray = [Int]()
        
        // run this looop until return array is full
        while returnArray.count < 4 {
            let index = Int(arc4random_uniform(UInt32(RPController.playersList.count)))
            if !returnArray.contains(index + 1) {
                returnArray.append(index + 1)
            }
        }
        
        return returnArray
    }
    
    func isIndexUnique(index: Int) -> Bool {
        
        return true
    }
}
