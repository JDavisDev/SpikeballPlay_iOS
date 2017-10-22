//
//  PoolPlayMatchup.swift
//  Duo Play
//
//  Created by Jordan Davis on 9/4/17.
//  Copyright © 2017 Jordan Davis. All rights reserved.
//

import Foundation

class PoolPlayMatchup {
    var teamOne: Team
    var teamTwo: Team
    var round: Int
    public var isReported = false
    
    init(round: Int, teamOne: Team, teamTwo: Team) {
        self.round = round
        self.teamOne = teamOne
        self.teamTwo = teamTwo
    }
}
