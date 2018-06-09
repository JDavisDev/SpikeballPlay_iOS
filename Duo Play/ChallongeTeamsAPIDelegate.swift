//
//  ChallongeTeamsAPIDelegate.swift
//  Duo Play
//
//  Created by Jordan Davis on 4/20/18.
//  Copyright © 2018 Jordan Davis. All rights reserved.
//

import Foundation

protocol ChallongeTeamsAPIDelegate {
	func didPostChallongeParticipant(team: Team, teamObject: [String:Any], success: Bool)
}