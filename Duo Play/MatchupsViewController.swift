//
//  MatchupsViewController.swift
//  Duo Play
//
//  Created by Jordan Davis on 1/1/18.
//  Copyright © 2018 Jordan Davis. All rights reserved.
//

import UIKit

class MatchupsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var matchupsTableView: UITableView!
    var matchupList = [BracketMatchup]()
    let tournament = TournamentController.getCurrentTournament()
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
        default:
            return 0
        }
    }
    
    func updateMatchupsList() {
        self.matchupList.removeAll()
        
        for matchup in tournament.matchupList {
            if !matchup.isReported {
                self.matchupList.append(matchup)
            }
        }
        
        matchupsTableView.reloadData()
    }
    
    // MARK: - Table View methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return matchupList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "matchupCell")
        let matchup = matchupList[indexPath.row]
        if !matchup.isReported {
            cell!.textLabel?.text = (matchup.teamOne?.name)! + "  vs.  " + (matchup.teamTwo?.name)!
        }
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedMatchup = matchupList[indexPath.row]
        performSegue(withIdentifier: "bracketReporterSegue", sender: selectedMatchup)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "bracketReporterSegue" {
            if let nextVC = segue.destination as? BracketReporterViewController {
                nextVC.selectedMatchup = sender as! BracketMatchup
            }
        }
    }

}
