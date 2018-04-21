//
//  TeamParser.swift
//  Duo Play
//
//  Created by Jordan Davis on 4/20/18.
//  Copyright © 2018 Jordan Davis. All rights reserved.
//

import Foundation
import RealmSwift

class TeamParser : ChallongeTeamsAPIDelegate {
	
	
	func didPostChallongeParticipant(team: Team, teamObject: [String:Any]) {
		Realm.asyncOpen() { realm, error in
			if let realm = realm {
				// Realm successfully opened
				try! realm.write {
					team.challonge_participant_id = teamObject["id"] as! Int
					team.challonge_group_id = teamObject["group_id"] as! Int
					team.challonge_tournament_id = teamObject["tournament_id"] as! Int
				}
			} else if error != nil {
				// Handle error that occurred while opening the Realm
			}
		}
	}
}

/*
CHALLONGE POST RESPONSE
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
