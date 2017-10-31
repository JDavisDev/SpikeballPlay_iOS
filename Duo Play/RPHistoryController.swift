//
//  RPHistoryController.swift
//  SpikeballPlay
//
//  Created by Jordan Davis on 8/4/17.
//  Copyright © 2017 HoverSlam. All rights reserved.
//

import Foundation
import CoreData

class RPHistoryController {
        
    func deleteHistoryMatch(game: RandomGame) {
        deleteFromPlayerStatistics(game: game)
        let session = RPSessionsView.getCurrentSession()
        let rpController = session.value(forKeyPath: "rpController") as! RPController
        rpController.gameList = (rpController.gameList?.filter { $0 !== game })!
    }
    
    // remove stats from players if a match is deleted
    func deleteFromPlayerStatistics(game: RandomGame) {
        if game.teamOneScore > game.teamTwoScore {
            // Team one won
            game.playerOne.wins -= 1
            game.playerTwo.wins -= 1
            game.playerThree.losses -= 1
            game.playerFour.losses -= 1
        } else {
            // Team two won
            game.playerOne.losses -= 1
            game.playerTwo.losses -= 1
            game.playerThree.wins -= 1
            game.playerFour.wins -= 1
        }
        
        game.playerOne.pointsFor -= game.teamOneScore
        game.playerTwo.pointsFor -= game.teamOneScore
        game.playerOne.pointsAgainst -= game.teamTwoScore
        game.playerTwo.pointsAgainst -= game.teamTwoScore
        
        game.playerThree.pointsFor -= game.teamTwoScore
        game.playerFour.pointsFor -= game.teamTwoScore
        game.playerThree.pointsAgainst -= game.teamOneScore
        game.playerFour.pointsAgainst -= game.teamOneScore
        
        saveSession()
    }
    
    func saveSession() {
        
        
    }
}
