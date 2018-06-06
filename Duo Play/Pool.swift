//
//  Pool.swift
//  SpikeballPlay
//
//  Created by Jordan Davis on 8/11/17.
//  Copyright © 2017 HoverSlam. All rights reserved.
//

import Foundation
import RealmSwift

public class Pool : Object {
    @objc dynamic public var name = ""
    @objc dynamic var division = ""
    @objc dynamic var isPowerPool = false
	@objc dynamic var tournament_id: Int = 0
	@objc dynamic var isFinished = false
	@objc dynamic var isStarted = false
    var matchupList = List<PoolPlayMatchup>()
	var teamList = List<Team>()
	
	var dictionary: [String: Any] {
		return [
			"name": name,
			"tournament_id": tournament_id,
			"isFinished": isFinished,
			"isStarted": isStarted,
			"isPowerPool": isPowerPool,
			"division": division
		]
	}
}
