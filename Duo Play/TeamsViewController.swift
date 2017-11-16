//
//  TeamsController.swift
//  SpikeballPlay
//
//  Created by Jordan Davis on 8/11/17.
//  Copyright © 2017 HoverSlam. All rights reserved.
//

import Foundation
import RealmSwift

class TeamsViewController {
    
    let realm = try! Realm()
    let tournamentController = TournamentController()
    
    let poolController = PoolsController()
    
    
    func addTeam(team: Team) {
        let tournament = TournamentController.getCurrentTournament()
        let newPool = getAvailablePool()
        
        try! realm.write() {
            realm.add(team)
            realm.add(newPool)
            tournament.poolList.append(newPool)
            newPool.teamList.append(team)
        }
    }
    
    func getAvailablePool() -> Pool {
        let tournament = TournamentController.getCurrentTournament()
        for pool in tournament.poolList {
            if pool.teamList.count < 8 {
                return pool
            }
        }
        
        // no available pool, create one, append it, and return it
        let poolCount = tournament.poolList.count
        let name = String(format: "%c", poolCount + 65) as String
        let pool = Pool()
        pool.name = name
        pool.teamList = List<Team>()
        pool.division = "Advanced"
        pool.isPowerPool = false
        pool.matchupList = List<PoolPlayMatchup>()
        
        return pool
    }
    
    
}
