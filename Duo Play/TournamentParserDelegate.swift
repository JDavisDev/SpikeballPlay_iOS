//
//  TournamentParserDelegate.swift
//  Duo Play
//
//  Created by Jordan Davis on 3/25/18.
//  Copyright © 2018 Jordan Davis. All rights reserved.
//

import Foundation

protocol TournamentParserDelegate {
	func didGetOnlineTournaments(onlineTournamentList: [Tournament])
	func didParseTournamentData()
}
