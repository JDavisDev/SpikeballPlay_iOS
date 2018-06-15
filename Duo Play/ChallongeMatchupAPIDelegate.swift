//
//  ChallongeMatchupAPIDelegate.swift
//  Duo Play
//
//  Created by Jordan Davis on 4/19/18.
//  Copyright © 2018 Jordan Davis. All rights reserved.
//

import Foundation

protocol ChallongeMatchupAPIDelegate {
	func didPostGameToChallonge(success: Bool)
	func didGetChallongeMatchups(challongeMatchups: [[String:Any]])
}
