//
//  RPHistoryController.swift
//  SpikeballPlay
//
//  Created by Jordan Davis on 8/4/17.
//  Copyright © 2017 HoverSlam. All rights reserved.
//

import Foundation

class RPHistoryController {
    
    func deleteHistoryMatch(game: RandomGame) {
        RPController.gameList = RPController.gameList.filter { $0 !== game }
        deleteFromPlayerStatistics(game: game)
    }
    
    func deleteFromPlayerStatistics(game: RandomGame) {
        if game.teamOneScore > game.teamTwoScore {
            // Team one won
            game.playerOne.wins -= 1
            game.playerTwo.wins -= 1
            game.playerThree.losses -= 1
            game.playerFour.losses -= 1
            
            game.playerOne.pointsFor -= game.teamOneScore
            game.playerTwo.pointsFor -= game.teamOneScore
            game.playerThree.pointsAgainst -= game.teamTwoScore
            game.playerFour.pointsAgainst -= game.teamTwoScore
        } else {
            // Team two won
            game.playerOne.losses -= 1
            game.playerTwo.losses -= 1
            game.playerThree.wins -= 1
            game.playerFour.wins -= 1
            
            game.playerOne.pointsAgainst -= game.teamOneScore
            game.playerTwo.pointsAgainst -= game.teamOneScore
            game.playerThree.pointsFor -= game.teamTwoScore
            game.playerFour.pointsFor -= game.teamTwoScore
        }
    }
}
