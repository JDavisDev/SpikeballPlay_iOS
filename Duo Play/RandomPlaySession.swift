//
//  RandomPlaySession.swift
//  SpikeballPlay
//
//  Created by Jordan Davis on 8/2/17.
//  Copyright © 2017 HoverSlam. All rights reserved.
//

import Foundation

public class RandomPlaySession {
    
    var rpController = RPController()
    var name: String
    var id = 1
    var dateCreated = Date()
    
    init(name: String) {
        self.name = name
    }
    
    func getController() -> RPController {
        return rpController
    }
    
}
