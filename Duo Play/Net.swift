//
//  Net.swift
//  Duo Play
//
//  Created by Jordan Davis on 11/8/17.
//  Copyright © 2017 Jordan Davis. All rights reserved.
//

import Foundation
import RealmSwift

class Net : Object{
    @objc dynamic var id = ""
    @objc dynamic var scoreOne = 0
    @objc dynamic var scoreTwo = 0
    var playersList = List<RandomPlayer>()
}
