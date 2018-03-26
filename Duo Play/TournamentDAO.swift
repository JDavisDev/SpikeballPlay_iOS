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

class TournamentDAO {
    var tournamentsList = [Tournament]()
	let fireDB = Firestore.firestore()

	func updateOnlineTournament(tournament: Tournament) {
		// Add a new document
		// Create an initial document to update.
		let tournamentsRef = fireDB.collection("tournaments").document(String(tournament.id))
		tournamentsRef.setData([
			"name": tournament.name,
			"id": tournament.id,
			"isOfficial": true,
			"isPoolPlay" : tournament.isPoolPlay,
			"progress_meter" : tournament.progress_meter,
			"isQuickReport" : tournament.isQuickReport,
			"isPoolPlayFinished" : tournament.isPoolPlayFinished,
			"isPrivate" : tournament.isPrivate,
			"playersPerPool" : tournament.playersPerPool,
			"state" : tournament.state,
			"tournament_type" : tournament.tournament_type,
			"participants_count" : tournament.participants_count
			])
	}
	
	func deleteOnlineTournament(tournament: Tournament) {
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
	
	func addOnlineMatchup(matchup: BracketMatchup) {
		// Add a new document
		// Create an initial document to update.
		let bracketMatchupRef = fireDB.collection("bracket_matchups")
			.document(
				String(matchup.tournament_id) + " : " + String(matchup.round) + "-" + String(matchup.round_position))
		bracketMatchupRef.setData([
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
	
	func updateOnlineMatchup(matchup: BracketMatchup) {
		
	}
	
	func addOnlineTournamentTeam(team: Team) {
		// Add a new document
		// Create an initial document to update.
		let bracketMatchupRef = fireDB.collection("teams")
			.document(
				String(team.tournament_id) + " : " + String(team.id) + "-" + String(team.name))
		bracketMatchupRef.setData([
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
			"bracketVerticalPositions": Array(team.bracketVerticalPositions),
			])
	}
	
	func updateOnlineTournamentTeam(team: Team) {
		
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
	
	func getOnlineTournaments() {
		var tournamentList = [[String: Any]]()
		
		fireDB.collection("tournaments").getDocuments { (querySnapshot, err) in
			if let err = err {
				print("Error getting tournaments \(err)")
			} else {
				for document in querySnapshot!.documents {
					tournamentList.append(document.data())
				}
			}
		}
	}
}
