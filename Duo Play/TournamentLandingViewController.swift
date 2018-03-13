//
//  TournamentLandingViewController.swift
//  Duo Play
//
//  Created by Jordan Davis on 3/11/18.
//  Copyright © 2018 Jordan Davis. All rights reserved.
//

import UIKit
import RealmSwift

class TournamentLandingViewController: UIViewController {

	@IBOutlet weak var poolPlayButton: UIButton!
	
	@IBOutlet weak var tournamentNameLabel: UILabel!
	@IBOutlet weak var bracketButton: UIButton!
	
	let realm = try! Realm()
	var tournament = Tournament()
	
    override func viewDidLoad() {
        super.viewDidLoad()

        tournament = TournamentController.getCurrentTournament()
    }
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(true)
		
		updateButtons()
		updateView()
	}
	
	func updateButtons() {
		poolPlayButton.layer.cornerRadius = 20
		poolPlayButton.layer.borderColor = UIColor.white.cgColor
		poolPlayButton.layer.borderWidth = 1
		
		bracketButton.layer.cornerRadius = 20
		bracketButton.layer.borderColor = UIColor.white.cgColor
		bracketButton.layer.borderWidth = 1
	}
	
	func updateView() {
		if tournament.isPoolPlay && !tournament.isPoolPlayFinished {
			poolPlayButton.isHidden = false
		} else {
			poolPlayButton.isHidden = true
		}
		
		tournamentNameLabel.text = tournament.name
		
		if !tournament.isPoolPlay || tournament.isPoolPlayFinished {
			bracketButton.isHidden = false
		} else {
			bracketButton.isHidden = true
		}
	}

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
