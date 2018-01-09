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
            
            realm.delete(game)
           
        }
        
        Answers.logCustomEvent(withName: "History Deleted",
            customAttributes: [:])
    }
    
    func editPlayerStatistics(game: RandomGame) {
        // delete the game in stats, then add it back with new values
        deleteHistoryMatch(game: game)
        // move them to game view with players populated
        
        Answers.logCustomEvent(withName: "History Edited",
                               customAttributes: [:])
    }
}

