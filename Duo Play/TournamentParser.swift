//
//  TournamentParser.swift
//  Duo Play
//
//  Created by Jordan Davis on 3/25/18.
//  Copyright © 2018 Jordan Davis. All rights reserved.
//

import Foundation
import Firebase
import RealmSwift

class TournamentParser : ChallongeTournamentAPIDelegate {
	
	let fireDB = Firestore.firestore()
	let realm = try! Realm()
	var isTeamsFinished = false
	var isBracketMatchupsFinished = false
	
	init() {
		
	}
	
	var delegate: TournamentParserDelegate?
	
	func parseOnlineTournaments(onlineTournamentData: [[String: Any]]) {
		var tournamentArray = [Tournament]()
		
		for obj in onlineTournamentData {
			let tournament = Tournament()
			
			tournament.id = obj["id"] as! Int
			tournament.password = obj["password"] as! String
			tournament.isOnline = true
			tournament.state = obj["state"] as! String
			tournament.tournament_type = obj["tournament_type"] as! String
			tournament.isPoolPlay = obj["isPoolPlay"] as! Bool
			tournament.participants_count = obj["participants_count"] as! Int
			tournament.isQuickReport = obj["isQuickReport"] as! Bool
			tournament.name = obj["name"] as! String
			tournament.isPrivate = obj["isPrivate"] as! Bool
			tournament.progress_meter = obj["progress_meter"] as! Int
			tournament.isPoolPlayFinished = obj["isPoolPlayFinished"] as! Bool
			tournament.playersPerPool = obj["playersPerPool"] as! Int
			
			// if tournament is public, add it.
			// if private, only add if the tournament was created by this user.
			// not sure if this will work perfectly.
			if !tournament.isPrivate || tournament.userID == Auth.auth().currentUser?.uid ||
				tournament.userID == Analytics.appInstanceID() {
				tournamentArray.append(tournament)
			}
		}
		
		delegate?.didParseTournaments(tournamentList: tournamentArray)
	}
	
	func parseOnlineTeams(onlineTeamsData: [[String: Any]], tournament: Tournament) {
		var teamArray = [Team]()
		
//		// wipe out realm data and insert the new stuff.
//		if realm.isInWriteTransaction {
//			tournament.matchupList.removeAll()
//			let objs = realm.objects(Team.self).filter("tournament_id = \(tournament.id)")
//			realm.delete(objs)
//		} else {
//			try! realm.write {
//				let objs = realm.objects(Team.self).filter("tournament_id = \(tournament.id)")
//				realm.delete(objs)
//			}
//		}
		
		for obj in onlineTeamsData {
			let team = Team()
			
			team.id = obj["id"] as! Int
			team.name = obj["name"] as! String
			team.division = obj["division"] as! String
			team.seed = obj["seed"] as! Int
			team.isCheckedIn = obj["isCheckedIn"] as! Bool
			team.wins = obj["wins"] as! Int
			team.losses = obj["losses"] as! Int
			team.pointsFor = obj["pointsFor"] as! Int
			team.pointsAgainst = obj["pointsAgainst"] as! Int
			// fetch pool by name
			//team.pool = obj["poolName"] as! String
			team.isEliminated = obj["isEliminated"] as! Bool
			team.tournament_id = obj["tournament_id"] as! Int
			
			// manually parse these guys
			let roundsArray = obj["bracketRounds"] as! [Int]
			let vertArray = obj["bracketVerticalPositions"] as! [Int]
			
			for item in roundsArray {
				team.bracketRounds.append(item)
			}
			
			for item in vertArray {
				team.bracketVerticalPositions.append(item)
			}
			
			// check for duplicates and this should be good!
			if isTeamUnique(team: team) {
				teamArray.append(team)
			}
		}
		
		// add stuff to our local storage
		if realm.isInWriteTransaction {
			realm.add(teamArray)
			tournament.teamList.append(objectsIn: teamArray)
		} else {
			try! realm.write {
				realm.add(teamArray)
				tournament.teamList.append(objectsIn: teamArray)
			}
		}
		
		isTeamsFinished = true
		didFetchData()
	}
	
	func isTeamUnique(team: Team) -> Bool {
		var count = 0
		
		if realm.isInWriteTransaction {
			count = realm.objects(Team.self).filter("id = \(team.id) AND tournament_id = \(team.tournament_id)").count
		} else {
			try! realm.write {
				count = realm.objects(Team.self).filter("id = \(team.id) AND tournament_id = \(team.tournament_id)").count
			}
		}
		
		return count == 0
	}
	
	
	
