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

    @IBOutlet weak var newSessionButton: UIButton!
    @IBOutlet weak var sessionTableView: UITableView!
    var sessionList = [NSManagedObject]()
    
    override func viewDidLoad() {
        sessionTableView.delegate = self
        sessionTableView.dataSource = self
        // Do any additional setup after loading the view.
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateSessionList()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let backItem = UIBarButtonItem()
        backItem.title = "Sessions"
        navigationItem.backBarButtonItem = backItem // This will show in the next view controller being pushed
    }
    
    // MARK: - Table View methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sessionList.count //RPManager.rpManager.sessionList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "sessionButtonCell")
        let button = cell?.contentView.subviews[0] as! UIButton
        button.addTarget(self, action: #selector(self.sessionClicked), for: .touchUpInside)

        // set button click method
        
        button.setTitle(sessionList[indexPath.row].value(forKey: "name") as? String, //RPManager.rpManager.sessionList[indexPath.row].value(forKey: "name") as? String,
                        for: .normal)
        return cell!
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    // Session item tapped
    func sessionClicked() {
    
    }
    
    // new session button clicked
    @IBAction func addNewSession(_ sender: UIButton) {
        let session = RandomPlaySession(name: "Session 3")
        
        // add this session to a list
        self.saveSession(session: session)
        self.updateSessionList()
        sessionTableView.reloadData()
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
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    // Save a new session to local storage / Core Data
    func saveSession(session: RandomPlaySession) {
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
        
        let newSession = NSManagedObject(entity: entity,
                                     insertInto: managedContext)
        
        // 3
        newSession.setValue(session.name, forKeyPath: "name")
        
        // 4
        do {
            try managedContext.save()
            RPManager.rpManager.sessionList.append(newSession)
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
}
