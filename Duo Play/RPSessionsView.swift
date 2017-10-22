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
    static var userSession = RandomPlaySession()
    @IBOutlet weak var newSessionButton: UIButton!
    @IBOutlet weak var sessionTableView: UITableView!
    var sessionList = [NSManagedObject]()
    
    override func viewDidLoad() {
        sessionTableView.delegate = self
        sessionTableView.dataSource = self

        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateSessionList()
        //deleteAllData(entity: "Session")
    }
    
    // Send tapped Session to new view
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let backItem = UIBarButtonItem()
        backItem.title = "Sessions"
        navigationItem.backBarButtonItem = backItem // This will show in the next view controller being pushed
        
        // send session
        let indexPath = sessionTableView.indexPathForSelectedRow
        let session = sessionList[(indexPath?.row)!]
        RPSessionsView.userSession = session as! RandomPlaySession
    }
    
    // MARK: - Table View methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sessionList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "sessionButtonCell")
        let button = cell?.contentView.subviews[0] as! UIButton
        
        button.setTitle(sessionList[indexPath.row].value(forKey: "name") as? String, //RPManager.rpManager.sessionList[indexPath.row].value(forKey: "name") as? String,
                        for: .normal)
        return cell!
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
            let session = NSEntityDescription.insertNewObject(forEntityName: "Session", into: AppDelegate.getContext())
            session.setValue(newName, forKey: "name")
            var code = NSCoder()
            session.setValue(RPController(coder: code), forKey: "rpController")
            self.appDelegate?.saveContext()
            
            // add this session to a list
            self.updateSessionList()
            self.sessionTableView.reloadData()
            RPSessionsView.userSession = self.sessionList[0] as! RandomPlaySession
        }
        
        let actionCancel = UIAlertAction(title: "Cancel", style: .cancel) { (alertAction) in
            return
        }
        
        alert.addAction(action)
        alert.addAction(actionCancel)
        
        present(alert, animated: true, completion: nil)
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
            sessionList = try managedContext.fetch(fetchRequest as! NSFetchRequest<NSFetchRequestResult>) as! [NSManagedObject]
                for item in sessionList {
                    for key in item.entity.attributesByName.keys {
                        let value: Any? = item.value(forKey: key)
                        print("\(key) = \(value)")
                    }
            }
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    // DELETE ALL SESSIONS
    func deleteAllData(entity: String) {
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
            sessionList = try managedContext.fetch(fetchRequest as! NSFetchRequest<NSFetchRequestResult>) as! [NSManagedObject]
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
