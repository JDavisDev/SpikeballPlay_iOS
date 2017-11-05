//
//  RPDifficultyController.swift
//  Duo Play
//
//  Created by Jordan Davis on 11/3/17.
//  Copyright © 2017 Jordan Davis. All rights reserved.
//

import Foundation
import RealmSwift

class RPDifficultyController {
    
    let realm = try! Realm()
    let session = RPSessionsView.getCurrentSession()
    let playersList: List<RandomPlayer>
    let gamesList: List<RandomGame>
    let historyList: List<History>
    
    init() {
        self.playersList = session.playersList
        self.gamesList = session.gameList
        self.historyList = session.historyList
    }
    
    func updateDifficulty() {
        updateOpponentDifficulty()
        updatePartnerDifficulty()
    }
    
    
 /*  If they play against a high scoring/high winning opponent, match difficulty goes up.
     If they play against a low scoring/winning opponent, match difficulty goes down */
    func updateOpponentDifficulty() {
        for player in self.playersList {
            for game in gamesList {
                if isPlayerInGame(player: player, game: game) {
                    let score = Float(getOpponentDifficulty(player: player, game: game))
                    player.matchDifficulty += score
                }
            }
        }
    }
    
    func isPlayerInGame(player: RandomPlayer, game: RandomGame) -> Bool {
        if game.playerOne == player ||
            game.playerTwo == player ||
            game.playerThree == player ||
            game.playerFour == player {
            return true
        }
        
        return false
    }
    
    func getOpponentDifficulty(player: RandomPlayer, game: RandomGame) -> Float {
        var returnScore = Float(0.0)
        
        switch player {
            // Team One
        case game.playerOne!,
             game.playerTwo!:
            
            let gameCount = (game.playerThree?.wins)! + (game.playerThree?.losses)! >
                (game.playerFour?.wins)! + (game.playerFour?.losses)! ?
                    (game.playerThree?.wins)! + (game.playerThree?.losses)! :
                    (game.playerFour?.wins)! + (game.playerFour?.losses)!
            
            let winRatioPoints = ((game.playerThree?.wins)! + (game.playerFour?.wins)! - (game.playerThree?.losses)! - (game.playerFour?.losses)!) / gameCount
            let pointRatioPoints = (game.playerThree?.pointsFor)! + (game.playerFour?.pointsFor)! - (game.playerThree?.pointsAgainst)! - (game.playerFour?.pointsAgainst)!
            returnScore = Float((winRatioPoints + pointRatioPoints) / gameCount)
            
            break
            // Team Two
        case game.playerThree!,
             game.playerFour!:
            
            let gameCount = (game.playerOne?.wins)! + (game.playerOne?.losses)! >
                (game.playerTwo?.wins)! + (game.playerTwo?.losses)! ?
                    (game.playerOne?.wins)! + (game.playerOne?.losses)! :
                (game.playerTwo?.wins)! + (game.playerTwo?.losses)!
            
            let winRatioPoints = ((game.playerOne?.wins)! + (game.playerTwo?.wins)! - (game.playerOne?.losses)! - (game.playerTwo?.losses)!)
            let pointRatioPoints = (game.playerOne?.pointsFor)! + (game.playerTwo?.pointsFor)! - (game.playerOne?.pointsAgainst)! - (game.playerTwo?.pointsAgainst)!
            returnScore = Float((winRatioPoints + pointRatioPoints) / gameCount)
            
            break
        default:
            return 0
        }
        
        return returnScore
    }
    
   /* If they play WITH a high rated partner, match difficulty goes down.
      If they play WITH a low rated partner, match difficulty goes up. */
    func updatePartnerDifficulty() {
        
    }
}


/* DIFFICULTY NOTES
 
 Could go with a rating system. each player starts at 500. Get a bump if you win, drop if you lose
 Then, as matches are predicted, results are weighed against expectations.
 Win * Expected Win == less points up
 Win * Expected Loss == more points up
 
 Loss * Expected Win == more points down
 Loss * Expected Loss == less points down
 
 Could Iterate through each player's opponents. Assign a point value to each game.

 

 
 */
