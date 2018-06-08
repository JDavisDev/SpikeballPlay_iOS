//
//  ChallongeAPIDelegate.swift
//  Duo Play
//
//  Created by Jordan Davis on 4/19/18.
//  Copyright © 2018 Jordan Davis. All rights reserved.
//

import Foundation

protocol ChallongeTournamentAPIDelegate {
	func didCreateChallongeTournament(onlineTournament: [String: Any]?, localTournament: Tournament?, success: Bool)
}
