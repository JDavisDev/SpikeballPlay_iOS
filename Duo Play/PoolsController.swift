//
//  PoolsController.swift
//  Duo Play
//
//  Created by Jordan Davis on 11/13/17.
//  Copyright © 2017 Jordan Davis. All rights reserved.
//

import Foundation
import RealmSwift

class PoolsController {
    let realm = try! Realm()
	var tournament = Tournament()
	
	init() {
		tournament = TournamentController.getCurrentTournament()
	}
	
    func addTeamToPool(pool: Pool, team: Team) {
        try! realm.write {
            team.pool = pool
            pool.teamList.append(team)
        }
    }
	
	func getProgressOfPool(pool: Pool) -> Float {
		for poolTest in tournament.poolList {
			if poolTest.name == pool.name {
				var totalMatchCount = 0
				var reportedMatchCount = 0
				
				// get progress of this pool
				for matchup in pool.matchupList {
					totalMatchCount += 1
					
					if matchup.isReported {
						reportedMatchCount += 1
					}
				}
			}
		}
		
		return 100
	}
	
	func getPoolPlayProgress() -> Float {
		if tournament.isPoolPlayFinished {
			return 100
		} else {
			var totalMatchCount: Float = 0
			var reportedMatchCount: Float = 0
			
			for pool in tournament.poolList {
				for matchup in pool.matchupList {
						totalMatchCount += 1
					
					if matchup.isReported {
						reportedMatchCount += 1
					}
				}
			}
			
			let pointsPerMatch = Float(100 / (totalMatchCount))
			
			return Float(pointsPerMatch * reportedMatchCount)
		}
	}
	
	func setPoolPlayFinished(isFinished: Bool) {
		try! realm.write {
			tournament.isPoolPlayFinished = isFinished
		}
	}
	
	func seedTeams() {
		try! realm.write {
			var array = Array(tournament.teamList)
			tournament.teamList.removeAll()
			
			// seed the teams here based on wins, then point diff, then name
			array.sort {
				if $0.wins == $1.wins {
					// if tournament has started, sort by wins, then seed.
					if tournament.progress_meter <= 0 {
						if ($0.pointsFor - $0.pointsAgainst) == ($1.pointsFor - $1.pointsAgainst) {
							return $0.seed < $1.seed
						} else {
							return ($0.pointsFor - $0.pointsAgainst) > ($1.pointsFor - $1.pointsAgainst)
						}
					} else {
						return $0.seed < $1.seed
					}
				} else {
					return $0.wins > $1.wins
				}
			}
			
			// we've sorted/seeded, now re-add
			var seed = 1
			for team in array {
				// if tournament has begun, don't change their seeds!
				if tournament.progress_meter <= 0 {
					team.seed = seed
				}
				
				tournament.teamList.append(team)
				seed += 1
			}
		}
	}
    
    
}
