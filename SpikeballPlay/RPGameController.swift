//
//  RPGameController.swift
//  SpikeballPlay
//
//  Created by Jordan Davis on 8/3/17.
//  Copyright © 2017 HoverSlam. All rights reserved.
//

import Foundation

class RPGameController {
    
    func submitMatch(playerOne: RandomPlayer,
                     playerTwo: RandomPlayer,
                     playerThree: RandomPlayer,
                     playerFour: RandomPlayer,
                     teamOneScore: Int,
                     teamTwoScore: Int) {
        
        // create game
        let newGame = RandomGame(playerOne: playerOne, playerTwo: playerTwo,
                                 playerThree: playerThree, playerFour: playerFour,
                                 teamOneScore: teamOneScore, teamTwoScore: teamTwoScore)
        
        // store game in controller
        RPController.addGame(game: newGame)
        
        // parse game for score accumulation
        parseGameForStats(game: newGame)
    }
    
    func parseGameForStats(game: RandomGame) {
        if game.teamOneScore > game.teamTwoScore {
            // teamOne won
            game.playerOne.wins += 1
            game.playerTwo.wins += 1
            game.playerThree.losses += 1
            game.playerFour.losses += 1
        } else {
            // teamTwo won
        }
    }
    
}
