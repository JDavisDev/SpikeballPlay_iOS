//
//  PoolsController.swift
//  Duo Play
//
//  Created by Jordan Davis on 11/13/17.
//  Copyright © 2017 Jordan Davis. All rights reserved.
//

import Foundation
import RealmSwift

class PoolsController {
    let realm = try! Realm()
    
    func addTeamToPool(pool: Pool, team: Team) {
        try! realm.write {
            team.pool = pool
            pool.teamList.append(team)
        }
    }
    
    
}
