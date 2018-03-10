//
//  BracketMatchup.swift
//  Duo Play
//
//  Created by Jordan Davis on 12/31/17.
//  Copyright © 2017 Jordan Davis. All rights reserved.
//

import Foundation
import RealmSwift

class BracketMatchup : Object {
    @objc dynamic var teamOne: Team?
    @objc dynamic var teamTwo: Team?
    var teamOneScores = List<Int>()
    var teamTwoScores = List<Int>()
    @objc dynamic public var round = 1
    @objc dynamic public var round_position = 1
    @objc dynamic public var division = ""
    @objc dynamic public var isReported = false
    @objc dynamic public var tournament_id: Int = 0
}
