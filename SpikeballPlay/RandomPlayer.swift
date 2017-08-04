//
//  RandomPlayer.swift
//  SpikeballPlay
//
//  Created by Jordan Davis on 8/2/17.
//  Copyright © 2017 HoverSlam. All rights reserved.
//

import Foundation

public class RandomPlayer {
    public var id: Int
    public var name: String
    public var wins: Int = 0
    public var losses: Int = 0
    public var pointsFor: Int = 0
    public var pointsAgainst: Int = 0
    public var rating: Int = 0
    
    init(id: Int, name: String) {
        self.id = id
        
        if name.isEmpty {
            self.name = String(id)
        } else {
            self.name = name
        }
    }
}
