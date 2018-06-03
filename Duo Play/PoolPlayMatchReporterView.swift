//
//  PoolPlayMatchReporter.swift
//  Duo Play
//
//  Created by Jordan Davis on 9/4/17.
//  Copyright © 2017 Jordan Davis. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift

class PoolPlayMatchReporterView : UIViewController {
    let realm = try! Realm()
    
    // the selected matchup gets stored here.
    var selectedMatchup = PoolPlayMatchup()
	var currentPool = Pool()
    
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
		title = "Pool Play"
        teamOneNameLabel.text = selectedMatchup.teamOne?.name
        teamTwoNameLabel.text = selectedMatchup.teamTwo?.name
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
        var numOfGamesPlayed = 1
        let teamOneGameOneScore = Int(teamOneGameOneScoreLabel.text!)
        let teamOneGameTwoScore = Int(teamOneGameTwoScoreLabel.text!)
        let teamOneGameThreeScore = Int(teamOneGameThreeScoreLabel.text!)
        
        let teamTwoGameOneScore = Int(teamTwoGameOneScoreLabel.text!)
        let teamTwoGameTwoScore = Int(teamTwoGameTwoScoreLabel.text!)
        let teamTwoGameThreeScore = Int(teamTwoGameThreeScoreLabel.text!)
        
        // Error checking the match before submitting
        
        // score isn't the same and ahead by atleast 2
        if teamOneGameOneScore != teamTwoGameOneScore {
            // difference of atleast one, all set.
        } else {
            //scores match
            let alert = UIAlertController(title: "Score Error",
                                          message: "Game One scores cannot match",
                                          preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action: UIAlertAction!) in
                return
            }))
            
            present(alert, animated: true, completion: nil)
        }
        
        // confirm game
        if teamOneGameTwoScore != teamTwoGameTwoScore {
            numOfGamesPlayed += 1
        }
        
        if teamOneGameThreeScore != teamTwoGameThreeScore {
            numOfGamesPlayed += 1
        }
        
        let message = "Games to report: \(numOfGamesPlayed) \n Please set scores to 0 if you do not want the game reported."
        
        let alert = UIAlertController(title: "Submit Game", message: message,
            preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action: UIAlertAction!) in
            // move on
            let reporterController = PoolPlayMatchReporterController()
            var teamOneScores = [Int]()
            teamOneScores.append(teamOneGameOneScore!)
            teamOneScores.append(teamOneGameTwoScore!)
            teamOneScores.append(teamOneGameThreeScore!)
            
            var teamTwoScores = [Int]()
            teamTwoScores.append(teamTwoGameOneScore!)
            teamTwoScores.append(teamTwoGameTwoScore!)
            teamTwoScores.append(teamTwoGameThreeScore!)
            
			reporterController.reportMatch(currentPool: self.currentPool,
										   selectedMatchup: self.selectedMatchup,
										   numOfGamesPlayed: numOfGamesPlayed,
										   teamOneScores: teamOneScores,
										   teamTwoScores: teamTwoScores)
			
            self.navigationController?.popViewController(animated: true)
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
            // cancel
            return
        }))
        
        present(alert, animated: true, completion: nil)
    }
}
