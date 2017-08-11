//
//  TeamsController.swift
//  SpikeballPlay
//
//  Created by Jordan Davis on 8/11/17.
//  Copyright © 2017 HoverSlam. All rights reserved.
//

import Foundation

class TeamsViewController {
    
    func addTeam(name: String) {
        let team = Team(name: name)
        addTeamToPool(team: team)
    }
    
    func addTeamToPool(team: Team) {
        // fetch next available pool with < 8 teams
        for pool in PoolsViewController.poolsList {
            pool.addTeamToPool(team: team)
        }
    }
}
