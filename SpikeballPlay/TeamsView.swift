//
//  TeamsView.swift
//  SpikeballPlay
//
//  Created by Jordan Davis on 8/11/17.
//  Copyright © 2017 HoverSlam. All rights reserved.
//

import UIKit

class TeamsView: UIViewController, UITableViewDataSource, UITableViewDelegate {

    var teamsController = TeamsViewController()
    var tableDataSource = [String]()
    @IBOutlet weak var teamNameTextField: UITextField!
    @IBOutlet weak var teamsTableView: UITableView!
    
    override func viewDidLoad() {
        teamsTableView.delegate = self
        teamsTableView.dataSource = self
        initTableDataSource()
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func initTableDataSource() {
        // set up team list with pools in the array
        for pool in PoolsViewController.poolsList {
            tableDataSource.append(pool.name)
            
            for team in TeamsViewController.teamsList {
                if pool === team.pool {
                    tableDataSource.append(team.name)
                }
            }
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    
    @IBAction func addTeam(_ sender: UIButton) {
        // let's present an alert to enter a team. cleaner ui
        let alert = UIAlertController(title: "Add Team",
                                      message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Save", style: .default) { (alertAction) in
            _ = alert.textFields![0] as UITextField
            let newName = alert.textFields![0].text!
            self.teamsController.addTeam(name: newName)
            self.teamsTableView.reloadData()
            // update list
        }
        
        alert.addTextField { (textField) in
            textField.placeholder = "Team Name"
        }
        
        alert.addAction(action)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
            // cancel
            return
        }))
        
        present(alert, animated: true, completion: nil)
    }
    
    //MARK: Table view init
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // fetches the number of teams in this pool
        return PoolsViewController.poolsList[section].teams.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return PoolsViewController.poolsList.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        // convert int to letter: 1 - A, 2 - B, etc.
        return "Pool \(section)"
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "teamNameCell")
        cell!.textLabel?.text = TeamsViewController.teamsList[indexPath.row].name
        cell?.detailTextLabel?.text = String(describing: TeamsViewController.teamsList[indexPath.row].division)
        return cell!
    }

}
