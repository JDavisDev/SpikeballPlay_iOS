//
//  RPSessionsView.swift
//  Duo Play
//
//  Created by Jordan Davis on 8/19/17.
//  Copyright © 2017 Jordan Davis. All rights reserved.
//

import UIKit
import CoreData
import Crashlytics
import RealmSwift

class RPSessionsView: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var newSessionButton: UIButton!
    @IBOutlet weak var sessionTableView: UITableView!
    public static var sessionUuid: String = "";
    var sessionList = [Session]()
    let realm = try! Realm()
    
    override func viewDidLoad() {
       // deleteAllData()
        sessionTableView.delegate = self
        sessionTableView.dataSource = self

        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateSessionList()
    }
    
//    // Send tapped Session to new view
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        let backItem = UIBarButtonItem()
//        backItem.title = "Sessions"
//        navigationItem.backBarButtonItem = backItem // This will show in the next view controller being pushed
//    }
    
    static func setCurrentSessionId(uuid: String) {
        RPSessionsView.sessionUuid = uuid
    }
    
    static func getCurrentSessionId() -> String {
        return sessionUuid
    }
    
    static func getCurrentSession() -> Session {
        let realm = try! Realm()
        let results = realm.objects(Session.self).filter("uuid = '" + getCurrentSessionId() + "'").first
        return results!
    }
    
    // MARK: - Table View methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sessionList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "sessionButtonCell")
        let button = cell?.contentView.subviews[0] as! UIButton
        button.setTitle(sessionList[indexPath.row].value(forKeyPath: "name") as? String,
                        for: .normal)
        
        button.addTarget(self,
                         action: #selector(sessionButton_Clicked),
                         for: .touchUpInside
        )
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        // DELETE SLIDE ACTION
        // delete dialog
        let delete = UITableViewRowAction(style: .destructive, title: "Delete") { action, index in
            // pop up dialog for deletion
            let alert = UIAlertController(title: "Delete",
                                          message: "Are you sure?", preferredStyle: .alert)
            
            let action = UIAlertAction(title: "Delete", style: .destructive) { (alertAction) in
                self.deleteSession(session: self.sessionList[indexPath.row])
                self.updateSessionList()
                self.sessionTableView.reloadData()
                Answers.logCustomEvent(withName: "Session Deleted",
                                       customAttributes: [:])
            }
            
            alert.addAction(action)
            
            alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: { (action: UIAlertAction!) in
                // cancel
                // update history list
                self.viewDidAppear(true)
                return
            }))
            
            self.present(alert, animated: true, completion: nil)
        }
        delete.backgroundColor = UIColor.red
        
        
        // RENAME SLIDE ACTION
        let rename = UITableViewRowAction(style: .normal, title: "Rename") { action, index in
            //action dialog for new name
            let alert = UIAlertController(title: "Rename Session",
                                          message: "", preferredStyle: .alert)
            
            alert.addTextField { (textField) in
                textField.placeholder = "Session Name"
                textField.text = self.sessionList[indexPath.row].name
            }
            
            let action = UIAlertAction(title: "Save", style: .default) { (alertAction) in
                _ = alert.textFields![0] as UITextField
                let newName = alert.textFields![0].text!
                try! self.realm.write {
                    let session = self.sessionList[indexPath.row]
                    session.name = newName
                }
                
                self.updateSessionList()
                self.sessionTableView.reloadData()
            }
            alert.addAction(action)
            
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
                // cancel
                // update history list
                self.viewDidAppear(true)
                return
            }))
            
            self.present(alert, animated: true, completion: nil)
        }
        rename.backgroundColor = UIColor.darkGray
        
        let share = UITableViewRowAction(style: .normal, title: "Share") { action, index in
            // Future...
        }
        
        share.backgroundColor = UIColor.blue
        
        return [delete, rename]
    }
    
    func deleteSession(session: Session) {
        try! realm.write {
            realm.delete(session.playersList)
            realm.delete(session.gameList)
            realm.delete(session.historyList)
            // all history objects are not being deleted
            realm.delete(session)
        }
    }
    
    @IBAction func sessionButton_Clicked(sender: UIButton) {
        let name = sender.currentTitle
        if sessionList.count > 0 {
            for sessionName in sessionList {
                if name == sessionName.name {
                    RPSessionsView.setCurrentSessionId(uuid: sessionName.uuid)
                }
            }
        }
        
        performSegue(withIdentifier: "sessionSelectedSegue", sender: self)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    // new session button clicked
    @IBAction func addNewSession(_ sender: UIButton) {
        let alert = UIAlertController(title: "New Session", message: "", preferredStyle: .alert)
    
        alert.addTextField { (textField) in
            textField.placeholder = "Session Name"
        }
        
        let action = UIAlertAction(title: "Save", style: .default) { (alertAction) in
            _ = alert.textFields![0] as UITextField
            let newName = alert.textFields![0].text!
            self.saveSession(name: newName)
            
            // add this session to a list
            self.updateSessionList()
            self.sessionTableView.reloadData()
        }
        
        let actionCancel = UIAlertAction(title: "Cancel", style: .cancel) { (alertAction) in
            return
        }
        
        alert.addAction(action)
        alert.addAction(actionCancel)
        
        present(alert, animated: true, completion: nil)
    }
    
    // Create a new session object
    func saveSession(name: String) {
        let session = Session()
        session.name = name
        
        let uuid = UUID().uuidString
        session.uuid = uuid
        RPSessionsView.setCurrentSessionId(uuid: uuid)
        
        session.gameList = List<RandomGame>()
        session.playersList = List<RandomPlayer>()
        
        try! realm.write {
            realm.add(session)
            sessionList.append(session)
            Answers.logCustomEvent(withName: "Session Added",
                                   customAttributes: [:])
        }
    }
    
    // fetch session list from db
    func updateSessionList() {
        let results = realm.objects(Session.self)
        sessionList.removeAll()
        for session in results {
            sessionList.append(session)
        }
    }
}
