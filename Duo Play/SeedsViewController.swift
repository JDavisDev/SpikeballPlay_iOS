//
//  SeedsViewController.swift
//  Duo Play
//
//  Created by Jordan Davis on 12/31/17.
//  Copyright © 2017 Jordan Davis. All rights reserved.
//

import UIKit

class SeedsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var teamSeedsTableView: UITableView!
    var teamList = [Team]()
    let tournament = TournamentController.getCurrentTournament()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        teamSeedsTableView.delegate = self
        teamSeedsTableView.dataSource = self
        
        updateTeamSeedsList()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        updateTeamSeedsList()
    }
    
    func updateTeamSeedsList() {
        self.teamList.removeAll()
        
        for team in tournament.teamList {
            self.teamList.append(team)
        }
        
        teamSeedsTableView.reloadData()
    }
    
    // MARK: - Table View methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return teamList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "seedCell")
        let team = self.teamList[indexPath.row]
        cell!.textLabel?.text = "\(indexPath.row + 1). " + team.name + ": " + String(team.wins) + "-" + String(team.losses)
        return cell!
    }
    
//    // Dragging teams around
//    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
//        let movedObject = self.teamList[sourceIndexPath.row]
//        self.teamList.remove(at: sourceIndexPath.row)
//        self.teamList.insert(movedObject, at: destinationIndexPath.row)
//        self.teamSeedsTableView.reloadData()
//    }

}
