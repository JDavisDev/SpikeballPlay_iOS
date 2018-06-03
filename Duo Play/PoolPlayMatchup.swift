//
//  PoolPlayMatchup.swift
//  Duo Play
//
//  Created by Jordan Davis on 9/4/17.
//  Copyright © 2017 Jordan Davis. All rights reserved.
//

import Foundation
import RealmSwift

public class PoolPlayMatchup : Object {
    @objc dynamic var teamOne: Team?
    @objc dynamic var teamTwo: Team?
    @objc dynamic public var round = 1
    @objc dynamic public var division = ""
    @objc dynamic public var isReported = false
	@objc dynamic public var tournament_id: Int = 0
	var teamOneScores = List<Int>()
	var teamTwoScores = List<Int>()
}
