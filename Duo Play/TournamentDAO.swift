//
//  TournamentDAO.swift
//  Duo Play
//
//  Created by Jordan Davis on 9/2/17.
//  Copyright © 2017 Jordan Davis. All rights reserved.
//

import Foundation
import RealmSwift
import Firebase

class TournamentDAO : TournamentParserDelegate {
    var tournamentsList = [Tournament]()
	let fireDB = Firestore.firestore()
	var delegate: TournamentDAODelegate?
	var tournamentParser = TournamentParser()
	
	init() {
		tournamentParser.delegate = self
	}
	
	// [GET]
	
	func getOnlineTournaments() {
		_ = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
		
		var list = [[String: Any]]()
		fireDB.collection("tournaments")
			//.whereField("dbVersion", isEqualTo: version)
			//.whereField("progress_meter", isGreaterThan: 0)
			.getDocuments { (querySnapshot, err) in
			if let err = err {
				print("Error getting tournaments \(err)")
			} else {
				for document in querySnapshot!.documents {
					list.append(document.data())
				}
				
				self.tournamentParser.parseOnlineTournaments(onlineTournamentData: list)
			}
		}
	}
	
	func getOnlineTournamentByName(name: String) {
		var list = [[String: Any]]()
		fireDB.collection("tournaments")
			.whereField("name", isEqualTo: name)
			.getDocuments { (querySnapshot, err) in
				if let err = err {
					print("Error getting tournaments \(err)")
				} else {
					for document in querySnapshot!.documents {
						list.append(document.data())
					}
					
					self.tournamentParser.parseOnlineTournaments(onlineTournamentData: list)
				}
		}
	}
	
	func getOnlineTournamentById(id: Int) {
		var list = [[String: Any]]()
		fireDB.collection("tournaments")
			.whereField("id", isEqualTo: id)
			.getDocuments { (querySnapshot, err) in
				if let err = err {
					print("Error getting tournaments \(err)")
				} else {
					for document in querySnapshot!.documents {
						list.append(document.data())
					}
					
					self.tournamentParser.parseOnlineTournaments(onlineTournamentData: list)
				}
		}
	}
	
	// Callback from tournament parser
	func didParseTournaments(tournamentList: [Tournament]) {
		// send on to the caller of this with the parsed tournament list
		delegate?.didGetOnlineTournaments(onlineTournamentList: tournamentList)
	}
	
	func getTournamentData(tournament: Tournament) {
		getOnlineTeams(tournament: tournament)
		getOnlineBracketMatchups(tournament: tournament)
	}
	
	func getOnlineTeams(tournament: Tournament) {
		fireDB.collection("teams")
			.whereField("tournament_id", isEqualTo: tournament.id).getDocuments { (querySnapshot, err) in
				if let err = err {
					print("Error getting teams \(err)")
				} else {
					var list = [[String: Any]]()
					for document in querySnapshot!.documents {
						list.append(document.data())
					}
					
					self.tournamentParser.parseOnlineTeams(onlineTeamsData: list, tournament: tournament)
				}
		}
	}
	
	func getOnlineBracketMatchups(tournament: Tournament) {
		fireDB.collection("bracket_matchups")
			.whereField("tournament_id", isEqualTo: tournament.id)
			.getDocuments { (querySnapshot, err) in
				if let err = err {
					print("Error getting bracket matchups \(err)")
				} else {
					var list = [[String: Any]]()
					for document in querySnapshot!.documents {
						list.append(document.data())
					}
					
					self.tournamentParser.parseOnlineBracketMatchups(onlineBracketMatchupData: list, tournament: tournament)
				}
		}
	}
	
	// Tournament Data parsing callbacks
	func didParseTouramentData() {
		delegate?.didGetOnlineTournamentData()
	}

