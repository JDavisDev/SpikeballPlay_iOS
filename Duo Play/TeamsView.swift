//
//  TeamsView.swift
//  SpikeballPlay
//
//  Created by Jordan Davis on 8/11/17.
//  Copyright © 2017 HoverSlam. All rights reserved.
//

import UIKit
import RealmSwift
import Crashlytics

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
	}
    
    override func viewDidAppear(_ animated: Bool) {
        updateTeamList()
    }
	
	func longPressGesture() -> UILongPressGestureRecognizer {
		let lpg = UILongPressGestureRecognizer(target: self, action: #selector(self.teamLongPress))
		lpg.minimumPressDuration = 0.5
		return lpg
	}
	
	@objc func teamLongPress(_ sender: UILongPressGestureRecognizer) {
		var selectedTeam = Team()
		
		if let label = sender.view?.subviews[0].subviews[0] as? UILabel {
			let name = label.text
			selectedTeam = teamsController.getTeamByName(name: name!, tournamentId: tournament.id)
		} else {
			return
		}
		
		//show dialog to rename or delete session
		let alert = UIAlertController(title: "Move Team",
									  message: "Enter Team's New Pool", preferredStyle: .alert)
		
		alert.addTextField { (textField) in
			textField.placeholder = "Pool Name"
			textField.text = selectedTeam.pool?.name
		}
		
		let moveToPoolAction = UIAlertAction(title: "Save", style: .default) { (alertAction) in
			_ = alert.textFields![0] as UITextField
			let newPoolName = alert.textFields![0].text!
			// find pool from pool name
			let newPool = self.poolsController.getPoolByName(name: newPoolName, tournamentId: self.tournament.id)
			
			if newPool.name != "nil" {
				self.showNewPoolConfirmationAlert(team: selectedTeam, pool: newPool)
			} else {
				self.showPoolSearchErrorAlert()
			}
		}
		
		alert.addAction(moveToPoolAction)
		
		let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { (alertAction) in
			
			self.updateTeamList()
			Answers.logCustomEvent(withName: "Team Deleted From Pool Play",
								   customAttributes: [:])
		}
		
		alert.addAction(deleteAction)
		
		alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
			// cancel
			return
		}))
		
		alert.popoverPresentationController?.sourceView = self.view
		self.present(alert, animated: true, completion: nil)
	}
	
	func showNewPoolConfirmationAlert(team: Team, pool: Pool) {
		let alert = UIAlertController(title: "Confirm Pool",
									  message: "Move team \(team.name) to \(pool.name)",
									  preferredStyle: .alert)
		
		alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action: UIAlertAction!) in
			try! self.realm.write {
				// assign new pool to team
				team.pool?.teamList.remove(at: (team.pool?.teamList.index(of: team))!)
				self.poolsController.addTeamToPool(pool: pool, team: team)
			}
			
			self.updateTeamList()
		}))
		
		alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
			return
		}))
		
		present(alert, animated: true, completion: nil)
	}
	
	func showPoolSearchErrorAlert() {
		let alert = UIAlertController(title: "Error",
									  message: "Could not find pool by that name.",
									  preferredStyle: .alert)
		
		alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action: UIAlertAction!) in
			return
		}))
		
		present(alert, animated: true, completion: nil)
	}
    
    func updateTeamList() {
        teamList.removeAll()
        
        for team in tournament.teamList {
            teamList.append(team)
        }
        
        teamsTableView.reloadData()
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
		// get the pool to match with the corresponding section
		let sourcePool = tournament.poolList[sourceIndexPath.section]
		let movedObject = sourcePool.teamList[sourceIndexPath.row]
		
		let destPool = tournament.poolList[destinationIndexPath.section]
		
		if sourcePool.isStarted || destPool.isStarted {
			showPoolStartedAlert()
		} else {
			try! realm.write {
				tournament.teamList.remove(at: tournament.teamList.index(of: movedObject)!)
				tournament.teamList.insert(movedObject, at: destinationIndexPath.row)
				sourcePool.teamList.remove(at: sourceIndexPath.row)
				destPool.teamList.append(movedObject)
			}
		}
		
        self.teamsTableView.reloadData()
    }
	
    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return .none
    }
		
    // moving and reassigning seems to work okay.
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "teamNameCell")
		
		// get the pool to match with the corresponding section
        let pool = tournament.poolList[indexPath.section]
		let team = pool.teamList[indexPath.row]
		
		if tournament.teamList.count > 0 {
        	cell!.textLabel?.text = team.name
        	cell?.detailTextLabel?.text = team.division
			cell?.addGestureRecognizer(self.longPressGesture())
		}
        return cell!
    }

	@IBAction func editTeamsButtonClicked(_ sender: UIButton) {
		if teamsTableView.isEditing {
			// turn editing off
			self.teamsTableView.setEditing(false, animated: true)
			editTeamsButton.setTitle("Edit", for: .normal)
		} else {
			// turn editing on
			self.teamsTableView.setEditing(true, animated: true)
			editTeamsButton.setTitle("Save", for: .normal)
		}
	}
	
	func showPoolStartedAlert() {
		let alert = UIAlertController(title: "Error",
									  message: "Pool has begun. You cannot make team changes.",
									  preferredStyle: .alert)
		
		alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action: UIAlertAction!) in
			return
		}))
		
		present(alert, animated: true, completion: nil)
	}
}
