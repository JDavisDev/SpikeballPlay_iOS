//
//  Pool.swift
//  SpikeballPlay
//
//  Created by Jordan Davis on 8/11/17.
//  Copyright © 2017 HoverSlam. All rights reserved.
//

import Foundation

class Pool {
    var name: String
    var teams = [Team]()
    
    init() {
        self.name = "Pool"
    }
    
    func addTeamToPool(team: Team) {
        self.teams.append(team)
    }
}
