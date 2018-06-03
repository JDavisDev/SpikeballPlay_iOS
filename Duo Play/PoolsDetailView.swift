//
//  PoolsDetailView.swift
//  Duo Play
//
//  Created by Jordan Davis on 11/14/17.
//  Copyright © 2017 Jordan Davis. All rights reserved.
//

import UIKit
import RealmSwift

class PoolsDetailView: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var matchupTableView: UITableView!
    
    let realm = try! Realm()
    let generator = PoolPlayMatchGenerator()
    
    var pool = Pool()
    var tournament = TournamentController.getCurrentTournament()
    var matchupList = [PoolPlayMatchup]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
		
        matchupTableView.delegate = self
        matchupTableView.dataSource = self
        pool = getCurrentPool()
		title = pool.name
		updateMatchupList()
    }
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(true)
		updateMatchupList()
	}
    
	func getCurrentPool() -> Pool {
		return PoolsController.getSelectedPool()
	}
    
    func updateMatchupList() {
		// this will generate and add matchups to pool object
		generateMatchupList()
		
        self.matchupList.removeAll()
        
        // fetch matches left then update list
        try! realm.write() {
            for matchup in pool.matchupList {
                if !matchup.isReported && matchup.teamOne != nil && matchup.teamTwo != nil {
                    self.matchupList.append(matchup)
                }
            }
        }
		
		// no more matches, lock it down!
		if pool.isStarted && matchupList.count <= 0 {
			finishPool()
		}
		
        matchupTableView.reloadData()
    }
    
    func generateMatchupList() {
		if !pool.isStarted {
			generator.generatePoolPlayGames(pool: pool)
		}
    }
	
	@IBAction func finishPoolButton(_ sender: UIButton) {
		// let's show a dialog to confirm!
		showFinishPoolDialog()
	}
	
	func showFinishPoolDialog() {
		let message = "Finish Pool and close all match ups?"
		
		let alert = UIAlertController(title: "Finalize Pool", message: message,
									  preferredStyle: .alert)
		
		alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action: UIAlertAction!) in
			self.finishPool()
		}))
		
		alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
			// cancel
			return
		}))
		
		present(alert, animated: true, completion: nil)
	}
	
	func finishPool() {
		try! realm.write {
			for matchup in pool.matchupList {
				matchup.isReported = true
			}
			
			pool.isFinished = true
		}
		
		checkIfPoolPlayFinished()
		
		self.navigationController?.popViewController(animated: true)
	}
	
	func checkIfPoolPlayFinished() {
		var isPoolPlayFinished = true
		
		try! realm.write {
			for pool in tournament.poolList {
				if !pool.isFinished {
					isPoolPlayFinished = false
				}
			}
			
			tournament.isPoolPlayFinished = isPoolPlayFinished
		}
		
		if isPoolPlayFinished {
			let poolsController = PoolsController()
			poolsController.finishPoolPlay()
		}
	}
	
    // MARK: - Pools Table View
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MatchupCell")
		// don't show reported games
		// need to add to not show more than one game per team? Just the next available game?
		let nextMatchup = matchupList[indexPath.row]
		
        if !nextMatchup.isReported  {
			// if a team in the matchup is nil, that must be a rest game!
			if nextMatchup.teamOne == nil {
				cell!.textLabel?.text = String((nextMatchup.teamTwo?.name)! + " vs. REST")
			} else if nextMatchup.teamTwo == nil {
				cell!.textLabel?.text = String((nextMatchup.teamOne?.name)! + " vs. REST")
			} else {
            	cell!.textLabel?.text = "Round \(nextMatchup.round) : " + String((nextMatchup.teamOne?.name)! + " vs. " + (nextMatchup.teamTwo?.name)!)
			}
        }
		
		cell?.textLabel?.textColor = UIColor.white
        return cell!
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return matchupList.count
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // make the cell act as a button to report
		// make sure that both teams are NOT nil
		// if tapped, maybe clear the row, show a dialog to mark it finished?
		// or hide it completely.
		if self.matchupList[indexPath.row].teamOne == nil ||
			self.matchupList[indexPath.row].teamTwo == nil {
			try! realm.write {
				self.matchupList[indexPath.row].isReported = true
				self.pool.matchupList[indexPath.row].isReported = true
			}
			
			updateMatchupList()
			self.matchupTableView.reloadData()
			return
		}
		
        let selectedMatchup = self.matchupList[indexPath.row]
        self.performSegue(withIdentifier: "MatchupDetailVC", sender: selectedMatchup)
    }
    
    /// passing
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "MatchupDetailVC" {
            if let nextVC = segue.destination as? PoolPlayMatchReporterView {
                nextVC.selectedMatchup = sender as! PoolPlayMatchup
				nextVC.currentPool = self.pool
            }
        }
    }
    
    func isMatchupAvailable(matchup: PoolPlayMatchup) -> Bool {
        // only show first match of each team
        var counter = 0
        for game in matchupList {
            if !game.isReported && (game.teamOne!.name == matchup.teamOne!.name || game.teamTwo!.name == matchup.teamTwo!.name ||
                game.teamTwo!.name == matchup.teamOne!.name || game.teamOne!.name == matchup.teamTwo?.name) {
                counter += 1
            }
            
            if counter >= 2 {
                return false
            }
        }
        
        return true
    }
}
