//
//  TournamentTeamsViewController.swift
//  Duo Play
//
//  Created by Jordan Davis on 2/27/18.
//  Copyright © 2018 Jordan Davis. All rights reserved.
//

import UIKit
import RealmSwift

class TournamentTeamsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    let realm = try! Realm()
    let tournament = TournamentController.getCurrentTournament()
    let teamsController = TeamsController()
    @IBOutlet weak var teamsTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        teamsTableView.delegate = self
        teamsTableView.dataSource = self
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        let bracketController = BracketController()
        bracketController.updateBracket()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Adding teams
    
    @IBAction func addTeam(_ sender: UIButton) {
        teamsTableView.setEditing(false, animated: true)
        // let's present an alert to enter a team. cleaner ui
        let alert = UIAlertController(title: "Add Team",
                                      message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Save", style: .default) { (alertAction) in
            _ = alert.textFields![0] as UITextField
            let newName = alert.textFields![0].text!
            let team = Team()
            
            try! self.realm.write() {
                team.name = newName
                team.division = "Advanced"
                team.bracketRounds.append(1)
                team.id = self.tournament.teamList.count + 1
                self.tournament.teamList.append(team)
            }
            
            self.teamsController.addTeam(team: team)
            self.teamsTableView.reloadData()
        }
        
        alert.addTextField { (textField) in
            textField.placeholder = "Team Name"
        }
        
        alert.addAction(action)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
            // cancel
            return
        }))
        
        present(alert, animated: true, completion: nil)
    }
    
    // MARK: - Tournament Teams Table View
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tournament.teamList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "teamCell")
        let team = tournament.teamList[indexPath.row]
        cell!.textLabel?.text = team.name
        
        return cell!
    }
}
