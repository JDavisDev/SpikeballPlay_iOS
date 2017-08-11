//
//  SettingsViewController.swift
//  SpikeballPlay
//
//  Created by Jordan Davis on 8/11/17.
//  Copyright © 2017 HoverSlam. All rights reserved.
//

import UIKit

class SettingsView: UIViewController {

    enum Setting {
        case Format
        case PlayersPerPool
    }
    enum SettingFormat {
        case SingleElimination
        case DoubleElimination
        case Spikeball
    }
    
    enum SettingPlayersPerPool {
        case Six
        case Seven
        case Eight
        case Nine
        case Ten
    }
    
    static var SETTINGS = Dictionary<Setting, String>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
