//
//  PoolPlayMatchReporterController.swift
//  Duo Play
//
//  Created by Jordan Davis on 9/8/17.
//  Copyright © 2017 Jordan Davis. All rights reserved.
//

import Foundation
import RealmSwift

public class PoolPlayMatchReporterController {
    let realm = try! Realm()
    
    func reportMatch(selectedMatchup: PoolPlayMatchup, numOfGamesPlayed: Int, teamOneScores: [Int], teamTwoScores: [Int]) {
        // save the match!
        try! realm.write {
            selectedMatchup.teamOne?.gameList.append(selectedMatchup)
            selectedMatchup.teamTwo?.gameList.append(selectedMatchup)
            
            var teamOneWins = 0
            for score in teamOneScores {
                if score == 21 {
                    teamOneWins += 1
                }
            }
            
            var teamTwoWins = 0
            for score in teamTwoScores {
                if score == 21 {
                    teamTwoWins += 1
                }
            }
            
            if teamOneWins > teamTwoWins {
                selectedMatchup.teamOne?.wins += 1
                selectedMatchup.teamTwo?.losses += 1
            } else {
                selectedMatchup.teamOne?.losses += 1
                selectedMatchup.teamTwo?.wins += 1
            }
            
            // point accumulation for seeding.
            selectedMatchup.teamOne?.pointsFor += teamOneScores[0]
            selectedMatchup.teamOne?.pointsFor += teamOneScores[1]
            selectedMatchup.teamOne?.pointsFor += teamOneScores[2]
            
            selectedMatchup.teamOne?.pointsAgainst += teamTwoScores[0]
            selectedMatchup.teamOne?.pointsAgainst += teamTwoScores[1]
            selectedMatchup.teamOne?.pointsAgainst += teamTwoScores[2]
            
            selectedMatchup.teamTwo?.pointsAgainst += teamOneScores[0]
            selectedMatchup.teamTwo?.pointsAgainst += teamOneScores[1]
            selectedMatchup.teamTwo?.pointsAgainst += teamOneScores[2]
            
            selectedMatchup.teamTwo?.pointsFor += teamTwoScores[0]
            selectedMatchup.teamTwo?.pointsFor += teamTwoScores[1]
            selectedMatchup.teamTwo?.pointsFor += teamTwoScores[2]
            
            selectedMatchup.isReported = true
        }
    }
    
}
