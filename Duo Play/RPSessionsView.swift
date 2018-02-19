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
        sessionTableView.delegate = self
        sessionTableView.dataSource = self

        newSessionButton.layer.cornerRadius = 20
        newSessionButton.layer.borderColor = UIColor.white.cgColor
        newSessionButton.layer.borderWidth = 1
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
        do {
            let realm = try Realm()
            let results = realm.objects(Session.self).filter("uuid = '" + getCurrentSessionId() + "'").first
            return results!
        } catch let error as NSError {
            print("REALM ERROR: \(error)")
            return Session()
        }
    }
    
    func getSessionByName(name: String) -> Session {
        return realm.objects(Session.self).filter("name = '\(name)'").first!
    }
    
    @IBAction func deleteAll_Clicked(_ sender: Any) {
        // add dialog here
        try! realm.write() {
            realm.deleteAll()
        }
        
        updateSessionList()
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
                         for: .touchUpInside)
    
        button.addGestureRecognizer(self.longPressGesture())
        
        return cell!
    }
    
    func longPressGesture() -> UILongPressGestureRecognizer {
        let lpg = UILongPressGestureRecognizer(target: self, action: #selector(self.longPress))
        lpg.minimumPressDuration = 0.5
        return lpg
    }
    
    @objc func longPress(_ sender: UILongPressGestureRecognizer) {
        var selectedSession = Session()
        
        if let button = sender.view as? UIButton {
            let name = button.currentTitle
            selectedSession = getSessionByName(name: name!)
        } else {
            return
        }
        
        //show dialog to rename or delete session
        let alert = UIAlertController(title: "Edit Session",
                                      message: "", preferredStyle: .alert)
        
        alert.addTextField { (textField) in
            textField.placeholder = "Session Name"
            textField.text = selectedSession.name
        }
        
        let renameAction = UIAlertAction(title: "Save", style: .default) { (alertAction) in
            _ = alert.textFields![0] as UITextField
            let newName = alert.textFields![0].text!
            try! self.realm.write {
                let session = selectedSession
                session.name = newName
            }
            
            self.updateSessionList()
            self.sessionTableView.reloadData()
        }
        alert.addAction(renameAction)
        
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { (alertAction) in
            self.deleteSession(session: selectedSession)
            self.updateSessionList()
            self.sessionTableView.reloadData()
            Answers.logCustomEvent(withName: "Session Deleted",
                                   customAttributes: [:])
        }
        
        alert.addAction(deleteAction)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
            // cancel
            // update history list
            self.viewDidAppear(true)
            return
        }))
        
        alert.popoverPresentationController?.sourceView = self.view
        self.present(alert, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func deleteSession(session: Session) {
        try! realm.write {
            realm.delete(session.playersList)
            realm.delete(session.gameList)
            realm.delete(session.historyList)
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
        
        sessionTableView.reloadData()
    }
}
