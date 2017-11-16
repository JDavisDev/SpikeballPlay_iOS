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
    let realm = try! Realm()
    
//    func saveTournaments() {
//        tournamentDAO.save()
//    }
//    
//    func getTournaments() -> [Tournament] {
//        tournamentDAO.getTournamentList()
//    }
    
    static func getCurrentTournament() -> Tournament {
        let realm = try! Realm()
        let results = realm.objects(Tournament.self).filter("uuid = '" + TournamentController.getCurrentTournamentId() + "'").first
        return results!
    }
    
    static func setTournamentId(uuid: String) {
        TournamentController.currentTournamentId = uuid
    }
    
    static func getCurrentTournamentId() -> String {
        return TournamentController.currentTournamentId
    }
}
