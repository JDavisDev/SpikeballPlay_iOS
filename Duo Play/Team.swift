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
	@objc dynamic var pool: Pool? = Pool()
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
		name = dictionary["name"] as? String ?? ""
		id = dictionary["id"] as? Int ?? 0
		seed = dictionary["seed"] as? Int ?? 0
		isEliminated = dictionary["isEliminated"] as? Bool ?? false
		wins = dictionary["wins"] as? Int ?? 0
		losses = dictionary["losses"] as? Int ?? 0
		pointsFor = dictionary["pointsFor"] as? Int ?? 0
		pointsAgainst = dictionary["pointsAgainst"] as? Int ?? 0
		tournament_id = dictionary["tournament_id"] as? Int ?? 0
		pool = Pool()
		pool?.name = dictionary["pool_name"] as? String ?? ""
		pool?.id = dictionary["pool_id"] as? Int ?? 0
		//let roundsArray = (dictionary["bracketRounds"] as? [Int])
		bracketRounds = dictionary["bracketRounds"] as? List<Int> ?? List<Int>()
		bracketVerticalPositions = dictionary["bracketRounds"] as? List<Int> ?? List<Int>()
		//bracketRounds.append(objectsIn: roundsArray)
		//let vertArray = dictionary["bracketVerticalPositions"] as? [Int]
		//bracketVerticalPositions.append(objectsIn: vertArray)
	}
	
	var dictionary: [String: Any] {
		return [
			"name": name,
			"id": id,
			"seed":seed,
			"isEliminated":isEliminated,
			"wins":wins,
			"losses":losses,
			"pointsFor":pointsFor,
			"pointsAgainst":pointsAgainst,
			"tournament_id":tournament_id,
			"pool_name":pool!.name,
			"pool_id":pool!.id,
			"bracketRounds":Array(bracketRounds),
			"bracketVerticalPositions":Array(bracketVerticalPositions)
		]
	}
}
