//
//  CoreDataManager.swift
//  Duo Play
//
//  Created by Jordan Davis on 6/3/18.
//  Copyright © 2018 Jordan Davis. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class CoreDataManager {
	
	static let sharedManager = CoreDataManager()
	
	private init() {} // Prevent clients from creating another instance.
	
	lazy var persistentContainer: NSPersistentContainer = {
		
		let container = NSPersistentContainer(name: "DataModel")
		
		
		container.loadPersistentStores(completionHandler: { (storeDescription, error) in
			
			if let error = error as NSError? {
				fatalError("Unresolved error \(error), \(error.userInfo)")
			}
		})
		return container
	}()
	
	func saveContext () {
		let context = CoreDataManager.sharedManager.persistentContainer.viewContext
		if context.hasChanges {
			do {
				try context.save()
			} catch {
				// Replace this implementation with code to handle the error appropriately.
				// fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
				let nserror = error as NSError
				fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
			}
		}
	}
	
	func insertTournament(name: String, id: Int, url: String, userId: String, createdDate: Date, password: String) -> CDTournament? {
		let managedContext = CoreDataManager.sharedManager.persistentContainer.viewContext
		let entity = NSEntityDescription.entity(forEntityName: "CDTournament",
												in: managedContext)!
		let tournament = NSManagedObject(entity: entity,
									 insertInto: managedContext) as? CDTournament
		tournament?.name = name
		tournament?.url = url
		tournament?.password = password
		tournament?.created_date = createdDate
		tournament?.userId = userId
		tournament?.id = Int64(id)
		
		do {
			try managedContext.save()
			return tournament as? CDTournament
		} catch let error as NSError {
			print("Could not save. \(error), \(error.userInfo)")
			return nil
		}
	}
	
	func fetchTournaments() -> [CDTournament]? {
		/*Before you can do anything with Core Data, you need a managed object context. */
		let managedContext = CoreDataManager.sharedManager.persistentContainer.viewContext
		
		/*As the name suggests, NSFetchRequest is the class responsible for fetching from Core Data.
		
		Initializing a fetch request with init(entityName:), fetches all objects of a particular entity. This is what you do here to fetch all Person entities.
		*/
		let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "CDTournament")
		
		/*You hand the fetch request over to the managed object context to do the heavy lifting. fetch(_:) returns an array of managed objects meeting the criteria specified by the fetch request.*/
		do {
			let tournament = try managedContext.fetch(fetchRequest)
			return tournament as? [CDTournament]
		} catch let error as NSError {
			print("Could not fetch. \(error), \(error.userInfo)")
			return nil
		}
	}
}
