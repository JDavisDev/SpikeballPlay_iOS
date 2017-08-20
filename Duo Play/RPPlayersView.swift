//
//  RandomPlayPlayersView.swift
//  SpikeballPlay
//
//  Created by Jordan Davis on 8/2/17.
//  Copyright © 2017 HoverSlam. All rights reserved.
//

import Foundation
import UIKit

class RPPlayersView : UIViewController, UITextFieldDelegate {
    
    var numOfPlayersSelected: Int = 0
    var controller: RPController = RPController()
    @IBOutlet weak var playerTextFieldStack: UIStackView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var newPlayerTextField: UITextField!
    
    // TODO - Check our passed session for data! load RP controller or something
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updatePlayerTextFields()
    }
    
    func updatePlayerTextFields() {
        // clear values first
        for i in self.playerTextFieldStack.subviews {
            i.removeFromSuperview()
        }
        
        if RPController.playersList.count == 0 {
            return
        }
        
        // re add views
        for i in 0...RPController.playersList.count - 1 {
            let button = UIButton()
            button.setTitle(" " + RPController.playersList[i].name, for: .normal)
            button.frame = CGRect(x: 0, y: 55 * i + 1, width: 335, height: 50)
            button.tag = i + 1
            button.contentHorizontalAlignment = .center
            button.backgroundColor = UIColor.darkGray
            button.setTitleColor(UIColor.white, for: .normal)
            button.addTarget(self, action: #selector(RPPlayersView.playerButtonClicked(_:)), for: .touchUpInside)
            // see if player for this index already exists
            // so users can add players without clearing their stats
            playerTextFieldStack.addSubview(button)
        }
        
        updatePlayerIds()
    }
    
    // Player item tapped for deletion
    func playerButtonClicked(_ sender: UIButton!) {
        let selectedPlayer = RPController.getPlayerByName(name: sender.currentTitle!)
        resignFirstResponder()
        // prompt for deletion with dialog!
        // Delete player confirmation
        // maybe add delete all button? 
        // ADD EDIT FUNCTION to edit name
        let alert = UIAlertController(title: "Edit Player",
                                      message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Save", style: .default) { (alertAction) in
            _ = alert.textFields![0] as UITextField
            let player = RPController.getPlayerByName(name: sender.currentTitle!)
            let newName = alert.textFields![0].text!
            player.name = newName
            self.updatePlayerTextFields()
        }
        
        alert.addTextField { (textField) in
            textField.placeholder = "Name"
            textField.text = selectedPlayer.name
        }
        
        alert.addAction(action)

        
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { (action: UIAlertAction!) in
            // delete!
            self.controller.deletePlayer(playerName: (sender.titleLabel?.text)!)
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
        let name = (newPlayerTextField.text?.isEmpty)! ? String(RPController.playersList.count + 1) : newPlayerTextField.text
        let player = RandomPlayer(id: RPController.playersList.count + 1,
                                  name: name!)
        controller.addPlayer(player: player)
        newPlayerTextField.text = ""
        updatePlayerTextFields()
    }
    
    // in case of deletions and weird additions
    // make sure we have linear, updated ids
    func updatePlayerIds() {
        var id = 1
        for player in RPController.playersList {
            player.id = id
            id += 1
        }
    }
}
