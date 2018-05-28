//
//  PoolsView.swift
//  SpikeballPlay
//
//  Created by Jordan Davis on 8/11/17.
//  Copyright © 2017 HoverSlam. All rights reserved.
//

import UIKit

class PoolsView: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var poolsTableView: UITableView!
    var tournament = TournamentController.getCurrentTournament()
    var poolsController = PoolsController()
	
    override func viewDidLoad() {
        super.viewDidLoad()
        poolsTableView.delegate = self
        poolsTableView.dataSource = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        poolsTableView.reloadData()
        super.viewDidAppear(true)
    }
    
	@IBAction func addPoolButtonClick(_ sender: UIButton) {
		poolsController.addNewPool()
		poolsTableView.reloadData()
	}
	
	// MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // this will handle pool cell click
        // send pool
        let indexPath = poolsTableView.indexPathForSelectedRow
        let pool = tournament.poolList[(indexPath?.row)!]
		let controller = segue.destination as? PoolsDetailView
		
		PoolsController.setSelectedPoolName(name: pool.name)
        controller?.pool = pool
    }
    
    // MARK: - Pools Table View
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "poolCell")
		// check if pool is finished
		if !tournament.poolList[indexPath.row].isFinished {
        	cell!.textLabel?.text = tournament.poolList[indexPath.row].name
        	cell?.detailTextLabel?.text = String(describing: tournament.poolList[indexPath.row].division)
		} else {
			cell!.textLabel?.text = "Finished Pool"
		}
		
		return cell!
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tournament.poolList.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let pool = tournament.poolList[indexPath.row]
		
		if !pool.isFinished {
        	performSegue(withIdentifier: "poolDetailSegue", sender: self)
		}
    }

}
