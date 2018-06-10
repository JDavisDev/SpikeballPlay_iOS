//
//  MatchupParser.swift
//  Duo Play
//
//  Created by Jordan Davis on 4/19/18.
//  Copyright © 2018 Jordan Davis. All rights reserved.
//

import Foundation
import RealmSwift

public class MatchupParser {
	var delegate : MatchupParserDelegate?
	weak var db: DBManager?
	
//	func parseIncludedMatchups(tournament: Tournament, challongeMatchups: [[String:Any]]) {
//		// assign retrieved matchups from challonge to our local matchups so we can report them later!
//		let db = DBManager()
//		db.beginWrite()
//		for matchup in challongeMatchups {
//			let localMatchup = getRealmMatchupFromChallongeData(tournament: tournament, data: matchup)
//			// same match... parse!
//			// basically, I'm reassigning the challonge IDs to overwrite these ids so they match
//			localMatchup.id = matchup["id"] as! Int
//			localMatchup.challongeId = matchup["id"] as! Int
//			localMatchup.tournament_id = matchup["tournament_id"] as! Int
//
//			db.updateRealmObject(object: localMatchup)
//		}
//		
//		db.commitWrite()
//		self.delegate?.didParseMatchups()
//	}
}

/**
CHALLONGE MATCH INDEX RESPONSE
{
"match": {
"attachment_count": null,
"created_at": "2015-01-19T16:57:17-05:00",
"group_id": null,
"has_attachment": false,
"id": 23575258,
"identifier": "A",
"location": null,
"loser_id": null,
"player1_id": 16543993,
"player1_is_prereq_match_loser": false,
"player1_prereq_match_id": null,
"player1_votes": null,
"player2_id": 16543997,
"player2_is_prereq_match_loser": false,
"player2_prereq_match_id": null,
"player2_votes": null,
"round": 1,
"scheduled_time": null,
"started_at": "2015-01-19T16:57:17-05:00",
"state": "open",
"tournament_id": 1086875,
"underway_at": null,
"updated_at": "2015-01-19T16:57:17-05:00",
"winner_id": null,
"prerequisite_match_ids_csv": "",
"scores_csv": ""
}
*/
