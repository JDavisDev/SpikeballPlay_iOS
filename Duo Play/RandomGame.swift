//
//  RandomGame.swift
//  SpikeballPlay
//
//  Created by Jordan Davis on 8/3/17.
//  Copyright © 2017 HoverSlam. All rights reserved.
//

import Foundation
import RealmSwift
import Realm

public class RandomGame : Object {
    
    @objc dynamic var playerOne: RandomPlayer?
    @objc dynamic var playerTwo: RandomPlayer?
    @objc dynamic var playerThree: RandomPlayer?
    @objc dynamic var playerFour: RandomPlayer?
    @objc dynamic var teamOneScore: Int =  0
    @objc dynamic var teamTwoScore: Int = 0
}
