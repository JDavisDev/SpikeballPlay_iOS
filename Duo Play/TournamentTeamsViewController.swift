//
//  TournamentTeamsViewController.swift
//  Duo Play
//
//  Created by Jordan Davis on 2/27/18.
//  Copyright © 2018 Jordan Davis. All rights reserved.
//

import UIKit
import RealmSwift
import Crashlytics

class TournamentTeamsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    let realm = try! Realm()
    let tournament = TournamentController.getCurrentTournament()
    let teamsController = TeamsController()
	let tournamentDAO = TournamentFirebaseDao()
	let challongeTeamsAPI = ChallongeTeamsAPI()
	
	@IBOutlet weak var editSeedsButton: UIButton!
	@IBOutlet weak var teamsTableView: UITableView!
	@IBOutlet weak var teamsSearchBar: UISearchBar!
	
    override func viewDidLoad() {
        super.viewDidLoad()
        
        teamsTableView.delegate = self
        teamsTableView.dataSource = self
    }
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(true)
		
		Answers.logContentView(withName: "Bracket Teams View",
							   contentType: "Bracket Teams View",
							   contentId: "7",
							   customAttributes: [:])
	}
    
    @IBAction func addTeam(_ sender: UIButton) {
        // check if tournament has started, only add teams if it has not.
        if !tournament.isStarted && !tournament.isReadOnly {
            teamsTableView.setEditing(false, animated: true)
            // let's present an alert to enter a team. cleaner ui
            let alert = UIAlertController(title: "Add Team",
                                          message: "", preferredStyle: .alert)
            
            let action = UIAlertAction(title: "Save", style: .default) { (alertAction) in
                _ = alert.textFields![0] as UITextField
                let newName = alert.textFields![0].text!
				
				//make sure they entered a name!
				if newName.count > 0 {
					self.createNewTeam(newName: newName)
					self.teamsTableView.reloadData()
				} else {
					self.presentTournamentErrorAlert(title: "Error", message: "Name cannot be empty")
				}
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
        } else {
			presentTournamentErrorAlert(title: "Tournament Started", message: "The tournament has already begun, teams may not be changed.")
        }
    }
	
	func createNewTeam(newName: String) {
		let team = Team()
		
		try! self.realm.write() {
			team.name = newName
			team.division = "Advanced"
			team.bracketRounds.append(1)
			team.id = self.tournament.teamList.count + 1
			team.seed = team.id
			self.tournament.teamList.append(team)
			team.tournament_id = self.tournament.id
		}
	
		self.teamsController.addTeam(team: team)
		
		let teamFirebaseDao = TeamFirebaseDao()
		teamFirebaseDao.addFirebaseTeam(team: team)
	}
	
	func saveTeamToChallonge(team: Team) {
		// challonge additions
		// idk if ill need these parsers since i have dictionaries
		//let teamsParser = TeamParser()
		//self.challongeTeamsAPI.delegate = teamsParser
		self.challongeTeamsAPI.createChallongeParticipant(tournament: tournament, team: team)
	}
	
	@IBAction func editSeedsClicked(_ sender: UIButton) {
		if !teamsTableView.isEditing {
			teamsTableView.setEditing(true, animated: true)
			editSeedsButton.setTitle("Save Seeds", for: .normal)
		} else {
			teamsTableView.setEditing(false, animated: true)
			editSeedsButton.setTitle("Edit Seeds", for: .normal)
		}
	}
	
	func presentTournamentErrorAlert(title: String, message: String) {
		let alert = UIAlertController(title: title,
									  message: message,
									  preferredStyle: .alert)
		
		alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action: UIAlertAction!) in
			// ok / dismiss
			return
		}))
		
		present(alert, animated: true, completion: nil)
	}
    
    func getTeamByName(name: String) -> Team {
        return realm.objects(Team.self).filter("name = '\(name)' AND tournament_id = \(tournament.id)").first!
    }
    
    func deleteTeam(team: Team) {
		let teamFirebaseDao = TeamFirebaseDao()
		
        try! realm.write {
			teamFirebaseDao.deleteFirebaseTeam(team: team, tournament: tournament)
            realm.delete(team.poolPlayGameList)
            realm.delete(team)
        }
    }
    
    func longPressGesture() -> UILongPressGestureRecognizer {
        let lpg = UILongPressGestureRecognizer(target: self, action: #selector(self.longPress))
        lpg.minimumPressDuration = 0.5
        return lpg
    }
    
    @objc func longPress(_ sender: UILongPressGestureRecognizer) {
        var selectedTeam = Team()
		
		if !tournament.isStarted && !tournament.isReadOnly {
			if let button = sender.view as? UIButton {
				let name = button.currentTitle
				selectedTeam = getTeamByName(name: name!)
			} else {
				return
			}
			
			//show dialog to rename or delete a team
			let alert = UIAlertController(title: "Edit Team",
										  message: "", preferredStyle: .alert)
			
			alert.addTextField { (textField) in
				textField.placeholder = "Team Name"
				textField.text = selectedTeam.name
			}
			
			let renameAction = UIAlertAction(title: "Save", style: .default) { (alertAction) in
				_ = alert.textFields![0] as UITextField
				let newName = alert.textFields![0].text!
				try! self.realm.write {
					let team = selectedTeam
					team.name = newName
				}
				
				// update lists
				self.teamsTableView.reloadData()
			}
			alert.addAction(renameAction)
			
			let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { (alertAction) in
				self.deleteTeam(team: selectedTeam)
				self.teamsTableView.reloadData()
				Answers.logCustomEvent(withName: "Tournament Team Deleted",
									   customAttributes: [:])
			}
			
			alert.addAction(deleteAction)
			
			alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
				// cancel
				// update history list
				self.viewDidAppear(true)
				return
			}))
			
			alert.popoverPresentationController?.sourceView = self.view
			self.present(alert, animated: true, completion: nil)
		} else {
			presentTournamentErrorAlert(title: "Tournament Started", message: "The tournament has already begun, teams may not be changed.")
		}
    }
    
    // MARK: - Tournament Teams Table View
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tournament.teamList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "teamCell")
        let button = cell?.contentView.subviews[0] as! UIButton
        let team = tournament.teamList[indexPath.row]
        button.setTitle(team.value(forKeyPath: "name") as? String,
                        for: .normal)
        
        button.addGestureRecognizer(self.longPressGesture())
        
        return cell!
    }
	
	// Dragging teams around
	func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
		let movedObject = tournament.teamList[sourceIndexPath.row]
		
		if tournament.isStarted || tournament.isReadOnly {
			presentTournamentErrorAlert(title: "Editing Error", message: "The tournament is locked and cannot be edited.")
		} else {
			try! realm.write {
				tournament.teamList.remove(at: tournament.teamList.index(of: movedObject)!)
				tournament.teamList.insert(movedObject, at: destinationIndexPath.row)
				reseedBasedOnPosition()
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
	
	func reseedBasedOnPosition() {
		var seed = 1
		for team in tournament.teamList {
			team.seed = seed
			seed += 1
		}
	}
}
