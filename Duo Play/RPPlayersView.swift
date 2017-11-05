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

class RPPlayersView : UIViewController, UITextFieldDelegate {
    
    var numOfPlayersSelected: Int = 0
    @IBOutlet weak var playerTextFieldStack: UIStackView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var newPlayerTextField: UITextField!
    var rpController = RPController()
    var session = RPSessionsView.getCurrentSession()
    let realm = try! Realm()
    
    // TODO - Check our passed session for data! load RP controller or something
    override func viewDidLoad() {
        super.viewDidLoad()
        updatePlayerTextFields()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        Answers.logContentView(withName: "Players Page View",
                               contentType: "Players Page View",
                               contentId: "3",
                               customAttributes: [:])
    }
    
    func updatePlayerTextFields() {
        // clear values first
        for i in self.playerTextFieldStack.subviews {
            i.removeFromSuperview()
        }
        
        if session == nil || session.playersList == nil || session.playersList.count <= 0 {
            return
        }
        
        // re add views
        for i in 0...(session.playersList.count) - 1 {
            let button = UIButton()
            button.setTitle(" " + (session.playersList[i].name), for: .normal)
            button.setTitleColor(UIColor.yellow, for: UIControlState.normal)
            button.setTitleColor(UIColor.white, for: UIControlState.highlighted)
            button.frame = CGRect(x: 0, y: 65 * i + 1, width: Int(UIScreen.main.bounds.width - 30), height: 50)
            
            button.tag = i + 1
            button.contentHorizontalAlignment = .center
            button.layer.cornerRadius = 7
            button.layer.borderColor = UIColor.yellow.cgColor
            button.layer.borderWidth = 1
            
            if session.playersList[i].isSuspended {
                button.backgroundColor = UIColor.black
            } else {
                button.backgroundColor = UIColor.darkGray
            }
            
            button.addTarget(self, action: #selector(RPPlayersView.playerButtonClicked(_:)), for: .touchUpInside)
            // see if player for this index already exists
            // so users can add players without clearing their stats
            playerTextFieldStack.addSubview(button)
        }
        
        updatePlayerIds()
    }
    
    // Player item tapped for deletion
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
            
            self.updatePlayerTextFields()
        }
        
        alert.addTextField { (textField) in
            textField.placeholder = "Name"
            textField.text = selectedPlayer.name
        }
        
        alert.addAction(action)
        
//        alert.addAction(UIAlertAction(title: "Suspend", style: .default, handler: { (action: UIAlertAction!) in
//            // suspend player so their stats remain but they won't be included in games!
//            try! self.realm.write {
//                let player = self.rpController.getPlayerByName(name: (sender.titleLabel?.text)!)
//                player.isSuspended = true
//            }
//
//            self.updatePlayerTextFields()
//        }))

        
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { (action: UIAlertAction!) in
            // delete!
            let player = self.rpController.getPlayerByName(name: (sender.titleLabel?.text)!)
            try! self.realm.write {
                self.realm.delete(player)
            }
            self.updatePlayerTextFields()
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
            // cancel
            self.updatePlayerTextFields()
            return
        }))
        
        present(alert, animated: true, completion: nil)
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

        rpController.addPlayer(player: player)
        newPlayerTextField.text = ""
        updatePlayerTextFields()
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
