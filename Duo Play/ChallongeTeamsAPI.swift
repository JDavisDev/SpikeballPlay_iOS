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
	
	func createChallongeParticipant(tournament: Tournament, team: Team) {
		var participants = [[String:Any]]()
		let finalString = challongeBaseUrl + tournament.url +
			"/participants/bulk_add.json?api_key=" + ChallongeUtil.ROUNDNET_API_KEY + getParticipantsBulkUrl(tournament: tournament)

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
					if error != nil || data == nil {
						self.delegate?.didBulkAddParticipants(participants: nil, success: false)
						
					}
					
					if let json = try JSONSerialization.jsonObject(with: data!) as? NSArray {
						for obj in json {
							if let teams = obj as? [String:Any] {
								if let team = teams["participant"] {
									participants.append(team as! [String : Any])
								}
							}
						}
						
						if participants.count > 0 {
							self.delegate?.didBulkAddParticipants(participants: nil, success: false)
						} else {
							// send to delegate to parse and save that dude
							self.delegate?.didBulkAddParticipants(participants: participants, success: true)
						}
					} else {
						self.delegate?.didBulkAddParticipants(participants: nil, success: false)
					}
				} catch {
					print("create challonge team error")
					self.delegate?.didBulkAddParticipants(participants: nil, success: false)
				}
			})
			
			task.resume()
		}
	}
	
	
	
	func getParticipantsBulkUrl(tournament: Tournament) -> String {
		var returnString = ""
		
		for team in tournament.teamList {
			returnString.append("&participants[][name]=\(team.name)")
		}
		
		return returnString
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
