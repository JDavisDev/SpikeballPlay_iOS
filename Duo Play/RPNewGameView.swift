//
//  RP_NewGameView.swift
//  SpikeballPlay
//
//  Created by Jordan Davis on 8/3/17.
//  Copyright © 2017 HoverSlam. All rights reserved.
//

import Foundation
import UIKit
import Crashlytics
import RealmSwift

public class RPNewGameView : UIViewController {
    
    let session = RPSessionsView.getCurrentSession()
    let statsController = RPStatisticsController()
    let rpController = RPController()
    let controller = RPRandomizingController()
    let realm = try! Realm()
    
    @IBOutlet weak var netSegmentedControl: UISegmentedControl!
    
    // keep a reference to the names and update them
    // as user changes players
    // use these for randomizing
    // will help with keeping logic in controller
    var playerOneName = ""
    var playerTwoName = ""
    var playerThreeName = ""
    var playerFourName = ""
    
    // Player Selection buttons
    @IBOutlet weak var playerOneButton: UIButton!
    @IBOutlet weak var playerTwoButton: UIButton!
    @IBOutlet weak var playerThreeButton: UIButton!
    @IBOutlet weak var playerFourButton: UIButton!
    var playerButtonList = [UIButton]()
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var randomizeAllButton: UIButton!
    
    // Labels
    @IBOutlet weak var teamOneScoreLabel: UILabel!
    @IBOutlet weak var teamTwoScoreLabel: UILabel!
    
    // Data source
    var pickerDataSource: [RandomPlayer] = [RandomPlayer]()

    // Sliders
    @IBOutlet weak var teamOneScoreSlider: UISlider!
    @IBOutlet weak var teamTwoScoreSlider: UISlider!
    
