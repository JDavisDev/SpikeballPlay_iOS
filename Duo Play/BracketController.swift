//
//  BracketController.swift
//  Duo Play
//
//  Created by Jordan Davis on 12/31/17.
//  Copyright © 2017 Jordan Davis. All rights reserved.
//

import Foundation
import RealmSwift
import Firebase

class BracketController {
	static var hasDrawn = false
    let realm = try! Realm()
    let tournament: Tournament
	let tournamentDAO = TournamentFirebaseDao()
	let matchupFirebaseDao = MatchupFirebaseDao()
	
    var nodeList = [Node]()
    var isEnd = false
    var baseBracketSize = 0
    var tournamentProgress = 0
	var teamCount = 0
	var isStarted = false
	
	var bracketControllerDelegate: LiveBracketViewDelegate?
	
    init() {
        tournament = TournamentController.getCurrentTournament()
    }
    
    func getRoundCount() -> Int {
        /* 5-8 players/teams: 3 rounds
         9-16 players/teams: 4 rounds
         17-32 players/teams: 5 rounds
         33-64 players/teams: 6 rounds
         65-128 players/teams: 7 rounds
         129-256 players/teams: 8 rounds */
        
        switch tournament.teamList.count {
        case 3...4:
            return 2;
        case 5...8:
            return 3
        case 9...16:
            return 4
        case 17...32:
            return 5
        case 33...64:
            return 6
        case 65...128:
            return 7
        case 129...256:
            return 8
		case 257...512:
			return 9
        default:
            return 3
        }
    }
    
    // Get games needed to play this round
    // NOT how many we have so far.
    func getRoundGameCount(round: Int) -> Int {
		var returnVal = 0
		let realm = try! Realm()
		try! realm.write {
			let teamCount = self.tournament.teamList.count
			let var1 = teamCount + getByeCount()
			let var2 = var1 / 2
			let final = var2 / round
			returnVal = final
		}
		
		return returnVal
    }
    
    func getByeCount() -> Int {
        let count = tournament.teamList.count
        switch count {
        case 3:
            return 1
        case 5...8:
            return 8 - count
        case 9...16:
            return 16 - count
        case 17...32:
            return 32 - count
        case 33...64:
            return 64 - count
        case 65...128:
            return 128 - count
        case 129...256:
            return 256 - count
		case 257...512:
			return 512 - count
        default:
            return 0
        }
    }
    
    
    
    // seeding teams is okay at any point.
    // if matchups have been reported, let's block them after seeding.
    // nothing else should be able to be updated
    func seedTeams() {
		let db = DBManager()
		db.beginWrite()
					var array = Array(self.tournament.teamList)
					self.tournament.teamList.removeAll()
					
					array.sort {
						return $0.seed < $1.seed
					}
					
					// seed the teams here based on wins, then point diff, then name
		//            array.sort {
		//                if $0.wins == $1.wins {
		//					// if tournament has started, sort by wins, then seed.
		//					if tournament.progress_meter <= 0 {
		//                    	if ($0.pointsFor - $0.pointsAgainst) == ($1.pointsFor - $1.pointsAgainst) {
		//                        	return $0.seed < $1.seed
		//                    	} else {
		//                        	return ($0.pointsFor - $0.pointsAgainst) > ($1.pointsFor - $1.pointsAgainst)
		//                    	}
		//					} else {
		//						return $0.seed < $1.seed
		//					}
		//                } else {
		//                    return $0.wins > $1.wins
		//                }
		//            }
					
					// we've sorted/seeded, now re-add
					var seed = 1
					for team in array {
						// if tournament has begun, don't change their seeds!
						if self.tournament.progress_meter <= 0 {
							team.seed = seed
						}
						
						self.tournament.teamList.append(team)
						seed += 1
					}
		
				db.commitWrite()
    }
	//THIS WILL CONFLICT WITH THE ABOVE METHOD
	// run through the list and SET seeds based position in the list
	// if we hit here, the user has edited th seeds.
	func updateSeeds(teamList: [Team]) {
		try! realm.write {
			tournament.teamList.removeAll()
			var counter = 1
			for team in teamList {
				team.seed = counter
				tournament.teamList.append(team)
				counter += 1
				resetTeamValues(team: team)
			}
		}
	}
	
