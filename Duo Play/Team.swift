//
//  Team.swift
//  SpikeballPlay
//
//  Created by Jordan Davis on 8/11/17.
//  Copyright © 2017 HoverSlam. All rights reserved.
//

import Foundation

class Team {
    var seed = 1
    var id = 1
    var name: String
    var pool: Pool
    var division: Division
    
    init(name: String, pool: Pool) {
        self.name = name
        self.pool = pool
        self.division = Division.Advanced
    }
    
    func getPool() -> Pool {
        return self.pool
    }
}
