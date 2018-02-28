//
//  TournamentsManager.swift
//  Duo Play
//
//  Created by Jordan Davis on 9/1/17.
//  Copyright © 2017 Jordan Davis. All rights reserved.
//

import Foundation
import RealmSwift

class TournamentController {
    static public var currentTournamentId = ""
    static public var IS_QUICK_REPORT = false
    let realm = try! Realm()
    
    static func getCurrentTournament() -> Tournament {
        let realm = try! Realm()
        let results = realm.objects(Tournament.self).filter("id = '" + TournamentController.getCurrentTournamentId() + "'").first
        return results!
    }
    
    static func setTournamentId(id: String) {
        TournamentController.currentTournamentId = id
    }
    
    static func getCurrentTournamentId() -> String {
        return TournamentController.currentTournamentId
    }
}
