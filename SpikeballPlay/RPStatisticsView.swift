//
//  RPStatisticsView.swift
//  SpikeballPlay
//
//  Created by Jordan Davis on 8/4/17.
//  Copyright © 2017 HoverSlam. All rights reserved.
//

import Foundation
import UIKit

class RPStatisticsView : UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var stats =  [Statistics]()
    @IBOutlet weak var statsTable: UITableView!
    
    override func viewDidLoad() {
        statsTable.delegate = self
        statsTable.dataSource = self
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        initStats()
        statsTable.reloadData()
    }
    
    // wipe them away and start fresh to stay up to date.
    func initStats() {
        stats.removeAll()
        for player in RPController.playersList {
            stats.append(Statistics(name: player.name, wins: player.wins, losses: player.losses, pointsFor: player.pointsFor,
                                    pointsAgainst: player.pointsAgainst, pointsDifferential: player.pointsFor - player.pointsAgainst))
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return stats.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: StatisticCell.self)) as! StatisticCell
        let statRow = stats[indexPath.row]
        cell.name = statRow.name
        cell.wins = String(statRow.wins)
        cell.losses = String(statRow.losses)
        cell.pointsFor = String(statRow.pointsFor)
        cell.pointsAgainst = String(statRow.pointsAgainst)
        cell.pointsDifferential = String(statRow.pointsDifferential)
        
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
}
