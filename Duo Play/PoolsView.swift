//
//  PoolsView.swift
//  SpikeballPlay
//
//  Created by Jordan Davis on 8/11/17.
//  Copyright © 2017 HoverSlam. All rights reserved.
//

import UIKit

class PoolsView: UIViewController {
    
    @IBOutlet weak var poolsTableView: UITableView!
    var tournament = TournamentController.getCurrentTournament()
    var poolsController = PoolsController()
	var selectedPool = Pool()
	
    override func viewDidLoad() {
        super.viewDidLoad()
		title = "Pools"
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
	
	// Specify a division here
	@IBAction func addPoolButtonClick(_ sender: UIButton) {
		// let's do a action sheet here to select division?
		showPoolDivisionActionSheet()
	}
	
	func showPoolDivisionActionSheet() {
		let actionSheet = UIAlertController(title: "Select Division", message: "", preferredStyle: .actionSheet)
		
		for division in Division.allValues {
			let action = UIAlertAction(title: "\(division.value())", style: .default) { (action: UIAlertAction) in
				let _ = self.poolsController.addNewPool(division: Division.Advanced)
				self.poolsTableView.reloadData()
			}
			actionSheet.addAction(action)
		}	
		
		let actionCancel = UIAlertAction(title: "Cancel", style: .cancel) { (action: UIAlertAction) in
			// do nothing
			return
		}
		
		
		actionSheet.addAction(actionCancel)
		actionSheet.popoverPresentationController?.sourceView = self.view
		present(actionSheet, animated: true, completion: nil)
	}
	
	func deletePool(pool: Pool) {
		poolsController.deletePool(pool: pool)
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
	
	func showAlert(title: String, message: String) {
		let alert = UIAlertController(title: title,
									  message: message,
			preferredStyle: .alert)
		
		alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { (action: UIAlertAction!) in
			self.deletePool(pool: self.selectedPool)
		}))
		
		alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
			return
		}))
		
		present(alert, animated: true, completion: nil)
	}
}

extension PoolsView : UITableViewDelegate, UITableViewDataSource {
	// MARK: - Pools Table View
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "poolCell")
		// check if pool is finished
		if !tournament.poolList[indexPath.row].isFinished {
			cell!.textLabel?.text = tournament.poolList[indexPath.row].name
			cell?.detailTextLabel?.text = tournament.poolList[indexPath.row].division
		} else {
			cell!.textLabel?.text = "Finished " + tournament.poolList[indexPath.row].name
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
	
	func tableView(_ tableView: UITableView, editActionsForRowAt: IndexPath) -> [UITableViewRowAction]? {
		let delete = UITableViewRowAction(style: .destructive, title: "Delete") { action, index in
			let pool = self.tournament.poolList[index.row]
			self.selectedPool = pool
			self.showAlert(title: "Delete " + pool.name, message: "Everything in this pool will be deleted.")
		}
		
		return [delete]
	}
}
