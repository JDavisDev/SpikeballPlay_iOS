//
//  TournamentsManager.swift
//  Duo Play
//
//  Created by Jordan Davis on 9/1/17.
//  Copyright © 2017 Jordan Davis. All rights reserved.
//

import Foundation

class TournamentsManager {
    var tournamentsList = [Tournament]()
    let tournamentDAO = TournamentDAO()
    
    func addTournament(tournament: Tournament) {
        tournamentsList.append(tournament)
    }
    
//    func saveTournaments() {
//        tournamentDAO.save()
//    }
//    
//    func getTournaments() -> [Tournament] {
//        tournamentDAO.getTournamentList()
//    }
}