	func parseOnlineBracketMatchups(onlineBracketMatchupData: [[String:Any]], tournament: Tournament) {
		var matchupArray = [BracketMatchup]()
		let teamsController = TeamsController()
		
		// wipe out realm data and insert the new stuff.
		if realm.isInWriteTransaction {
			tournament.matchupList.removeAll()
			let objs = realm.objects(BracketMatchup.self).filter("tournament_id = \(tournament.id)")
			realm.delete(objs)
		} else {
			try! realm.write {
				let objs = realm.objects(BracketMatchup.self).filter("tournament_id = \(tournament.id)")
				realm.delete(objs)
			}
		}
		
		for obj in onlineBracketMatchupData {
			let matchup = BracketMatchup()
			
			matchup.id = obj["id"] as! Int
			matchup.division = obj["division"] as! String
			matchup.isReported = obj["isReported"] as! Bool
			matchup.round = obj["round"] as! Int
			matchup.round_position = obj["round_position"] as! Int
			matchup.teamOne = teamsController.getTeamById(id: obj["teamOneId"] as! Int, tournamentId: obj["tournament_id"] as! Int)
			matchup.teamTwo = teamsController.getTeamById(id: obj["teamTwoId"] as! Int, tournamentId: obj["tournament_id"] as! Int)
			matchup.tournament_id = obj["tournament_id"] as! Int
		
			let teamOneScores = obj["teamOneScores"] as! [Int]
			let teamTwoScores = obj["teamTwoScores"] as! [Int]
			
			for score in teamOneScores {
				matchup.teamOneScores.append(score)
			}
			
			for score in teamTwoScores {
				matchup.teamTwoScores.append(score)
			}
			
			if isBracketMatchupUnique(bracketMatchup: matchup) {
				matchupArray.append(matchup)
			}
		}
		
		// add stuff to our local storage
		if realm.isInWriteTransaction {
			realm.add(matchupArray)
			tournament.matchupList.append(objectsIn: matchupArray)
		} else {
			try! realm.write {
				realm.add(matchupArray)
				tournament.matchupList.append(objectsIn: matchupArray)
			}
		}
		
		
		isBracketMatchupsFinished = true
		didFetchData()
	}
	
	func isBracketMatchupUnique(bracketMatchup: BracketMatchup) -> Bool {
		var count = 0
		
		if realm.isInWriteTransaction {
			count = realm.objects(BracketMatchup.self).filter("id = \(bracketMatchup.id) AND tournament_id = \(bracketMatchup.tournament_id)").count
		} else {
			try! realm.write {
				count = realm.objects(BracketMatchup.self).filter("id = \(bracketMatchup.id) AND tournament_id = \(bracketMatchup.tournament_id)").count
			}
		}
		
		return count == 0
	}
	
	func didFetchData() {
		if isTeamsFinished && isBracketMatchupsFinished {
			delegate?.didParseTouramentData()
			isTeamsFinished = false
			isBracketMatchupsFinished = false
		}
	}
	
	func didCreateChallongeTournament(onlineTournament: [String: Any], localTournament: Tournament) {
		Realm.asyncOpen() { realm, error in
			if let realm = realm {
				// Realm successfully opened
				try! realm.write {
					localTournament.id = onlineTournament["id"] as! Int
					localTournament.full_challonge_url = onlineTournament["full_challonge_url"] as! String
					localTournament.isPrivate = onlineTournament["private"] as! Bool
					localTournament.live_image_url = onlineTournament["live_image_url"]as! String
					localTournament.participants_count = onlineTournament["participants_count"] as! Int
					localTournament.progress_meter = onlineTournament["progress_meter"] as! Int
					localTournament.state = onlineTournament["state"] as! String
					localTournament.url = onlineTournament["url"] as! String
					localTournament.tournament_type = onlineTournament["tournament_type"] as! String
				}
			} else if error != nil {
				// Handle error that occurred while opening the Realm
			}
		}
	}
	
	// we should have a list of included matchups and participants
	// map our teams to participants
	// map
	func parseStartedTournament(localTournament: Tournament, challongeParticipants: [[String:Any]], challongeMatchups: [[String:Any]]) {
		
		let matchupParser = MatchupParser()
		let teamParser = TeamParser()
		teamParser.parseIncludedTeams(tournament: localTournament, challongeParticipants: challongeParticipants)
		matchupParser.parseIncludedMatchups(tournament: localTournament, challongeMatchups: challongeMatchups)
	}
}
