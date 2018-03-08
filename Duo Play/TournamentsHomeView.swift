//
//  TournamentsHome.swift
//  SpikeballPlay
//
//  Created by Jordan Davis on 8/11/17.
//  Copyright © 2017 HoverSlam. All rights reserved.
//

import UIKit
import RealmSwift

class TournamentsHomeView: UIViewController, UITableViewDataSource, UITableViewDelegate {

    let tournamentController = TournamentController()
    var tournamentList = [Tournament]()
    let realm = try! Realm()
    let challongeConnector = ChallongeAPI()
    
    @IBOutlet weak var tournamentNameTextField: UITextField!
    @IBOutlet weak var tournamentTableView: UITableView!
        
    override func viewDidLoad() {
        
//        try! realm.write() {
//            realm.deleteAll()
//        }
        
        super.viewDidLoad()
        tournamentTableView.delegate = self
        tournamentTableView.dataSource = self
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        updateTournamentList()
        tournamentTableView.reloadData()
        
        super.viewDidAppear(true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
    }
    
    
    @IBAction func addTournamentButtonClicked(_ sender: UIButton) {
        let tournament = Tournament()
        
        tournament.name = "Tournament #" + String(tournamentList.count + 1)
        
        let id = UUID.init().uuidString
        tournament.id = id
        
        tournament.poolList = List<Pool>()
        tournament.teamList = List<Team>()
        
        try! realm.write {
            realm.add(tournament)
            tournamentList.append(tournament)
        }
        
        TournamentController.setTournamentId(id: id)
        updateTournamentList()
    }
    
    @IBAction func getOnlineTournamentButtonClicked(_ sender: UIButton) {
        parseOnlineTournaments()
    }
    
    func parseOnlineTournaments() {
        challongeConnector.getTournaments()
        let onlineTournaments = challongeConnector.tournamentList
        
        for tournament in onlineTournaments {
            let newTournament = Tournament()
            
            // assign properties from online tournament to realm tournament for local storage
            newTournament.name = tournament.value(forKey: "name") as! String
            newTournament.id = String(tournament.value(forKey: "id") as! Int)
            newTournament.poolList = List<Pool>()
            newTournament.teamList = List<Team>()
            newTournament.full_challonge_url = tournament.value(forKey: "full_challonge_url") as! String
            newTournament.game_id = tournament.value(forKey: "game_id") as! Int
            newTournament.isPrivate = tournament.value(forKey: "private") as! Bool
            newTournament.live_image_url = tournament.value(forKey: "live_image_url") as! String
            newTournament.participants_count = tournament.value(forKey: "participants_count") as! Int
            newTournament.progress_meter = tournament.value(forKey: "progress_meter") as! Int
            newTournament.state = tournament.value(forKey: "state") as! String
            newTournament.teams = tournament.value(forKey: "teams") as! Bool
            newTournament.url = tournament.value(forKey: "url") as! String
            newTournament.tournament_type = tournament.value(forKey: "tournament_type") as! String
            
            try! realm.write {
                realm.add(newTournament)
                tournamentList.append(newTournament)
            }
        }
        updateTournamentList()
        
    }
    
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
    
    func updateTournamentList() {
        // fetch session list from db
        let results = realm.objects(Tournament.self)
        tournamentList.removeAll()
        for tournament in results {
            tournamentList.append(tournament)
        }
        
        tournamentTableView.reloadData()
    }
    
    @IBAction func tournamentButton_Clicked(sender: UIButton) {
        let name = sender.currentTitle
        if tournamentList.count > 0 {
            for tournament in tournamentList {
                if name == tournament.name {
                    TournamentController.setTournamentId(id: tournament.id)
                }
            }
        }
        
        performSegue(withIdentifier: "tournamentSelectedSegue", sender: self)
    }

}
