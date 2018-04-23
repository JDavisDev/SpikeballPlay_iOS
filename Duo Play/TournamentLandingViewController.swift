//
//  TournamentLandingViewController.swift
//  Duo Play
//
//  Created by Jordan Davis on 3/11/18.
//  Copyright © 2018 Jordan Davis. All rights reserved.
//

import UIKit
import RealmSwift

class TournamentLandingViewController: UIViewController, TournamentDAODelegate, UITextFieldDelegate {
	@IBOutlet weak var poolPlayButton: UIButton!
	
	@IBOutlet weak var teamsButton: UIButton!
	@IBOutlet weak var settingsButton: UIButton!
	@IBOutlet weak var tournamentNameLabel: UILabel!
	@IBOutlet weak var bracketButton: UIButton!
	@IBOutlet weak var refreshButton: UIButton!
	@IBOutlet weak var challongeLinkLabel: UITextField!
	
	let tournamentDao = TournamentDAO()
	let realm = try! Realm()
	var tournament = Tournament()
	let bracketController = BracketController()
	
    override func viewDidLoad() {
        super.viewDidLoad()

        tournament = TournamentController.getCurrentTournament()
		tournamentDao.delegate = self
		updateButtons()
		updateView()
	
		bracketController.updateTournamentProgress()
    }
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(true)
		
		// could make this a button... a click takes them to the page.
		challongeLinkLabel.delegate = self
		if tournament.url.count > 0 {
			challongeLinkLabel.text = "www.challonge.com/" + tournament.url
		}
	}
	
	// make it so user can't change the text, it just allows copying!
	func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
		return false
	}
	
	@IBAction func teamsButtonClicked(_ sender: UIButton) {
		// go to teams page.
	}
	
	
	@IBAction func refreshButtonClicked(_ sender: UIButton) {
		// refresh tournament data and reload.
		tournamentDao.getOnlineTournamentById(id: tournament.id)
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
		
		teamsButton.layer.cornerRadius = 20
		teamsButton.layer.borderColor = UIColor.white.cgColor
		teamsButton.layer.borderWidth = 1
	}
	
	func updateView() {
		tournamentNameLabel.text = tournament.name
		
		if tournament.isPoolPlay && !tournament.isPoolPlayFinished {
			poolPlayButton.isHidden = false
		} else {
			poolPlayButton.isHidden = true
		}
		
		if !tournament.isPoolPlay || tournament.isPoolPlayFinished {
			bracketButton.isHidden = false
		} else {
			bracketButton.isHidden = true
		}
	}
	
	// DAO DELEGATION METHODS
	
	// we got the tournament
	func didGetOnlineTournaments(onlineTournamentList: [Tournament]) {
		if let tournament = onlineTournamentList.first {
			tournamentDao.getTournamentData(tournament: tournament)
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