	// if pool play, check the pool matches
	// else just check bracket matchups.
	// calculate tourney size and how much each match is worth
	// then add them up, not including byes!
    func updateTournamentProgress() {
        if tournament.teamList.count > 1 {
			var currentPoints = Float(0)
			var pointsPerMatchup: Float
			
			if tournament.isPoolPlay {
				var totalMatchCounter = 0
				var matchupReportedCounter = 0
				
				for pool in tournament.poolList {
					for match in pool.matchupList {
						totalMatchCounter += 1
						
						if match.isReported {
							matchupReportedCounter += 1
						}
					}
				}
				
				pointsPerMatchup = Float(Float(100) / Float((tournament.teamList.count - 1) + totalMatchCounter))
				currentPoints = Float(pointsPerMatchup) * Float(matchupReportedCounter)
			} else {
				pointsPerMatchup = Float(Float(100) / Float((tournament.teamList.count - 1)))
			}
			
			for matchup in tournament.matchupList {
				if matchup.isReported && matchup.teamOne != nil && matchup.teamTwo != nil {
					currentPoints += pointsPerMatchup
				}
			}
			
			let progress = Int(round(currentPoints))
			tournamentProgress = progress
		} else {
        	tournamentProgress = 0
		}
		
		try! realm.write {
			tournament.progress_meter = tournamentProgress
		}
		
		if tournament.isOnline {
			tournamentDAO.addFirebaseTournament(tournament: tournament)
		}
    }
	
	func isIdUnique(id: Int) -> Bool {
		var count = 0
		if !realm.isInWriteTransaction {
			try! realm.write {
				count = realm.objects(BracketMatchup.self).filter("id = \(id)").count
			}
		} else {
			count = realm.objects(BracketMatchup.self).filter("id = \(id)").count
		}
		
		return count == 0
	}
	
	func resetTeamValues(team: Team) {
		if !realm.isInWriteTransaction {
			let db = DBManager()
			db.beginWrite()
			
			team.wins = 0
			team.losses = 0
			team.bracketRounds.removeAll()
			team.bracketRounds.append(1)
			team.bracketVerticalPositions.removeAll()
			
			db.commitWrite()
		} else {
			team.wins = 0
			team.losses = 0
			team.bracketRounds.removeAll()
			team.bracketRounds.append(1)
			team.bracketVerticalPositions.removeAll()
		}
	}
    
    // called from within a realm.write
    func getTeamBySeed(seed: String) -> Team {
		let objects = realm.objects(Team.self).filter("seed = \(Int(seed)!) AND tournament_id = \(tournament.id)")
		
		if objects.count > 0 {
			return objects.first!
		} else {
			return Team()
		}
    }
    
    // Run through teams, see if they are next to each other based on position,
    // are NOT in a matchup already, too.
	// this doesn't update the bracket view itself,
	// just checks to see if a new match up is ready to be played.
    func updateMatchups() {
        let availableTeams = List<Team>()
		
		for team in tournament.teamList {
			if team.losses == 0 && team.bracketRounds.count > 1 {
				availableTeams.append(team)
			}
		}
		
		// two teams left, grab them!
		if availableTeams.count == 2 {
			let team = availableTeams[0]
			let teamTwo = availableTeams[1]
			
			if  team.name != teamTwo.name && team.bracketRounds.last == teamTwo.bracketRounds.last &&
				team.bracketVerticalPositions.last != nil &&
				team.bracketVerticalPositions.last == teamTwo.bracketVerticalPositions.last {
				
				var canContinue = true
				// make sure this matchup doesn't exist.
				for matchup in tournament.matchupList {
					if	((!matchup.isReported) && (matchup.teamOne?.seed == teamTwo.seed ||
						matchup.teamTwo?.seed == teamTwo.seed)) {
						canContinue = false
						break
					}
				}
				
				if canContinue {
					createBracketMatchup(team: team, teamTwo: teamTwo)
				}
			}
		} else {
			// more than two teams, let's find the right two
			for team in availableTeams {
				var canContinue = true
				for matchup in tournament.matchupList {
					if ((!matchup.isReported) && (matchup.teamOne?.seed == team.seed ||
						matchup.teamTwo?.seed == team.seed)) {
						canContinue = false
						break
					}
				}
				
				for teamTwo in availableTeams {
					var canContinueTwo = true
					// make sure the team isn't in another matchup
					for matchup in tournament.matchupList {
						if	((!matchup.isReported) && (matchup.teamOne?.seed == teamTwo.seed ||
							matchup.teamTwo?.seed == teamTwo.seed)) {
							canContinueTwo = false
							break
						}
					}
					
					if canContinue && canContinueTwo &&
						team.name != teamTwo.name && team.bracketRounds.last == teamTwo.bracketRounds.last &&
						team.bracketVerticalPositions.last != nil &&
						team.bracketVerticalPositions.last == teamTwo.bracketVerticalPositions.last {
						
						// teams are in same spot! create a match up.
						createBracketMatchup(team: team, teamTwo: teamTwo)
					}
				}
			}
        }
		
		if bracketControllerDelegate != nil {
			bracketControllerDelegate?.bracketCreated(isUpdateMatchups: false)
		}
    }
	
