//
//  TournamentsHome.swift
//  SpikeballPlay
//
//  Created by Jordan Davis on 8/11/17.
//  Copyright © 2017 HoverSlam. All rights reserved.
//

import UIKit
import RealmSwift
import Crashlytics
import Firebase

class TournamentsHomeView: UIViewController, UITableViewDataSource, UITableViewDelegate, TournamentParserDelegate {

    let tournamentController = TournamentController()
    var tournamentList = [Tournament]()
    let realm = try! Realm()
    let challongeConnector = ChallongeAPI()
	let tournamentDao = TournamentDAO()
	let fireDB = Firestore.firestore()
	let tournamentParser = TournamentParser()
	
	var onlineTournamentList = [[String:Any]]()
	
    @IBOutlet weak var tournamentNameTextField: UITextField!
    @IBOutlet weak var tournamentTableView: UITableView!
        
    override func viewDidLoad() {
        tournamentTableView.delegate = self
        tournamentTableView.dataSource = self
		tournamentParser.delegate = self
		
		super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
		Answers.logContentView(withName: "Tournaments Page View",
							   contentType: "Tournaments Page View",
							   contentId: "8",
							   customAttributes: [:])
		
		tournamentList.removeAll()
		getOnlineTournaments()
		updateLocalTournamentList()
        
        super.viewDidAppear(true)
    }
    
    @IBAction func addTournamentButtonClicked(_ sender: UIButton) {
        let tournament = Tournament()
        
        tournament.name = "Tournament #" + String(tournamentList.count + 1)
        
        let max = 2147483600
        var id = Int(arc4random_uniform(UInt32(max)))
        while !isIdUnique(id: id) {
            id = Int(arc4random_uniform(UInt32(max)))
        }
        
        tournament.id = Int(id)
        
        tournament.poolList = List<Pool>()
        tournament.teamList = List<Team>()
        
        try! realm.write {
            realm.add(tournament)
            tournamentList.append(tournament)
        }

		Analytics.logEvent("Tournament_Created", parameters: [
			"id": id ])
		
        TournamentController.setTournamentId(id: id)
        updateTournamentList()
    }
    
    func isIdUnique(id: Int) -> Bool {
        var count = 0
        try! realm.write {
             count = realm.objects(Tournament.self).filter("id = \(id)").count
        }
        
        return count == 0
    }
    
//    @IBAction func getOnlineTournamentButtonClicked(_ sender: UIButton) {
//        parseOnlineTournaments()
//    }
//
//    func parseOnlineTournaments() {
//        challongeConnector.getTournaments()
//        let onlineTournaments = challongeConnector.tournamentList
//
//        for tournament in onlineTournaments {
//            let newTournament = Tournament()
//
//            // assign properties from online tournament to realm tournament for local storage
//            newTournament.name = tournament.value(forKey: "name") as! String
//            newTournament.id = tournament.value(forKey: "id") as! Int
//            newTournament.poolList = List<Pool>()
//            newTournament.teamList = List<Team>()
//            newTournament.full_challonge_url = tournament.value(forKey: "full_challonge_url") as! String
//            newTournament.game_id = tournament.value(forKey: "game_id") as! Int
//            newTournament.isPrivate = tournament.value(forKey: "private") as! Bool
//            newTournament.live_image_url = tournament.value(forKey: "live_image_url") as! String
//            newTournament.participants_count = tournament.value(forKey: "participants_count") as! Int
//            newTournament.progress_meter = tournament.value(forKey: "progress_meter") as! Int
//            newTournament.state = tournament.value(forKey: "state") as! String
//            newTournament.teams = tournament.value(forKey: "teams") as! Bool
//            newTournament.url = tournament.value(forKey: "url") as! String
//            newTournament.tournament_type = tournament.value(forKey: "tournament_type") as! String
//
//            try! realm.write {
//                realm.add(newTournament)
//                tournamentList.append(newTournament)
//            }
//        }
//        updateTournamentList()
//
//    }
	
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tournamentButtonCell")
        let button = cell?.contentView.subviews[0] as! UIButton
        if tournamentList.count > 0 {
            button.setTitle(tournamentList[indexPath.row].value(forKeyPath: "name") as? String,
                        for: .normal)
        
            button.addTarget(self,
                         action: #selector(tournamentButton_Clicked),
                         for: .touchUpInside
            )
        }
        
        return cell!
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tournamentList.count
    }
    
    func updateLocalTournamentList() {
        // fetch session list from db
        let results = realm.objects(Tournament.self)
        for tournament in results {
            tournamentList.append(tournament)
        }
		
        updateTournamentList()
    }
	
	func getOnlineTournaments() {
		tournamentParser.getOnlineTournaments()
	}
	
	func didParseTournamentData() {
		performSegue(withIdentifier: "tournamentSelectedSegue", sender: self)
	}
	
	func didGetOnlineTournaments(onlineTournamentList: [Tournament]) {
		for tournament in onlineTournamentList {
			if isTournamentUnique(tournament: tournament) {
				if realm.isInWriteTransaction {
					realm.add(tournament)
				} else {
					try! realm.write {
						realm.add(tournament)
					}
				}
				
				tournamentList.append(tournament)
			}
		}
		
		updateTournamentList()
	}
	
	func isTournamentUnique(tournament: Tournament) -> Bool {
		var count = 0
		try! realm.write {
			count = realm.objects(Tournament.self).filter("id = \(tournament.id)").count
		}
		
		return count == 0
	}
	
	func updateTournamentList() {
		tournamentTableView.reloadData()
	}
	
    @IBAction func tournamentButton_Clicked(sender: UIButton) {
        let name = sender.currentTitle
        if tournamentList.count > 0 {
            for tournament in tournamentList {
                if name == tournament.name {
                    TournamentController.setTournamentId(id: tournament.id)
					tournamentParser.getTournamentData(tournament: tournament)
                }
            }
        }
	}
}
