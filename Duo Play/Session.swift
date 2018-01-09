//
//  Session.swift
//  Duo Play
//
//  Created by Jordan Davis on 10/31/17.
//  Copyright © 2017 Jordan Davis. All rights reserved.
//

import Foundation
import RealmSwift

class Session : Object {
    @objc dynamic var uuid = ""
    @objc dynamic var name = "test"
    var playersList = List<RandomPlayer>()
    var netList = List<Net>()
    var gameList = List<RandomGame>()
    var historyList = List<History>()
    
    override static func primaryKey() -> String? {
        return "uuid"
    }
}
