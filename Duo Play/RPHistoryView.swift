//
//  RPHistoryView.swift
//  SpikeballPlay
//
//  Created by Jordan Davis on 8/4/17.
//  Copyright © 2017 HoverSlam. All rights reserved.
//

import Foundation
import UIKit

class RPHistoryView : UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var historyTableView: UITableView!
    var historyList = [History]()
    var controller = RPHistoryController()
    var gameList = [RandomGame]()
    
    override func viewDidLoad() {
        historyTableView.delegate = self
        historyTableView.dataSource = self
        let rpController = getRPController()
        gameList = (rpController.gameList)!
        super.viewDidLoad()
    }

    func getRPController() -> RPController {
        return RPSessionsView.getCurrentSession().rpController ?? RPController(playersList: [RandomPlayer](), gameList: [RandomGame]())
    }
    
    func updateHistoryList() {
        historyList.removeAll()
        for game in gameList {
            historyList.append(History(playerOne: game.playerOne.name, playerTwo: game.playerTwo.name, playerThree: game.playerThree.name, playerFour: game.playerFour.name, scoreOne: String(game.teamOneScore), scoreTwo: String(game.teamTwoScore)))
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let rpController = getRPController()
        gameList = (rpController.gameList)!
        updateHistoryList()
        historyTableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return historyList.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: HistoryCell.self)) as! HistoryCell
        let statRow = historyList[indexPath.row]
        cell.playerOne = statRow.playerOne
        cell.playerTwo = statRow.playerTwo
        cell.playerThree = statRow.playerThree
        cell.playerFour = statRow.playerFour
        cell.teamOneScore = statRow.scoreOne
        cell.teamTwoScore = statRow.scoreTwo
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // delete match on tap
        // prompt for deletion with dialog!
        // delete all button?
        let alert = UIAlertController(title: "Delete Match", message: "Delete this match?", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { (action: UIAlertAction!) in
            // delete!
            self.controller.deleteHistoryMatch(game: self.gameList[indexPath.row])
            // update history list
            self.viewDidAppear(true)
        }))
        
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: { (action: UIAlertAction!) in
            // cancel
            // update history list
            self.viewDidAppear(true)
            return
        }))
        
        present(alert, animated: true, completion: nil)
    }
}
