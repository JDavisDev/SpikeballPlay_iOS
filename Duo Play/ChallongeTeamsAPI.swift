//
//  File.swift
//  Duo Play
//
//  Created by Jordan Davis on 4/20/18.
//  Copyright © 2018 Jordan Davis. All rights reserved.
//

import Foundation
import RealmSwift

class ChallongeTeamsAPI {
	let realm = try! Realm()
	var delegate: ChallongeTeamsAPIDelegate?
	let challongeBaseUrl = "https://api.challonge.com/v1/tournaments/"
	let PERSONAL_API_KEY = "dtxaTM8gb4BRN13yLxwlbFmaYcteFxWwLrmAJV3h"
	let TEST_API_KEY = "obUAOsG1dCV2bTpLqPvGy6IIB3MzF4o4TYUkze7M"
	let SPIKEBALL_API_KEY = ""
	
	func createChallongeParticipant(tournament: Tournament, team: Team) {
		let teamName = team.name
		let finalString = challongeBaseUrl + tournament.url +
			"/participants.json?api_key=" + PERSONAL_API_KEY +
			"&participant[name]=" + teamName + "&" + "participant[seed]=" + String(team.seed)
		
		let squareBracketSet = CharacterSet(charactersIn: "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789?=:&/-._~[]")
		
		let urlString = finalString.addingPercentEncoding(withAllowedCharacters: squareBracketSet)
		if let myURL = URL(string: urlString!) {
			var request = URLRequest(url: myURL)
			request.httpMethod = "POST"
			let session = URLSession.shared; if #available(iOS 11.0, *) {
                session.configuration.waitsForConnectivity = true
            } else {
                // Fallback on earlier versions
            }
			let task = session.dataTask(with: request, completionHandler: { data, response, error -> Void in
				do {
					if let json = try JSONSerialization.jsonObject(with: data!) as? [String: Any] {
						/* json[0] == key"tournament" and value: Any */
						if let teamObject = json["participant"] as? [String: Any] {
							// send to delegate to parse and save that dude
							self.delegate?.didPostChallongeParticipant(team: team, teamObject: teamObject)
						}
					}
				} catch {
					print("create challonge team error")
				}
			})
			
			task.resume()
		}
	}
}

/*
POST RESPONSE
{
"participant": {
"active": true,
"checked_in_at": null,
"created_at": "2015-01-19T16:54:40-05:00",
"final_rank": null,
"group_id": null,
"icon": null,
"id": 16543993,
"invitation_id": null,
"invite_email": null,
"misc": null,
"name": "Participant #1",
"on_waiting_list": false,
"seed": 1,
"tournament_id": 1086875,
"updated_at": "2015-01-19T16:54:40-05:00",
"challonge_username": null,
"challonge_email_address_verified": null,
"removable": true,
"participatable_or_invitation_attached": false,
"confirm_remove": true,
"invitation_pending": false,
"display_name_with_invitation_email_address": "Participant #1",
"email_hash": null,
"username": null,
"attached_participatable_portrait_url": null,
"can_check_in": false,
"checked_in": false,
"reactivatable": false
}
*/