	func createBracketMatchup(team: Team, teamTwo: Team) {
		try! realm.write {
			let game = BracketMatchup()
			
			let max = 2147483600
			var id = Int(arc4random_uniform(UInt32(max)))
			while !isBracketMatchupIdUnique(id: id) {
				id = Int(arc4random_uniform(UInt32(max)))
			}
			
			game.id = Int(id)
			
			game.tournament_id = tournament.id
			// better seed is shown first.
			game.teamOne = team.seed < teamTwo.seed ? team : teamTwo
			game.teamTwo = team.seed < teamTwo.seed ? teamTwo : team
			game.round = team.bracketRounds.last!
			game.round_position = team.bracketVerticalPositions.last!
			game.division = "Advanced"
			
			if isGameUnique(game: game) {
				realm.add(game)
				tournament.matchupList.append(game)
				let matchupFirebaseDao = MatchupFirebaseDao()
				matchupFirebaseDao.addFirebaseBracketMatchup(matchup: game)
			}
		}
	}
	
	func isBracketMatchupIdUnique(id: Int) -> Bool {
		var count = 0
		
		if realm.isInWriteTransaction {
			count = realm.objects(BracketMatchup.self).filter("id = \(id)").count
		} else {
			try! realm.write {
				count = realm.objects(BracketMatchup.self).filter("id = \(id)").count
			}
		}
		
		return count == 0
	}
    
    func isGameUnique(game: BracketMatchup) -> Bool {
        for matchup in tournament.matchupList {
			if (matchup.teamOne?.name == game.teamOne?.name || matchup.teamTwo?.name == game.teamOne?.name) &&
				(matchup.teamOne?.name == game.teamTwo?.name || matchup.teamTwo?.name == game.teamTwo?.name) &&
				matchup.tournament_id == game.tournament_id {
                return false
            }
        }
        
        return true
    }
	
	// use this to advance teams if they have a bye
	// already in a write transaction
	func reportByeMatch(teamToAdvance: Team) {
		teamToAdvance.wins += 1
		teamToAdvance.bracketRounds.append(teamToAdvance.bracketRounds.last! + 1)
		advanceTeamToNextBracketPosition(winningTeam: teamToAdvance)
	}
	
	// quick report match
	// no scores, just wins/losses/advancing
	func reportQuickMatch(teamToAdvance: Team, losingTeam: Team) {
		try! realm.write {
			teamToAdvance.wins += 1
			teamToAdvance.bracketRounds.append(teamToAdvance.bracketRounds.last! + 1)
			advanceTeamToNextBracketPosition(winningTeam: teamToAdvance)
			
			losingTeam.losses += 1
		}
		
		updateTournamentProgress()
		
		// a new matchup may be ready!
		updateMatchups()
	}
    
    func reportMatch(selectedMatchup: BracketMatchup, numOfGamesPlayed: Int, teamOneScores: [Int], teamTwoScores: [Int]) {
        // save the match!
		
        try! realm.write {
			selectedMatchup.isReported = true
            var teamOneWins = 0
			var teamTwoWins = 0
            for i in 0..<teamOneScores.count {
				if teamOneScores[i] > teamTwoScores[i] {
					teamOneWins += 1
				} else if teamTwoScores[i] > teamOneScores[i] {
					teamTwoWins += 1
				}
            }
			
            if teamOneWins > teamTwoWins {
				selectedMatchup.teamOne?.wins += 1
                selectedMatchup.teamTwo?.losses += 1
				selectedMatchup.teamOne?.bracketRounds.append(selectedMatchup.round + 1)
				advanceTeamToNextBracketPosition(winningTeam: selectedMatchup.teamOne!)
            } else {
				selectedMatchup.teamOne?.losses += 1
                selectedMatchup.teamTwo?.wins += 1
                selectedMatchup.teamTwo?.bracketRounds.append(selectedMatchup.round + 1)
                advanceTeamToNextBracketPosition(winningTeam: selectedMatchup.teamTwo!)
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
			
			// we appended the scores to the actual matchup in the reporter view controller
            selectedMatchup.isReported = true
        }
		
        updateTournamentProgress()
		
		// a new matchup may be ready!
		updateMatchups()
		
		if (self.tournament.isOnline) && !(self.tournament.isReadOnly) {
			matchupFirebaseDao.addFirebaseBracketMatchup(matchup: selectedMatchup)
			
			let teamFirebaseDao = TeamFirebaseDao()
			teamFirebaseDao.updateFirebaseTeam(team: selectedMatchup.teamOne!)
			teamFirebaseDao.updateFirebaseTeam(team: selectedMatchup.teamTwo!)
		}
	}
    
    // based on previous position, determine next position
    // also set if the team is on the bottom or top for easy reading
    // set the property, then update the bracket view, which will set teams based on attributes.
    // already in Realm.write here.
    func advanceTeamToNextBracketPosition(winningTeam: Team) {
        if winningTeam.bracketVerticalPositions.count > 0 {
            var nextPos = 0
            let lastPos = winningTeam.bracketVerticalPositions.last!
            if lastPos % 2 == 1 {
                // odd number
                nextPos = lastPos / 2 + 1
            } else {
                nextPos = lastPos / 2
            }
            
            winningTeam.bracketVerticalPositions.append(nextPos)
        }
    }
}
