//
//  SeedsViewController.swift
//  Duo Play
//
//  Created by Jordan Davis on 12/31/17.
//  Copyright © 2017 Jordan Davis. All rights reserved.
//

import UIKit
import Crashlytics

class SeedsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var teamSeedsTableView: UITableView!
	var bracketController = BracketController()
    var teamList = [Team]()
    let tournament = TournamentController.getCurrentTournament()
	@IBOutlet weak var editSeedsButton: UIButton!
	var didSeedsChange = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        teamSeedsTableView.delegate = self
        teamSeedsTableView.dataSource = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
		
		Answers.logContentView(withName: "Bracket Seeds Page View",
							   contentType: "Bracket Seeds Page View",
							   contentId: "12",
							   customAttributes: [:])
		
        updateTeamSeedsList()
		updateTitle()
    }
	
	func updateTitle() {
		if tournament.progress_meter > 0 {
			tabBarItem.title = "Standings"
			editSeedsButton.isHidden = true
		} else {
			tabBarItem.title = "Seeds"
			editSeedsButton.isHidden = false
		}
	}
    
    func updateTeamSeedsList() {
        self.teamList.removeAll()
        
        for team in tournament.teamList {
            self.teamList.append(team)
        }
        
        teamSeedsTableView.reloadData()
    }
	
	
	@IBAction func editSeedsButtonClicked(_ sender: UIButton) {
		if teamSeedsTableView.isEditing {
			// turn editing off
			self.teamSeedsTableView.setEditing(false, animated: true)
			editSeedsButton.setTitle("Edit Seeds", for: .normal)
			
			if didSeedsChange {
				bracketController.updateSeeds(teamList: teamList)
				didSeedsChange = false
			}
		} else {
			self.teamSeedsTableView.setEditing(true, animated: true)
			editSeedsButton.setTitle("Save Seeds", for: .normal)
		}
		
		self.teamSeedsTableView.reloadData()
	}
    
    // MARK: - Table View methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return teamList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "seedCell")
        let team = self.teamList[indexPath.row]
		if tournament.progress_meter > 0 {
			// tournament has started, show wins/losses
        	cell!.textLabel?.text = "\(indexPath.row + 1). " + team.name + ": " + String(team.wins) + "-" + String(team.losses)
		} else {
			// just show seeds.
			cell!.textLabel?.text = "\(indexPath.row + 1). " + team.name
		}
        return cell!
    }
	
	func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
		return .none
	}
	
	func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
		return false
	}
	
	func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
		let movedObject = self.teamList[sourceIndexPath.row]
		self.teamList.remove(at: sourceIndexPath.row)
		self.teamList.insert(movedObject, at: destinationIndexPath.row)
		didSeedsChange = true
		self.teamSeedsTableView.reloadData()
	}
	
	func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
		return true
	}
}
