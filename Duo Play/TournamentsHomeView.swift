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

    let tournamentsHomeController = TournamentsHomeViewController()
    let tournamentController = TournamentController()
    var tournamentList = [Tournament]()
    let realm = try! Realm()
    
    @IBOutlet weak var tournamentNameTextField: UITextField!
    @IBOutlet weak var tournamentTableView: UITableView!
        
    override func viewDidLoad() {
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
        
        if tournamentNameTextField.text!.count > 0 {
            tournament.name = tournamentNameTextField.text!
        } else {
            tournament.name = "Tournament #" + String(tournamentList.count + 1)
        }
        
        
        let uuid = UUID.init().uuidString
        tournament.uuid = uuid
        
        tournament.bracket = Bracket()
        tournament.poolList = List<Pool>()
        tournament.teamList = List<Team>()
        
        try! realm.write {
            realm.add(tournament)
            tournamentList.append(tournament)
        }
        
        TournamentController.setTournamentId(uuid: uuid)
        updateTournamentList()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tournamentButtonCell")
        let button = cell?.contentView.subviews[0] as! UIButton
        button.setTitle(tournamentList[indexPath.row].value(forKeyPath: "name") as? String,
                        for: .normal)
        
        button.addTarget(self,
                         action: #selector(tournamentButton_Clicked),
                         for: .touchUpInside
        )
        
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
                    TournamentController.setTournamentId(uuid: tournament.uuid)
                }
            }
        }
        
        performSegue(withIdentifier: "tournamentSelectedSegue", sender: self)
    }

}
