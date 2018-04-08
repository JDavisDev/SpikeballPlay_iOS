//
//  SettingsViewController.swift
//  SpikeballPlay
//
//  Created by Jordan Davis on 8/11/17.
//  Copyright © 2017 HoverSlam. All rights reserved.
//

import UIKit
import RealmSwift
import Crashlytics

// TODO : Disable settings if tournament has started!
// Need some pool play settings to check where we are in tournament.
// controlling flow between pool play and bracket or Bracket only.
class TournamentSettingsView: UIViewController {
    
	@IBOutlet weak var challongeLinkLabel: UILabel!
	@IBOutlet weak var isPublicSwitch: UISwitch!
	@IBOutlet weak var isOnlineSwitch: UISwitch!
	@IBOutlet weak var tournamentNameTextField: UITextField!
    @IBOutlet weak var isQuickReportSwitch: UISwitch!
    @IBOutlet weak var isBracketOnlySwitch: UISwitch!
    @IBOutlet weak var playersPerPoolSegementedControl: UISegmentedControl!
    @IBOutlet weak var advanceButton: UIButton!
    @IBOutlet weak var playersPerPoolLabel: UILabel!
	
	@IBOutlet weak var poolPlayAndBracketButton: UIButton!
	@IBOutlet weak var bracketOnlyButton: UIButton!
	
	let bracketController = BracketController()
    let realm = try! Realm()
    let tournament = TournamentController.getCurrentTournament()
    
    override func viewDidLoad() {
        super.viewDidLoad()
		
		if tournament.isPoolPlay {
			playersPerPoolSegementedControl.isHidden = true
			playersPerPoolLabel.isHidden = true
			
			// bracket AND Pool Play
			poolPlayAndBracketButton.setTitleColor(UIColor.yellow, for: .normal)
			bracketOnlyButton.setTitleColor(UIColor.white, for: .normal)
			playersPerPoolSegementedControl.isHidden = false
			playersPerPoolLabel.isHidden = false
			playersPerPoolSegementedControl.selectedSegmentIndex = tournament.playersPerPool - 6
		} else {
			// bracket only
			poolPlayAndBracketButton.setTitleColor(UIColor.white, for: .normal)
			bracketOnlyButton.setTitleColor(UIColor.yellow, for: .normal)
			playersPerPoolSegementedControl.isHidden = true
			playersPerPoolLabel.isHidden = true
		}
		
		if tournament.progress_meter > 0 || tournament.isReadOnly {
			// tournament has begun, don't let settings be editable
			bracketOnlyButton.isEnabled = false
			poolPlayAndBracketButton.isEnabled = false
			playersPerPoolSegementedControl.isEnabled = false
			// maybe show a message as to why everything is disabled.
		}
		
		tournamentNameTextField.text = tournament.name
		challongeLinkLabel.text = "Challonge Link : " + tournament.full_challonge_url
		
		// tournament is read only, let's hide everything!
		if tournament.isReadOnly {
			bracketOnlyButton.isHidden = true
			poolPlayAndBracketButton.isHidden = true
			isOnlineSwitch.isHidden = true
			isPublicSwitch.isHidden = true
			tournamentNameTextField.isEnabled = false
			advanceButton.setTitle("Next", for: .normal)
		}
    }
	
