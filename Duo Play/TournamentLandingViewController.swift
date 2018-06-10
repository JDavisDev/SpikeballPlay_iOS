//
//  TournamentLandingViewController.swift
//  Duo Play
//
//  Created by Jordan Davis on 3/11/18.
//  Copyright © 2018 Jordan Davis. All rights reserved.
//

import UIKit
import RealmSwift

class TournamentLandingViewController: UIViewController, TournamentDAODelegate, UITextFieldDelegate, ChallongeTournamentAPIDelegate {
	@IBOutlet weak var poolPlayButton: UIButton!
	
	@IBOutlet weak var settingsButton: UIButton!
	@IBOutlet weak var tournamentNameLabel: UILabel!
	@IBOutlet weak var bracketButton: UIButton!
	@IBOutlet weak var refreshButton: UIButton!
	@IBOutlet weak var challongeLinkLabel: UITextField!
	@IBOutlet weak var saveToChallongeButton: UIButton!
	
	@IBOutlet weak var activityIndicator: UIActivityIndicatorView!
	
	let tournamentFirebaseDao = TournamentFirebaseDao()
	let tournamentChallongeDao = ChallongeTournamentAPI()
	let realm = try! Realm()
	var tournament = Tournament()
	let bracketController = BracketController()
	
    override func viewDidLoad() {
        super.viewDidLoad()

        tournament = TournamentController.getCurrentTournament()
		tournamentFirebaseDao.delegate = self
		tournamentChallongeDao.delegate = self
		bracketController.updateTournamentProgress()
		
		// could make this a button... a click takes them to the page.
		challongeLinkLabel.delegate = self
		if tournament.url.count > 0 {
			challongeLinkLabel.text = "www.challonge.com/" + tournament.url
		}
		
		updateButtons()
		updateView()
    }
	
	// make it so user can't change the text, it just allows copying!
	func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
		return false
	}
	
	@IBAction func refreshButtonClicked(_ sender: UIButton) {
		// refresh tournament data from FIREBASE and reload.
		//tournamentDao.getFirebaseTournamentById(id: tournament.id)
	}
	
	@IBAction func didTapSaveToChallonge(_ sender: UIButton) {
		// show loading indicator and wait for response
		// if failure, show dialog and allow them to move on.
		// check if tournament has been synced before
		// check if teamlist is > 0, if it is, sync those teams at this time
		// matches can be manually synced later  ?
		
		
		// live_image_url is the only property ONLY coming from challonge
		if tournament.live_image_url.isEmpty {
			activityIndicator?.startAnimating()
			activityIndicator?.isHidden = false
			tournamentChallongeDao.createChallongeTournament(tournament: tournament)
		}
	}
	
	
	func updateButtons() {
		poolPlayButton.layer.cornerRadius = 20
		poolPlayButton.layer.borderColor = UIColor.white.cgColor
		poolPlayButton.layer.borderWidth = 1
		
		bracketButton.layer.cornerRadius = 20
		bracketButton.layer.borderColor = UIColor.white.cgColor
		bracketButton.layer.borderWidth = 1
		
		settingsButton.layer.cornerRadius = 20
		settingsButton.layer.borderColor = UIColor.white.cgColor
		settingsButton.layer.borderWidth = 1
		
		saveToChallongeButton.layer.cornerRadius = 20
		saveToChallongeButton.layer.borderColor = UIColor.white.cgColor
		saveToChallongeButton.layer.borderWidth = 1
	}
	
	func updateView() {
		tournamentNameLabel.text = tournament.name
		
		if tournament.isPoolPlay && !tournament.isPoolPlayFinished {
			poolPlayButton.isEnabled = true
		} else {
			poolPlayButton.isEnabled = false
		}
		
		if !tournament.isPoolPlay || tournament.isPoolPlayFinished {
			bracketButton.isEnabled = true
		} else {
			bracketButton.isEnabled = false
		}
		
		if tournament.isOnline && !tournament.isReadOnly && tournament.live_image_url.isEmpty {
			saveToChallongeButton.isHidden = false
		} else {
			saveToChallongeButton.isHidden = true
		}
	}
	
	// DAO DELEGATION METHODS
	
	// created challonge tournamented
	func didCreateChallongeTournament(onlineTournament: [String : Any]?, localTournament: Tournament?, success: Bool) {
		// got the tournament back from challonge
		DispatchQueue.main.sync {
			if success {
				let updatedTournament = Tournament(dictionary: onlineTournament!)
					try! realm.write {
						localTournament?.challonge_tournament_id = updatedTournament.id
						localTournament?.live_image_url = updatedTournament.live_image_url
						localTournament?.state = updatedTournament.state
						localTournament?.tournament_type = updatedTournament.tournament_type
						localTournament?.full_challonge_url = updatedTournament.full_challonge_url
						localTournament?.url = updatedTournament.url
					}
				
					updateView()
					showAlertMessage(title: "Success", message: "Tournament saved to Challonge!")
			} else {
				showAlertMessage(title: "Challonge Error", message: "Could not connect to Challonge. Please check your network connection and try again.")
			}
			
			activityIndicator?.isHidden = true
			activityIndicator?.stopAnimating()
		}
	}
	
	// we got the tournament
	func didGetOnlineTournaments(onlineTournamentList: [Tournament]) {
		if let tournament = onlineTournamentList.first {
			tournamentFirebaseDao.getTournamentData(tournament: tournament)
		}
	}
	
	// we got the tournament data!
	func didGetOnlineTournamentData() {
		showAlertMessage(title: "Success", message: "Tournament Updated!")
	}
	
	// END DELEGATION
	
	func showAlertMessage(title: String, message: String) {
		let alert = UIAlertController(title: title,
									  message: message, preferredStyle: .alert)
		
		alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { (action: UIAlertAction!) in
			// ok
			return
		}))
		
		present(alert, animated: true, completion: nil)
	}
}
