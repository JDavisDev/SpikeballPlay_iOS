//
//  RPRandomizingController.swift
//  SpikeballPlay
//
//  Created by Jordan Davis on 8/4/17.
//  Copyright © 2017 HoverSlam. All rights reserved.
//

import Foundation

class RPRandomizingController {
    
    init() {
        
    }
    
    public func getFourRandomPlayers() -> [Int] {
        // return four integers for the positions
        // since I'm not using 0 as an id, I can send back player id
        var returnArray = [Int]()
        
        // run this looop until return array is full
        while returnArray.count < 4 {
            let index = Int(arc4random_uniform(UInt32(RPController.playersList.count)))
            if !returnArray.contains(index) {
                returnArray.append(index)
            }
        }
        
        return returnArray
    }
    
    func getRandomPlayerIndex(nameOne: String, nameTwo: String, nameThree: String, nameFour: String) -> Int {
        if RPController.playersList.count == 4 &&
            !nameOne.isEmpty && !nameTwo.isEmpty && !nameThree.isEmpty && !nameFour.isEmpty &&
            nameOne != "Select Player" && nameTwo != "Select Player" && nameThree != "Select Player" && nameFour != "Select Player"   {
            return -1
        }
        
        var index = Int(arc4random_uniform(UInt32(RPController.playersList.count)))
        while !isPlayerSelectedUnique(playerIndex: index, nameOne: nameOne, nameTwo: nameTwo, nameThree: nameThree,nameFour: nameFour) {
            index = Int(arc4random_uniform(UInt32(RPController.playersList.count)))
        }
        
        return index
        
    }
    
    func isPlayerSelectedUnique(playerIndex: Int, nameOne: String, nameTwo: String, nameThree: String, nameFour: String) -> Bool {
        let name = RPController.playersList[playerIndex].name
        if  name.isEmpty ||
            name == nameOne ||
            name == nameTwo ||
            name == nameThree ||
            name == nameFour {
            return false
        }
        
        return true;
    }
}
