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
    let teamList: List<Team>
    
    init() {
        tournament = TournamentController.getCurrentTournament()
        poolList = tournament.poolList
        teamList = tournament.teamList
    }
    
    func startBracket() {
        seedTeams()
    }
    
    func seedTeams() {
        try! realm.write {
            var array = Array(teamList)
            teamList.removeAll()
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
                teamList.append(team)
            }
        }
        
        createMatchups()
    }
    
    func createMatchups() {
        for i in 1...teamList.count / 2 {
            try! realm.write {
                let game = BracketMatchup()
            
                game.teamOne = teamList[i - 1]
                game.teamTwo = teamList[teamList.count - i]
                game.division = "Advanced"
                game.round = 1
                
                realm.add(game)
                tournament.matchupList.append(game)
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
