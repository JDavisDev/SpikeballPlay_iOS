//
//  BracketReporterViewController.swift
//  Duo Play
//
//  Created by Jordan Davis on 1/1/18.
//  Copyright © 2018 Jordan Davis. All rights reserved.
//

import UIKit
import RealmSwift
import Crashlytics

class BracketReporterViewController: UIViewController, ChallongeMatchupAPIDelegate {
	
    let realm = try! Realm()
	let challongeMatchupAPI = ChallongeMatchupAPI()
	
	var tournament: Tournament?
    // the selected matchup gets stored here.
    var selectedMatchup = BracketMatchup()
    var didTournamentJustStart = false
	
    @IBOutlet weak var teamTwoNameLabel: UILabel!
    @IBOutlet weak var teamOneNameLabel: UILabel!
    @IBOutlet weak var teamOneGameOneSlider: UISlider!
    @IBOutlet weak var teamTwoGameOneSlider: UISlider!
    
    // Score labels
    @IBOutlet weak var teamOneGameOneScoreLabel: UILabel!
    @IBOutlet weak var teamOneGameTwoScoreLabel: UILabel!
    @IBOutlet weak var teamOneGameThreeScoreLabel: UILabel!
    @IBOutlet weak var teamTwoGameOneScoreLabel: UILabel!
    @IBOutlet weak var teamTwoGameTwoScoreLabel: UILabel!
    @IBOutlet weak var teamTwoGameThreeScoreLabel: UILabel!
    
    override func viewDidLoad() {
		super.viewDidLoad()
		checkSelectedMatchup()
    }
	
