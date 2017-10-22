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
    
    @IBOutlet weak var sortButton: UIButton!
    var stats =  [Statistics]()
    @IBOutlet weak var statsTable: UITableView!
    var sortingData = [String]()
    var controller = RPStatisticsController()
    
    var rpController = RPSessionsView.userSession.rpController!
    
    override func viewDidLoad() {
        statsTable.delegate = self
        statsTable.dataSource = self
        initSortingData()
        
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        controller.sort(sortMethod: sortButton.currentTitle!, controller: rpController)
        initStats()
        statsTable.reloadData()
    }
    
    func initSortingData() {
        sortingData.append("Wins")
        sortingData.append("Losses")
        sortingData.append("Name")
        sortingData.append("Points For")
        sortingData.append("Points Against")
        sortingData.append("Point Differential")
        sortingData.append("Rank")
    }
    
    // wipe them away and start fresh to stay up to date.
    func initStats() {
        stats.removeAll()
        for player in rpController.playersList! {
            stats.append(Statistics(name: player.name, wins: player.wins, losses: player.losses, pointsFor: player.pointsFor,
                                    pointsAgainst: player.pointsAgainst, pointsDifferential: player.pointsFor - player.pointsAgainst))
        }
    }
    
    //MARK: Table View of statistics
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
    
    @IBAction func sortButtonClicked(_ sender: UIButton) {
        let actionSheet = UIAlertController(title: "Sort By", message: "", preferredStyle: .actionSheet)
        for method in sortingData {
            let action = UIAlertAction(title: "\(method)", style: .default) { (action: UIAlertAction) in
                self.sortButton.setTitle(method, for: .normal)
                self.viewDidAppear(true)
            }
            actionSheet.addAction(action)
        }
    
        let actionCancel = UIAlertAction(title: "Cancel", style: .cancel) { (action: UIAlertAction) in
        // reset this selection to "Select Player One"
        }
        actionSheet.addAction(actionCancel)
        present(actionSheet, animated: true, completion: nil)
    }

}
