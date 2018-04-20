//
//  PoolStandingsView.swift
//  Duo Play
//
//  Created by Jordan Davis on 12/31/17.
//  Copyright © 2017 Jordan Davis. All rights reserved.
//

import UIKit
import RealmSwift

class PoolStandingsView: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var teamStandingsTableView: UITableView!
    var pool = Pool()
    var teamList = [Team]()
	var poolController = PoolsController()
	var tournament = TournamentController.getCurrentTournament()
    
    override func viewDidLoad() {
        super.viewDidLoad()
		
        teamStandingsTableView.delegate = self
        teamStandingsTableView.dataSource = self
        
        updateTeamStandingsList()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        updateTeamStandingsList()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func updateTeamStandingsList() {
        self.teamList.removeAll()
		
        for team in tournament.teamList {
            self.teamList.append(team)
        }
        
        teamStandingsTableView.reloadData()
    }
    
    // MARK: - Table View methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.teamList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "standingsCell")
        let team = self.teamList[indexPath.row]
        cell!.textLabel?.text = "\(indexPath.row + 1). " + team.name + ": " + String(team.wins) + "-" + String(team.losses)
        return cell!
    }
}
