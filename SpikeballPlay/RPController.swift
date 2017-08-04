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
}
