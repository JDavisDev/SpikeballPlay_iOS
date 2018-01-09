//
//  Pool.swift
//  SpikeballPlay
//
//  Created by Jordan Davis on 8/11/17.
//  Copyright © 2017 HoverSlam. All rights reserved.
//

import Foundation
import RealmSwift

public class Pool : Object {
    @objc dynamic public var name = ""
    var teamList = List<Team>()
    @objc dynamic var division = ""
    @objc dynamic var isPowerPool = false
    var matchupList = List<PoolPlayMatchup>()
}
