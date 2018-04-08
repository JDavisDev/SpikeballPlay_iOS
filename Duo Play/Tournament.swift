//
//  Tournament.swift
//  SpikeballPlay
//
//  Created by Jordan Davis on 8/11/17.
//  Copyright © 2017 HoverSlam. All rights reserved.
//

import Foundation
import RealmSwift

class Tournament : Object {
	@objc dynamic public var userID = ""
	@objc dynamic public var isReadOnly = false
	@objc dynamic public var password = ""
    @objc dynamic public var id: Int = 0
	@objc dynamic public var isOnline = false
    @objc dynamic public var name = ""
    @objc dynamic public var url = ""
    @objc dynamic public var tournament_type = ""
    @objc dynamic public var isPrivate = false
    @objc dynamic public var state = ""
    @objc dynamic public var progress_meter = 0
    @objc dynamic public var game_id = 0
    @objc dynamic public var participants_count = 0
    @objc dynamic public var full_challonge_url = ""
    @objc dynamic public var live_image_url = ""
    @objc dynamic public var teams = true
    @objc dynamic public var isPoolPlay = false
    @objc dynamic public var isQuickReport = false
	@objc dynamic public var isPoolPlayFinished = false
    @objc dynamic public var playersPerPool = 8
	@objc dynamic public var swissRounds = 0
	@objc dynamic public var created_date = Date()
	@objc dynamic public var updated_date = Date()
	@objc dynamic public var creatorUserName = ""
    var poolList = List<Pool>()
    var teamList = List<Team>()
    var matchupList = List<BracketMatchup>()
}

/*
 "tournament":
 {
 "id": 1694415,
 "name": "IO Ping Pong Championship",
 "url": "IOTT",
 "description": "",
 "tournament_type": "double elimination",
 "started_at": "2015-06-01T12:10:15.839-04:00",
 "completed_at": "2015-06-25T15:43:46.521-04:00",
 "require_score_agreement": false,
 "notify_users_when_matches_open": true,
 "created_at": "2015-05-29T14:32:58.411-04:00",
 "updated_at": "2015-06-25T15:43:46.659-04:00",
 "state": "complete",
 "open_signup": false,
 "notify_users_when_the_tournament_ends": true,
 "progress_meter": 100,
 "quick_advance": false,
 "hold_third_place_match": false,
 "pts_for_game_win": "0.0",
 "pts_for_game_tie": "0.0",
 "pts_for_match_win": "1.0",
 "pts_for_match_tie": "0.5",
 "pts_for_bye": "1.0",
 "swiss_rounds": 0,
 "private": false,
 "ranked_by": "match wins",
 "show_rounds": true,
 "hide_forum": false,
 "sequential_pairings": false,
 "accept_attachments": false,
 "rr_pts_for_game_win": "0.0",
 "rr_pts_for_game_tie": "0.0",
 "rr_pts_for_match_win": "1.0",
 "rr_pts_for_match_tie": "0.5",
 "created_by_api": false,
 "credit_capped": false,
 "category": null,
 "hide_seeds": false,
 "prediction_method": 0,
 "predictions_opened_at": null,
 "anonymous_voting": false,
 "max_predictions_per_user": 1,
 "signup_cap": null,
 "game_id": 600,
 "participants_count": 16,
 "group_stages_enabled": false,
 "allow_participant_match_reporting": true,
 "teams": false,
 "check_in_duration": null,
 "start_at": null,
 "started_checking_in_at": null,
 "tie_breaks": [
 "match wins vs tied",
 "game wins",
 "points scored"
 ],
 "locked_at": null,
 "event_id": null,
 "public_predictions_before_start_time": null,
 "ranked": null,
 "grand_finals_modifier": null,
 "predict_the_losers_bracket": null,
 "spam": null,
 "ham": null,
 "rr_iterations": null,
 "tournament_registration_id": null,
 "donation_contest_enabled": null,
 "mandatory_donation": null,
 "description_source": "",
 "subdomain": null,
 "full_challonge_url": "http://challonge.com/IOTT",
 "live_image_url": "http://challonge.com/IOTT.svg",
 "sign_up_url": null,
 "review_before_finalizing": true,
 "accepting_predictions": false,
 "participants_locked": true,
 "game_name": "Table Tennis",
 "participants_swappable": false,
 "team_convertable": false,
 "group_stages_were_started": false
 }
 */
