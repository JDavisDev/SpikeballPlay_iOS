////
////  LosersBracketViewController.swift
////  Duo Play
////
////  Created by Jordan Davis on 6/11/18.
////  Copyright © 2018 Jordan Davis. All rights reserved.
////
//
//import Foundation
//import UIKit
//import RealmSwift
//import Crashlytics
//import Firebase
//
//class LosersBracketViewController: UIViewController, UIScrollViewDelegate, LiveBracketViewDelegate {
//	
//	var pinch = UIPinchGestureRecognizer()
//	
//	@IBOutlet weak var scrollView: UIScrollView!
//	@IBOutlet weak var activityIndicator: UIActivityIndicatorView!
//	let challongeMatchupAPI = ChallongeMatchupAPI()
//	let realm = try! Realm()
//	let challongeTournamentAPI = ChallongeTournamentAPI()
//	let teamsController = TeamsController()
//	let bracketController = LosersBracketController()
//	
//	var losersTeamList = List<Team>()
//	var tournament = Tournament()
//	var selectedMatchup = BracketMatchup()
//	var bracketCellWidth = 76
//	var labelWidth = 68
//	var bracketCells = [UIView]()
//	var bracketDict: [UIView : (x: Int, y: Int)] = [:]
//	var bracketMatchCount = 0
//	var roundCount = 0
//	var byeCount = 0
//	var teamCount = 0
//	var frameWidth: CGFloat = 0
//	
//	override func viewWillAppear(_ animated: Bool) {
//		super.viewWillAppear(true)
//		initBracketView()
//		Answers.logContentView(withName: "Losers Bracket Page View",
//							   contentType: "Losers Bracket Page View",
//							   contentId: "99",
//							   customAttributes: [:])
//		
//		Analytics.logEvent("Losers_Live_Bracket_View_Viewed", parameters: nil)
//	}
//	
//	func initBracketView() {
//		activityIndicator?.startAnimating()
//		clearView()
//		
//		self.view.backgroundColor = UIColor.black
//		self.view.addSubview(scrollView)
//		bracketController.bracketControllerDelegate = self
//		self.scrollView.delegate = self
//		self.scrollView.addGestureRecognizer(pinch)
//		//pinch = UIPinchGestureRecognizer(target: self, action: #selector(self.pinch(sender:)))
//		self.scrollView.minimumZoomScale = 1
//		self.scrollView.maximumZoomScale = 10
//		self.scrollView.isUserInteractionEnabled = true
//		self.scrollView.contentSize = CGSize(width: 10000, height: 10000)
//		
//		tournament = TournamentController.getCurrentTournament()
//	
//		// every view, let's refetch and redraw.
//		// make this less dependent on other functions updating things.
//		createBracket()
//	}
//	
//	func addTeamToLosersBracket(team: Team) {
//		losersTeamList.append(team)
//	}
//	
//	func createBracket() {
//		let bracketCreator = LosersBracketCreator(tournament: tournament, bracketController: bracketController)
//		bracketCreator.bracketCreatorDelegate = self
//		
//		if !tournament.isStarted && tournament.teamList.count > 0  {
//			bracketController.seedTeams()
//			bracketCreator.createBracket()
//		} else {
//			bracketController.updateMatchups()
//		}
//	}
//	
//	func clearView() {
//		let subViews = self.scrollView.subviews
//		for subview in subViews {
//			subview.removeFromSuperview()
//		}
//		
//		for cell in bracketCells {
//			cell.removeFromSuperview()
//		}
//		
//		bracketCells.removeAll()
//		bracketDict.removeAll()
//	}
//	
//	// BRACKET DELEGATE
//	func bracketCreated(isUpdateMatchups: Bool) {
//		if isUpdateMatchups {
//			bracketController.updateMatchups()
//		} else {
//			createBracketView()
//		}
//		
//	}
//	
//	
//	// BRACKET CREATION DELEGATE
//	func bracketCreated(isUpdateMatchups: Bool) {
//		
//	}
//}
