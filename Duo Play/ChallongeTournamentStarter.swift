//
//  ChallongeTournamentStarter.swift
//  Duo Play
//
//  Created by Jordan Davis on 6/9/18.
//  Copyright © 2018 Jordan Davis. All rights reserved.
//

import Foundation
import RealmSwift

class ChallongeTournamentStarter : ChallongeTeamsAPIDelegate,
ChallongeTournamentAPIDelegate {
	
	var delegate: ChallongeTournamentStarterDelegate?
	
	let realm = try! Realm()
	var tournament: Tournament?
	var teamsChallongeSavedCount = 0
	var teamCount = 0
	
	func startChallongeTournament(tournament: Tournament) {
		self.tournament = tournament
		teamCount = tournament.teamList.count
		let teamsChallongeAPI = ChallongeTeamsAPI()
		teamsChallongeAPI.delegate = self
		// add teams first.
		let team = tournament.teamList[0]
		teamsChallongeAPI.createChallongeParticipant(tournament: tournament, team: team)

	}
	
	func didBulkAddParticipants(participants: [[String:Any]]?, success: Bool) {
		if success {
			//will have to fetch realm objects to match returned participants
			DispatchQueue.main.sync {
				try! realm.write {
					for team in participants! {
						let onlineTeam = Team(dictionary: team)
						let realmTeam = getRealmTeam(tournamentId: (self.tournament?.id)!, teamName: team["name"] as! String)
						// update the new team with the challonge team data
						realmTeam.challonge_participant_id = onlineTeam.id
						realmTeam.challonge_tournament_id = onlineTeam.tournament_id
						teamsChallongeSavedCount += 1
					}
				}
				
				if teamsChallongeSavedCount >= teamCount {
					// all finished, start tournament
					let tournamentChallongeAPI = ChallongeTournamentAPI()
					tournamentChallongeAPI.delegate = self
					tournamentChallongeAPI.startTournament(tournament: tournament!)
				}
			}
		} else {
			DispatchQueue.main.sync {
				self.delegate?.didFinishStartingTournament(success: false)
			}
		}
	}
	
	func getRealmTeam(tournamentId: Int, teamName: String) -> Team {
		let result = realm.objects(Team.self).filter("tournament_id = \(tournamentId) AND name = '\(teamName)'")
		if result.count > 0 {
			return result.first!
		} else {
			print("Cannot fetch team from realm")
			return Team()
		}
	}
	
	// challonge start challonge delegate
	// will return the started tournament AND included match ups
	func didStartChallongeTournament(tournament: Tournament, challongeMatchups: [[String: Any]]?, success: Bool) {
		if success && teamsChallongeSavedCount >= teamCount {
			DispatchQueue.main.sync {
				parseChallongeMatchups(tournament: tournament, challongeMatchups: challongeMatchups)
				self.delegate?.didFinishStartingTournament(success: success)
			}
		} else {
			DispatchQueue.main.sync {
					self.delegate?.didFinishStartingTournament(success: false)
			}
		}
	}
	
	func parseChallongeMatchups(tournament: Tournament, challongeMatchups: [[String:Any]]?) {
		try! realm.write {
			for dictObject in challongeMatchups! {
				guard let localMatchup = getRealmMatchupFromChallongeData(tournament: tournament, data: dictObject) else { continue }
				// same match... parse!
				// basically, I'm reassigning the challonge IDs to overwrite these ids so they match
				localMatchup.challongeId = dictObject["id"] as! Int
				localMatchup.tournament_id = dictObject["tournament_id"] as! Int
				
				realm.add(localMatchup, update: true)
			}
		}
	}
	
	func getRealmMatchupFromChallongeData(tournament: Tournament, data: [String: Any]) -> BracketMatchup? {
		var matchup: BracketMatchup?
		if let oneId = data["player1_id"] as? Int {
			if let twoId = data["player2_id"] as? Int {
				guard let teamOne = getTournamentTeamFromChallonge(tournamentId: tournament.id, teamChallongeId: oneId) else { return nil }
				guard let teamTwo = getTournamentTeamFromChallonge(tournamentId: tournament.id, teamChallongeId: twoId)
					else { return nil }
				
				matchup = getTournamentMatchupWithTeams(tournament: tournament, teamOne: teamOne, teamTwo: teamTwo)
				return matchup
			}
		}
		
		return nil
	}
	
	func getTournamentTeamFromChallonge(tournamentId: Int, teamChallongeId: Int) -> Team? {
		let result = realm.objects(Team.self).filter("tournament_id = \(tournamentId) AND challonge_participant_id = \(teamChallongeId)")
		if result.count > 0 {
			return result.first!
		} else {
			print("Cannot fetch bracket team from challonge")
			return Team()
		}
	}
	
	func getTournamentMatchupWithTeams(tournament: Tournament, teamOne: Team, teamTwo: Team) -> BracketMatchup? {
		let predicate = NSPredicate(format: "tournament_id = \(tournament.id)")
		let result = realm.objects(BracketMatchup.self).filter(predicate)
		if result.count > 0 {
			// we have all match ups in the tournament
			for obj in result {
				if (obj.teamOne?.name == teamOne.name && obj.teamTwo?.name == teamTwo.name) ||
					(obj.teamTwo?.name == teamOne.name && obj.teamOne?.name == teamTwo.name) {
					return obj
				}
			}
		} else {
			print("Cannot fetch bracket matchup from realm")
		}
		
		return nil
	}
}
