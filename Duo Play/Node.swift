//
//  Node.swift
//  Duo Play
//
//  Created by Jordan Davis on 3/7/18.
//  Copyright © 2018 Jordan Davis. All rights reserved.
//

import Foundation

class Node {
    var value: [String]
    var children: [Node] = []
    
    init(value: [String]) {
        self.value = value
    }
    
    func add(child: Node) {
        children.append(child)
    }
}
