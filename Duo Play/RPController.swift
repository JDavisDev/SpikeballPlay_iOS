//
//  RandomPlayController.swift
//  SpikeballPlay
//
//  Created by Jordan Davis on 8/3/17.
//  Copyright © 2017 HoverSlam. All rights reserved.
//

import Foundation
import RealmSwift

class RPController {
    let realm = try! Realm()
    let session = RPSessionsView.getCurrentSession()
    
    public func addPlayer(player: RandomPlayer) {
        try! realm.write {
            session.playersList.append(player)
        }
    }
    
    func getPlayerByName(name: String) -> RandomPlayer {
        for player in session.playersList {
            if player.name.trimmingCharacters(in: .whitespaces) == name.trimmingCharacters(in: .whitespaces) {
                return player
            }
        }
        
        return RandomPlayer()
    }
    
    func addGame(game: RandomGame) {
        try! realm.write {
            realm.add(game)
            session.gameList.append(game)
        }
    }
    
    // Deletes a player from list
    public func deletePlayer(playerName: String) {
        if session.playersList.count > 0 {
            // finds player by name, and uses their ID to fetch their index for list deletion
            session.playersList.remove(at: getPlayerByName(name: playerName.trimmingCharacters(in: .whitespacesAndNewlines)).id - 1)
        } else {
            session.playersList.removeAll()
        }
    }
    
    func isIndexUnique(index: Int) -> Bool {
        
        return true
    }

}
