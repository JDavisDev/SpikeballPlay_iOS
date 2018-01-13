//
//  RPHistoryController.swift
//  SpikeballPlay
//
//  Created by Jordan Davis on 8/4/17.
//  Copyright © 2017 HoverSlam. All rights reserved.
//

import Foundation
import CoreData
import RealmSwift
import Crashlytics

class RPHistoryController {
    let session = RPSessionsView.getCurrentSession()
    let gameController = RPGameController()
    let realm = try! Realm()
    
    func deleteHistoryMatch(game: RandomGame) {
        deleteFromPlayerStatistics(game: game)
    }
    
    // remove stats from players if a match is deleted
    func deleteFromPlayerStatistics(game: RandomGame) {
        try! realm.write() {
            if game.teamOneScore > game.teamTwoScore {
                // Team one won
                game.playerOne?.wins -= 1
                game.playerTwo?.wins -= 1
                game.playerThree?.losses -= 1
                game.playerFour?.losses -= 1
            } else {
                // Team two won
                game.playerOne?.losses -= 1
                game.playerTwo?.losses -= 1
                game.playerThree?.wins -= 1
                game.playerFour?.wins -= 1
            }
            
            game.playerOne?.pointsFor -= game.teamOneScore
            game.playerTwo?.pointsFor -= game.teamOneScore
            game.playerOne?.pointsAgainst -= game.teamTwoScore
            game.playerTwo?.pointsAgainst -= game.teamTwoScore
            
            game.playerThree?.pointsFor -= game.teamTwoScore
            game.playerFour?.pointsFor -= game.teamTwoScore
            game.playerThree?.pointsAgainst -= game.teamOneScore
            game.playerFour?.pointsAgainst -= game.teamOneScore
        
            updateEloRating(game: game)
            updateEloRatingsAfterDeletion()
            let index = session.gameList.index(of: game)
            session.gameList.remove(at: index!)
            realm.delete(game)
            
        }
        
        Answers.logCustomEvent(withName: "History Deleted",
            customAttributes: [:])
    }
    
    func updateEloRating(game: RandomGame) {
        let oneRating = game.playerOne?.rating
        let twoRating = game.playerTwo?.rating
        let threeRating = game.playerThree?.rating
        let fourRating = game.playerFour?.rating
        let tOneRating = teamOneRating(oneRating: oneRating!, twoRating: twoRating!)
        let tTwoRating = teamTwoRating(threeRating: threeRating!, fourRating: fourRating!)
        
        game.playerThree?.totalOpponentRating -= tOneRating
        game.playerFour?.totalOpponentRating -= tOneRating
        game.playerOne?.totalOpponentRating -= tTwoRating
        game.playerTwo?.totalOpponentRating -= tTwoRating
        
        game.playerThree?.gameList.remove(at: (game.playerThree?.gameList.index(of: game))!)
        game.playerFour?.gameList.remove(at: (game.playerFour?.gameList.index(of: game))!)
        game.playerOne?.gameList.remove(at: (game.playerOne?.gameList.index(of: game))!)
        game.playerTwo?.gameList.remove(at: (game.playerTwo?.gameList.index(of: game))!)
    }
    
    func teamTwoRating(threeRating: Int, fourRating: Int) -> Int {
        var returnScore = 1000
        if threeRating > fourRating {
            let midRating = ((threeRating - fourRating) / 2)
            returnScore = (threeRating - midRating)
        } else if fourRating > threeRating {
            let midRating = Int((fourRating - threeRating) / 2)
            returnScore = (fourRating - midRating)
        } else {
            // ratings are same
            returnScore = (threeRating)
        }
        
        return returnScore
    }
        
        /** Team One **/
    func teamOneRating(oneRating: Int, twoRating: Int) -> Int {
        var returnScore = 1000
        if oneRating > twoRating {
            let midRating = ((oneRating - twoRating) / 2)
            returnScore = (oneRating - midRating)
        } else if twoRating > oneRating {
            let midRating = Int((twoRating - oneRating) / 2)
            returnScore = (twoRating - midRating)
        } else {
            // ratings are same
            returnScore = (oneRating)
        }
        
        return returnScore
    }
    
    func updateEloRatingsAfterDeletion() {
        for player in session.playersList {
            if player.gameList.count > 0 {
                player.rating = (player.totalOpponentRating + (400 * (player.wins - player.losses))) / (player.gameList.count)
            }
        }
    }
    
    func editPlayerStatistics(game: RandomGame) {
        // delete the game in stats, then add it back with new values
        deleteHistoryMatch(game: game)
        // move them to game view with players populated
        
        Answers.logCustomEvent(withName: "History Edited",
                               customAttributes: [:])
    }
}

