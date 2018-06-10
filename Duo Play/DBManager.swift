//
//  DBManager.swift
//  Duo Play
//
//  Created by Jordan Davis on 5/4/18.
//  Copyright © 2018 Jordan Davis. All rights reserved.
//

import Foundation
import RealmSwift
import Dispatch

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
}
