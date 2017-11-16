//
//  Tournament.swift
//  SpikeballPlay
//
//  Created by Jordan Davis on 8/11/17.
//  Copyright © 2017 HoverSlam. All rights reserved.
//

import Foundation
import RealmSwift

class Tournament : Object {
    @objc dynamic public var uuid = ""
    @objc dynamic public var name = ""
    
    var bracket = Bracket()
    var poolList = List<Pool>()
    var teamList = List<Team>()
}
