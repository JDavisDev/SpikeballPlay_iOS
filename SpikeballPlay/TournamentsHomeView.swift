//
//  TournamentsHome.swift
//  SpikeballPlay
//
//  Created by Jordan Davis on 8/11/17.
//  Copyright © 2017 HoverSlam. All rights reserved.
//

import UIKit

class TournamentsHomeView: UIViewController {

    let tournamentsHomeController = TournamentsHomeViewController()
    
    @IBOutlet weak var tournamentNameTextField: UITextField!
    
    @IBOutlet weak var tournamentTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        tournamentTableView.reloadData()
        super.viewDidAppear(true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
    }
    
    
    @IBAction func addTournamentButtonClicked(_ sender: UIButton) {
        tournamentsHomeController.addTournament(tournamentName: tournamentNameTextField.text!)
    }

}
