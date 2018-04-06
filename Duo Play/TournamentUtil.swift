//
//  TournamentUtil.swift
//  Duo Play
//
//  Created by Jordan Davis on 3/28/18.
//  Copyright © 2018 Jordan Davis. All rights reserved.
//

import Foundation
import RealmSwift

class TournamentUtil {
	// static functions to check things
	// is duplicate, get teams, etc
	
	
	
	static func AddObjectToRealm(obj: Any) {
		let realm = try! Realm()
		
		if realm.isInWriteTransaction {
			realm.add(obj as! Object)
		} else {
			try! realm.write {
				realm.add(obj as! Object)
			}
		}
	}
}
