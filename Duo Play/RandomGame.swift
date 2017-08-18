//
//  RandomGame.swift
//  SpikeballPlay
//
//  Created by Jordan Davis on 8/3/17.
//  Copyright © 2017 HoverSlam. All rights reserved.
//

import Foundation

public class RandomGame {
    
    var playerOne: RandomPlayer
    var playerTwo: RandomPlayer
    var playerThree: RandomPlayer
    var playerFour: RandomPlayer
    var teamOneScore: Int
    var teamTwoScore: Int
    
    init(playerOne: RandomPlayer,
        playerTwo: RandomPlayer,
        playerThree: RandomPlayer,
        playerFour: RandomPlayer,
        teamOneScore: Int,
        teamTwoScore: Int) {
        self.playerOne = playerOne
        self.playerTwo = playerTwo
        self.playerThree = playerThree
        self.playerFour = playerFour
        self.teamOneScore = teamOneScore
        self.teamTwoScore = teamTwoScore
    }
}
