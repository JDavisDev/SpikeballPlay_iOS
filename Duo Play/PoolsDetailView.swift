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
    var poolName = "Pool A"
    var tournament = TournamentController.getCurrentTournament()
    var matchupList = [PoolPlayMatchup]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        matchupTableView.delegate = self
        matchupTableView.dataSource = self
        pool = getCurrentPool()
        generateMatchupList()
        // need to get current pool by passing in clicked ID or something
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        updateMatchupList()
    }
    
    func getCurrentPool() -> Pool {
        let realm = try! Realm()
        if let results = realm.objects(Pool.self).filter("name = '" + poolName + "'").first {
            return results
        }
        
        var pool = Pool()
        pool.name = "nil"
        return pool
    }
    
    func updateMatchupList() {
        self.matchupList.removeAll()
        
        // fetch matches left then update list
        try! realm.write() {
            for matchup in pool.matchupList {
                if !matchup.isReported {
                    self.matchupList.append(matchup)
                }
            }
        }
        
        matchupTableView.reloadData()
    }
    
    func generateMatchupList() {
        if pool.matchupList.count == 0 {
            // this will generate and add matchups to pool object
            generator.generatePoolPlayGames(pool: pool)
        }
        
        updateMatchupList()
    }
    
    // MARK: - Pools Table View
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MatchupCell")
        if !matchupList[indexPath.row].isReported  {
            cell!.textLabel?.text = String((matchupList[indexPath.row].teamOne?.name)! + " vs. " + (matchupList[indexPath.row].teamTwo?.name)!)
        }
        
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
        let selectedMatchup = self.matchupList[indexPath.row]
        self.performSegue(withIdentifier: "MatchupDetailVC", sender: selectedMatchup)
    }
    
    /// passing
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "MatchupDetailVC" {
            if let nextVC = segue.destination as? PoolPlayMatchReporterView {
                nextVC.selectedMatchup = sender as! PoolPlayMatchup
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
