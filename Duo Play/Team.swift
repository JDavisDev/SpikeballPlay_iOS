//
//  Team.swift
//  SpikeballPlay
//
//  Created by Jordan Davis on 8/11/17.
//  Copyright © 2017 HoverSlam. All rights reserved.
//

import Foundation
import RealmSwift
import Realm

public class Team : Object {
    @objc dynamic public var seed = 1
    @objc dynamic public var id = 1
    @objc dynamic public var name = ""
    @objc dynamic var pool: Pool?
    @objc dynamic public var division = ""
}
