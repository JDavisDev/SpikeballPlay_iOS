//
//  TeamsController.swift
//  SpikeballPlay
//
//  Created by Jordan Davis on 8/11/17.
//  Copyright © 2017 HoverSlam. All rights reserved.
//

import Foundation

class TeamsViewController {
    static var teamsList = [Team]()
    
    func addTeam(name: String) {
        let pool = getAvailablePool()
        let team = Team(name: name, pool: pool)
        TeamsViewController.teamsList.append(team)
        pool.addTeamToPool(team: team)
    }
    
    func getAvailablePool() -> Pool {
        for pool in PoolsViewController.poolsList {
            if pool.teams.count < 8 {
                return pool
            }
        }
        
        // no available pool, create one, append it, and return it
        let pool = Pool()
        PoolsViewController.poolsList.append(pool)
        return pool
    }
    
    
}
