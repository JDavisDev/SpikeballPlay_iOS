//
//  DBManager.swift
//  Duo Play
//
//  Created by Jordan Davis on 5/4/18.
//  Copyright © 2018 Jordan Davis. All rights reserved.
//

import Foundation
import RealmSwift

class DBManager {
	public var database: Realm
	
	init() {
		database = try! Realm()
	}
	
	func beginWrite() {
		database.beginWrite()
	}
	
	func commitWrite() {
		do {
			try database.commitWrite()
		} catch {
			print("Failed to commit realm")
		}
	}
	
	func addObjectToRealm(object: Object) {
		database.add(object)
	}
	
	func updateRealmObject(object: Object) {
		database.add(object, update: true)
	}
	
	func getTournamentTeamsList(tournament: Tournament) -> List<Team> {
		database = try! Realm()
		var teamList = List<Team>()
		try! database.write {
			teamList = tournament.teamList
		}
		
		return teamList.count > 0 ? teamList : List<Team>()
	}
	
	func getTournamentMatchupWithTeams(tournament: Tournament, teamOne: Team, teamTwo: Team) -> BracketMatchup {
		let predicate = NSPredicate(format: "tournament_id = \(tournament.id) AND teamOne == \(teamOne) AND teamTwo == \(teamTwo)")
		let result = database.objects(BracketMatchup.self).filter(predicate)
		if result.count > 0 {
			return result.first!
		} else {
			print("Cannot fetch bracket matchup from challonge")
			return BracketMatchup()
		}
	}
	
	func getTournamentTeamFromChallonge(tournamentId: Int, teamChallongeId: Int) -> Team {
		let result = database.objects(Team.self).filter("tournament_id = \(tournamentId) AND challonge_participant_id = \(teamChallongeId)")
		if result.count > 0 {
			return result.first!
		} else {
			print("Cannot fetch bracket matchup from challonge")
			return Team()
		}
	}
}
