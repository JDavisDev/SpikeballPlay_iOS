//
//  RandomPlayPlayersView.swift
//  SpikeballPlay
//
//  Created by Jordan Davis on 8/2/17.
//  Copyright © 2017 HoverSlam. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift
import Crashlytics

class RPPlayersView : UIViewController, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource {
    
    var numOfPlayersSelected: Int = 0
    @IBOutlet weak var newPlayerTextField: UITextField!
    @IBOutlet weak var newPlayerButton: UIButton!
    @IBOutlet weak var playerButton: UIButton!
    var rpController = RPController()
    let statsController = RPStatisticsController()
    var randomController = RPRandomizingController()
    var session = RPSessionsView.getCurrentSession()
    let realm = try! Realm()
    
    @IBOutlet weak var playersTableView: UITableView!
    // TODO - Check our passed session for data! load RP controller or something
    override func viewDidLoad() {
        super.viewDidLoad()

        playersTableView.delegate = self
        playersTableView.dataSource = self
        
        newPlayerButton.layer.cornerRadius = 20
        newPlayerButton.layer.borderColor = UIColor.white.cgColor
        newPlayerButton.layer.borderWidth = 1
        
        self.playersTableView.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        statsController.sort(sortMethod: "ID")
        Answers.logContentView(withName: "Players Page View",
                               contentType: "Players Page View",
                               contentId: "3",
                               customAttributes: [:])
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        let netCount = session.playersList.count / 4
        let newNetNumber = session.netList.count + 1
        if netCount >= 1 && newNetNumber <= netCount {
            for net in newNetNumber...netCount {
                try! realm.write() {
                    let netObject = Net()
                    netObject.id = String(net)
                    realm.add(netObject)
                    session.netList.append(netObject)
                }
            }
        }
        
        super.viewDidDisappear(true)
    }
    
    // hide keyboard on tap outside
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
        resignFirstResponder()
    }
    
    
    // MARK: - Table View methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return session.playersList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let player = session.playersList[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "playerButtonCell")
        let button = cell?.contentView.subviews[0] as! UIButton
        button.setTitle(player.name, for: .normal)
        
        if player.isSuspended {
            button.setTitleColor(UIColor.lightGray, for: .normal)
        } else {
            button.setTitleColor(UIColor.yellow, for: .normal)
        }
        
        button.addTarget(self,
                         action: #selector(playerButtonClicked),
                         for: .touchUpInside
        )
        
        return cell!
    }
    
    // Player item tapped for editing
    @objc func playerButtonClicked(_ sender: UIButton!) {
        resignFirstResponder()
        
        let selectedPlayer = rpController.getPlayerByName(name: sender.currentTitle!)
        
        let alert = UIAlertController(title: "Edit Player",
                                      message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Save", style: .default) { (alertAction) in
            _ = alert.textFields![0] as UITextField
            let player = self.rpController.getPlayerByName(name: sender.currentTitle!)
            let newName = alert.textFields![0].text!
            
            try! self.realm.write {
                player.name = newName
            }
            self.playersTableView.reloadData()
        }
        
        alert.addTextField { (textField) in
            textField.placeholder = "Name"
            textField.text = selectedPlayer.name
        }
        
        alert.addAction(action)
        
        try! realm.write {
            
        }
        let title = selectedPlayer.isSuspended ? "Activate" : "Suspend"
        alert.addAction(UIAlertAction(title: title, style: .default, handler: { (action: UIAlertAction!) in
            // suspend player so their stats remain but they won't be included in games!
            try! self.realm.write {
                let player = self.rpController.getPlayerByName(name: (sender.titleLabel?.text)!)
                if title == "Activate" {
                    player.isSuspended = false
                } else {
                    player.isSuspended = true
                }
            }
            
            self.playersTableView.reloadData()
        }))

        
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { (action: UIAlertAction!) in
            // delete!
            let player = self.rpController.getPlayerByName(name: (sender.titleLabel?.text)!)
            try! self.realm.write {
                self.realm.delete(player)
            }
            self.playersTableView.reloadData()
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
            // cancel
            self.playersTableView.reloadData()
            return
        }))
        
        alert.popoverPresentationController?.sourceView = self.view
        
        self.present(alert, animated: true)
    }
    
    // on return press, keyboard hides
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    //MARK: - Add Player Button processing
    // CHECK FOR DUPLICATES
    // Add Player Button Clicked
    @IBAction func addPlayerButtonClicked(_ sender: UIButton) {
        // if text field is empty, use the player index as their name
        let name = (newPlayerTextField.text?.isEmpty)! ? String((session.playersList.count) + 1) : newPlayerTextField.text
        let player = RandomPlayer()
        player.id = (session.playersList.count) + 1
        player.name = name!
        player.rating = 1000
        
        rpController.addPlayer(player: player)
        newPlayerTextField.text = ""
        self.playersTableView.reloadData()
    }
    
    // in case of deletions and weird additions
    // make sure we have linear, updated ids
    func updatePlayerIds() {
        var id = 1
        
        try! realm.write {
            for player in (session.playersList) {
                player.id = id
                id += 1
            }
        }
    }
}
