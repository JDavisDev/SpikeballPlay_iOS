//
//  MatchupsViewController.swift
//  Duo Play
//
//  Created by Jordan Davis on 1/1/18.
//  Copyright © 2018 Jordan Davis. All rights reserved.
//

import UIKit
import Crashlytics
import Firebase

class MatchupsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var matchupsTableView: UITableView!
	let tournament = TournamentController.getCurrentTournament()
	let challongeTournamentAPI = ChallongeTournamentAPI()
	
    var matchupList = [BracketMatchup]()
    var roundCount = 3
	
    
    override func viewDidLoad() {
        super.viewDidLoad()
        matchupsTableView.delegate = self
        matchupsTableView.dataSource = self
        roundCount = getRoundCount()
        updateMatchupsList()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
		
		Answers.logContentView(withName: "Bracket Matchups View",
							   contentType: "Bracket Matchups Page View",
							   contentId: "11",
							   customAttributes: [:])
		
        updateMatchupsList()
    }
    
    func getRoundCount() -> Int {
/* 5-8 players/teams: 3 rounds
 9-16 players/teams: 4 rounds
 17-32 players/teams: 5 rounds
 33-64 players/teams: 6 rounds
 65-128 players/teams: 7 rounds
 129-256 players/teams: 8 rounds */
        
        switch tournament.teamList.count {
        case 5...8:
            return 3
        case 9...16:
            return 4
        case 17...32:
            return 5
        case 33...64:
            return 6
        case 65...128:
            return 7
        case 129...256:
            return 8
		case 257...512:
			return 9
        default:
            return 0
        }
    }
    
    func updateMatchupsList() {
        self.matchupList.removeAll()
        
        for matchup in tournament.matchupList {
            if !matchup.isReported && matchup.teamOne != nil &&
                matchup.teamTwo != nil {
                self.matchupList.append(matchup)
            }
        }
        
        matchupsTableView.reloadData()
    }
	
	func checkStartTournament() {
		// tournament has NOT began. check if they want to finalize and begin the tournament
		let message = "Finalize participants and start tournament?"
		
		let alert = UIAlertController(title: "Start Tournament", message: message,
									  preferredStyle: .alert)
		
		alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action: UIAlertAction!) in
			self.challongeTournamentAPI.startTournament(tournament: self.tournament)
		}))
		
		alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
			// cancel
			return
		}))
		
		present(alert, animated: true, completion: nil)
	}
    
    // MARK: - Table View methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return matchupList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "matchupCell")
        let matchup = matchupList[indexPath.row]
        if !matchup.isReported && matchup.teamOne != nil && matchup.teamTwo != nil {
            cell!.textLabel?.text = (matchup.teamOne?.name)! + "  vs.  " + (matchup.teamTwo?.name)!
        }
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		// only allow selection if tournament is editable.
		if(!tournament.isStarted) {
			self.checkStartTournament()
		} else if !tournament.isReadOnly {
        	let selectedMatchup = matchupList[indexPath.row]
			Answers.logCustomEvent(withName: "Matchup List Tapped",
							   customAttributes: [:])
			Analytics.logEvent("Bracket_List_Tapped", parameters: nil)
        	performSegue(withIdentifier: "bracketReporterSegue", sender: selectedMatchup)
		}
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "bracketReporterSegue" {
            if let nextVC = segue.destination as? BracketReporterViewController {
                nextVC.selectedMatchup = sender as! BracketMatchup
            }
        }
    }

}
