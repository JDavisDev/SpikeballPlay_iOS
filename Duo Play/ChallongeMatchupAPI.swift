//
//  ChallongeMatchupAPI.swift
//  Duo Play
//
//  Created by Jordan Davis on 4/19/18.
//  Copyright © 2018 Jordan Davis. All rights reserved.
//

import Foundation

public class ChallongeMatchupAPI {
	let challongeBaseUrl = "https://api.challonge.com/v1/"
	
	var delegate : ChallongeMatchupAPIDelegate?
	
	func getMatchupsForTournament(tournament: Tournament) {
		var challongeMatchups = [[String:Any]]()
		let urlString = challongeBaseUrl + "tournaments/" +
			tournament.url + "/matches.json?" + "api_key=" + ChallongeUtil.ROUNDNET_API_KEY
		
		if let myURL = URL(string: urlString) {
			var request = URLRequest(url: myURL)
			request.httpMethod = "GET"
			let session = URLSession.shared;
			session.configuration.timeoutIntervalForResource = TimeInterval(10)
			if #available(iOS 11.0, *) {
                session.configuration.waitsForConnectivity = true
            } else {
                // Fallback on earlier versions
            }
			let task = session.dataTask(with: request, completionHandler: { data, response, error -> Void in
				do {
					if error != nil || data == nil { return }
					if let json = try JSONSerialization.jsonObject(with: data!) as? NSArray {
						for obj in json {
							if let matches = obj as? [String:Any] {
								if let match = matches["match"] as? [String:Any] {
									challongeMatchups.append(match)
								}
							}
						}
						
						self.delegate?.didGetChallongeMatchups(challongeMatchups: challongeMatchups)
					}
				} catch {
					print("create challonge tournament error")
				}
			})
			
			task.resume()
		}
	}
	
	/*
match[scores_csv]	Comma separated set/game scores with player 1 score first (e.g. "1-3,3-0,3-2")
match[winner_id]	The participant ID of the winner or "tie" if applicable (Round Robin and Swiss). NOTE: If you change the outcome of a completed match, all matches in the bracket that branch from the updated match will be reset.
*/
	func updateChallongeMatch(tournament: Tournament, match: BracketMatchup, winnerId: Int) {
		let baseUrl = "https://api.challonge.com/v1/tournaments/" + tournament.url + "/matches/" + String(match.challongeId)
		let apiUrl = ".json?api_key=" + ChallongeUtil.ROUNDNET_API_KEY
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
				// let's check the response to verify it was all good.
				if error == nil  {
					do {
						if let httpResponse = response as? HTTPURLResponse {
							let statusCode = httpResponse.statusCode
							
							if statusCode == 200 {
								self.delegate?.didPostGameToChallonge(success: true)
								print("Challonge match submission success")
							} else {
								self.delegate?.didPostGameToChallonge(success: false)
							}
							self.delegate?.didPostGameToChallonge(success: false)
						}
						self.delegate?.didPostGameToChallonge(success: false)
					}
				} else {
					self.delegate?.didPostGameToChallonge(success: false)
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
