//
//  RPGameController.swift
//  SpikeballPlay
//
//  Created by Jordan Davis on 8/3/17.
//  Copyright © 2017 HoverSlam. All rights reserved.
//

import Foundation
import RealmSwift
import Crashlytics

class RPGameController {
    let difficultyController = RPDifficultyController()
    var rpController = RPController()
    let realm = try! Realm()
    let session = RPSessionsView.getCurrentSession()
    
    //MARK: Submit Match
    func submitGame(playerOne: RandomPlayer,
                     playerTwo: RandomPlayer,
                     playerThree: RandomPlayer,
                     playerFour: RandomPlayer,
                     teamOneScore: Int,
                     teamTwoScore: Int) {
        
        // create game
        let newGame = RandomGame()
        newGame.playerOne = playerOne
        newGame.playerTwo = playerTwo
        newGame.playerThree = playerThree
        newGame.playerFour = playerFour
        newGame.teamOneScore = teamOneScore
        newGame.teamTwoScore = teamTwoScore
        
        try! realm.write {
            playerOne.gameList.append(newGame)
            playerTwo.gameList.append(newGame)
            playerThree.gameList.append(newGame)
            playerFour.gameList.append(newGame)
        }
    
        // store game in controller
        saveGame(game: newGame)
        
        // parse game for score accumulation
        parseGameForStats(game: newGame)
        difficultyController.updateDifficulty()
    }
    
    func saveGame(game: RandomGame) {
        try! realm.write {
            realm.add(game)
            session.gameList.append(game)
            Answers.logCustomEvent(withName: "Game Submitted",
                                   customAttributes: [
                                    "Team One Score": game.teamOneScore,
                                    "Team Two Score": game.teamTwoScore ])
        }
    }
    
    //MARK: Parse game wins and point stats
    func parseGameForStats(game: RandomGame) {
        try! realm.write {
            if game.teamOneScore > game.teamTwoScore {
                // teamOne won
                game.playerOne?.wins += 1
                game.playerTwo?.wins += 1
                
                game.playerThree?.losses += 1
                game.playerFour?.losses += 1
                
                
            } else {
                // teamTwo won
                game.playerOne?.losses += 1
                game.playerTwo?.losses += 1
                
                game.playerThree?.wins += 1
                game.playerFour?.wins += 1
            }
            
            // Doesn't matter who won, points remain the same.
            game.playerThree?.pointsFor += game.teamTwoScore
            game.playerFour?.pointsFor += game.teamTwoScore
            
            game.playerThree?.pointsAgainst += game.teamOneScore
            game.playerFour?.pointsAgainst += game.teamOneScore
            
            game.playerOne?.pointsFor += game.teamOneScore
            game.playerTwo?.pointsFor += game.teamOneScore
            
            game.playerOne?.pointsAgainst += game.teamTwoScore
            game.playerTwo?.pointsAgainst += game.teamTwoScore
        }
    }
}
