//
//  RandomPlayer.swift
//  SpikeballPlay
//
//  Created by Jordan Davis on 8/2/17.
//  Copyright © 2017 HoverSlam. All rights reserved.
//

import Foundation

class RandomPlayer {
    var id: Int
    var name: String
    
    init(id: Int, name: String) {
        self.id = id
        
        if name.isEmpty {
            self.name = String(id)
        } else {
            self.name = name
        }
    }
}
