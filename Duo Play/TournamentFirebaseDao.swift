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
		let date = Date()
		let calendar = Calendar.autoupdatingCurrent
		let year = calendar.component(.year, from: date)
		let month = calendar.component(.month, from: date)
		let day = calendar.component(.day, from: date)
		
		if !tournament.isReadOnly {
			fireDB.collection("tournaments").document("\(year).\(month).\(day): \(tournament.name) - \(tournament.id)")
			.setData(tournament.dictionary)
		}
	}
	
	func updateFirebaseTournament(tournament: Tournament) {
		let date = Date()
		let calendar = Calendar.autoupdatingCurrent
		let year = calendar.component(.year, from: date)
		let month = calendar.component(.month, from: date)
		let day = calendar.component(.day, from: date)
		let realm = try! Realm()
		
		try! realm.write {
			tournament.updated_date = "\(year).\(month).\(day)"
		}
		
		if !tournament.isReadOnly {
			fireDB.collection("tournaments").document("\(tournament.created_date): \(tournament.name) - \(tournament.id)")
			.updateData(tournament.dictionary)
		}
	}
	
	// delete everything with that tournament id
	func deleteFirebaseTournament(tournament: Tournament) {
		if !tournament.isReadOnly {
			fireDB.collection("bracket_matchups").whereField("tournament_id", isEqualTo: tournament.id)
				.getDocuments() { (querySnapshot, err) in
				if let err = err {
					print("Error deleting bracket_matchups: \(err)")
				} else {
					for document in querySnapshot!.documents {
						document.reference.delete()
					}
				}
			}
		
			fireDB.collection("teams").whereField("tournament_id", isEqualTo: tournament.id)
				.getDocuments() { (querySnapshot, err) in
				if let err = err {
					print("Error deleting teams: \(err)")
				} else {
					for document in querySnapshot!.documents {
						document.reference.delete()
					}
				}
			}
			
			fireDB.collection("pools").whereField("tournament_id", isEqualTo: tournament.id)
				.getDocuments() { (querySnapshot, err) in
					if let err = err {
						print("Error deleting pools: \(err)")
					} else {
						for document in querySnapshot!.documents {
							document.reference.delete()
						}
					}
			}
			
			fireDB.collection("pool_play_matchups").whereField("tournament_id", isEqualTo: tournament.id)
				.getDocuments() { (querySnapshot, err) in
					if let err = err {
						print("Error deleting pool play matchups: \(err)")
					} else {
						for document in querySnapshot!.documents {
							document.reference.delete()
						}
					}
			}
			
			fireDB.collection("tournaments").whereField("id", isEqualTo: tournament.id)
				.getDocuments() { (querySnapshot, err) in
					if let err = err {
						print("Error deleting tournament: \(err)")
					} else {
						for document in querySnapshot!.documents {
							document.reference.delete()
						}
					}
			}
		}
	}
}
