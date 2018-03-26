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

class TournamentParser {
	
	let fireDB = Firestore.firestore()
	let realm = try! Realm()
	var isTeamsFinished = false
	var isBracketMatchupsFinished = false
	
	init() {
		
	}
	
	var delegate: TournamentParserDelegate?
	
	func getOnlineTournaments() {
		var list = [[String: Any]]()
		fireDB.collection("tournaments").getDocuments { (querySnapshot, err) in
			if let err = err {
				print("Error getting tournaments \(err)")
			} else {
				for document in querySnapshot!.documents {
					list.append(document.data())
				}
				
				self.parseOnlineTournaments(onlineTournamentData: list)
			}
		}
	}
	
	func parseOnlineTournaments(onlineTournamentData: [[String: Any]]) {
		var tournamentArray = [Tournament]()
		
		for obj in onlineTournamentData {
			let tournament = Tournament()
			
			tournament.id = obj["id"] as! Int
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
			
			tournamentArray.append(tournament)
		}
		
		delegate?.didGetOnlineTournaments(onlineTournamentList: tournamentArray)
	}
	
	func getTournamentData(tournament: Tournament) {
		
		fireDB.collection("teams")
			.whereField("tournament_id", isEqualTo: tournament.id).getDocuments { (querySnapshot, err) in
			if let err = err {
				print("Error getting teams \(err)")
			} else {
				var list = [[String: Any]]()
				for document in querySnapshot!.documents {
					list.append(document.data())
				}
				
				self.parseOnlineTeams(onlineTeamsData: list, tournament: tournament)
			}
		}
		
		fireDB.collection("bracket_matchups")
			.whereField("tournament_id", isEqualTo: tournament.id).getDocuments { (querySnapshot, err) in
				if let err = err {
					print("Error getting bracket matchups \(err)")
				} else {
					var list = [[String: Any]]()
					for document in querySnapshot!.documents {
						list.append(document.data())
					}
					
					self.parseOnlineBracketMatchups(onlineBracketMatchupData: list, tournament: tournament)
				}
		}
	}
	
	func parseOnlineTeams(onlineTeamsData: [[String: Any]], tournament: Tournament) {
		var teamArray = [Team]()
		
		for obj in onlineTeamsData {
			let team = Team()
			
			team.id = obj["id"] as! Int
			team.name = obj["name"] as! String
			team.division = obj["division"] as! String
			team.seed = obj["seed"] as! Int
			team.isCheckedIn = obj["isCheckedIn"] as! Bool
			// manually parse these guys
			//team.bracketRounds = obj["bracketRounds"] as! List<Int>
			//team.bracketVerticalPositions = obj["bracketVerticalPositions"] as! List<Int>
			team.wins = obj["wins"] as! Int
			team.losses = obj["losses"] as! Int
			team.pointsFor = obj["pointsFor"] as! Int
			team.pointsAgainst = obj["pointsAgainst"] as! Int
			//team.pool = obj["poolName"] as! String
			team.isEliminated = obj["isEliminated"] as! Bool
			team.tournament_id = obj["tournament_id"] as! Int
			
			// check for duplicates and this should be good!
			// then do the same for bracket match ups!!!!
			teamArray.append(team)
		}
		
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
	
	func parseOnlineBracketMatchups(onlineBracketMatchupData: [[String:Any]], tournament: Tournament) {
		
		
		
		isBracketMatchupsFinished = true
		didFetchData()
	}
	
	func didFetchData() {
		if isTeamsFinished && isBracketMatchupsFinished {
			delegate?.didParseTournamentData()
		}
	}
	
	
	
}
