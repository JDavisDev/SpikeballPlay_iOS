//
//  ChallongeAPIDelegate.swift
//  Duo Play
//
//  Created by Jordan Davis on 4/19/18.
//  Copyright © 2018 Jordan Davis. All rights reserved.
//

import Foundation

@objc protocol ChallongeTournamentAPIDelegate {
	@objc optional func didCreateChallongeTournament(onlineTournament: [String: Any]?, localTournament: Tournament?, success: Bool)
	@objc optional func didStartChallongeTournament(tournament: Tournament, challongeMatchups: [[String: Any]], success: Bool)
	@objc optional func didGetParticipantsFromTournament(participants: [[String:Any]]?, success: Bool)
}
