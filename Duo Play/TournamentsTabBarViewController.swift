//
//  TournamentsTabBarViewController.swift
//  Duo Play
//
//  Created by Jordan Davis on 2/28/18.
//  Copyright © 2018 Jordan Davis. All rights reserved.
//

import UIKit
import RealmSwift

class TournamentsTabBarViewController: UITabBarController {

    // set basic information for the tab bar controller
    // mainly view like back button functionality and titles
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // if tournament is bracketOnly, set title = "bracketPlay"
        // else check the tab or something to see if it's pool play or bracket play
        
        let newBackButton = UIBarButtonItem(title: "Back", style: UIBarButtonItemStyle.plain, target: self, action: #selector(self.back(sender:)))
        self.navigationItem.leftBarButtonItem = newBackButton
    }
    
    @objc func back(sender: UIBarButtonItem) {
        // Perform your custom actions
        // ...
        // Go back to the previous ViewController
        _ = navigationController?.popViewController(animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
