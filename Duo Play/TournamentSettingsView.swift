//
//  SettingsViewController.swift
//  SpikeballPlay
//
//  Created by Jordan Davis on 8/11/17.
//  Copyright © 2017 HoverSlam. All rights reserved.
//

import UIKit
import RealmSwift

class TournamentSettingsView: UIViewController {
    
    @IBOutlet weak var tournamentNameTextField: UITextField!
    @IBOutlet weak var isQuickReportSwitch: UISwitch!
    @IBOutlet weak var isBracketOnlySwitch: UISwitch!
    @IBOutlet weak var playersPerPoolSegementedControl: UISegmentedControl!
    @IBOutlet weak var advanceButton: UIButton!
    @IBOutlet weak var playersPerPoolLabel: UILabel!
	
	@IBOutlet weak var poolPlayAndBracketButton: UIButton!
	@IBOutlet weak var bracketOnlyButton: UIButton!
    
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
			advanceButton.setTitle("Advance To Pool Play", for: UIControlState.normal)
			playersPerPoolSegementedControl.isHidden = false
			playersPerPoolLabel.isHidden = false
		} else {
			// bracket only
			poolPlayAndBracketButton.setTitleColor(UIColor.white, for: .normal)
			bracketOnlyButton.setTitleColor(UIColor.yellow, for: .normal)
			advanceButton.setTitle("Advance To Bracket", for: UIControlState.normal)
			playersPerPoolSegementedControl.isHidden = true
			playersPerPoolLabel.isHidden = true
		}
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
	
	@IBAction func deleteButton(_ sender: UIButton) {
		// show safety dialog first.
		try! realm.write {
			for team in tournament.teamList {
				for game in team.poolPlayGameList {
					realm.delete(game)
				}
				
				realm.delete(team)
			}
			
			for matchup in tournament.matchupList {
				realm.delete(matchup)
			}
			
			for pool in tournament.poolList {
				for matchup in pool.matchupList {
					realm.delete(matchup)
				}
				
				realm.delete(pool)
			}
			
			realm.delete(tournament)
		}
		
		navigationController?.popViewController(animated: true)
	}
	
	@IBAction func poolPlayAndBracketButton(_ sender: UIButton) {
		try! realm.write {
			tournament.isPoolPlay = true
		}
		
		// bracket AND Pool Play
		poolPlayAndBracketButton.setTitleColor(UIColor.yellow, for: .normal)
		bracketOnlyButton.setTitleColor(UIColor.white, for: .normal)
		advanceButton.setTitle("Advance To Pool Play", for: UIControlState.normal)
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
		advanceButton.setTitle("Advance To Bracket", for: UIControlState.normal)
		playersPerPoolSegementedControl.isHidden = true
		playersPerPoolLabel.isHidden = true
	}
	
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    @IBAction func advanceButtonClicked(_ sender: UIButton) {
        // if pool play, go to that tab bar
        // else go to bracket play
		if !tournament.isPoolPlay {
			let bracketController = BracketController()
			bracketController.createBracket()
			
			performSegue(withIdentifier: "bracketSegue", sender: self)
		} else {
			performSegue(withIdentifier: "poolPlaySegue", sender: self)
		}
    }
    
    @IBAction func saveSettings(_ sender: UIButton) {
        TournamentController.IS_QUICK_REPORT = isQuickReportSwitch.isOn
        
        try! realm.write {
            tournament.isQuickReport = isQuickReportSwitch.isOn
            tournament.playersPerPool = playersPerPoolSegementedControl.selectedSegmentIndex + 6
            tournament.name = (tournamentNameTextField.text?.count.magnitude)! > 0 ?
                tournamentNameTextField.text! :
                tournament.name
        }
    }
    
}
