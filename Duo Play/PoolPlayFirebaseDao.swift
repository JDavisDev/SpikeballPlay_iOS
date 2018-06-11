//
//  PoolPlayFirebaseDao.swift
//  Duo Play
//
//  Created by Jordan Davis on 6/5/18.
//  Copyright © 2018 Jordan Davis. All rights reserved.
//

import Foundation
import Firebase

class PoolPlayFirebaseDao {
	let fireDB = Firestore.firestore()
	
	func addFirebasePool(pool: Pool) {
		// Add a new document
		// Create an initial document to update.
		fireDB.collection("pools")
			.document("\(pool.tournament_id) - \(pool.name)")
			.setData(pool.dictionary)
	}
	
	func deleteFirebasePool(pool: Pool) {
		fireDB.collection("pools").whereField("tournament_id", isEqualTo: pool.tournament_id)
			.whereField("name", isEqualTo: pool.name)
			.whereField("id", isEqualTo: pool.id)
			.getDocuments() { (querySnapshot, err) in
				if let err = err {
					print("Error getting pools: \(err)")
				} else {
					for document in querySnapshot!.documents {
						document.reference.delete()
					}
				}
		}
	}
}
