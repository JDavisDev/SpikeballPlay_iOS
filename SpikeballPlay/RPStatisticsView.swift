//
//  RPStatisticsView.swift
//  SpikeballPlay
//
//  Created by Jordan Davis on 8/4/17.
//  Copyright © 2017 HoverSlam. All rights reserved.
//

import Foundation
import UIKit

class RPStatisticsView : UIViewController, UITableViewDataSource, UITableViewDelegate,
UIPickerViewDelegate, UIPickerViewDataSource {
    
    var stats =  [Statistics]()
    @IBOutlet weak var statsTable: UITableView!
    @IBOutlet weak var sortingPicker: UIPickerView!
    var pickerDataSource = [String]()
    var controller = RPStatisticsController()
    
    override func viewDidLoad() {
        statsTable.delegate = self
        statsTable.dataSource = self
        sortingPicker.delegate = self
        sortingPicker.dataSource = self
        initpickerData()
        
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        controller.sort(sortMethod: pickerDataSource[sortingPicker.selectedRow(inComponent: 0)])
        initStats()
        initpickerData()
        statsTable.reloadData()
    }
    
    func initpickerData() {
        pickerDataSource.append("Wins")
        pickerDataSource.append("Losses")
        pickerDataSource.append("Name")
        pickerDataSource.append("Points For")
        pickerDataSource.append("Points Against")
        pickerDataSource.append("Point Differential")
        pickerDataSource.append("Rank")
    }
    
    // wipe them away and start fresh to stay up to date.
    func initStats() {
        stats.removeAll()
        for player in RPController.playersList {
            stats.append(Statistics(name: player.name, wins: player.wins, losses: player.losses, pointsFor: player.pointsFor,
                                    pointsAgainst: player.pointsAgainst, pointsDifferential: player.pointsFor - player.pointsAgainst))
        }
    }
    
    //MARK: Table View of statistics
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return stats.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: StatisticCell.self)) as! StatisticCell
        let statRow = stats[indexPath.row]
        cell.name = statRow.name
        cell.wins = String(statRow.wins)
        cell.losses = String(statRow.losses)
        cell.pointsFor = String(statRow.pointsFor)
        cell.pointsAgainst = String(statRow.pointsAgainst)
        cell.pointsDifferential = String(statRow.pointsDifferential)
        
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    //MARK: Sorting Picker
    
    @available(iOS 2.0, *)
    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerDataSource.count
    }
    
    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    public func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        // this weird stuff is so the first item in the picker is not a player and will help with randomizing
        return pickerDataSource[row]
    }
    
    public func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        let titleData = pickerDataSource[row]
        let myTitle = NSAttributedString(string: titleData, attributes: [NSForegroundColorAttributeName: UIColor.white])
        return myTitle
    }
    
    // Selected a sort method
    public func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let sortMethod = pickerDataSource[row]
        controller.sort(sortMethod: sortMethod)
        viewDidAppear(true)
    }
}