	@IBAction func deleteButton(_ sender: UIButton) {
		// show safety dialog first.
		let alert = UIAlertController(title: "Delete Tourament",
									  message: "Everything will be deleted!", preferredStyle: .alert)
		
		let action = UIAlertAction(title: "Delete", style: .destructive) { (alertAction) in
			if self.tournament.isReadOnly {
				self.deleteTournament(deleteOnline: false)
			} else if self.tournament.password.count > 0 {
				self.showPasswordAlert()
			} else {
				self.deleteTournament(deleteOnline: true)
			}
		}
		
		alert.addAction(action)
		
		alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
			// cancel
			return
		}))
		
		present(alert, animated: true, completion: nil)
	}
	
	func deleteTournament(deleteOnline: Bool) {
		var count = 0
		if realm.isInWriteTransaction {
			count = realm.objects(Tournament.self).filter("id = \(tournament.id)").count
		} else {
			try! realm.write {
				count = realm.objects(Tournament.self).filter("id = \(tournament.id)").count
			}
		}
		
		if count == 0 { return }
		
		if deleteOnline {
			let tournamentDAO = TournamentDAO()
			tournamentDAO.deleteOnlineTournament(tournament: tournament)
		}
		
		try! realm.write {
			for team in tournament.teamList {
				for game in team.poolPlayGameList {
					realm.delete(game)
				}
				
				realm.delete(team)
			}
			
			realm.delete(realm.objects(BracketMatchup.self).filter("tournament_id = \(tournament.id)"))
			
			for pool in tournament.poolList {
				for matchup in pool.matchupList {
					realm.delete(matchup)
				}
				
				realm.delete(pool)
			}
			
			realm.delete(tournament)
		}
		
		Answers.logCustomEvent(withName: "Tournament Deleted",
							   customAttributes: [:])
		navigationController?.popViewController(animated: true)
	}
	
	func showPasswordAlert() {
		let alert = UIAlertController(title: "Password",
									  message: "Please enter password to delete this tournament online.", preferredStyle: .alert)
		
		let submit = UIAlertAction(title: "Submit", style: .default) { (alertAction) in
			_ = alert.textFields![0] as UITextField
			let pw = alert.textFields![0].text!
			let password = self.tournament.password
			
			if pw == password {
				self.deleteTournament(deleteOnline: true)
			} else {
				self.showPasswordIncorrectAlert()
			}
		}
		
		alert.addAction(submit)
		
		alert.addTextField { (textField) in
			textField.placeholder = "Password"
			textField.borderStyle = UITextBorderStyle.roundedRect
		}
		
		
		alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
			// cancel
			return
		}))
		
		present(alert, animated: true, completion: nil)
	}
	
	func showPasswordIncorrectAlert() {
		let alert = UIAlertController(title: "Password Incorrect",
									  message: "Do you wish to delete this tournament from your device?", preferredStyle: .alert)
		
		alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { (action: UIAlertAction!) in
			// delete
			self.deleteTournament(deleteOnline: false)
		}))
		
		alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
			// cancel
			return
		}))
		
		present(alert, animated: true, completion: nil)
	}
	
	@IBAction func poolPlayAndBracketButton(_ sender: UIButton) {
		try! realm.write {
			tournament.isPoolPlay = true
		}
		
		// bracket AND Pool Play
		poolPlayAndBracketButton.setTitleColor(UIColor.yellow, for: .normal)
		bracketOnlyButton.setTitleColor(UIColor.white, for: .normal)
		playersPerPoolSegementedControl.isHidden = false
		playersPerPoolLabel.isHidden = false
	}
	
	@IBAction func bracketOnlyButton(_ sender: UIButton) {
		try! realm.write {
			tournament.isPoolPlay = false
		}
		
		// bracket only
		poolPlayAndBracketButton.setTitleColor(UIColor.white, for: .normal)
		bracketOnlyButton.setTitleColor(UIColor.yellow, for: .normal)
		playersPerPoolSegementedControl.isHidden = true
		playersPerPoolLabel.isHidden = true
	}
    
    @IBAction func saveSettings(_ sender: UIButton) {
        TournamentController.IS_QUICK_REPORT = false //isQuickReportSwitch.isOn
        
        try! realm.write {
			if !tournament.isReadOnly {
				tournament.isOnline = isOnlineSwitch.isOn
				tournament.isPrivate = !isPublicSwitch.isOn
				tournament.isQuickReport = false //isQuickReportSwitch.isOn
				tournament.playersPerPool = playersPerPoolSegementedControl.selectedSegmentIndex + 6
				tournament.name = (tournamentNameTextField.text?.count.magnitude)! > 0 ?
					tournamentNameTextField.text! :
					tournament.name
				
				let tournamentDao = TournamentDAO()
				tournamentDao.addOnlineTournament(tournament: tournament)
				
				//		let challongeAPI = ChallongeAPI()
				//		challongeAPI.createTournament(tournament: tournament)
			}
        }
		
		Answers.logCustomEvent(withName: "Tournament Settings Saved",
		   customAttributes: [
			"isPoolPlay": String(tournament.isPoolPlay),
			"isOnline": String(tournament.isOnline),
			"isPublic": String(!tournament.isPrivate),
			"isPassword": String(tournament.password.count > 0)])
    }
}
