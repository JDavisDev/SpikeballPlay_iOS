//
//  RandomPlayPlayersView.swift
//  SpikeballPlay
//
//  Created by Jordan Davis on 8/2/17.
//  Copyright © 2017 HoverSlam. All rights reserved.
//

import Foundation
import UIKit

class RPPlayersView : UIViewController, UIPickerViewDelegate,
UIPickerViewDataSource, UITextFieldDelegate {
    
    var numOfPlayersSelected: Int = 4
    var pickerData: [Int] = [Int]()
    var controller: RPController = RPController()
    @IBOutlet weak var playerNumberPicker: UIPickerView!
    @IBOutlet weak var playerTextFieldStack: UIStackView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        playerNumberPicker.delegate = self
        playerNumberPicker.dataSource = self
        
        pickerData = [4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20]
        
        // call this method so we don't start with null num of players
        numOfPlayersSelected = RPController.playersList.count >= 4 ?
                               RPController.playersList.count : 4
        updatePlayerTextFields()
    }
    
    //MARK: - Player Picker Data
    
    @available(iOS 2.0, *)
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    internal func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return String(pickerData[row])
    }
    
    // Catpure the picker view selection
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        // This method is triggered whenever the user makes a change to the picker selection.
        // The parameter named row and component represents what was selected.
        numOfPlayersSelected = row + 4
        updatePlayerTextFields()
    }
    
    func updatePlayerTextFields() {
        // clear values first
        for i in self.playerTextFieldStack.subviews {
            i.removeFromSuperview()
        }
        
        // re add views
        for i in 1...self.numOfPlayersSelected {
            let textField = UITextField()
            textField.placeholder = String(i) + ". Player Name"
            textField.frame = CGRect(x: 0, y: 55 * i, width: 335, height: 50)
            textField.borderStyle = UITextBorderStyle.roundedRect
            textField.tag = i
            textField.delegate = self
            playerTextFieldStack.addSubview(textField)
        }
    }
    
    // on return press, keyboard hides
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    //MARK: - Submit Button processing
    
    @IBAction func submitButtonClicked(_ sender: UIButton) {
        RPController.playersList.removeAll()
        for field in playerTextFieldStack.subviews as! [UITextField] {
            let player = RandomPlayer(id: field.tag, name: field.text!)
            controller.addPlayer(player: player)
        }
        
        // move to next page!
        self.tabBarController?.selectedIndex = 1
    }
}
