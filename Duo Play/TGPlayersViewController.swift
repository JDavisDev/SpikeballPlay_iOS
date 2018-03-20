//
//  TGPlayersViewController.swift
//  Duo Play
//
//  Created by Jordan Davis on 3/12/18.
//  Copyright © 2018 Jordan Davis. All rights reserved.
//

import UIKit

class TGPlayersViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITableViewDelegate, UITableViewDataSource {
	
	var playerList = [String]()
	var pickerData = [String]()
	var teamSizeSupported: Int = 16
	var teamSize = 0
	
	@IBOutlet weak var playersTableView: UITableView!
	@IBOutlet weak var teamSizePickerView: UIPickerView!
	
	override func viewDidLoad() {
        super.viewDidLoad()
		
        // Do any additional setup after loading the view.
		teamSizePickerView.delegate = self
		teamSizePickerView.dataSource = self as? UIPickerViewDataSource
		
		playersTableView.delegate = self
		playersTableView.dataSource = self
		
		for i in 1...16 {
			pickerData.append(String(i))
		}
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
	
	
	@IBAction func addPlayer(_ sender: Any) {
		let alert = UIAlertController(title: "Add Player",
									  message: "", preferredStyle: .alert)
		
		let action = UIAlertAction(title: "Save", style: .default) { (alertAction) in
			_ = alert.textFields![0] as UITextField
			let newName = alert.textFields![0].text!
			self.playerList.append(newName)
			self.playersTableView.reloadData()
		}
		
		alert.addTextField { (textField) in
			textField.placeholder = "Player Name"
		}
		
		alert.addAction(action)
		
		alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
			// cancel
			return
		}))
		
		present(alert, animated: true, completion: nil)
	}
	
	@IBAction func generateButton(_ sender: Any) {
		// get result from controller
		// send to next page in two arrays
		
	}
	
	// MARK: - Table View methods
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return playerList.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "tgTeamCell")
		let team = playerList[indexPath.row]
		cell!.textLabel?.text = team
		
		return cell!
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		// edit/delete name
	}
	
		
	
	
	// MARK: PICKER VIEW
	
	// The number of columns of data
	func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
		return 1
	}
	
	// The number of rows of data
	func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
		return pickerData.count
	}
	
	// The data to return for the row and component (column) that's being passed in
	func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
		return pickerData[row]
	}
	
	// Capture the picker view selection
	func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
		// This method is triggered whenever the user makes a change to the picker selection.
		// The parameter named row and component represents what was selected.
		teamSize = Int(pickerData[row])!
	}
	
	func numberOfComponents(in pickerView: UIPickerView) -> Int {
		return 1
	}
}
