//
//  TeamsController.swift
//  SpikeballPlay
//
//  Created by Jordan Davis on 8/11/17.
//  Copyright © 2017 HoverSlam. All rights reserved.
//

import Foundation
import RealmSwift

class TeamsController: ChallongeTeamsAPIDelegate {
    var playersPerPool = 8
    let realm = try! Realm()
    let tournamentController = TournamentController()
    var isNewPool = false
    let poolController = PoolsController()
	let challongeTeamsAPI = ChallongeTeamsAPI()
	let challongeTournamentAPI = ChallongeTournamentAPI()
	
	var tournament: Tournament?
	var teamsCount = 0
	var teamsChallongeSavedCount = 0
	
	init() {
		challongeTeamsAPI.delegate = self
		tournament = TournamentController.getCurrentTournament()
		teamsCount = (tournament?.teamList.count)!
	}
    
    func addTeam(team: Team) {
        let newPool = getAvailablePool()
        let tournament = TournamentController.getCurrentTournament()

		try! realm.write() {
            if team.name.count == 0 {
				team.name = "Team #" + getNextTeamNameId(tournament: tournament)
            }
			
			playersPerPool = tournament.playersPerPool
            
            realm.add(team)
            newPool.teamList.append(team)
            team.pool = newPool
        }
    }
	
	func getNextTeamNameId(tournament: Tournament) -> String {
		var count = tournament.teamList.count
		var countString = String(count)
		
		for _ in 1...tournament.teamList.count + 2 {
			if getTeamByName(name: "Team #" + countString, tournamentId: tournament.id)?.name == "Team #" + countString {
				// we've found a match, try another number
				count += 1
				countString = String(count)
			} else {
				return countString
			}
		}
		
		// we've went thru them all with duplicates..
		return "infinity"
	}
    
    func getTeamByName(name: String, tournamentId: Int) -> Team? {
		let teams = realm.objects(Team.self).filter("name = '\(name)' AND tournament_id = \(tournamentId)")
		
		if teams.count > 0 {
			return teams.first!
		} else {
			return nil
		}
    }
	
	func getTeamById(id: Int, tournamentId: Int) -> Team? {
		let teams = realm.objects(Team.self).filter("id = \(id) AND tournament_id = \(tournamentId)")
		
		if teams.count > 0 {
			return teams.first!
		} else {
			return nil
		}
	}
    
    func getAvailablePool() -> Pool {
        let tournament = TournamentController.getCurrentTournament()
        for pool in tournament.poolList {
            if pool.teamList.count < playersPerPool && !pool.isStarted {
                isNewPool = false
                return pool
            }
        }
        
        // no available pool, create one, append it, and return it
        isNewPool = true
		return poolController.addNewPool()!
    }
    
	// challonge stuffs
	func saveTeamToChallonge(team: Team, tournament: Tournament) {
		// challonge additions
		self.challongeTeamsAPI.createChallongeParticipant(tournament: tournament, team: team)
	}
	
	// Teams Challonge Delegate method
	func didPostChallongeParticipant(team: Team, teamObject: [String : Any], success: Bool) {
		if success {
			let newTeam = Team(dictionary: teamObject)
			DispatchQueue.main.sync {
				try! realm.write {
					// update the new team with the challonge team data
					team.challonge_participant_id = newTeam.challonge_participant_id
					team.challonge_tournament_id = newTeam.challonge_tournament_id
					teamsChallongeSavedCount += 1
				}
				
				if teamsChallongeSavedCount == teamsChallongeSavedCount {
					// all finished, start tournament
					let tournamentController = TournamentController()
					tournamentController.postStartChallongeTournament(tournament: tournament!)
				}
			}
		}
	}
}
