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
    
	func reportMatch(currentPool: Pool, selectedMatchup: PoolPlayMatchup, numOfGamesPlayed: Int, teamOneScores: [Int], teamTwoScores: [Int]) {
        // save the match!
        try! realm.write {
			currentPool.isStarted = true
            selectedMatchup.teamOne?.poolPlayGameList.append(selectedMatchup)
            selectedMatchup.teamTwo?.poolPlayGameList.append(selectedMatchup)
            
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
			
			// add scores to matchup object
			selectedMatchup.teamOneScores.append(teamOneScores[0])
			selectedMatchup.teamOneScores.append(teamOneScores[1])
			selectedMatchup.teamOneScores.append(teamOneScores[2])
			
			selectedMatchup.teamTwoScores.append(teamTwoScores[0])
			selectedMatchup.teamTwoScores.append(teamTwoScores[1])
			selectedMatchup.teamTwoScores.append(teamTwoScores[2])
            
            selectedMatchup.isReported = true
			
			let matchupDao = MatchupFirebaseDao()
			matchupDao.addFirebasePoolMatchup(matchup: selectedMatchup)
        }
    }
    
}
