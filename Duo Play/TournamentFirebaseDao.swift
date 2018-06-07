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

class TournamentFirebaseDao : TournamentParserDelegate {
    var tournamentsList = [Tournament]()
	let fireDB = Firestore.firestore()
	var delegate: TournamentDAODelegate?
	var tournamentParser = TournamentParser()
	
	init() {
		tournamentParser.delegate = self
	}
	
	// [GET]
	
	func getFirebaseTournaments() {
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
	
	func getFirebaseTournamentByName(name: String) {
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
	
	func getFirebaseTournamentById(id: Int) {
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
		//getOnlineTeams(tournament: tournament)
		//getOnlineBracketMatchups(tournament: tournament)
	}
	
	
	
	// Tournament Data parsing callbacks
	func didParseTouramentData() {
		delegate?.didGetOnlineTournamentData()
	}

	func addFirebaseTournament(tournament: Tournament) {
		// Add a new document
		// Create an initial document to update.
		if tournament.isOnline && !tournament.isReadOnly {
			let tournamentsRef = fireDB.collection("tournaments").document("\(tournament.id)")
			tournamentsRef.setData(tournament.dictionary)
		}
	}
	
	// delete everything with that tournament id
	func deleteFirebaseTournament(tournament: Tournament) {
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
			
			fireDB.collection("pools").whereField("tournament_id", isEqualTo: tournament.id)
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
}
