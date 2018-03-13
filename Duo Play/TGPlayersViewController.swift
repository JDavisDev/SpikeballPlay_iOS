//
//  TGPlayersViewController.swift
//  Duo Play
//
//  Created by Jordan Davis on 3/12/18.
//  Copyright © 2018 Jordan Davis. All rights reserved.
//

import UIKit

class TGPlayersViewController: UIViewController {

	@IBOutlet weak var playersTableView: UITableView!
	
	@IBOutlet weak var teamSizePickerView: UIPickerView!
	
	override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
	
	
	@IBAction func addPlayer(_ sender: Any) {
	}
	
	@IBAction func generateButton(_ sender: Any) {
	}
}
