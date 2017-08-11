//
//  TournamentsHomeController.swift
//  SpikeballPlay
//
//  Created by Jordan Davis on 8/11/17.
//  Copyright © 2017 HoverSlam. All rights reserved.
//

import Foundation

class TournamentsHomeViewController {
    
    static var tournamentsList = [Tournament]()
    
    // CHECK FOR DUPLICATES
    
    func addTournament(tournamentName: String) {
        let tournament = Tournament(name: tournamentName)
        TournamentsHomeViewController.tournamentsList.append(tournament)
    }
}
