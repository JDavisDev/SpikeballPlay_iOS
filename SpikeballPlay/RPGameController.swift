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
        
        // parse game for score accumulation
    }
    
}
