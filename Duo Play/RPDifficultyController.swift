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
    let session: Session
    var playersList: List<RandomPlayer>
    var gamesList: List<RandomGame>
    var historyList: List<History>
    
    init() {
        self.session = RPSessionsView.getCurrentSession()
        self.playersList = List<RandomPlayer>()
        self.gamesList = List<RandomGame>()
        self.historyList = List<History>()
        
        try! realm.write {
            self.playersList = session.playersList
            self.gamesList = session.gameList
            self.historyList = session.historyList
        }
    }
    
    
 /*  If they play against a high scoring/high winning opponent, match difficulty goes up.
     If they play against a low scoring/winning opponent, match difficulty goes down */
    func updateDifficulty() {
        for player in self.playersList {
            // reset score first, so old values aren't appended on top of each other
            try! realm.write {
                player.matchDifficulty = 0
            }
            
            for game in self.gamesList {
                if isPlayerInGame(player: player, game: game) {
                    let score = Float(getOpponentDifficulty(player: player, game: game) +
                                      getPartnerDifficulty(player: player, game: game))
                    
                    try! realm.write {
                        player.matchDifficulty += score
                    }
                }
            }
        }
    }
    
    func isPlayerInGame(player: RandomPlayer, game: RandomGame) -> Bool {
        if game.playerOne?.id == player.id ||
            game.playerTwo?.id == player.id ||
            game.playerThree?.id == player.id ||
            game.playerFour?.id == player.id {
            return true
        }
        
        return false
    }
    
    // MARK - Opponent Difficulty Calculations
    
    func getOpponentDifficulty(player: RandomPlayer, game: RandomGame) -> Float {
        var returnScore = Float(0.0)
        let playerGameCount = (player.wins) + (player.losses)
        
        if game.playerOne == nil && game.playerTwo == nil && game.playerThree == nil && game.playerFour == nil {
            return returnScore
        }
        
        // Find the current player's opposing team
        switch player.id {
            // Team One
        case (game.playerOne?.id)!,
             (game.playerTwo?.id)!:
            
            let gameCount = (game.playerThree?.wins)! + (game.playerThree?.losses)! >
                (game.playerFour?.wins)! + (game.playerFour?.losses)! ?
                    (game.playerThree?.wins)! + (game.playerThree?.losses)! :
                    (game.playerFour?.wins)! + (game.playerFour?.losses)!
            
            let winRatioPoints = ((game.playerThree?.wins)! + (game.playerFour?.wins)! - (game.playerThree?.losses)! - (game.playerFour?.losses)!) / gameCount
            let pointRatioPoints = (game.playerThree?.pointsFor)! + (game.playerFour?.pointsFor)! - (game.playerThree?.pointsAgainst)! - (game.playerFour?.pointsAgainst)!
            returnScore = Float((winRatioPoints + pointRatioPoints) / gameCount)
            
            break
            // Team Two
        case game.playerThree!.id,
             game.playerFour!.id:
            
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
        
        return returnScore / Float(playerGameCount)
    }
    
    // MARK - Partner Difficulty Calculations
    
   /* If they play WITH a high rated partner, match difficulty goes down.
      If they play WITH a low rated partner, match difficulty goes up. */
    func getPartnerDifficulty(player: RandomPlayer, game: RandomGame) -> Float {
        var returnScore = Float(0.0)
        let playerGameCount = (player.wins) + (player.losses)
        
        // Find the current player's partner and accumulate their stats.
        switch player.id {
        // Player One
        case (game.playerOne?.id)!:
            
            let gameCount = (game.playerTwo?.wins)! + (game.playerTwo?.losses)!
            let winRatioPoints = (game.playerTwo?.wins)! - (game.playerTwo?.losses)!
            let pointRatioPoints = (game.playerTwo?.pointsFor)! - (game.playerTwo?.pointsAgainst)!
            returnScore = Float((winRatioPoints + pointRatioPoints) / gameCount)
            
            break
        // Player Two
        case (game.playerTwo?.id)!:
            
            let gameCount = (game.playerOne?.wins)! + (game.playerOne?.losses)!
            let winRatioPoints = (game.playerOne?.wins)! - (game.playerOne?.losses)!
            let pointRatioPoints = (game.playerOne?.pointsFor)! - (game.playerOne?.pointsAgainst)!
            returnScore = Float((winRatioPoints + pointRatioPoints) / gameCount)
            
            break
        // Player Three
        case game.playerThree!.id:
            
            let gameCount = (game.playerFour?.wins)! + (game.playerFour?.losses)!
            let winRatioPoints = (game.playerFour?.wins)! - (game.playerFour?.losses)!
            let pointRatioPoints = (game.playerFour?.pointsFor)! - (game.playerFour?.pointsAgainst)!
            returnScore = Float((winRatioPoints + pointRatioPoints) / gameCount)
            
            break
            // Player Four
        case game.playerFour!.id:
            
            let gameCount = (game.playerThree?.wins)! + (game.playerThree?.losses)!
            let winRatioPoints = (game.playerThree?.wins)! - (game.playerThree?.losses)!
            let pointRatioPoints = (game.playerThree?.pointsFor)! - (game.playerThree?.pointsAgainst)!
            returnScore = Float((winRatioPoints + pointRatioPoints) / gameCount)
            
            break
        default:
            return 0
        }
        
        return returnScore / Float(playerGameCount)
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
