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

// NEED to work on deleting unused objects...
// when deleting matchups, maybe delete all games by tournament id or something...

class BracketController {
	static var hasDrawn = false
    let realm = try! Realm()
    let tournament: Tournament
    let poolList: List<Pool>
	let tournamentDAO = TournamentDAO()
    var byeCount = 0
    var roundCount = 0
    var nodeList = [Node]()
    var isEnd = false
    var baseBracketSize = 0
    var tournamentProgress = 0
	
	
    init() {
        tournament = TournamentController.getCurrentTournament()
        poolList = tournament.poolList
        byeCount = getByeCount()
    }
    
    // this will be called when tournament starts
    // when things change, like settings and teams.
    // be dynamic and adaptable!
    func createBracket() {
        if tournament.teamList.count > 0 {
            seedTeams()
            
            if tournamentProgress <= 0 {
                createAndOrderMatchups()
			} else {
				try! realm.write {
					for team in tournament.teamList {
						resetTeamValues(team: team)
					}
				}
				
				createAndOrderMatchups()
			}
			
			updateTournamentProgress()
        }
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
        let teamCount = tournament.teamList.count
        let var1 = teamCount + getByeCount()
        let var2 = var1 / 2
        let final = var2 / round
        return final
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
    
    func getNextPowerOfTwo(num: Int) -> Int {
        switch(num) {
        case 3...4:
            return 4
            case 5...8:
                return 8
            case 9...16:
                return 16
            case 17...32:
                return 32
            case 33...64:
                return 64
            case 65...128:
                return 128
            case 129...256:
                return 256
			case 257...512:
				return 512
            default:
                return 0
        }
    }
    
    // seeding teams is okay at any point.
    // if matchups have been reported, let's block them after seeding.
    // nothing else should be able to be updated
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
		
		createAndOrderMatchups()
	}
	
	// if pool play, check the pool matches
	// else just check bracket matchups.
    func updateTournamentProgress() {
        if tournament.teamList.count > 0 {
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
				if matchup.isReported {
					currentPoints += pointsPerMatchup
				}
			}
			
			// BYE matchups are counted as reported.
			// if we ONLY have byes reported, set to zero
			// when another is reported, we can count them in the progress
			if getByeCount() == Int(currentPoints/pointsPerMatchup) {
				tournamentProgress = 0
			} else {
				let progress = Int(round(currentPoints))
				tournamentProgress = progress
			}
		} else {
        	tournamentProgress = 0
		}
		
		try! realm.write {
			tournament.progress_meter = tournamentProgress
		}
		
