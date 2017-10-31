//
//  RPSessionsView.swift
//  Duo Play
//
//  Created by Jordan Davis on 8/19/17.
//  Copyright © 2017 Jordan Davis. All rights reserved.
//

import UIKit
import CoreData

class RPSessionsView: UIViewController, UITableViewDelegate, UITableViewDataSource {
    let appDelegate = UIApplication.shared.delegate as? AppDelegate
    @IBOutlet weak var newSessionButton: UIButton!
    @IBOutlet weak var sessionTableView: UITableView!
    public static var sessionUuid: String = "";
    var sessionList: [Session] = []
    
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
    
    // Send tapped Session to new view
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let backItem = UIBarButtonItem()
        backItem.title = "Sessions"
        navigationItem.backBarButtonItem = backItem // This will show in the next view controller being pushed
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
    
    @IBAction func sessionButton_Clicked(sender: UIButton) {
        let name = sender.currentTitle
        var uuid = ""
        if sessionList.count > 0 {
            for sessionName in sessionList {
                if name == sessionName.name {
                    RPSessionsView.setCurrentSessionId(uuid: sessionName.uuid!)
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
    
    // SAVE SESSION
    func saveSession(name: String) {
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return
        }
        
        // 1
        let managedContext =
            appDelegate.persistentContainer.viewContext
        
        // 2
        let entity =
            NSEntityDescription.entity(forEntityName: "Session",
                                       in: managedContext)!
        
        let session = NSEntityDescription.insertNewObject(forEntityName: "Session", into: managedContext) as! Session
        
//        let session = NSManagedObject(entity: entity,
//                                     insertInto: managedContext)

        
        // 3
        session.setValue(name, forKeyPath: "name")
        session.name = name
        
        let uuid = UUID().uuidString
        session.setValue(uuid, forKeyPath: "uuid")
        session.uuid = uuid
        RPSessionsView.setCurrentSessionId(uuid: uuid)
        
        let controller = RPController(playersList: [RandomPlayer](), gameList: [RandomGame]())
        session.rpController = controller
        session.setValue(controller, forKeyPath: "rpController")
        
        // 4
        do {
            try managedContext.save()
            sessionList.append(session)
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    public static func getCurrentSessionId() -> String {
        return RPSessionsView.sessionUuid
    }
    
    public static func setCurrentSessionId(uuid: String) {
        RPSessionsView.sessionUuid = uuid
    }
    
    public static func getCurrentSession() -> Session {
        let id = getCurrentSessionId()
        
        //1
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return Session()
        }
        
        let managedContext =
            appDelegate.persistentContainer.viewContext
        
        //2
        let fetchRequest =
            NSFetchRequest<NSManagedObject>(entityName: "Session")
        
        // filter
        fetchRequest.predicate = NSPredicate(format: "uuid == %@", id)
        
        //3
        do {
            let list = try managedContext.fetch(fetchRequest as! NSFetchRequest<NSFetchRequestResult>) as! [NSManagedObject]
            if list.count > 0 {
                return list.first as! Session
            }
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    
        // create default session with right values

        
        // 2
        let entity =
            NSEntityDescription.entity(forEntityName: "Session",
                                       in: managedContext)!
        
        let session = NSEntityDescription.insertNewObject(forEntityName: "Session", into: managedContext) as! Session
        
        //        let session = NSManagedObject(entity: entity,
        //                                     insertInto: managedContext)
        
        
        // 3
        session.setValue("default", forKeyPath: "name")
        session.name = "default"
        
        let uuid = UUID().uuidString
        session.setValue(uuid, forKeyPath: "uuid")
        session.uuid = uuid
        RPSessionsView.setCurrentSessionId(uuid: uuid)
        
        let controller = RPController(playersList: [RandomPlayer](), gameList: [RandomGame]())
        session.rpController = controller
        session.setValue(controller, forKeyPath: "rpController")
        
        // 4
        do {
            try managedContext.save()
            
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
        
        return session
    }
    
    // Fetch from core data and update our local list
    func updateSessionList() {
        //1
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return
        }
        
        let managedContext =
            appDelegate.persistentContainer.viewContext
        
        //2
        let fetchRequest =
            NSFetchRequest<NSManagedObject>(entityName: "Session")
        
        //3
        do {
            sessionList = try managedContext.fetch(fetchRequest as! NSFetchRequest<NSFetchRequestResult>) as! [Session]
                for item in sessionList {
                    for key in item.entity.attributesByName.keys {
                        let value: Any? = item.value(forKeyPath: key)
                        print("\(key) = \(String(describing: value))")
                    }
            }
            
           // var sessionT = sessionList[0].
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    // DELETE ALL SESSIONS
    func deleteAllData() {
        //1
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return
        }
        
        let managedContext =
            appDelegate.persistentContainer.viewContext
        
        //2
        let fetchRequest =
            NSFetchRequest<NSManagedObject>(entityName: "Session")
        
        //3
        do {
            sessionList = try managedContext.fetch(fetchRequest as! NSFetchRequest<NSFetchRequestResult>) as! [Session]
            for item in sessionList {
                managedContext.delete(item)
            }
            
            // Save Changes
            try managedContext.save()
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
}
}
