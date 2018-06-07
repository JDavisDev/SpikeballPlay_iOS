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
    let teamsController = TeamsController()
	let searchController = UISearchController(searchResultsController: nil)
    let poolsController = PoolsController()
    let realm = try! Realm()
    let tournament = TournamentController.getCurrentTournament()
	
	@IBOutlet weak var searchBar: UISearchBar!
	var teamList = [Team]()
	var bracketController = BracketController()
	var filteredTeams = [Team]()
	
    @IBOutlet weak var teamNameTextField: UITextField!
    @IBOutlet weak var teamsTableView: UITableView!
    
    override func viewDidLoad() {
		super.viewDidLoad()
		
        title = "Teams"
        teamsTableView.delegate = self
        teamsTableView.dataSource = self
		// Setup the Search Controller
		searchController.searchResultsUpdater = self
		searchController.obscuresBackgroundDuringPresentation = false
		searchController.searchBar.placeholder = "Search Teams"
		teamsTableView.tableHeaderView = searchController.searchBar
		definesPresentationContext = true
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
		
		showMoveTeamDialog(selectedTeam: selectedTeam)
	}
	
	func showMoveTeamDialog(selectedTeam: Team) {
		if (selectedTeam.pool.isStarted) || (selectedTeam.pool.isFinished) || self.tournament.isReadOnly || self.tournament.isStarted {
			self.showPoolStartedAlert()
			return
		}
		
		let alert = UIAlertController(title: "Move Team",
									  message: "Enter Team's New Pool", preferredStyle: .alert)
		
		alert.addTextField { (textField) in
			textField.placeholder = "Pool Name"
			textField.text = selectedTeam.pool.name
		}
		
		let moveToPoolAction = UIAlertAction(title: "Save", style: .default) { (alertAction) in
			_ = alert.textFields![0] as UITextField
			let newPoolName = alert.textFields![0].text!
			// find pool from pool name
			let newPool = self.poolsController.searchPoolByName(name: newPoolName, tournamentId: self.tournament.id)
			
			if newPool.name != "nil" {
				if newPool.isFinished || newPool.isStarted || self.tournament.isReadOnly {
					self.showPoolStartedAlert()
					return
				} else {
					self.showNewPoolConfirmationAlert(team: selectedTeam, pool: newPool)
				}
			} else {
				self.showPoolSearchErrorAlert()
			}
		}
		
		alert.addAction(moveToPoolAction)
		
		let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { (alertAction) in
			self.deleteTeam(team: selectedTeam)
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
	
	func deleteTeam(team: Team) {
		if (team.pool.isStarted) || (team.pool.isFinished) || self.tournament.isReadOnly || self.tournament.isStarted {
			self.showPoolStartedAlert()
			return
		}
		
		try! realm.write {
			//self.tournamentDAO.deleteOnlineTournamentTeam(team: team, tournament: tournament)
			let pool = team.pool
			let index = pool.teamList.index(of: team)
			team.pool.teamList.remove(at: index!)
			
			let tourneyIndex = tournament.teamList.index(of: team)
			tournament.teamList.remove(at: tourneyIndex!)
			
			realm.delete(team.poolPlayGameList)
			realm.delete(team)
		}
		
		updateTeamList()
	}
	
	func showNewPoolConfirmationAlert(team: Team, pool: Pool) {
		let alert = UIAlertController(title: "Confirm Pool",
									  message: "Move team \(team.name) to \(pool.name)",
									  preferredStyle: .alert)
		
		alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action: UIAlertAction!) in
			try! self.realm.write {
				// assign new pool to team
				team.pool.teamList.remove(at: (team.pool.teamList.index(of: team))!)
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
		
		if let pool = tournament.poolList.last {
			if pool.isStarted || pool.isFinished || self.tournament.isReadOnly || self.tournament.isStarted {
				self.showPoolStartedAlert()
				return
			}
		}
		
        // let's present an alert to enter a team. cleaner ui
        let alert = UIAlertController(title: "Add Team",
                                      message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Save", style: .default) { (alertAction) in
            _ = alert.textFields![0] as UITextField
            let newName = alert.textFields![0].text!
			
			if !self.isTeamNameUnique(teamName: newName) {
				self.showTeamNameNotUniqueAlert()
				return
			}
			
            let team = Team()
            
            try! self.realm.write() {
                team.name = newName
                team.division = "Advanced"
                team.bracketRounds.append(1)
                team.id = self.tournament.teamList.count + 1
                self.tournament.teamList.append(team)
                team.tournament_id = self.tournament.id
            }
			
			self.updateTeamList()
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
	
	private func isTeamNameUnique(teamName: String) -> Bool {
		let dbManager = DBManager()
		if !realm.isInWriteTransaction {
			dbManager.beginWrite()
		}
		
		for team in tournament.teamList {
			if team.name.lowercased() == teamName.lowercased() {
				return false
			}
		}
		
		if realm.isInWriteTransaction {
			dbManager.commitWrite()
		}
		
		return true
	}
	
	private func showTeamNameNotUniqueAlert() {
		let alert = UIAlertController(title: "Error",
									  message: "Team Name Must Be Unique",
									  preferredStyle: .alert)
		
		alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action: UIAlertAction!) in
			return
		}))
		
		present(alert, animated: true, completion: nil)
	}
    
    //MARK: Table view init
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // fetches the number of teams in this pool
		if isFiltering() {
			return filteredTeams.count
		}
		
        return tournament.poolList[section].teamList.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
		if isFiltering() {
			return 1
		}
        return tournament.poolList.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        //Idk if this does anything but I think I need it here
        return "Pool"
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		let header = tableView.dequeueReusableCell(withIdentifier: "teamNameCell")
		if isFiltering() {
			header?.textLabel?.text = "Teams"
		} else {
        	header?.textLabel?.text = tournament.poolList[section].name
		}
        return header
    }
    
    // Dragging teams around
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
		// get the pool to match with the corresponding section
		let sourcePool = tournament.poolList[sourceIndexPath.section]
		let movedObject = sourcePool.teamList[sourceIndexPath.row]
		
		let destPool = tournament.poolList[destinationIndexPath.section]
		
		if sourcePool.isStarted || destPool.isStarted || sourcePool.isFinished || destPool.isFinished {
			showPoolStartedAlert()
		} else {
			try! realm.write {
				tournament.teamList.remove(at: tournament.teamList.index(of: movedObject)!)
				tournament.teamList.insert(movedObject, at: destinationIndexPath.row)
				sourcePool.teamList.remove(at: sourceIndexPath.row)
				destPool.teamList.append(movedObject)
			}
		}
		
		updateTeamList()
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
		if isFiltering() {
			// handle this diff
			if filteredTeams.count > indexPath.row {
				let team = filteredTeams[indexPath.row]
				cell!.textLabel?.text = team.name
				cell?.detailTextLabel?.text = team.division
				cell?.addGestureRecognizer(self.longPressGesture())
			}
		} else {
			let pool = tournament.poolList[indexPath.section]
			let team = pool.teamList[indexPath.row]
			
			if tournament.teamList.count > 0 {
				cell!.textLabel?.text = team.name
				cell?.detailTextLabel?.text = team.division
				cell?.addGestureRecognizer(self.longPressGesture())
			}
		}
        return cell!
    }
	
	func tableView(_ tableView: UITableView, editActionsForRowAt: IndexPath) -> [UITableViewRowAction]? {
		let move = UITableViewRowAction(style: .normal, title: "Move") { action, index in
			let pool = self.tournament.poolList[index.section]
			self.showMoveTeamDialog(selectedTeam: pool.teamList[index.row])
		}
		move.backgroundColor = .lightGray
		
		let rename = UITableViewRowAction(style: .normal, title: "Rename") { action, index in
			let pool = self.tournament.poolList[index.section]
			self.showRenameTeamAlert(team: pool.teamList[index.row])
		}
		rename.backgroundColor = .orange
		
		let delete = UITableViewRowAction(style: .destructive, title: "Delete") { action, index in
			let pool = self.tournament.poolList[index.section]
			self.deleteTeam(team: pool.teamList[index.row])
		}
		
		return [delete, rename, move]
	}
	
	func showRenameTeamAlert(team: Team) {
		if !tournament.isStarted && !tournament.isReadOnly {
			//show dialog to rename or delete a team
			let alert = UIAlertController(title: "Rename",
										  message: "", preferredStyle: .alert)
			
			alert.addTextField { (textField) in
				textField.placeholder = "Team Name"
				textField.text = team.name
			}
			
			let renameAction = UIAlertAction(title: "Save", style: .default) { (alertAction) in
				_ = alert.textFields![0] as UITextField
				let newName = alert.textFields![0].text!
				try! self.realm.write {
					team.name = newName
				}
				
				// update lists
				self.teamsTableView.reloadData()
			}
			alert.addAction(renameAction)
			
			alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
				// cancel
				return
			}))
			
			alert.popoverPresentationController?.sourceView = self.view
			self.present(alert, animated: true, completion: nil)
		}
	}

	@IBAction func editTeamsButtonClicked(_ sender: UIButton) {
		if teamsTableView.isEditing {
			// turn editing off
			self.teamsTableView.setEditing(false, animated: true)
			editTeamsButton.setTitle("Move Teams", for: .normal)
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
	
	// MARK: - Search Bar methods
	
	func isFiltering() -> Bool {
		return searchController.isActive && !searchBarIsEmpty()
	}
	
	func searchBarIsEmpty() -> Bool {
		// Returns true if the text is empty or nil
		return searchController.searchBar.text?.isEmpty ?? true
	}
	
	func filterContentForSearchText(_ searchText: String, scope: String = "All") {
		filteredTeams = teamList.filter({( team : Team) -> Bool in
			return team.name.lowercased().contains(searchText.lowercased())
		})
		
		teamsTableView.reloadData()
	}
}

extension TeamsView: UISearchResultsUpdating {
	// MARK: - UISearchResultsUpdating Delegate
	func updateSearchResults(for searchController: UISearchController) {
		filterContentForSearchText(searchController.searchBar.text!)
	}
}
