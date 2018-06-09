//
//  TournamentsManager.swift
//  Duo Play
//
//  Created by Jordan Davis on 9/1/17.
//  Copyright © 2017 Jordan Davis. All rights reserved.
//

import Foundation
import RealmSwift

class TournamentController : ChallongeTournamentAPIDelegate {
    static public var currentTournamentId: Int = 0
    static public var IS_QUICK_REPORT = false
    let realm = try! Realm()
	let challongeTournamentAPI = ChallongeTournamentAPI()
    
    static func getCurrentTournament() -> Tournament {
        let realm = try! Realm()
        let id = TournamentController.getCurrentTournamentId()
        let results = realm.objects(Tournament.self).filter("id = \(id)").first
        return results!
    }
    
    static func setTournamentId(id: Int) {
        TournamentController.currentTournamentId = id
    }
    
    static func getCurrentTournamentId() -> Int {
        return TournamentController.currentTournamentId
    }
	
	func postStartChallongeTournament(tournament: Tournament) {
		self.challongeTournamentAPI.startTournament(tournament: tournament)
	}
	
	// challonge delegate
	func didCreateChallongeTournament(onlineTournament: [String : Any]?, localTournament: Tournament?, success: Bool) {
		if success {
			DispatchQueue.main.sync {
				try! realm.write {
					<#code#>
				}
				
				// challonge match api, get matchups
			}
		}
	}
}
