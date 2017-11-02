//
//  History.swift
//  SpikeballPlay
//
//  Created by Jordan Davis on 8/6/17.
//  Copyright © 2017 HoverSlam. All rights reserved.
//

import Foundation
import RealmSwift

class History : Object {
    @objc dynamic var playerOne: String = ""
    @objc dynamic var playerTwo: String = ""
    @objc dynamic var playerThree: String = ""
    @objc dynamic var playerFour: String = ""
    @objc dynamic var scoreOne: String = ""
    @objc dynamic var scoreTwo: String = ""
}
