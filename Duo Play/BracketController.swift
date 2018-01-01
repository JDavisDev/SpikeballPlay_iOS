//
//  BracketController.swift
//  Duo Play
//
//  Created by Jordan Davis on 12/31/17.
//  Copyright © 2017 Jordan Davis. All rights reserved.
//

import Foundation
import RealmSwift

class BracketController {
    let realm = try! Realm()
    let tournament: Tournament
    let poolList: List<Pool>
    
    init() {
        tournament = TournamentController.getCurrentTournament()
        poolList = tournament.poolList
    }
    
    func startBracket() {
        seedTeams()
    }
    
    func seedTeams() {
        try! realm.write {
            var array = Array(tournament.teamList)
            tournament.teamList.removeAll()
            
            // seed the teams here based on wins, then point diff, then name
            array.sort {
                if $0.wins == $1.wins {
                    if ($0.pointsFor - $0.pointsAgainst) == ($1.pointsFor - $1.pointsAgainst) {
                        return $0.name < $1.name
                    } else {
                        return ($0.pointsFor - $0.pointsAgainst) > ($1.pointsFor - $1.pointsAgainst)
                    }
                } else {
                    return $0.wins > $1.wins
                }
            }
            
            // we've sorted/seeded, not re add
            for team in array {
                tournament.teamList.append(team)
            }
        }
        
        createMatchups()
    }
    
    func createMatchups() {
        if tournament.matchupList.count == 0 {
            for i in 1...tournament.teamList.count / 2 {
                try! realm.write {
                    let game = BracketMatchup()
            
                    game.teamOne = tournament.teamList[i - 1]
                    game.teamTwo = tournament.teamList[tournament.teamList.count - i]
                    game.division = "Advanced"
                    game.round = 1
                
                    realm.add(game)
                    tournament.matchupList.append(game)
                }
            }
        }
    }
    
    func updateMatchups() {
        
    }
    
    func drawBracket() {
        
    }
    
    func submitMatch() {
        
    }
    
    func updateSeeds() {
        
    }
}