    // View Did Load
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        pickerDataSource.removeAll()
        for player in (session.playersList) {
            pickerDataSource.append(player)
        }
        initNetSegments()
        initPlayerButtonStyles()
        statsController.sort(sortMethod: "ID")
    }
    
    // View did Appear
    override public func viewDidAppear(_ animated: Bool) {
        Answers.logContentView(withName: "New Game Page View",
                               contentType: "New Game Page View",
                               contentId: "2",
                               customAttributes: [:])
        
        super.viewDidAppear(true)
        viewDidLoad()
    }
    
    // MARK: Net Change
    @IBAction func netChanged(_ sender: UISegmentedControl) {
        let netNumString = sender.titleForSegment(at: sender.selectedSegmentIndex)
        loadNet(netNumString: netNumString!)
    }
    
    func initNetSegments() {
        netSegmentedControl.removeAllSegments()
        netSegmentedControl.isHidden = false
        let netCount = session.playersList.count / 4
        
        for net in 0..<netCount {
            netSegmentedControl.insertSegment(withTitle: String(net + 1), at: net, animated: true)
        }
        
        netSegmentedControl.selectedSegmentIndex = 0
        loadNet(netNumString: "1")
    }
    
    func loadNet(netNumString: String) {
        // get net from session
        // populate values from net
        try! realm.write {
            let net = session.netList.filter("id = '" + netNumString + "'").first
            
            if (net != nil) && (net?.playersList.count)! >= 4 && net?.playersList[0].name != "name" {
                self.playerOneName = (net?.playersList[0].name)!
                self.playerTwoName = (net?.playersList[1].name)!
                self.playerThreeName = (net?.playersList[2].name)!
                self.playerFourName = (net?.playersList[3].name)!
                updatePlayerButtons()
            } else {
                self.playerOneName = "Select Player"
                self.playerTwoName = "Select Player"
                self.playerThreeName = "Select Player"
                self.playerFourName = "Select Player"
                updatePlayerButtons()
            }
        }
        
        saveNet()
    }
    
    func initPlayerButtonStyles() {
        playerButtonList.append(playerOneButton)
        playerButtonList.append(playerTwoButton)
        playerButtonList.append(playerThreeButton)
        playerButtonList.append(playerFourButton)
    }

    //MARK:  Player Selection Buttons
    /// Each button calls an action sheet to select a player
    
    @IBAction func selectPlayerButtonClicked(_ sender: UIButton) {
        let actionSheet = UIAlertController(title: "Select Player", message: "", preferredStyle: .actionSheet)
        for player in (session.playersList) {
            let action = UIAlertAction(title: "\(player.name)", style: .default) { (action: UIAlertAction) in
                // we have a selection!
                // store it
                sender.setTitle("\(action.title!)", for: .normal)
                switch sender.accessibilityIdentifier! {
                    case "PlayerOne":
                        self.playerOneName = action.title!
                        break
                    case "PlayerTwo":
                        self.playerTwoName = action.title!
                        break
                    case "PlayerThree":
                        self.playerThreeName = action.title!
                        break
                    case "PlayerFour":
                        self.playerFourName = action.title!
                        break
                    default:
                        // nothing
                        break
                }
                
                self.saveNet()
            }
    
            actionSheet.addAction(action)
        }
        
        let actionCancel = UIAlertAction(title: "Cancel", style: .cancel) { (action: UIAlertAction) in
            // reset this selection to "Select Player One"
        }
        actionSheet.addAction(actionCancel)
        present(actionSheet, animated: true, completion: nil)
    }

    
    //MARK: Sliders and score
    
    @IBAction func teamOneSliderValueChanged(_ sender: UISlider) {
        teamOneScoreLabel.text = String(Int(round(sender.value) / 1 * 1))
    }
    
    @IBAction func teamTwoSliderValueChanged(_ sender: UISlider) {
        teamTwoScoreLabel.text = String(Int(round(sender.value) / 1 * 1))
    }
    
    
    //MARK: Submit logic
    @IBAction func submitButtonClicked(_ sender: UIButton) {
        let teamOneScore = Int(teamOneScoreLabel.text!)
        let teamTwoScore = Int(teamTwoScoreLabel.text!)
        
        // Error checking the match before submitting
        
        // score isn't the same and ahead by atleast 2
        if teamOneScore != teamTwoScore {
            // difference of atleast one, all set.
        } else {
            //scores match
            let alert = UIAlertController(title: "Score Error",
                                          message: "Scores cannot match",
                preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action: UIAlertAction!) in
                return
            }))
            
            present(alert, animated: true, completion: nil)
        }
        
        // no players match and are valid
        // save ids/names and scores to match controller for point assignment
        if !allPickersAreValid() || !allPlayersAreUnique() {
            // player selection is invalid
            let alert = UIAlertController(title: "Player Error",
                                          message: "Please Select Four Unique Players",
                                          preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action: UIAlertAction!) in
                return
            }))
            
            present(alert, animated: true, completion: nil)
        } else {
            let playerOne = rpController.getPlayerByName(name: playerOneName)
            let playerTwo = rpController.getPlayerByName(name: playerTwoName)
            
            let playerThree = rpController.getPlayerByName(name: playerThreeName)
            let playerFour = rpController.getPlayerByName(name: playerFourName)
        
//            // confirm game
            let alert = UIAlertController(title: "Submit Game",
                                          message: "\(playerOne.name)/\(playerTwo.name) : \(teamOneScore!) \n VS. \n\(playerThree.name)/\(playerFour.name) : \(teamTwoScore!)  ",
                                        preferredStyle: .alert)
        
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action: UIAlertAction!) in
                // move on
                let gameController = RPGameController()
                gameController.submitGame(playerOne: playerOne, playerTwo: playerTwo,
                                           playerThree: playerThree, playerFour: playerFour,
                                       teamOneScore: teamOneScore!,
                                       teamTwoScore: teamTwoScore!)
                self.resetGameValues()
            }))
        
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
                // cancel
                return
            }))
        
            present(alert, animated: true, completion: nil)
        }
    }
    
    // Make sure no picker has the 0th value selected on submit
    // 0th value is "Select A Player"
    func allPickersAreValid() -> Bool {
        // check if all buttons have a title that is not "Select Player"
        if playerOneButton.currentTitle != "Select Player" &&
            playerTwoButton.currentTitle != "Select Player" &&
            playerThreeButton.currentTitle != "Select Player" &&
            playerFourButton.currentTitle != "Select Player" {
            return true
        }
        
        return false
    }
    
    // make sure all pickers are unique
    func allPlayersAreUnique() -> Bool {
        let one = playerOneName
        let two = playerTwoName
        let three = playerThreeName
        let four = playerFourName
        
        if one == two || one == three || one == four ||
            two == three || two == four ||
            three == four {
            return false
        }
        
        return true
    }
    
    
    //MARK: Randomize Section
    
    // Randomize Button Clicks
    // While randomly chosen player is NOT unique, 
    // pick a new random player until unique
    @IBAction func playerFourRandomize() {
        let index = controller.getRandomPlayerIndex(nameOne: playerOneName, nameTwo: playerTwoName, nameThree: playerThreeName,nameFour: playerFourName)
        if index != -1 {
            playerFourButton.setTitle(session.playersList[index].name, for: .normal)
        }
        updatePlayerNames()
    }
    
    @IBAction func playerThreeRandomize() {
        let index = controller.getRandomPlayerIndex(nameOne: playerOneName, nameTwo: playerTwoName, nameThree: playerThreeName,nameFour: playerFourName)
        if index != -1 {
            playerThreeButton.setTitle(session.playersList[index].name, for: .normal)
        }
        updatePlayerNames()
    }
    
    @IBAction func playerTwoRandomize() {
        let index = controller.getRandomPlayerIndex(nameOne: playerOneName, nameTwo: playerTwoName, nameThree: playerThreeName,nameFour: playerFourName)
        if index != -1 {
            playerTwoButton.setTitle(session.playersList[index].name, for: .normal)
        }
        updatePlayerNames()
    }
    
    @IBAction func playerOneRandomize() {
        let index = controller.getRandomPlayerIndex(nameOne: playerOneName, nameTwo: playerTwoName, nameThree: playerThreeName,nameFour: playerFourName)
        if index != -1 {
            playerOneButton.setTitle(session.playersList[index].name, for: .normal)
        }
        updatePlayerNames()
    }
    
    @IBAction func gameRandomize() {
        if((session.playersList.count) >= 4) {
            let playerArray = controller.getFourRandomPlayers()
            
            if playerArray.count == 4 {
                playerOneButton.setTitle(session.playersList[playerArray[0]].name, for: .normal)
                playerTwoButton.setTitle(session.playersList[playerArray[1]].name, for: .normal)
                playerThreeButton.setTitle(session.playersList[playerArray[2]].name, for: .normal)
                playerFourButton.setTitle(session.playersList[playerArray[3]].name, for: .normal)
                updatePlayerNames()
            }
            
            highlightServingTeam()
        }
    }
    
    func highlightServingTeam() {
        var servingTeam = Int(arc4random_uniform(UInt32(2)))
        
        if servingTeam <= 0 {
            playerOneButton.titleLabel?.textColor = UIColor.black
            playerTwoButton.titleLabel?.textColor = UIColor.black
            playerThreeButton.titleLabel?.textColor = UIColor.white
            playerFourButton.titleLabel?.textColor = UIColor.white
        } else {
            playerOneButton.titleLabel?.textColor = UIColor.white
            playerTwoButton.titleLabel?.textColor = UIColor.white
            playerThreeButton.titleLabel?.textColor = UIColor.black
            playerFourButton.titleLabel?.textColor = UIColor.black
        }
    }
    
    func updatePlayerNames() {
        playerOneName = playerOneButton.currentTitle!
        playerTwoName = playerTwoButton.currentTitle!
        playerThreeName = playerThreeButton.currentTitle!
        playerFourName = playerFourButton.currentTitle!
        
        saveNet()
        
    }
    
    func updatePlayerButtons() {
        playerOneButton.setTitle(playerOneName, for: .normal)
        playerTwoButton.setTitle(playerTwoName, for: .normal)
        playerThreeButton.setTitle(playerThreeName, for: .normal)
        playerFourButton.setTitle(playerFourName, for: .normal)
    }
    
    func saveNet() {
        try! realm.write {
            let net = self.session.netList.filter("id = '" + String(self.netSegmentedControl.selectedSegmentIndex + 1) + "'").first
            
            if (net != nil) && (net?.playersList.count)! >= 4 {
                net?.playersList[0] = self.rpController.getPlayerByName(name: self.playerOneName)
                net?.playersList[1] = self.rpController.getPlayerByName(name: self.playerTwoName)
                net?.playersList[2] = self.rpController.getPlayerByName(name: self.playerThreeName)
                net?.playersList[3] = self.rpController.getPlayerByName(name: self.playerFourName)
            } else if (net != nil) {
                net?.playersList.append(self.rpController.getPlayerByName(name: self.playerOneName))
                net?.playersList.append(self.rpController.getPlayerByName(name: self.playerOneName))
                net?.playersList.append(self.rpController.getPlayerByName(name: self.playerOneName))
                net?.playersList.append(self.rpController.getPlayerByName(name: self.playerOneName))
            }
        }
    }
    
    func resetGameValues() {
        playerOneButton.setTitle("Select Player", for: .normal)
        playerTwoButton.setTitle("Select Player", for: .normal)
        playerThreeButton.setTitle("Select Player", for: .normal)
        playerFourButton.setTitle("Select Player", for: .normal)
        
        try! realm.write {
            let net = self.session.netList.filter("id = '" + String(self.netSegmentedControl.selectedSegmentIndex + 1) + "'").first
            net?.playersList.removeAll()
        }
        
        updatePlayerNames()
        saveNet()
    }
}
