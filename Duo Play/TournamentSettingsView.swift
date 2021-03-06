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
class TournamentSettingsView: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
	
//	func didGetChallongeTournamentData(onlineTournament: [String : Any], localTournament: Tournament) {
//			localTournament.id = onlineTournament["id"] as! Int
//			localTournament.full_challonge_url = onlineTournament["full_challonge_url"] as! String
//			localTournament.isPrivate = onlineTournament["private"] as! Bool
//			localTournament.live_image_url = onlineTournament["live_image_url"]as! String
//			localTournament.participants_count = onlineTournament["participants_count"] as! Int
//			localTournament.progress_meter = onlineTournament["progress_meter"] as! Int
//			localTournament.state = onlineTournament["state"] as! String
//			localTournament.url = onlineTournament["url"] as! String
//			localTournament.tournament_type = onlineTournament["tournament_type"] as! String
//	}
	
	
	@IBOutlet weak var tournamentStylePicker: UIPickerView!
	@IBOutlet weak var isPublicSwitch: UISwitch!
	@IBOutlet weak var isOnlineSwitch: UISwitch!
	@IBOutlet weak var tournamentNameTextField: UITextField!
    @IBOutlet weak var isQuickReportSwitch: UISwitch!
    @IBOutlet weak var isBracketOnlySwitch: UISwitch!
    @IBOutlet weak var playersPerPoolSegementedControl: UISegmentedControl!
    @IBOutlet weak var advanceButton: UIButton!
    @IBOutlet weak var playersPerPoolLabel: UILabel!
	@IBOutlet weak var isPoolPlaySwitch: UISwitch!
	
	let challongeTournamentAPI = ChallongeTournamentAPI()
	let bracketController = BracketController()
    let tournament = TournamentController.getCurrentTournament()
	let dbManager = DBManager()
	
	var tournamentStyles = [String]()
	
	private enum TournamentFormat: String {
		case BracketPoolPlay = "Bracket + Pool Play"
		case BracketOnly = "Bracket Only"
		//case BracketSwissPool = "Bracket + Swiss Pool Play"
		//case SwissOnly = "Swiss Only"
		
		static let allValues = [BracketPoolPlay, BracketOnly]//, BracketSwissPool, SwissOnly]
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		updateView()
	}
	
	private func updateView() {
		initPicker()
		tournamentNameTextField.text = tournament.name
		
		setPoolPlayOn(isOn: tournament.isPoolPlay && !tournament.isPoolPlayFinished)
		
		isOnlineSwitch.setOn(tournament.isOnline, animated: true)
		
		if isPoolPlaySwitch.isOn {
			playersPerPoolSegementedControl.isHidden = false
			playersPerPoolLabel.isHidden = false
			playersPerPoolSegementedControl.selectedSegmentIndex = tournament.playersPerPool - 4
		} else {
			playersPerPoolSegementedControl.isHidden = true
			playersPerPoolLabel.isHidden = true
		}
		
		if tournament.progress_meter > 0 || tournament.isReadOnly || tournament.isStarted {
			// tournament has begun, don't let settings be editable
			playersPerPoolSegementedControl.isEnabled = false
			isPoolPlaySwitch.isEnabled = false
			tournamentStylePicker.isUserInteractionEnabled = false
			isOnlineSwitch.isEnabled = false
			isPublicSwitch.isEnabled = false
		}
		
		// tournament is read only, let's hide everything!
		if tournament.isReadOnly {
			isOnlineSwitch.isHidden = true
			isPublicSwitch.isHidden = true
			tournamentNameTextField.isEnabled = false
			tournamentStylePicker.isUserInteractionEnabled = false
			advanceButton.setTitle("Next", for: .normal)
		}
	}
	
	private func initPicker() {
		for value in TournamentFormat.allValues {
			tournamentStyles.append(value.rawValue)
		}
		
		tournamentStylePicker.delegate = self
		tournamentStylePicker.dataSource = self
		tournamentStylePicker.tintColor = UIColor.white
		tournamentStylePicker.showsSelectionIndicator = true
		tournamentStylePicker.reloadAllComponents()
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
	
	@IBAction func isPoolPlaySwitchToggled(_ sender: UISwitch) {
		if isPoolPlaySwitch.isOn {
			playersPerPoolSegementedControl.isHidden = false
			playersPerPoolLabel.isHidden = false
			playersPerPoolSegementedControl.selectedSegmentIndex = tournament.playersPerPool - 4
			tournamentStylePicker.selectRow(0, inComponent: 0, animated: true)
		} else {
			playersPerPoolSegementedControl.isHidden = true
			playersPerPoolLabel.isHidden = true
			tournamentStylePicker.selectRow(1, inComponent: 0, animated: true)
		}
	}
	
	func deleteTournament(deleteOnline: Bool) {
		var count = 0
		let realm = try! Realm()
		
		if realm.isInWriteTransaction {
			count = realm.objects(Tournament.self).filter("id = \(tournament.id)").count
		} else {
			try! realm.write {
				count = realm.objects(Tournament.self).filter("id = \(tournament.id)").count
			}
		}
		
		if count == 0 { return }
		
		// delete challonge tournament
		challongeTournamentAPI.deleteChallongeTournament(tournament: tournament)
		
		if deleteOnline {
			let tournamentDAO = TournamentFirebaseDao()
			tournamentDAO.deleteFirebaseTournament(tournament: tournament)
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
				// crashing here from realm??
				for matchup in pool.matchupList {
					realm.delete(matchup)
				}
				
				realm.delete(pool)
			}
			
			realm.delete(tournament)
		}
		
		Answers.logCustomEvent(withName: "Tournament Deleted",
							   customAttributes: [:])
		// navigate to tournament home page.
		for controller in self.navigationController!.viewControllers as Array {
			if controller.isKind(of: TournamentsHomeView.self) {
				self.navigationController!.popToViewController(controller, animated: true)
				break
			}
		}
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

    
    @IBAction func saveSettings(_ sender: UIButton) {
		let realm = try! Realm()
        TournamentController.IS_QUICK_REPORT = false //isQuickReportSwitch.isOn
		// set a param here to ONLY send up a tournament once, otherwise update the tournament
		if !tournament.isReadOnly && !tournament.isStarted {
        	try! realm.write {
				tournament.isPoolPlay = isPoolPlaySwitch.isOn
				tournament.isOnline = isOnlineSwitch.isOn
				tournament.isPrivate = !isPublicSwitch.isOn
				tournament.isQuickReport = false //isQuickReportSwitch.isOn
				tournament.playersPerPool = playersPerPoolSegementedControl.selectedSegmentIndex + 4
				tournament.name = (tournamentNameTextField.text?.count)! > 0 ?
					tournamentNameTextField.text! :
					tournament.name
			}
			
			Answers.logCustomEvent(withName: "Tournament Settings Saved",
								   customAttributes: [
									"isPoolPlay": String(tournament.isPoolPlay),
									"isOnline": String(tournament.isOnline),
									"isPublic": String(!tournament.isPrivate),
									"isPassword": String(tournament.password.count > 0)])
        }
    }
	
	func setPoolPlayOn(isOn: Bool) {
		isPoolPlaySwitch.setOn(isOn, animated: true)
		playersPerPoolLabel.isHidden = !isOn
		playersPerPoolSegementedControl.isHidden = !isOn
		tournamentStylePicker.selectRow(isOn ? 0 : 1, inComponent: 0, animated: true)
	}
	
	// MARK: Tournament Style Picker
	func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
		return tournamentStyles.count
	}
	
	func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
		return tournamentStyles[row]
	}
	
	func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
		// save setting
		if row == 0 {
			setPoolPlayOn(isOn: true)
		} else {
			setPoolPlayOn(isOn: false)
		}
	}
	
	func numberOfComponents(in pickerView: UIPickerView) -> Int {
		return 1
	}
}
