//
//  PoolPlayMatchReporter.swift
//  Duo Play
//
//  Created by Jordan Davis on 9/4/17.
//  Copyright © 2017 Jordan Davis. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift

class PoolPlayMatchReporterView : UIViewController {
    let realm = try! Realm()
    
    // hopefully, the selected matchup gets stored here.
    var selectedMatchup = PoolPlayMatchup()
    
    @IBOutlet weak var teamTwoNameLabel: UILabel!
    @IBOutlet weak var teamOneNameLabel: UILabel!
    @IBOutlet weak var teamOneGameOneSlider: UISlider!
    @IBOutlet weak var teamTwoGameOneSlider: UISlider!
    
    
    override func viewDidLoad() {
        teamOneNameLabel.text = selectedMatchup.teamOne?.name
        teamTwoNameLabel.text = selectedMatchup.teamTwo?.name
    }
    
    /* SLIDER VALUE CHANGED
        update score labels */
    @IBAction func teamOneGameOneValueChanged(_ sender: UISlider) {
        
    }
    
    @IBAction func teamTwoGameOneValueChanged(_ sender: UISlider) {
        
    }
    
    
    @IBAction func submitButtonClicked(_ sender: UIButton) {
        try! realm.write() {
            selectedMatchup.isReported = true
        }
    }
}
