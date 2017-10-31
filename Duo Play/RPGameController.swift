//
//  RPGameController.swift
//  SpikeballPlay
//
//  Created by Jordan Davis on 8/3/17.
//  Copyright © 2017 HoverSlam. All rights reserved.
//

import Foundation

class RPGameController {
    
    var rpController: RPController
    
    init(rpController: RPController) {
        self.rpController = rpController
    }
    
    //MARK: Submit Match
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
        rpController.addGame(game: newGame)
        
        // parse game for score accumulation
        parseGameForStats(game: newGame)
    }
    
    //MARK: Parse game wins and point stats
    func parseGameForStats(game: RandomGame) {
        if game.teamOneScore > game.teamTwoScore {
            // teamOne won
            game.playerOne.wins += 1
            game.playerTwo.wins += 1
            
            game.playerThree.losses += 1
            game.playerFour.losses += 1
            

        } else {
            // teamTwo won
            game.playerOne.losses += 1
            game.playerTwo.losses += 1
            
            game.playerThree.wins += 1
            game.playerFour.wins += 1
        }
        
        // Doesn't matter who won, points remain the same.
        game.playerThree.pointsFor += game.teamTwoScore
        game.playerFour.pointsFor += game.teamTwoScore
        
        game.playerThree.pointsAgainst += game.teamOneScore
        game.playerFour.pointsAgainst += game.teamOneScore
        
        game.playerOne.pointsFor += game.teamOneScore
        game.playerTwo.pointsFor += game.teamOneScore
        
        game.playerOne.pointsAgainst += game.teamTwoScore
        game.playerTwo.pointsAgainst += game.teamTwoScore
    }
    
}
