//
//  RandomPlayer.swift
//  SpikeballPlay
//
//  Created by Jordan Davis on 8/2/17.
//  Copyright © 2017 HoverSlam. All rights reserved.
//

import Foundation
import RealmSwift
import Realm

public class RandomPlayer : Object {
    @objc dynamic public var id: Int = 0
    @objc dynamic public var name: String = "name"
    @objc dynamic public var wins: Int = 0
    @objc dynamic public var losses: Int = 0
    @objc dynamic public var pointsFor: Int = 0
    @objc dynamic public var pointsAgainst: Int = 0
    @objc dynamic public var rating: Float = 0
    @objc dynamic public var matchDifficulty: Float = 0.0
    @objc dynamic public var isSuspended: Bool = false
}
