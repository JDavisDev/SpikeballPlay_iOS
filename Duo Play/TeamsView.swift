//
//  TeamsView.swift
//  SpikeballPlay
//
//  Created by Jordan Davis on 8/11/17.
//  Copyright © 2017 HoverSlam. All rights reserved.
//

import UIKit
import RealmSwift

class TeamsView: UIViewController, UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate {
    
	@IBOutlet weak var editTeamsButton: UIButton!
	@IBOutlet var longPressRecognizer: UILongPressGestureRecognizer!
    var teamsController = TeamsController()
    let poolsController = PoolsController()
    let realm = try! Realm()
    let tournament = TournamentController.getCurrentTournament()
    var teamList = [Team]()
	var bracketController = BracketController()
    
    @IBOutlet weak var teamNameTextField: UITextField!
    @IBOutlet weak var teamsTableView: UITableView!
    
    override func viewDidLoad() {
		super.viewDidLoad()
		
        title = "Teams"
        teamsTableView.delegate = self
        teamsTableView.dataSource = self
		
        initGestureRecognizer()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        updateTeamList()
    }
    
    func updateTeamList() {
        teamList.removeAll()
        
        for team in tournament.teamList {
            teamList.append(team)
        }
        
        teamsTableView.reloadData()
    }
    
    func initGestureRecognizer() {
        longPressRecognizer.delegate = self
        longPressRecognizer.addTarget(self, action: #selector(self.onLongPress))
        self.teamsTableView.addGestureRecognizer(longPressRecognizer)
    }
    
    @objc func onLongPress() {
        //teamsTableView.setEditing(true, animated: true)
    }
    
    
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
                team.tournament_id = self.tournament.id
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
    
    //MARK: Table view init
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // fetches the number of teams in this pool
        return tournament.poolList[section].teamList.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return tournament.poolList.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        //Idk if this does anything but I think I need it here
        return "Pool"
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableCell(withIdentifier: "teamNameCell")
        header?.textLabel?.text = tournament.poolList[section].name
        return header
    }
    
    // Dragging teams around
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let movedObject = tournament.teamList[sourceIndexPath.row]
		try! realm.write {
			tournament.teamList.remove(at: sourceIndexPath.row)
			tournament.teamList.insert(movedObject, at: destinationIndexPath.row)
		}
		
		resetPoolTeams()
        self.teamsTableView.reloadData()
		
    }
    
    func resetPoolTeams() {
        // teams were moved around, reset which pool they belong to
		
		try! realm.write {
			for pool in tournament.poolList {
				pool.teamList.removeAll()
			}
		}
		
			
			var poolIndex = 0
			for index in 1...tournament.teamList.count {
				if index % tournament.playersPerPool == 0 {
					poolIndex += 1
				}
				
				if tournament.poolList.count > poolIndex && tournament.teamList.count > index - 1 {
					poolsController.addTeamToPool(pool: tournament.poolList[poolIndex], team: tournament.teamList[index - 1])
				}
		}
    }
    
    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return .none
    }
    
    // moving and reassigning seems to work okay.
    // Just need help accessing each row in each section.
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "teamNameCell")
        
        // hacky modifier.. 
        let modifier = indexPath.section * tournament.teamList.count - 1 > 0 ? (indexPath.section * tournament.playersPerPool) : 0
		
		if tournament.teamList.count > indexPath.row + modifier {
        	cell!.textLabel?.text = tournament.teamList[indexPath.row + modifier].name
        	cell?.detailTextLabel?.text = String(describing: tournament.teamList[indexPath.row].division)
		}
        return cell!
    }

	@IBAction func editTeamsButtonClicked(_ sender: UIButton) {
		if teamsTableView.isEditing {
			// turn editing off
			self.teamsTableView.setEditing(false, animated: true)
			editTeamsButton.setTitle("Edit", for: .normal)
			//bracketController.updateSeeds(teamList: teamList)
		} else {
			self.teamsTableView.setEditing(true, animated: true)
			editTeamsButton.setTitle("Save", for: .normal)
		}
	}
}
