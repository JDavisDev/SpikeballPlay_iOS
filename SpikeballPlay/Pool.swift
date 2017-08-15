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
    
    init(name: String) {
        self.name = "Pool \(name)"
    }
    
    func addTeamToPool(team: Team) {
        self.teams.append(team)
    }
}
