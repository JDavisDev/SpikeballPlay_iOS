//
//  RPRandomizingController.swift
//  SpikeballPlay
//
//  Created by Jordan Davis on 8/4/17.
//  Copyright © 2017 HoverSlam. All rights reserved.
//

import Foundation

class RPRandomizingController {
    
    var sittingPlayersArray = [Int]()
    var backupSittersArray = [Int]()
    var controller: RPController
    
    init(controller: RPController) {
            self.controller = controller
    }
    
    public func getFourRandomPlayers() -> [Int] {
        // return four integers for the positions
        // since I'm not using 0 as an id, I can send back player id
        var returnArray = [Int]()
        backupSittersArray = [Int]()
        
        // run until we get a unique game
        while !isGameUnique(current: returnArray) {
            returnArray.removeAll()
            
            // if the game was not unique, make sure we grab the sitters since we cleared them
            returnArray = backupSittersArray
            
            // run this looop until return array is full
            while returnArray.count < 4 {
                // no sitters, so grab 4 randoms
                if sittingPlayersArray.count <= 0 {
                    let index = Int(arc4random_uniform(UInt32(controller.playersList!.count)))
                    if !returnArray.contains(index) {
                        returnArray.append(index)
                    }
                } else {
                    // we have sitters, so grab them and randomize them
                    sittingPlayersArray = randomizeArray(array: sittingPlayersArray)
                    backupSittersArray = sittingPlayersArray
                    
                    // this will add the sitters to our return Array
                    // when empty, it may grab randoms and add them, though it may duplicate some
                    returnArray = sittingPlayersArray
                    sittingPlayersArray.removeAll()
                }
            }
        }
        
        for index in 0..<controller.playersList!.count {
            if !returnArray.contains(index) {
                sittingPlayersArray.append(index)
            }
        }
        
        return returnArray
    }
    
    // check if the game has been reported yet
    func isGameUnique(current: [Int]) -> Bool {
        if current.count < 4 { return false }
        if !isUniqueGamesLeft() { return true } /// all unique games played, so return true to prevent infinite loop
        
        for game in controller.gameList! {
            // try to fail fast
            if isTeamIdsEqual(current: current, game: game) {
                if isMatchupsEqual(current: current, game: game) {
                    return false
                }
            }
        }
        
        return true
    }
    
    // see if all the unique games have been played
    func isUniqueGamesLeft() -> Bool {
        let numGamesPossible = factorial(num: (controller.playersList?.count)!) / 8
        let currentCount = controller.gameList?.count
        return currentCount! < numGamesPossible
    }
    
    // Calculates the factorial of a number
    func factorial(num: Int) -> Int {
        if num == 0 {
            return 1
        }
        var o: Int = 1
        for i in 1...num {
            o *= i
        }
        return o
    }
    
    // mix up an array and return it
    func randomizeArray(array: [Int]) -> [Int] {
        var temp: Int
        var randomIntOne = Int(arc4random_uniform(UInt32(array.count)))
        
        return array
        
    }

    
    // check if team ids match, if they don't we know they are unique quicker
    func isTeamIdsEqual(current: [Int], game: RandomGame) -> Bool {
       if (current[0] + current[1] + 2   == game.playerOne.id + game.playerTwo.id) &&
            (current[2] + current[3] + 2 == game.playerThree.id + game.playerFour.id) ||
            (current[0] + current[1] + 2 == game.playerThree.id + game.playerFour.id) &&
            (current[2] + current[3] + 2 == game.playerOne.id + game.playerTwo.id) {
           return true
       } else {
           return false
       }
    }
    
    // check if these teams have played with each other and the match up is identical
    func isMatchupsEqual(current: [Int], game: RandomGame) -> Bool {
        if (current[0] + 1 == game.playerOne.id && current[1] + 1 == game.playerTwo.id) ||
            (current[0] + 1 == game.playerTwo.id && current[1] + 1 == game.playerOne.id) {
            if (current[2] + 1 == game.playerThree.id && current[3] + 1 == game.playerFour.id) ||
                (current[2] + 1 == game.playerFour.id && current[3] + 1 == game.playerThree.id) {
                return true
            }
        }
        
        if (current[2] + 1 == game.playerOne.id && current[3] + 1 == game.playerTwo.id) ||
            (current[2] + 1 == game.playerTwo.id && current[3] + 1 == game.playerOne.id) {
            if (current[0] + 1 == game.playerThree.id && current[1] + 1 == game.playerFour.id) ||
                (current[0] + 1 == game.playerFour.id && current[1] + 1 == game.playerThree.id) {
                return true
            }
        }
        
        return false
    }

    func getRandomPlayerIndex(nameOne: String, nameTwo: String, nameThree: String, nameFour: String) -> Int {
        if controller.playersList?.count == 4 &&
            !nameOne.isEmpty && !nameTwo.isEmpty && !nameThree.isEmpty && !nameFour.isEmpty &&
            nameOne != "Select Player" && nameTwo != "Select Player" && nameThree != "Select Player" && nameFour != "Select Player"   {
            return -1
        }
        
        var index = Int(arc4random_uniform(UInt32(controller.playersList!.count)))
        while !isPlayerSelectedUnique(playerIndex: index, nameOne: nameOne, nameTwo: nameTwo, nameThree: nameThree,nameFour: nameFour) {
            index = Int(arc4random_uniform(UInt32(controller.playersList!.count)))
        }
        
        return index
        
    }
    
    func isPlayerSelectedUnique(playerIndex: Int, nameOne: String, nameTwo: String, nameThree: String, nameFour: String) -> Bool {
        let name = controller.playersList![playerIndex].name
        if  name.isEmpty ||
            name == nameOne ||
            name == nameTwo ||
            name == nameThree ||
            name == nameFour ||
            controller.playersList![playerIndex].isSuspended {
            return false
        }
        
        return true;
    }
}
