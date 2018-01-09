//
//  RPHistoryView.swift
//  SpikeballPlay
//
//  Created by Jordan Davis on 8/4/17.
//  Copyright © 2017 HoverSlam. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift
import Crashlytics

class RPHistoryView : UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var historyTableView: UITableView!
    var controller = RPHistoryController()
    var gameList = List<RandomGame>()
    var session = RPSessionsView.getCurrentSession()
    let realm = try! Realm()
    
    override func viewDidLoad() {
        historyTableView.delegate = self
        historyTableView.dataSource = self
        gameList = (session.gameList)
        super.viewDidLoad()
    }

    
    func updateHistoryList() {
        try! realm.write {
            session.historyList.removeAll()
            
            for game in gameList {
                if game.playerOne != nil && game.playerTwo != nil && game.playerThree != nil && game.playerFour != nil {
                    let history = History()
                    history.playerOne = (game.playerOne?.name)!
                    history.playerTwo = (game.playerTwo?.name)!
                    history.playerThree = (game.playerThree?.name)!
                    history.playerFour = (game.playerFour?.name)!
                    history.scoreOne = String(game.teamOneScore)
                    history.scoreTwo = String(game.teamTwoScore)
                    
                    session.historyList.append(history)
                    realm.add(history)
                }
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        gameList = (session.gameList)
        updateHistoryList()
        historyTableView.reloadData()
        
        Answers.logContentView(withName: "History Page View",
                                       contentType: "History Page View",
                                       contentId: "4",
                                       customAttributes: [:])
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return session.historyList.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: HistoryCell.self)) as! HistoryCell
        let statRow = session.historyList[indexPath.row]
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
        let alert = UIAlertController(title: "Edit Match", message: "Delete this match?", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { (action: UIAlertAction!) in
            // delete!
            self.controller.deleteHistoryMatch(game: self.gameList[indexPath.row])
            // update history list
            self.viewDidAppear(true)
        }))
        
//        alert.addAction(UIAlertAction(title: "Edit", style: .default, handler: { (action: UIAlertAction!) in
//            // edit
//            // this works, it doesn't delete the previous game, but moves user to game view with current values.
//            // need a manual score page or something.. too fickle.
//
//            // move them to game view with players populated
//            self.performSegue(withIdentifier: "editGameSegue", sender: self.gameList[indexPath.row])
//            // update history list
//            self.viewDidAppear(true)
//        }))
        
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: { (action: UIAlertAction!) in
            // cancel
            // update history list
            self.viewDidAppear(true)
            return
        }))
        
        present(alert, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "editGameSegue" {
            if let nextVC = segue.destination as? RPNewGameView {
                nextVC.gameToEdit = sender as! RandomGame
            }
        }
    }
}
