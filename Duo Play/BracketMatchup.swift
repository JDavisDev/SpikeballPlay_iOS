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
	@objc dynamic var id: Int = 0
	@objc dynamic var challongeId: Int = 0
	@objc dynamic var teamOne: Team?
	@objc dynamic var teamTwo: Team?
    var teamOneScores = List<Int>()
    var teamTwoScores = List<Int>()
    @objc dynamic public var round = 1
    @objc dynamic public var round_position = 1
    @objc dynamic public var division = ""
    @objc dynamic public var isReported = false
    @objc dynamic public var tournament_id: Int = 0
	
	override static func primaryKey() -> String? {
		return "id"
	}
	
	// creating a tournament based on incoming firebase/challonge datas
	convenience init(dictionary: [String : Any]) {
		self.init()
		id = dictionary["id"] as! Int
		challongeId = dictionary["challonge_id"] as! Int
		teamOne = Team()
		teamTwo = Team()
		teamOne?.id = dictionary["team_one_id"] as! Int
		teamTwo?.id = dictionary["team_two_id"] as! Int
		round = dictionary["round"] as! Int
		round_position = dictionary["round_position"] as! Int
		division = dictionary["division"] as! String
		isReported = dictionary["is_reported"] as! Bool
		tournament_id = dictionary["tournament_id"] as! Int
		teamOneScores = dictionary["team_one_scores"] as! List<Int>
		teamTwoScores = dictionary["team_two_scores"] as! List<Int>
	}
	
	// returned to post to firebase
	var dictionary: [String: Any] {
		return [
			"id": id,
			"teamOneId" : teamOne?.id ?? -1,
			"teamTwoId" : teamTwo?.id ?? -1,
			"teamOneScores": Array(teamOneScores),
			"teamTwoScores": Array(teamTwoScores),
			"round": round,
			"round_position" : round_position,
			"division" : division,
			"isReported" : isReported,
			"tournament_id": tournament_id,
			"challonge_id":challongeId
		]
	}
}
