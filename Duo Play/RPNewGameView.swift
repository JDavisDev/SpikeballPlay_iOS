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
import StoreKit

public class RPNewGameView : UIViewController {
    var gameToEdit = RandomGame()
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
    @IBOutlet weak var evenTeamsSwitch: UISwitch!
    
    // Player Randomize buttons
    @IBOutlet weak var playerOneRandomizeButton: UIButton!
    @IBOutlet weak var playerTwoRandomizeButton: UIButton!
    @IBOutlet weak var playerThreeRandomizeButton: UIButton!
    @IBOutlet weak var playerFourRandomizeButton: UIButton!
    
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
        
        if gameToEdit.playerOne != nil && gameToEdit.playerOne?.name != nil {
            fillEditedGame()
        }
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
    
    func fillEditedGame() {
        playerOneButton.setTitle(gameToEdit.playerOne?.name, for: .normal)
        playerTwoButton.setTitle(gameToEdit.playerTwo?.name, for: .normal)
        playerFourButton.setTitle(gameToEdit.playerFour?.name, for: .normal)
        playerThreeButton.setTitle(gameToEdit.playerThree?.name, for: .normal)
        updatePlayerNames()
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
        
        if netCount <= 1 {
            netSegmentedControl.isHidden = true
        }
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
        
        playerOneButton.layer.cornerRadius = 20
        playerOneButton.layer.borderColor = UIColor.yellow.cgColor
        playerOneButton.layer.borderWidth = 1
        
        playerTwoButton.layer.cornerRadius = 20
        playerTwoButton.layer.borderColor = UIColor.yellow.cgColor
        playerTwoButton.layer.borderWidth = 1
        
        playerThreeButton.layer.cornerRadius = 20
        playerThreeButton.layer.borderColor = UIColor.yellow.cgColor
        playerThreeButton.layer.borderWidth = 1
        
        playerFourButton.layer.cornerRadius = 20
        playerFourButton.layer.borderColor = UIColor.yellow.cgColor
        playerFourButton.layer.borderWidth = 1
                
//        playerOneRandomizeButton.layer.cornerRadius = 25
//        playerOneRandomizeButton.layer.borderColor = UIColor.white.cgColor
//        playerOneRandomizeButton.layer.borderWidth = 1
//
//        playerTwoRandomizeButton.layer.cornerRadius = 25
//        playerTwoRandomizeButton.layer.borderColor = UIColor.white.cgColor
//        playerTwoRandomizeButton.layer.borderWidth = 1
//
//        playerThreeRandomizeButton.layer.cornerRadius = 25
//        playerThreeRandomizeButton.layer.borderColor = UIColor.white.cgColor
//        playerThreeRandomizeButton.layer.borderWidth = 1
//
//        playerFourRandomizeButton.layer.cornerRadius = 25
//        playerFourRandomizeButton.layer.borderColor = UIColor.white.cgColor
//        playerFourRandomizeButton.layer.borderWidth = 1
        
//        randomizeAllButton.layer.cornerRadius = 7
//        randomizeAllButton.layer.borderColor = UIColor.white.cgColor
//        randomizeAllButton.layer.borderWidth = 1
//
//        submitButton.layer.cornerRadius = 7
//        submitButton.layer.borderColor = UIColor.white.cgColor
//        submitButton.layer.borderWidth = 1
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
        actionSheet.popoverPresentationController?.sourceView = self.view
        present(actionSheet, animated: true, completion: nil)
    }

    
    //MARK: Sliders and score
    
    @IBAction func teamOneSliderValueChanged(_ sender: UISlider) {
        teamOneScoreLabel.text = String(Int(round(sender.value) / 1 * 1))
    }
    
    @IBAction func teamTwoSliderValueChanged(_ sender: UISlider) {
        teamTwoScoreLabel.text = String(Int(round(sender.value) / 1 * 1))
    }
    
    // MARK: Even Teams Switch toggle
    
