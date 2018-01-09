//
//  Team.swift
//  SpikeballPlay
//
//  Created by Jordan Davis on 8/11/17.
//  Copyright © 2017 HoverSlam. All rights reserved.
//

import Foundation
import RealmSwift
import Realm

public class Team : Object {
    @objc dynamic public var seed = 1
    @objc dynamic public var id = 1
    @objc dynamic public var bracketRound = 1
    @objc dynamic public var name = ""
    @objc dynamic var pool: Pool?
    @objc dynamic public var wins = 0
    @objc dynamic public var losses = 0
    @objc dynamic public var pointsFor: Int = 0
    @objc dynamic public var pointsAgainst: Int = 0
    @objc dynamic public var division = ""
    @objc dynamic public var isEliminated = false
    
    var poolPlayGameList = List<PoolPlayMatchup>()
}
