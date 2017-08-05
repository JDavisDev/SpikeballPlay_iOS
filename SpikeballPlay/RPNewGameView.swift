//
//  RP_NewGameView.swift
//  SpikeballPlay
//
//  Created by Jordan Davis on 8/3/17.
//  Copyright © 2017 HoverSlam. All rights reserved.
//

import Foundation
import UIKit

public class RPNewGameView : UIViewController,
    UIPickerViewDelegate,
    UIPickerViewDataSource {
    
    // Pickers
    @IBOutlet weak var playerOnePicker: UIPickerView!
    @IBOutlet weak var playerTwoPicker: UIPickerView!
    @IBOutlet weak var playerThreePicker: UIPickerView!
    @IBOutlet weak var playerFourPicker: UIPickerView!
    @IBOutlet weak var groupIDPicker: UIPickerView!
    
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
        for player in RPController.playersList {
            pickerDataSource.append(player)
        }
        
        // init pickers
        playerOnePicker.dataSource = self
        playerOnePicker.delegate = self
        
        playerTwoPicker.dataSource = self
        playerTwoPicker.delegate = self
        
        playerThreePicker.dataSource = self
        playerThreePicker.delegate = self
        
        playerFourPicker.dataSource = self
        playerFourPicker.delegate = self
    }
    
    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        viewDidLoad()
    }
    
    //MARK: Sliders and score
    
    @IBAction func teamOneSliderValueChanged(_ sender: UISlider) {
        teamOneScoreLabel.text = String(Int(round(sender.value) / 1 * 1))
    }
    
    @IBAction func teamTwoSliderValueChanged(_ sender: UISlider) {
        teamTwoScoreLabel.text = String(Int(round(sender.value) / 1 * 1))
    }

    //MARK: Picker stuff
    
    @available(iOS 2.0, *)
    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerDataSource.count + 1
    }
    
    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    public func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        // this weird stuff is so the first item in the picker is not a player and will help with randomizing
        return String(row == 0 ? "Select Player" : pickerDataSource[row - 1].name)
    }
    
    // Catpure the picker view selection
    public func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        // This method is triggered whenever the user makes a change to the picker selection.
        // The parameter named row and component represents what was selected.

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
            let playerOne = pickerDataSource[playerOnePicker.selectedRow(inComponent: 0) - 1]
            let playerTwo = pickerDataSource[playerTwoPicker.selectedRow(inComponent: 0) - 1]
            
            let playerThree = pickerDataSource[playerThreePicker.selectedRow(inComponent: 0) - 1]
            let playerFour = pickerDataSource[playerFourPicker.selectedRow(inComponent: 0) - 1]
        
            // confirm game
            let alert = UIAlertController(title: "Submit Game",
                                      message: "\(playerOne.name)/\(playerTwo.name) : \(teamOneScore!) \n VS. \n\(playerThree.name)/\(playerFour.name) : \(teamTwoScore!)  ",
                                        preferredStyle: .alert)
        
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action: UIAlertAction!) in
                // move on
                let gameController: RPGameController = RPGameController()
                gameController.submitMatch(playerOne: playerOne, playerTwo: playerTwo,
                                       playerThree: playerThree, playerFour: playerFour,
                                       teamOneScore: teamOneScore!,
                                       teamTwoScore: teamTwoScore!)
                // clear all values
                self.resetViewValues()
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
        if playerOnePicker.selectedRow(inComponent: 0) == 0  ||
            playerTwoPicker.selectedRow(inComponent: 0) == 0  ||
            playerThreePicker.selectedRow(inComponent: 0) == 0 ||
            playerFourPicker.selectedRow(inComponent: 0) == 0 {
            return false
        }
        
        return true
    }
    
    // make sure all pickers are unique
    func allPlayersAreUnique() -> Bool {
        let one = playerOnePicker.selectedRow(inComponent: 0)
        let two = playerTwoPicker.selectedRow(inComponent: 0)
        let three = playerThreePicker.selectedRow(inComponent: 0)
        let four = playerFourPicker.selectedRow(inComponent: 0)
        
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
        playerFourPicker.selectRow(0, inComponent: 0, animated: false)
        let index = getRandomPlayerIndex()
        playerFourPicker.selectRow(index, inComponent: 0, animated: true)
    }
    
    @IBAction func playerThreeRandomize() {
        playerThreePicker.selectRow(0, inComponent: 0, animated: false)
        let index = getRandomPlayerIndex()
        playerThreePicker.selectRow(index, inComponent: 0, animated: true)
    }
    
    @IBAction func playerTwoRandomize() {
        playerTwoPicker.selectRow(0, inComponent: 0, animated: false)
        let index = getRandomPlayerIndex()
        playerTwoPicker.selectRow(index, inComponent: 0, animated: true)
    }
    
    @IBAction func playerOneRandomize() {
        playerOnePicker.selectRow(0, inComponent: 0, animated: false)
        let index = getRandomPlayerIndex()
        playerOnePicker.selectRow(index, inComponent: 0, animated: true)
    }
    
    @IBAction func gameRandomize() {
        let controller = RPController()
        let playerArray = controller.getFourRandomPlayers()
        
        playerOnePicker.selectRow(playerArray[0], inComponent: 0, animated: true)
        playerTwoPicker.selectRow(playerArray[1], inComponent: 0, animated: true)
        playerThreePicker.selectRow(playerArray[2], inComponent: 0, animated: true)
        playerFourPicker.selectRow(playerArray[3], inComponent: 0, animated: true)
    }
    
    func getRandomPlayerIndex() -> Int {
        var index = Int(arc4random_uniform(UInt32(RPController.playersList.count + 1)))
        while !isPlayerSelectedUnique(playerIndex: index) || index == 0 {
            index = Int(arc4random_uniform(UInt32(RPController.playersList.count + 1)))
        }
        
        return index
        
    }
    
    func isPlayerSelectedUnique(playerIndex: Int) -> Bool {
        if  playerIndex == 0 ||
            playerIndex == playerOnePicker.selectedRow(inComponent: 0) ||
            playerIndex == playerTwoPicker.selectedRow(inComponent: 0) ||
            playerIndex == playerThreePicker.selectedRow(inComponent: 0) ||
            playerIndex == playerFourPicker.selectedRow(inComponent: 0) {
            return false
        }
        
        return true;
    }
    
    func resetViewValues() {
        // reset everything back to normal - maybe?
//        teamOneScoreSlider.setValue(10, animated: true)
//        teamTwoScoreSlider.setValue(10, animated: true)
//        
//        teamOneScoreLabel.text = "10"
//        teamTwoScoreLabel.text = "10"
    }
    
    
}