    @IBAction func evenTeamsSwitchChanged(_ sender: Any) {
        resetGameValues()
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
        
            // confirm game
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
                
                // Show review prompt if this is the second+ game submitted
                #if !DEBUG
                if self.session.gameList.count > 1 {
                    if #available(iOS 10.3, *) {
                        SKStoreReviewController.requestReview()
                    }
                }
                #endif
                
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
            // reset CURRENT net so they can regenerate a game
            resetGameValues()
            let playerArray = controller.getFourRandomPlayers()
            
            if evenTeamsSwitch.isOn && playerArray.count == 4 {
                var realPlayerArray = [RandomPlayer]()
                realPlayerArray.append(session.playersList[playerArray[0]])
                realPlayerArray.append(session.playersList[playerArray[1]])
                realPlayerArray.append(session.playersList[playerArray[2]])
                realPlayerArray.append(session.playersList[playerArray[3]])
                realPlayerArray = balanceTeams(playerArray: realPlayerArray)
                
                if realPlayerArray.count == 4 {
                    playerOneButton.setTitle(realPlayerArray[0].name, for: .normal)
                    playerTwoButton.setTitle(realPlayerArray[3].name, for: .normal)
                    playerThreeButton.setTitle(realPlayerArray[1].name, for: .normal)
                    playerFourButton.setTitle(realPlayerArray[2].name, for: .normal)
                    updatePlayerNames()
                }
            } else if playerArray.count == 4 {
                playerOneButton.setTitle(session.playersList[playerArray[0]].name, for: .normal)
                playerTwoButton.setTitle(session.playersList[playerArray[1]].name, for: .normal)
                playerThreeButton.setTitle(session.playersList[playerArray[2]].name, for: .normal)
                playerFourButton.setTitle(session.playersList[playerArray[3]].name, for: .normal)
                updatePlayerNames()
            }
        }
    }
    
    func balanceTeams(playerArray: [RandomPlayer]) -> [RandomPlayer] {
    
        // high rating first, then lowest, then 2nd/3rd lowest OF the game already created.
        var array = Array(playerArray)
        array.sort {
            if ($0.pointsFor - $0.pointsAgainst) == ($1.pointsFor - $1.pointsAgainst) {
                return $0.wins > $1.wins
            } else {
                return ($0.pointsFor - $0.pointsAgainst) > ($1.pointsFor - $1.pointsAgainst)
            }
        }
        
        return array
    }
    
    func highlightServingTeam() {
        let servingTeam = Int(arc4random_uniform(UInt32(2)))
        
        if servingTeam <= 0 {
            playerOneButton.layer.backgroundColor = UIColor.black.cgColor
            playerTwoButton.layer.backgroundColor = UIColor.black.cgColor
            playerThreeButton.layer.backgroundColor = UIColor.clear.cgColor
            playerFourButton.layer.backgroundColor = UIColor.clear.cgColor
        } else {
            playerOneButton.layer.backgroundColor = UIColor.clear.cgColor
            playerTwoButton.layer.backgroundColor = UIColor.clear.cgColor
            playerThreeButton.layer.backgroundColor = UIColor.black.cgColor
            playerFourButton.layer.backgroundColor = UIColor.black.cgColor
        }
    }
    
    func updatePlayerNames() {
        playerOneName = playerOneButton.currentTitle!
        playerTwoName = playerTwoButton.currentTitle!
        playerThreeName = playerThreeButton.currentTitle!
        playerFourName = playerFourButton.currentTitle!
        highlightServingTeam()
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
        
        playerThreeButton.layer.backgroundColor = UIColor.clear.cgColor
        playerFourButton.layer.backgroundColor = UIColor.clear.cgColor
        playerOneButton.layer.backgroundColor = UIColor.clear.cgColor
        playerTwoButton.layer.backgroundColor = UIColor.clear.cgColor
        
        try! realm.write {
            let net = self.session.netList.filter("id = '" + String(self.netSegmentedControl.selectedSegmentIndex + 1) + "'").first
            net?.playersList.removeAll()
        }
        
        updatePlayerNames()
        saveNet()
    }
}
