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
    
    @IBOutlet weak var playerOnePicker: UIPickerView!
    @IBOutlet weak var playerTwoPicker: UIPickerView!
    @IBOutlet weak var playerThreePicker: UIPickerView!
    @IBOutlet weak var playerFourPicker: UIPickerView!
    @IBOutlet weak var groupIDPicker: UIPickerView!
    
    @IBOutlet weak var teamOneScoreLabel: UILabel!
    @IBOutlet weak var teamTwoScoreLabel: UILabel!
    
    var pickerDataSource: [RandomPlayer] = [RandomPlayer]()

    @IBOutlet weak var teamOneScoreSlider: UISlider!
    @IBOutlet weak var teamTwoScoreSlider: UISlider!
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        for player in RPController.playersList {
            pickerDataSource.append(player)
        }
        
        playerOnePicker.dataSource = self
        playerOnePicker.delegate = self
        
        playerTwoPicker.dataSource = self
        playerTwoPicker.delegate = self
        
        playerThreePicker.dataSource = self
        playerThreePicker.delegate = self
        
        playerFourPicker.dataSource = self
        playerFourPicker.delegate = self
    
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
        return pickerDataSource.count
    }
    
    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    public func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return String(pickerDataSource[row].name)
    }
    
    // Catpure the picker view selection
    public func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        // This method is triggered whenever the user makes a change to the picker selection.
        // The parameter named row and component represents what was selected.

    }
    
    //MARK: Submit logic
    @IBAction func submitButtonClicked(_ sender: UIButton) {
        // save ids/names and scores to match controller for point assignment
        let playerOne = pickerDataSource[playerOnePicker.selectedRow(inComponent: 0)]
        let playerTwo = pickerDataSource[playerTwoPicker.selectedRow(inComponent: 0)]
        
        let playerThree = pickerDataSource[playerThreePicker.selectedRow(inComponent: 0)]
        let playerFour = pickerDataSource[playerFourPicker.selectedRow(inComponent: 0)]
        
        let teamOneScore = Int(teamOneScoreLabel.text!)
        let teamTwoScore = Int(teamTwoScoreLabel.text!)
        
        // check that all fields are correct
        
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
        
        // no players match
        
        
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
    
    func resetViewValues() {
        // reset everything back to normal
    }
}
