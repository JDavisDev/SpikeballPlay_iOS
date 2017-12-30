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
        updateMatchupList()
        generateMatchupList()
        // need to get current pool by passing in clicked ID or something
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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        updateMatchupList()
    }
    
    func updateMatchupList() {
        self.matchupList.removeAll()
        
        // fetch matches left then update list
        try! realm.write() {
            for matchup in pool.matchupList {
                self.matchupList.append(matchup)
            }
        }
    }
    
    func generateMatchupList() {
        try! realm.write() {
            pool.matchupList.removeAll()
        }
        
        // this will generate and add matchups to pool object
        // worked for 4 teams
        generator.generatePoolPlayGames(pool: pool)
        
        updateMatchupList()
        matchupTableView.reloadData()
    }
    
    // MARK: - Pools Table View
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MatchupCell")
        cell!.textLabel?.text = String((matchupList[indexPath.row].teamOne?.name)! + " vs. " + (matchupList[indexPath.row].teamTwo?.name)!)
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

}
