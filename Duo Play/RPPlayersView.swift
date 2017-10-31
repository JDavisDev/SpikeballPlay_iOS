//
//  RandomPlayPlayersView.swift
//  SpikeballPlay
//
//  Created by Jordan Davis on 8/2/17.
//  Copyright © 2017 HoverSlam. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class RPPlayersView : UIViewController, UITextFieldDelegate {
    
    var numOfPlayersSelected: Int = 0
    @IBOutlet weak var playerTextFieldStack: UIStackView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var newPlayerTextField: UITextField!
    
    func getRPController() -> RPController {
        let session = RPSessionsView.getCurrentSession()
        let controller = session.rpController
    
        return controller!
    }
    
    // TODO - Check our passed session for data! load RP controller or something
    override func viewDidLoad() {
        super.viewDidLoad()
        updatePlayerTextFields()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        save()
        super.viewWillDisappear(true)
        
    }
    
    func save() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.saveContext()
    }
    
    func updatePlayerTextFields() {
        let rpController = getRPController()
        // clear values first
        for i in self.playerTextFieldStack.subviews {
            i.removeFromSuperview()
        }
        
        if rpController.playersList?.count == 0 {
            return
        }
        
        // re add views
        for i in 0...(rpController.playersList?.count)! - 1 {
            let button = UIButton()
            button.setTitle(" " + (rpController.playersList![i].name), for: .normal)
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
        let rpController = getRPController()
        let selectedPlayer = rpController.getPlayerByName(name: sender.currentTitle!)
        resignFirstResponder()
        let alert = UIAlertController(title: "Edit Player",
                                      message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Save", style: .default) { (alertAction) in
            _ = alert.textFields![0] as UITextField
            let player = rpController.getPlayerByName(name: sender.currentTitle!)
            let newName = alert.textFields![0].text!
            player.name = newName
            self.updatePlayerTextFields()
        }
        
        alert.addTextField { (textField) in
            textField.placeholder = "Name"
            textField.text = selectedPlayer.name
        }
        
        alert.addAction(action)
        
        alert.addAction(UIAlertAction(title: "Suspend", style: .default, handler: { (action: UIAlertAction!) in
            // suspend player so their stats remain but they won't be included in games!
            rpController.getPlayerByName(name: (sender.titleLabel?.text)!).isSuspended = true
            self.updatePlayerTextFields()
        }))

        
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { (action: UIAlertAction!) in
            // delete!
        //    self.session?.getController().deletePlayer(playerName: (sender.titleLabel?.text)!)
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
        let rpController = getRPController()
        // if text field is empty, use the player index as their name
        let name = (newPlayerTextField.text?.isEmpty)! ? String((rpController.playersList?.count)! + 1) : newPlayerTextField.text
        let player = RandomPlayer(id: (rpController.playersList?.count)! + 1,
                                  name: name!)
        rpController.addPlayer(player: player)
        newPlayerTextField.text = ""
        updatePlayerTextFields()
    }
    
    // in case of deletions and weird additions
    // make sure we have linear, updated ids
    func updatePlayerIds() {
        let rpController = getRPController()
        var id = 1
        for player in (rpController.playersList)! {
            player.id = id
            id += 1
        }
        
        save()
    }
}
