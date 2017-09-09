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
    var division: Division
    var isPowerPool = false
    public var matchupList = [PoolPlayMatchup]()
    
    init(name: String) {
        self.name = "Pool \(name)"
        self.division = Division.Advanced
    }
    
    func addTeamToPool(team: Team) {
        team.id = self.teams.count + 1
        self.teams.append(team)
    }
}
