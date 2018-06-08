//
//  MatchupFirebaseDao.swift
//  Duo Play
//
//  Created by Jordan Davis on 6/6/18.
//  Copyright © 2018 Jordan Davis. All rights reserved.
//

import Foundation

import Firebase

class MatchupFirebaseDao {
	let fireDB = Firestore.firestore()

	func addFirebaseBracketMatchup(matchup: BracketMatchup) {
		// Add a new document
		// Create an initial document to update.
		fireDB.collection("bracket_matchups")
			.document(String(matchup.tournament_id) + " : " + String(matchup.round) + "-" + String(matchup.round_position))
			.setData(matchup.dictionary)
			/*
			"id": matchup.id,
			"teamOneId" : matchup.teamOne?.id ?? 0,
			"teamTwoId" : matchup.teamTwo?.id ?? 0,
			"teamOneScores": Array(matchup.teamOneScores),
			"teamTwoScores": Array(matchup.teamTwoScores),
			"round": matchup.round,
			"round_position" : matchup.round_position,
			"division" : matchup.division,
			"isReported" : matchup.isReported,
			"tournament_id": matchup.tournament_id])
		*/
	}
	
	func addFirebasePoolMatchup(matchup: PoolPlayMatchup) {
		// Add a new document
		// Create an initial document to update.
		let oneName = matchup.teamOne?.name ?? "null"
		let twoName = matchup.teamTwo?.name ?? "null"
		fireDB.collection("pool_play_matchups")
			.document("\(matchup.tournament_id) : \(matchup.round) - \(oneName) vs. \(twoName)")
			.setData(matchup.dictionary)
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
					
					//self.tournamentParser.parseOnlineBracketMatchups(onlineBracketMatchupData: list, tournament: tournament)
				}
		}
	}
}
