//
//  TournamentDAODelegate.swift
//  Duo Play
//
//  Created by Jordan Davis on 3/28/18.
//  Copyright © 2018 Jordan Davis. All rights reserved.
//

import Foundation

protocol TournamentDAODelegate {
	func didGetOnlineTournaments(onlineTournamentList: [Tournament])
	func didGetOnlineTournamentData()
}
