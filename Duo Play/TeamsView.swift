//
//  TeamsView.swift
//  SpikeballPlay
//
//  Created by Jordan Davis on 8/11/17.
//  Copyright © 2017 HoverSlam. All rights reserved.
//

import UIKit

class TeamsView: UIViewController, UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate {
    
    @IBOutlet var longPressRecognizer: UILongPressGestureRecognizer!
    var teamsController = TeamsViewController()
    var tableDataSource = [String]()
    @IBOutlet weak var teamNameTextField: UITextField!
    @IBOutlet weak var teamsTableView: UITableView!
    
    override func viewDidLoad() {
        title = "Teams"
        teamsTableView.delegate = self
        teamsTableView.dataSource = self
        initTableDataSource()
        initGestureRecognizer()
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
    
    func initGestureRecognizer() {
        longPressRecognizer.delegate = self
        longPressRecognizer.addTarget(self, action: #selector(self.onLongPress))
        self.teamsTableView.addGestureRecognizer(longPressRecognizer)
    }
    
    func onLongPress() {
        teamsTableView.isEditing = true
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
        //Idk if this does anything but I think I need it here
        return "Pool"
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableCell(withIdentifier: "teamNameCell")
        header?.textLabel?.text = PoolsViewController.poolsList[section].name
        return header
    }
    
    // Dragging teams around
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let movedObject = TeamsViewController.teamsList[sourceIndexPath.row]
        TeamsViewController.teamsList.remove(at: sourceIndexPath.row)
        TeamsViewController.teamsList.insert(movedObject, at: destinationIndexPath.row)
        resetPoolTeams()
        self.teamsTableView.reloadData()
    }
    
    func resetPoolTeams() {
        // teams were moved around, reset which pool they belong to
        var poolIndex = 0
        for index in 1...TeamsViewController.teamsList.count {
            if index % 8 == 0 {
                poolIndex += 1
            }
            
            PoolsViewController.poolsList[poolIndex].addTeamToPool(team: TeamsViewController.teamsList[index - 1])
        }
    }
    
    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return .none
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "teamNameCell")
        cell!.textLabel?.text = TeamsViewController.teamsList[indexPath.row].name
        cell?.detailTextLabel?.text = String(describing: TeamsViewController.teamsList[indexPath.row].division)
        return cell!
    }

}