	func checkSelectedMatchup() {
		if (selectedMatchup.teamOne?.name.count)! > 0 && selectedMatchup.teamTwo != nil {
			teamOneNameLabel.text = (selectedMatchup.teamOne?.name)!
			teamTwoNameLabel.text = (selectedMatchup.teamTwo?.name)!
		} else {
			let alert = UIAlertController(title: "Matchup Error",
										  message: "Failed to retrieve matchup.",
										  preferredStyle: .alert)
			
			alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action: UIAlertAction!) in
				self.navigationController?.popViewController(animated: true)
			}))
			
			present(alert, animated: true, completion: nil)
		}
	}
    
    /* SLIDER VALUE CHANGED TEAM ONE
     update score labels */
    @IBAction func teamOneGameOneValueChanged(_ sender: UISlider) {
        teamOneGameOneScoreLabel.text = String(Int(round(sender.value) / 1 * 1))
    }
    
    @IBAction func teamOneGameTwoValueChanged(_ sender: UISlider) {
        teamOneGameTwoScoreLabel.text = String(Int(round(sender.value) / 1 * 1))
    }
    
    @IBAction func teamOneGameThreeValueChanged(_ sender: UISlider) {
        teamOneGameThreeScoreLabel.text = String(Int(round(sender.value) / 1 * 1))
    }
    
    // SLIDER VALUE CHANGED TEAM TWO
    
    @IBAction func teamTwoGameOneValueChanged(_ sender: UISlider) {
        teamTwoGameOneScoreLabel.text = String(Int(round(sender.value) / 1 * 1))
    }
    
    @IBAction func teamTwoGameTwoValueChanged(_ sender: UISlider) {
        teamTwoGameTwoScoreLabel.text = String(Int(round(sender.value) / 1 * 1))
    }
    
    @IBAction func teamTwoGameThreeValueChanged(_ sender: UISlider) {
        teamTwoGameThreeScoreLabel.text = String(Int(round(sender.value) / 1 * 1))
    }
    
    
    @IBAction func submitButtonClicked(_ sender: UIButton) {
		self.tournament = TournamentController.getCurrentTournament()
		if(tournament?.isStarted == false) {
			checkStartTournament()
		} else {
			checkViewValues()
		}
    }
	
	func checkStartTournament() {
		// tournament has NOT began. check if they want to finalize and begin the tournament
		let message = "Finalize participants and start tournament?"
		
		let alert = UIAlertController(title: "Start Tournament", message: message,
									  preferredStyle: .alert)
		
		alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action: UIAlertAction!) in
			// move on
			self.didTournamentJustStart = true
			self.checkViewValues()
		}))
		
		alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
			// cancel
			return
		}))
		
		present(alert, animated: true, completion: nil)
	}
	
	func checkViewValues() {
		let teamOneGameOneScore = Int(teamOneGameOneScoreLabel.text!)
		let teamTwoGameOneScore = Int(teamTwoGameOneScoreLabel.text!)
		
		// score isn't the same for game one
		if teamOneGameOneScore != teamTwoGameOneScore {
			// difference of atleast one, all set.
			submitGame()
		} else {
			//scores match
			let alert = UIAlertController(title: "Score Error",
										  message: "Game one scores cannot match",
										  preferredStyle: .alert)
			
			alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action: UIAlertAction!) in
				return
			}))
			
			present(alert, animated: true, completion: nil)
		}
	}
	
	func submitGame() {
		// show loading indicator for challonge stuffs
		var numOfGamesPlayed = 0
		let teamOneGameOneScore = Int(teamOneGameOneScoreLabel.text!)
		let teamOneGameTwoScore = Int(teamOneGameTwoScoreLabel.text!)
		let teamOneGameThreeScore = Int(teamOneGameThreeScoreLabel.text!)
		
		let teamTwoGameOneScore = Int(teamTwoGameOneScoreLabel.text!)
		let teamTwoGameTwoScore = Int(teamTwoGameTwoScoreLabel.text!)
		let teamTwoGameThreeScore = Int(teamTwoGameThreeScoreLabel.text!)
		
		// validate and confirm game
		if teamOneGameOneScore != teamTwoGameOneScore {
			numOfGamesPlayed += 1
		} else  {
			showAlert(title: "Error", message: "Game scores cannot be equal.")
			return
		}
		
		if teamOneGameTwoScore != teamTwoGameTwoScore {
			numOfGamesPlayed += 1
		} else if teamOneGameTwoScore != 0 {
			showAlert(title: "Error", message: "Game scores cannot be equal.")
			return
		}
		
		if teamOneGameThreeScore != teamTwoGameThreeScore {
			numOfGamesPlayed += 1
		} else if teamOneGameThreeScore != 0 {
			showAlert(title: "Error", message: "Game scores cannot be equal.")
			return
		}
		
		let message = "Games to report: \(numOfGamesPlayed) \n Please set scores to 0 if you do not wish to report the game."
		
		let alert = UIAlertController(title: "Submit Game", message: message,
									  preferredStyle: .alert)
		
		alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action: UIAlertAction!) in
			// move on
			let reporterController = BracketController()
			
			var teamOneScores = [Int]()
			teamOneScores.append(teamOneGameOneScore!)
			teamOneScores.append(teamOneGameTwoScore!)
			teamOneScores.append(teamOneGameThreeScore!)
			
			var teamTwoScores = [Int]()
			teamTwoScores.append(teamTwoGameOneScore!)
			teamTwoScores.append(teamTwoGameTwoScore!)
			teamTwoScores.append(teamTwoGameThreeScore!)
			
			var teamOneWins = 0
			var teamTwoWins = 0
			for score in 0..<teamOneScores.count {
				if teamOneScores[score] > teamTwoScores[score] {
					teamOneWins += 1
				} else if teamTwoScores[score] > teamOneScores[score] {
					teamTwoWins += 1
				}
			}
			
			var winnerId = 0
			if teamOneWins > teamTwoWins {
				winnerId = (self.selectedMatchup.teamOne?.challonge_participant_id)!
			} else {
				winnerId = (self.selectedMatchup.teamTwo?.challonge_participant_id)!
			}
			
			reporterController.reportMatch(selectedMatchup: self.selectedMatchup, numOfGamesPlayed: numOfGamesPlayed, teamOneScores: teamOneScores, teamTwoScores: teamTwoScores)
			
			if (self.tournament?.isOnline)! && !(self.tournament?.isReadOnly)! && (self.tournament?.live_image_url.count)! > 0 {
				self.challongeMatchupAPI.delegate = self
				self.challongeMatchupAPI.updateChallongeMatch(tournament: self.tournament!, match: self.selectedMatchup, winnerId: winnerId)
			}
			
			Answers.logCustomEvent(withName: "Bracket Match Reported",
								   customAttributes: [
									"Games Submitted": numOfGamesPlayed])
			
			self.navigationController?.popViewController(animated: true)
		}))
		
		alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
			// cancel
			return
		}))
		
		present(alert, animated: true, completion: nil)
	}
	
	func didGetChallongeMatchups(challongeMatchups: [[String : Any]]) {
		// re parse the tournament matches and save!
		DispatchQueue.main.sync {
			parseChallongeMatchups(tournament: tournament!, challongeMatchups: challongeMatchups)
		}
	}
	
	func parseChallongeMatchups(tournament: Tournament, challongeMatchups: [[String:Any]]) {
		try! realm.write {
			for dictObject in challongeMatchups {
				guard let localMatchup = getRealmMatchupFromChallongeData(tournament: tournament, data: dictObject) else { continue }
				// same match... parse!
				localMatchup.challongeId = dictObject["id"] as! Int
				localMatchup.tournament_id = dictObject["tournament_id"] as! Int
				
				// if our local match is reported but the winner id is 0/nil
				// re report that match to challonge.
				if localMatchup.isReported {
					if let winnerId = dictObject["winner_id"] as? Int {
						if  winnerId <= 0 {
							self.challongeMatchupAPI.delegate = self
							self.challongeMatchupAPI.updateChallongeMatch(tournament: self.tournament!, match: localMatchup, winnerId: winnerId)
						}
					} else {
						let id = getMatchupWinnerId(matchup: localMatchup)
						self.challongeMatchupAPI.delegate = self
						self.challongeMatchupAPI.updateChallongeMatch(tournament: self.tournament!, match: localMatchup, winnerId: id)
					}
				}
				
				realm.add(localMatchup, update: true)
			}
		}
	}
	
	func getMatchupWinnerId(matchup: BracketMatchup) -> Int {
		var winnerId = 0
		var teamOneWins = 0
		var teamTwoWins = 0
		for score in 0..<matchup.teamOneScores.count {
			if matchup.teamOneScores[score] > matchup.teamTwoScores[score] {
				teamOneWins += 1
			} else if matchup.teamTwoScores[score] > matchup.teamOneScores[score] {
				teamTwoWins += 1
			}
		}
		
		if teamOneWins > teamTwoWins {
			winnerId = (matchup.teamOne?.challonge_participant_id)!
		} else {
			winnerId = (matchup.teamTwo?.challonge_participant_id)!
		}
		
		return winnerId
	}
	
	func getRealmMatchupFromChallongeData(tournament: Tournament, data: [String: Any]) -> BracketMatchup? {
		var matchup: BracketMatchup?
		if let oneId = data["player1_id"] as? Int {
			if let twoId = data["player2_id"] as? Int {
				guard let teamOne = getTournamentTeamFromChallonge(tournamentId: tournament.id, teamChallongeId: oneId) else { return nil }
				guard let teamTwo = getTournamentTeamFromChallonge(tournamentId: tournament.id, teamChallongeId: twoId)
					else { return nil }
				
				matchup = getTournamentMatchupWithTeams(tournament: tournament, teamOne: teamOne, teamTwo: teamTwo)
				return matchup
			}
		}
		
		return nil
	}
	
	func getTournamentTeamFromChallonge(tournamentId: Int, teamChallongeId: Int) -> Team? {
		let result = realm.objects(Team.self).filter("tournament_id = \(tournamentId) AND challonge_participant_id = \(teamChallongeId)")
		if result.count > 0 {
			return result.first!
		} else {
			print("Cannot fetch team from realm")
			return Team()
		}
	}
	
	func getTournamentMatchupWithTeams(tournament: Tournament, teamOne: Team, teamTwo: Team) -> BracketMatchup? {
		let predicate = NSPredicate(format: "tournament_id = \(tournament.id)")
		let result = realm.objects(BracketMatchup.self).filter(predicate)
		if result.count > 0 {
			// we have all match ups in the tournament
			for obj in result {
				if (obj.teamOne?.name == teamOne.name && obj.teamTwo?.name == teamTwo.name) ||
					(obj.teamTwo?.name == teamOne.name && obj.teamOne?.name == teamTwo.name) {
					return obj
				}
			}
		} else {
			print("Cannot fetch bracket matchup from realm")
		}
		
		return nil
	}
	
	func showAlert(title: String, message: String) {
		let alert = UIAlertController(title: title,
									  message: message, preferredStyle: .alert)
		
		alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { (action: UIAlertAction!) in
			// ok
			return
		}))
		
		present(alert, animated: true, completion: nil)
	}
}
