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
    @IBOutlet weak var bracketOnlyLabel: UILabel!
    @IBOutlet weak var poolPlayAndBracketLabel: UILabel!
    
    let realm = try! Realm()
    let tournament = TournamentController.getCurrentTournament()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.rightBarButtonItem?.isEnabled = false
        playersPerPoolSegementedControl.isHidden = true
        playersPerPoolLabel.isHidden = true
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func isPoolPlaySwitchToggled(_ sender: UISwitch) {
        try! realm.write {
            tournament.isPoolPlay = sender.isOn
        }
        
        if sender.isOn {
            // bracket AND Pool Play
            poolPlayAndBracketLabel.textColor = UIColor.yellow
            bracketOnlyLabel.textColor = UIColor.white
            advanceButton.setTitle("Advance To Pool Play", for: UIControlState.normal)
            playersPerPoolSegementedControl.isHidden = false
            playersPerPoolLabel.isHidden = false
        } else {
            // pool play only
            poolPlayAndBracketLabel.textColor = UIColor.white
            bracketOnlyLabel.textColor = UIColor.yellow
            advanceButton.setTitle("Advance To Bracket", for: UIControlState.normal)
            playersPerPoolSegementedControl.isHidden = true
            playersPerPoolLabel.isHidden = true
        }
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
        
        let bracketController = BracketController()
        bracketController.updateBracket()
        
        
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
