//
//  LosersBracketViewController.swift
//  Duo Play
//
//  Created by Jordan Davis on 6/11/18.
//  Copyright © 2018 Jordan Davis. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift
import Crashlytics
import Firebase

class LosersBracketViewController: UIViewController, UIScrollViewDelegate, LiveBracketViewDelegate {
	
	var pinch = UIPinchGestureRecognizer()
	
	@IBOutlet weak var scrollView: UIScrollView!
	@IBOutlet weak var activityIndicator: UIActivityIndicatorView!
	let challongeMatchupAPI = ChallongeMatchupAPI()
	let realm = try! Realm()
	let challongeTournamentAPI = ChallongeTournamentAPI()
	let teamsController = TeamsController()
	var tournament = Tournament()
	// used for quick report
	var selectedMatchup = BracketMatchup()
	var bracketCellWidth = 76
	var labelWidth = 68
	
	let bracketController = BracketController()
	
	var bracketCells = [UIView]()
	var bracketDict: [UIView : (x: Int, y: Int)] = [:]
	var bracketMatchCount = 0
	var roundCount = 0
	var byeCount = 0
	var teamCount = 0
	var frameWidth: CGFloat = 0
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(true)
		initBracketView()
		Answers.logContentView(withName: "Bracket Page View",
							   contentType: "Bracket Page View",
							   contentId: "9",
							   customAttributes: [:])
		
		Analytics.logEvent("Live_Bracket_View_Viewed", parameters: nil)
	}
	
	func initBracketView() {
		
	}
	
	
	// BRACKET CREATION DELEGATE
	func bracketCreated(isUpdateMatchups: Bool) {
		
	}
}
