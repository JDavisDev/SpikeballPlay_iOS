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
	let tournamentDAO = TournamentDAO()
    @IBOutlet weak var teamsTableView: UITableView!
	
	@IBOutlet weak var teamsSearchBar: UISearchBar!
	
	var didTeamsChange = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        teamsTableView.delegate = self
        teamsTableView.dataSource = self
    }
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(true)
		
		Answers.logContentView(withName: "Bracket Teams View",
							   contentType: "Bracket Teams View",
							   contentId: "7",
							   customAttributes: [:])
	}
    
    override func viewWillDisappear(_ animated: Bool) {
		if didTeamsChange {
			let bracketController = BracketController()
			
			for team in tournament.teamList {
				bracketController.resetTeamValues(team: team)
			}
			
			bracketController.createBracket()
			didTeamsChange = false
		}
		
		super.viewWillDisappear(true)
    }
    
    // MARK: - Adding teams
	
	@IBAction func addTeamsInBulk(_ sender: UIButton) {
		// debug only for now
		// add a ton of teams to see what happens
		if tournament.progress_meter <= 0 && !tournament.isReadOnly {
			for _ in 1...2 {
				let team = Team()
				
				try! self.realm.write() {
					team.name = "Team #" + String(tournament.teamList.count + 1)
					team.division = "Advanced"
					team.bracketRounds.append(1)
					team.id = self.tournament.teamList.count + 1
					self.tournament.teamList.append(team)
					team.tournament_id = self.tournament.id
				}
				
				self.teamsController.addTeam(team: team)
				self.tournamentDAO.addOnlineTournamentTeam(team: team)
			}
			
			
			self.didTeamsChange = true
			self.teamsTableView.reloadData()
		} else {
			presentTournamentStartedAlert()
		}
	}
    
    @IBAction func addTeam(_ sender: UIButton) {
        // check if tournament has started, only add teams if it has not.
        if tournament.progress_meter <= 0 && !tournament.isReadOnly {
            teamsTableView.setEditing(false, animated: true)
            // let's present an alert to enter a team. cleaner ui
            let alert = UIAlertController(title: "Add Team",
                                          message: "", preferredStyle: .alert)
            
            let action = UIAlertAction(title: "Save", style: .default) { (alertAction) in
                _ = alert.textFields![0] as UITextField
                let newName = alert.textFields![0].text!
				
				//make sure they entered a name!
				if newName.count > 0 {
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
					
					self.tournamentDAO.addOnlineTournamentTeam(team: team)
					self.didTeamsChange = true
					self.teamsController.addTeam(team: team)
					self.teamsTableView.reloadData()
				} else {
					self.presentEmptyTeamNameAlert()
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
			presentTournamentStartedAlert()
        }
    }
	
	func presentTournamentStartedAlert() {
		let alert = UIAlertController(title: "Tournament Started",
									  message: "The tournament has already begun, teams may not be changed.",
									  preferredStyle: .alert)
		
		alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action: UIAlertAction!) in
			// ok / dismiss
			return
		}))
		
		present(alert, animated: true, completion: nil)
	}
	
	func presentEmptyTeamNameAlert() {
		let alert = UIAlertController(title: "Error",
									  message: "Must enter a team name",
									  preferredStyle: .alert)
		
		alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action: UIAlertAction!) in
			// ok / dismiss
			return
		}))
		
		present(alert, animated: true, completion: nil)
	}
	
	func presentTournamentReadOnlyAlert() {
		let alert = UIAlertController(title: "Read Only",
									  message: "The tournament is locked and cannot be edited.",
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
        try! realm.write {
			self.tournamentDAO.deleteOnlineTournamentTeam(team: team, tournament: tournament)
            realm.delete(team.poolPlayGameList)
            realm.delete(team)
			self.didTeamsChange = true
        }
    }
    
    func longPressGesture() -> UILongPressGestureRecognizer {
        let lpg = UILongPressGestureRecognizer(target: self, action: #selector(self.longPress))
        lpg.minimumPressDuration = 0.5
        return lpg
    }
    
    @objc func longPress(_ sender: UILongPressGestureRecognizer) {
        var selectedTeam = Team()
		
		if tournament.progress_meter <= 0 && !tournament.isReadOnly {
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
					self.didTeamsChange = true
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
			presentTournamentStartedAlert()
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
        cell!.textLabel?.text = team.name
		cell!.textLabel?.textColor = UIColor.white
        button.setTitle(team.value(forKeyPath: "name") as? String,
                        for: .normal)
        
        button.addGestureRecognizer(self.longPressGesture())
        
        return cell!
    }
}
