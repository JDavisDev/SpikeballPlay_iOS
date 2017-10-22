//
//  PoolDetailView.swift
//  Duo Play
//
//  Created by Jordan Davis on 9/8/17.
//  Copyright © 2017 Jordan Davis. All rights reserved.
//

import Foundation
import UIKit

class PoolDetailView : UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var matchupsTableView: UITableView!
    
    var allPoolMatchups = [PoolPlayMatchup]()
    var remainingPoolMatchups = [PoolPlayMatchup]()
    var pool = Pool(name: "EMPTY")
    var sectionHeaderList = ["Round One", "Round Two", "Round Three", "Round Four", "Round Five", "Round Six", "Round Seven", "Round Eight", "Round Nine", "Round Ten"]
    var matchupIndex = 0
    
    // receive a pool which contains match up list
    // show each match up as a button for reporting the match
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.matchupIndex = 0
        //generate pools matches
        matchupsTableView.dataSource = self
        matchupsTableView.delegate = self
    }
//
//    override func viewDidAppear() {
//        // update visible pool list based on matches reported and pool play round
//    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MatchupCell")
        let section = indexPath.section
        let matchupIndex = section * 2 + indexPath.row
        cell!.textLabel?.text = "(\(pool.matchupList[matchupIndex].teamOne.id)) \(pool.matchupList[matchupIndex].teamOne.name) \n" +
                "(\(pool.matchupList[matchupIndex].teamTwo.id)) \(pool.matchupList[matchupIndex].teamTwo.name)"
        return cell!
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // fetches the number of teams in this pool
        return pool.teams.count / 2
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return pool.teams.count % 2 == 0 ?
            pool.teams.count - 1 :
            pool.teams.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        //Idk if this does anything but I think I need it here
        return sectionHeaderList[section]
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableCell(withIdentifier: "MatchupCell")
        header?.textLabel?.text = sectionHeaderList[section]
        return header
    }

    
}
