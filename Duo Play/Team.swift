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
    @objc dynamic public var name = ""
    @objc dynamic var pool = Pool()
	@objc dynamic public var isCheckedIn = false
    @objc dynamic public var wins = 0
    @objc dynamic public var losses = 0
    @objc dynamic public var pointsFor: Int = 0
    @objc dynamic public var pointsAgainst: Int = 0
    @objc dynamic public var division = ""
    @objc dynamic public var isEliminated = false
    @objc dynamic public var tournament_id: Int = 0
	@objc dynamic public var challonge_tournament_id: Int = 0
	@objc dynamic public var final_rank: Int = 0
	@objc dynamic public var challonge_group_id: Int = 0
	@objc dynamic public var challonge_participant_id: Int = 0
    var bracketRounds = List<Int>()
    var bracketVerticalPositions = List<Int>()
    var poolPlayGameList = List<PoolPlayMatchup>()
	
	convenience init(dictionary: [String : Any]) {
		self.init()
		name = dictionary["name"] as! String
		id = dictionary["id"] as! Int
		seed = dictionary["seed"] as! Int
		isEliminated = dictionary["isEliminated"] as! Bool
		wins = dictionary["wins"] as! Int
		losses = dictionary["losses"] as! Int
		pointsFor = dictionary["pointsFor"] as! Int
		pointsAgainst = dictionary["pointsAgainst"] as! Int
		tournament_id = dictionary["tournament_id"] as! Int
		pool.name = dictionary["poolName"] as! String
		let roundsArray = (dictionary["bracketRounds"] as! [Int])
		bracketRounds.append(objectsIn: roundsArray)
		let vertArray = dictionary["bracketVerticalPositions"] as! [Int]
		bracketVerticalPositions.append(objectsIn: vertArray)
	}
	
	var dictionary: [String: Any] {
		return [
			"name": name,
			"id": id
		]
	}
}
