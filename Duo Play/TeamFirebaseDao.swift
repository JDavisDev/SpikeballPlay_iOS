//
//  TeamFirebaseDao.swift
//  Duo Play
//
//  Created by Jordan Davis on 6/6/18.
//  Copyright © 2018 Jordan Davis. All rights reserved.
//

import Foundation
import Firebase

class TeamFirebaseDao {
	let fireDB = Firestore.firestore()
	
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
					
					//self.tournamentParser.parseOnlineTeams(onlineTeamsData: list, tournament: tournament)
				}
		}
	}
	
	func addFirebaseTeam(team: Team) {
		// Add a new document
		// Create an initial document to update.
		fireDB.collection("teams")
			.document("\(team.tournament_id) : \(team.id) - \(team.name)")
			.setData(team.dictionary)
	}
	
	func updateFirebaseTeam(team: Team) {
		// Update a team
		fireDB.collection("teams")
			.document("\(team.tournament_id) : \(team.id) - \(team.name)")
			.updateData(team.dictionary)
	}
	
	func deleteFirebaseTeam(team: Team, tournament: Tournament) {
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
