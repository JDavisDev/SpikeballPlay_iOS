//
//  SettingsViewController.swift
//  SpikeballPlay
//
//  Created by Jordan Davis on 8/11/17.
//  Copyright © 2017 HoverSlam. All rights reserved.
//

import Foundation

class SettingsViewController {
    static let SINGLE_ELIMINATION = "SINGLE ELIMINATION"
    static let DOUBLE_ELIMINATION = "DOUBLE ELIMINATION"
    static let SINGLE_AND_CONSOLATION = "SINGLE AND CONSOLATION"
    
    static var SETTINGS = Dictionary<String, String>()
    
    func setFormat(format: String) {
        SettingsViewController.SETTINGS.updateValue(format, forKey: "FORMAT")
    }
}