		tournamentDAO.updateOnlineTournament(tournament: tournament)
    }
    
    // Setting up the bracket matchups
    // Ordering the match ups based on official tournament seeding
    func createAndOrderMatchups() {
        var seedStringList = [String]()
        nodeList = [Node]()
        var halfNodesList = [Node]()
        
        // need a number to sim bracket size. basically, it's the next highest power of 2
        // 14 teams is a 16 team bracket wtih 2 byes that'll go to highest seeds, rest of bracket looks the same
        baseBracketSize = getNextPowerOfTwo(num: tournament.teamList.count)
		
		if baseBracketSize > 0 {
        	for i in 1...baseBracketSize {
            	seedStringList.append(String(i))
        	}
		} else {
			return
		}
        
        // 1/2 are always at the end, set that up now.
        let root = Node(value: [seedStringList[0], seedStringList[1]])
        seedStringList.removeFirst(2)
        nodeList.append(root)
        
        // handle round by round
        // create and fill nodes
        // half nodes need filled in, as they were just branched.
        // we know we've reached the end based on node counts and it's children and baseBracketSize
        while nodeList.count < baseBracketSize - 1 {
            halfNodesList.removeAll()
            
            for node in nodeList {
                if node.value.count > 1 && node.children.count <= 0 &&
                    !(Int(node.value[0])! + Int(node.value[1])! == baseBracketSize + 1) {
                    // two values, create two splitting branches
                    let nodeOne = Node(value: [node.value[0]])
                    let nodeTwo = Node(value: [node.value[1]])
                    
                    //add children to that node
                    node.add(child: nodeOne)
                    node.add(child: nodeTwo)
                    
                    // append both to the list for iteration
                    nodeList.append(nodeOne)
                    nodeList.append(nodeTwo)
                    
                    // we just branched off of full nodes, so they are now halves.
                    halfNodesList.append(nodeOne)
                    halfNodesList.append(nodeTwo)
                }
            }
            
            addSeedToNode(nodes: halfNodesList, seedList: seedStringList)
            // check if counts match up to be the final round
            if isEnd {
                break
            }
        }
        
        // use this to make sure we only have the final round of nodes in our list
        // to gen match ups from
        var copyList = [Node]()
        
        for node in nodeList {
            if node.children.count <= 0 {
                copyList.append(node)
            }
        }
        
        createMatchupsFromNodeList(nodes: copyList)
    }
    
    // iterate thru the half nodes and add a seed to each
    func addSeedToNode(nodes: [Node], seedList: [String]) {
        // may be able to delete the nodeList.add() in the order method above.
        // delete and re-add nodes that contain two values.
        // keep the nodeList intact with no half nodes.
        var copyList = [Node]()
        
        for node in nodeList {
            if node.value.count >= 2 {
                copyList.append(node)
            }
        }
        
        nodeList.removeAll()
        nodeList = copyList
        
        // check counts and additions of seeds to match current round
        // current round is calculated by nodes.count * 2 + 1
        // example: round 2 of nodes will always have just 2 full nodes.
        // 1v4 & 2v3. 2 nodes * 2 = 4 + 1 = 5. 1+4 = 5 & 2+3 = 5.
        // this is the same for each subsequent round.
        for node in nodes {
            for seed in seedList {
                if Int(node.value[0])! + Int(seed)! == (nodes.count * 2) + 1 {
                    node.value.append(seed)
                    nodeList.append(node)
                    break;
                }
            }
        }
        
        // check to see if we have all we need, and call isEnd to break out of the loop above.
        if nodeList.count == baseBracketSize - 1 {
            isEnd = true
        }
    }
    
    func createMatchupsFromNodeList(nodes: [Node]) {
        var verticalPositionCounter: Int = 1
        
        try! realm.write {
            tournament.matchupList.removeAll()
        
            for node in nodes {
                if node.value.count == 2 {
                    let game = BracketMatchup()
					
					let max = 2147483600
					var id = Int(arc4random_uniform(UInt32(max)))
					while !isIdUnique(id: id) {
						id = Int(arc4random_uniform(UInt32(max)))
					}
					
					game.id = Int(id)
					
                    game.tournament_id = tournament.id
                    game.teamOne = getTeamBySeed(seed: node.value[0])
                    resetTeamValues(team: (game.teamOne)!)
					
                    game.division = "Advanced"
                    game.round = 1
                    game.round_position = verticalPositionCounter
                    game.teamOne?.bracketVerticalPositions.append(game.round_position)
					
                    // check if a node value exceeds our teams, in which case, it's a bye.
                    let seedInt = Int(node.value[1])!
                    if seedInt > tournament.teamList.count {
						// teamOne will get a bye here.
						game.teamTwo = nil
						game.isReported = true
						reportByeMatch(teamToAdvance: game.teamOne!)
                    } else {
						// not a bye, proceed normally
                        game.teamTwo = getTeamBySeed(seed: node.value[1])
						resetTeamValues(team: (game.teamTwo)!)
						game.teamTwo?.bracketVerticalPositions.append(game.round_position)
                    }
					
					realm.add(game)
					tournament.matchupList.append(game)
					tournamentDAO.addOnlineMatchup(matchup: game)
					verticalPositionCounter += 1
                }
            }
        }
		
		if getByeCount() > 2 {
			updateMatchups()
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
		team.wins = 0
		team.losses = 0
		team.bracketRounds.removeAll()
		team.bracketRounds.append(1)
		team.bracketVerticalPositions.removeAll()
	}
    
    // called from within a realm.write
    func getTeamBySeed(seed: String) -> Team {
        return realm.objects(Team.self).filter("seed = \(Int(seed)!) AND tournament_id = \(tournament.id)").first!
    }
    
    // Run through teams, see if they are next to each other based on position,
    // are NOT in a matchup already, too.
	// this doesn't update the bracket view itself,
	// just checks to see if a new match up is ready to be played.
    func updateMatchups() {
        let availableTeams = List<Team>()
		
		for team in tournament.teamList {
			if !team.isEliminated && team.bracketRounds.count > 1 {
				availableTeams.append(team)
			}
		}
	
        for team in availableTeams {
			var canContinue = true
			for matchup in tournament.matchupList {
				if !matchup.isReported && matchup.teamOne?.seed == team.seed ||
					matchup.teamTwo?.seed == team.seed {
					canContinue = false
					break
				}
			}
			
            for teamTwo in availableTeams {
				// make sure the team isn't in another matchup
				for matchup in tournament.matchupList {
					if	!matchup.isReported && matchup.teamOne?.seed == teamTwo.seed ||
						matchup.teamTwo?.seed == teamTwo.seed {
						canContinue = false
						break
					}
				}
				
                if canContinue &&
					team.name != teamTwo.name && team.bracketRounds.last == teamTwo.bracketRounds.last &&
                    team.bracketVerticalPositions.last != nil &&
                    team.bracketVerticalPositions.last == teamTwo.bracketVerticalPositions.last {
					
                    // teams are in same spot! create a match up.
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
						realm.add(game)
						tournament.matchupList.append(game)
						tournamentDAO.addOnlineMatchup(matchup: game)
					}
                }
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
            if matchup == game {
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
			losingTeam.isEliminated = true
		}
		
		updateTournamentProgress()
		
		// a new matchup may be ready!
		updateMatchups()
	}
    
    func reportMatch(selectedMatchup: BracketMatchup, numOfGamesPlayed: Int, teamOneScores: [Int], teamTwoScores: [Int]) {
        // save the match!
        try! realm.write {
            
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
                selectedMatchup.teamTwo?.isEliminated = true
                selectedMatchup.teamOne?.bracketRounds.append(selectedMatchup.round + 1)
                advanceTeamToNextBracketPosition(winningTeam: selectedMatchup.teamOne!)
            } else {
                selectedMatchup.teamOne?.losses += 1
                selectedMatchup.teamTwo?.wins += 1
                selectedMatchup.teamOne?.isEliminated = true
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
            
            selectedMatchup.teamOneScores.append(objectsIn: teamOneScores)
            selectedMatchup.teamTwoScores.append(objectsIn: teamTwoScores)
            
            selectedMatchup.teamTwo?.pointsAgainst += teamOneScores[0]
            selectedMatchup.teamTwo?.pointsAgainst += teamOneScores[1]
            selectedMatchup.teamTwo?.pointsAgainst += teamOneScores[2]
            
            selectedMatchup.teamTwo?.pointsFor += teamTwoScores[0]
            selectedMatchup.teamTwo?.pointsFor += teamTwoScores[1]
            selectedMatchup.teamTwo?.pointsFor += teamTwoScores[2]
            
            selectedMatchup.isReported = true
			tournamentDAO.addOnlineMatchup(matchup: selectedMatchup)
        }
        
        updateTournamentProgress()
		
		// a new matchup may be ready!
		updateMatchups()
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