	func addOnlineTournament(tournament: Tournament) {
		// Add a new document
		// Create an initial document to update.
		if tournament.isOnline && !tournament.isReadOnly {
			let updatedDate = Date()
			
			let tournamentsRef = fireDB.collection("tournaments").document(String(tournament.id))
			tournamentsRef.setData([
				"userID": tournament.userID,
				"password": tournament.password,
				"isReadOnly": tournament.isReadOnly,
				"created_date": tournament.created_date,
				"updated_date": updatedDate,
				"name": tournament.name,
				"id": tournament.id,
				"isOfficial": true,
				"isPoolPlay" : tournament.isPoolPlay,
				"progress_meter" : tournament.progress_meter,
				"isQuickReport" : tournament.isQuickReport,
				"isPoolPlayFinished" : tournament.isPoolPlayFinished,
				"isPrivate" : false, //tournament.isPrivate,
				"playersPerPool" : tournament.playersPerPool,
				"state" : tournament.state,
				"isOnline": true, // tournament.isOnline,
				"tournament_type" : tournament.tournament_type,
				"participants_count" : tournament.teamList.count
			])
		}
	}
	
	func deleteOnlineTournament(tournament: Tournament) {
		if !tournament.isReadOnly {
			fireDB.collection("bracket_matchups").whereField("tournament_id", isEqualTo: tournament.id)
				.getDocuments() { (querySnapshot, err) in
				if let err = err {
					print("Error getting bracket_matchups: \(err)")
				} else {
					for document in querySnapshot!.documents {
						document.reference.delete()
					}
				}
			}
		
			fireDB.collection("teams").whereField("tournament_id", isEqualTo: tournament.id)
				.getDocuments() { (querySnapshot, err) in
				if let err = err {
					print("Error getting teams: \(err)")
				} else {
					for document in querySnapshot!.documents {
						document.reference.delete()
					}
				}
			}
			
			fireDB.collection("tournaments").document(String(tournament.id))
				.delete() { err in
				if let err = err {
					print("Error removing document: " + String(tournament.id) + "\(err)")
				} else {
					print("Tournament successfully removed!")
				}
			}
		}
	}
	
	func addOnlineMatchup(matchup: BracketMatchup) {
		// Add a new document
		// Create an initial document to update.
		let bracketMatchupRef = fireDB.collection("bracket_matchups")
			.document(
				String(matchup.tournament_id) + " : " + String(matchup.round) + "-" + String(matchup.round_position))
		bracketMatchupRef.setData([
			"id": matchup.id,
			"teamOneId" : matchup.teamOne?.id ?? 0,
			"teamTwoId" : matchup.teamTwo?.id ?? 0,
			"teamOneScores": Array(matchup.teamOneScores),
			"teamTwoScores": Array(matchup.teamTwoScores),
			"round": matchup.round,
			"round_position" : matchup.round_position,
			"division" : matchup.division,
			"isReported" : matchup.isReported,
			"tournament_id": matchup.tournament_id
			])
	}
	
	func addOnlineTournamentTeam(team: Team) {
		// Add a new document
		// Create an initial document to update.
		let teamsRef = fireDB.collection("teams")
			.document(
				String(team.tournament_id) + " : " + String(team.id) + "-" + String(team.name))
		teamsRef.setData([
			"tournament_id": team.tournament_id,
			"id": team.id,
			"seed": team.seed,
			"name" : team.name,
			"poolName" : team.pool?.name ?? "nil",
			"isCheckedIn": team.isCheckedIn,
			"wins": team.wins,
			"losses": team.losses,
			"pointsFor": team.pointsFor,
			"pointsAgainst": team.pointsAgainst,
			"division": team.division,
			"isEliminated": team.isEliminated,
			"bracketRounds": Array(team.bracketRounds),
			"bracketVerticalPositions": Array(team.bracketVerticalPositions)
			])
	}
	
	func deleteOnlineTournamentTeam(team: Team, tournament: Tournament) {
		fireDB.collection("teams").whereField("tournament_id", isEqualTo: tournament.id)
			.whereField("name", isEqualTo: team.name)
			.whereField("id", isEqualTo: team.id)
			.getDocuments() { (querySnapshot, err) in
			if let err = err {
				print("Error getting teams: \(err)")
			} else {
				for document in querySnapshot!.documents {
					document.reference.delete()
				}
			}
		}
	}
}
