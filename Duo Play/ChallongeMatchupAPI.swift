//
//  ChallongeMatchupAPI.swift
//  Duo Play
//
//  Created by Jordan Davis on 4/19/18.
//  Copyright © 2018 Jordan Davis. All rights reserved.
//

import Foundation

public class ChallongeMatchupAPI : MatchupParserDelegate {
	let challongeBaseUrl = "https://api.challonge.com/v1/"
	let PERSONAL_API_KEY = "dtxaTM8gb4BRN13yLxwlbFmaYcteFxWwLrmAJV3h"
	let TEST_API_KEY = "obUAOsG1dCV2bTpLqPvGy6IIB3MzF4o4TYUkze7M"
	let SPIKEBALL_API_KEY = ""
	let matchupParser = MatchupParser()
	
	var delegate : ChallongeMatchupAPIDelegate?
	
	func getMatchupsForTournament(tournament: Tournament) {
		var challongeMatchups = [[String:Any]]()
		let matchParser = MatchupParser()
		let urlString = challongeBaseUrl + "tournaments/" +
			tournament.url + "/matches.json?" + "api_key=" + PERSONAL_API_KEY
		
		if let myURL = URL(string: urlString) {
			var request = URLRequest(url: myURL)
			request.httpMethod = "GET"
			let session = URLSession.shared; if #available(iOS 11.0, *) {
                session.configuration.waitsForConnectivity = true
            } else {
                // Fallback on earlier versions
            }
			let task = session.dataTask(with: request, completionHandler: { data, response, error -> Void in
				do {
					if let json = try JSONSerialization.jsonObject(with: data!) as? NSArray {
						for obj in json {
							if let match = obj as? [String:Any] {
								if let match = match["match"] {
									challongeMatchups.append(match as! [String : Any])
								}
							}
						}
						
						// Note, you want to update the property inside the async closure to make sure that you don’t update the property from a background thread.
						matchParser.delegate = self
						
						matchParser.parseIncludedMatchups(tournament: tournament, challongeMatchups: challongeMatchups)
					}
				} catch {
					print("create challonge tournament error")
				}
			})
			
			task.resume()
		}
	}
	
	func didParseMatchups() {
		delegate?.didGetChallongeMatchups()
	}
	
	/*
match[scores_csv]	Comma separated set/game scores with player 1 score first (e.g. "1-3,3-0,3-2")
match[winner_id]	The participant ID of the winner or "tie" if applicable (Round Robin and Swiss). NOTE: If you change the outcome of a completed match, all matches in the bracket that branch from the updated match will be reset.
*/
	func updateChallongeMatch(tournament: Tournament, match: BracketMatchup, winnerId: Int) {
		let baseUrl = "https://api.challonge.com/v1/tournaments/" + tournament.url + "/matches/" + String(match.id)
		let apiUrl = ".json?api_key=" + ChallongeTournamentAPI.PERSONAL_API_KEY
		let matchUrl = "&match[scores_csv]="
		let scoreString = String(match.teamOneScores[0]) + "-" + String(match.teamTwoScores[0]) + "," + String(match.teamOneScores[1]) + "-" + String(match.teamTwoScores[1]) + "," + String(match.teamOneScores[2]) + "-" + String(match.teamTwoScores[2])
		let winnerIdString = "&match[winner_id]=" + String(winnerId)
		let finalString = baseUrl + apiUrl + matchUrl + scoreString + winnerIdString
		let squareBracketSet = CharacterSet(charactersIn: "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789?=:&/-._~[]")
		
		let urlString = finalString.addingPercentEncoding(withAllowedCharacters: squareBracketSet)
		
		if let myURL = URL(string: urlString!) {
			var request = URLRequest(url: myURL)
			request.httpMethod = "PUT"
			let session = URLSession.shared; if #available(iOS 11.0, *) {
                session.configuration.waitsForConnectivity = true
            } else {
                // Fallback on earlier versions
            }
			let task = session.dataTask(with: request, completionHandler: { data, response, error -> Void in
				print(error ?? "No Error Here!")
				print(response ?? "No response :(")
				print(data ?? "No data")
//				do {
//					if let json = try JSONSerialization.jsonObject(with: data!) as? [String: Any] {
//						/* json[0] == key"tournament" and value: Any */
//						if let matchupList = json["match"] as? [[String: Any]] {
//							//matchupParser.parseChallongeMatchups(onlineMatchups: matchupList, localTournament: tournament)
//						}
//					}
//				} catch {
//					print("create challonge tournament error")
//				}
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