//
//  ChallongeMatchupAPI.swift
//  Duo Play
//
//  Created by Jordan Davis on 4/19/18.
//  Copyright © 2018 Jordan Davis. All rights reserved.
//

import Foundation

public class ChallongeMatchupAPI {
	static let challongeBaseUrl = "https://api.challonge.com/v1/"
	static let PERSONAL_API_KEY = "dtxaTM8gb4BRN13yLxwlbFmaYcteFxWwLrmAJV3h"
	static let TEST_API_KEY = "obUAOsG1dCV2bTpLqPvGy6IIB3MzF4o4TYUkze7M"
	static let SPIKEBALL_API_KEY = ""
	
	let matchupParser = MatchupParser()
	
	func getMatchupsForTournament(tournament: Tournament) {
		let urlString = ChallongeMatchupAPI.challongeBaseUrl + "tournaments/" +
			tournament.url + "/matches.json?"
		
		if let myURL = URL(string: urlString) {
			var request = URLRequest(url: myURL)
			request.httpMethod = "GET"
			let session = URLSession.shared
			let task = session.dataTask(with: request, completionHandler: { data, response, error -> Void in
				do {
					if let json = try JSONSerialization.jsonObject(with: data!) as? [String: Any] {
						/* json[0] == key"tournament" and value: Any */
						if let matchupList = json["match"] as? [[String: Any]] {
							//matchupParser.parseChallongeMatchups(onlineMatchups: matchupList, localTournament: tournament)
						}
					}
				} catch {
					print("create challonge tournament error")
				}
			})
			
			task.resume()
		}
	}
}

/** RESPONSE
{
"match": {
"attachment_count": null,
"created_at": "2015-01-19T16:57:17-05:00",
"group_id": null,
"has_attachment": false,
"id": 23575259,
"identifier": "B",
"location": null,
"loser_id": null,
"player1_id": 16543994,
"player1_is_prereq_match_loser": false,
"player1_prereq_match_id": null,
"player1_votes": null,
"player2_id": 16543996,
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
},
{
"match": {
"attachment_count": null,
"created_at": "2015-01-19T16:57:17-05:00",
"group_id": null,
"has_attachment": false,
"id": 23575260,
"identifier": "C",
"location": null,
"loser_id": null,
"player1_id": null,
"player1_is_prereq_match_loser": false,
"player1_prereq_match_id": 23575258,
"player1_votes": null,
"player2_id": null,
"player2_is_prereq_match_loser": false,
"player2_prereq_match_id": 23575259,
"player2_votes": null,
"round": 2,
"scheduled_time": null,
"started_at": null,
"state": "pending",
"tournament_id": 1086875,
"underway_at": null,
"updated_at": "2015-01-19T16:57:17-05:00",
"winner_id": null,
"prerequisite_match_ids_csv": "23575258,23575259",
"scores_csv": ""
}
*/
