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
}
