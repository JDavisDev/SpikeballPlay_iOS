//
//  RPRandomizingController.swift
//  SpikeballPlay
//
//  Created by Jordan Davis on 8/4/17.
//  Copyright © 2017 HoverSlam. All rights reserved.
//
import Foundation
import RealmSwift

class RPRandomizingController {
    /// **** UPDATE SITTERS BASED ON WHO IS ON A NET! **** \\\
    let session = RPSessionsView.getCurrentSession()
    let realm = try! Realm()
    var backupSittersArray = [Int]()
    // a list of player ids that are available and not on a net
    public var playersAvailable = [Int]()
    
    public func getFourRandomPlayers() -> [Int] {
        // return four integers for the positions
        // since I'm not using 0 as an id, I can send back player id
        var returnArray = [Int]()
        playersAvailable = getPlayersAvailable()
        
        // run until we get a unique game
        if playersAvailable.count >= 4 {
            while !isGameUnique(current: returnArray) {
                returnArray.removeAll()
           
                // run this looop until return array is full
                while returnArray.count < 4 {
                    // get a random index and check if that player is 'available' by not being on a net
                    let index = Int(arc4random_uniform(UInt32(session.playersList.count)))
                    if playersAvailable.contains(session.playersList[index].id) && !returnArray.contains(index) {
                        returnArray.append(index)
                    }
                }
            }
        }
        
        return returnArray
    }
    
    func getPlayersAvailable() -> [Int] {
        var returnArray = [Int]()
        
        // the player to possible add. Checking ALL players in this session
        for player in session.playersList {
            var isAvailable = true
            
            // check each net in our session
            for net in session.netList {
                // check each player on each net
                for netPlayer in net.playersList {
                    // if player on each net matches a player on a net
                    // set isAvailable to false
                    if netPlayer.id == player.id {
                        isAvailable = false
                    }
                }
            }
            
            if isAvailable {
                returnArray.append(player.id)
            }
        }
        
        return returnArray
    }
    
    // check if the game has been reported yet
    func isGameUnique(current: [Int]) -> Bool {
        if current.count < 4 { return false }
        if !isUniqueGamesLeft() { return true } /// all unique games played, so return true to prevent infinite loop
        
        for game in session.gameList {
            // try to fail fast
            if game.playerOne != nil && game.playerTwo != nil && game.playerThree != nil && game.playerFour != nil {
                if isTeamIdsEqual(current: current, game: game) {
                    if isMatchupsEqual(current: current, game: game) {
                        return false
                    }
                }
            }
        }
        
        return true
    }
    
    // see if all the unique games have been played
    func isUniqueGamesLeft() -> Bool {
        
        let numGamesPossible = factorial(num: (session.playersList.count)) / 8
        let currentCount = session.gameList.count
        return currentCount < numGamesPossible
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
        if (current[0] + current[1] + 2   == (game.playerOne?.id)! + (game.playerTwo?.id)!) {
            if (current[2] + current[3] + 2 == (game.playerThree?.id)! + (game.playerFour?.id)!) {
                if (current[0] + current[1] + 2 == (game.playerThree?.id)! + (game.playerFour?.id)!) {
                    if (current[2] + current[3] + 2 == (game.playerOne?.id)! + (game.playerTwo?.id)!) {
                        return true
                    }
                }
            }
        }
        
        return false
    }
    
    // check if these teams have played with each other and the match up is identical
    func isMatchupsEqual(current: [Int], game: RandomGame) -> Bool {
        if (current[0] + 1 == game.playerOne?.id && current[1] + 1 == game.playerTwo?.id) ||
            (current[0] + 1 == game.playerTwo?.id && current[1] + 1 == game.playerOne?.id) {
            if (current[2] + 1 == game.playerThree?.id && current[3] + 1 == game.playerFour?.id) ||
                (current[2] + 1 == game.playerFour?.id && current[3] + 1 == game.playerThree?.id) {
                return true
            }
        }
        
        if (current[2] + 1 == game.playerOne?.id && current[3] + 1 == game.playerTwo?.id) ||
            (current[2] + 1 == game.playerTwo?.id && current[3] + 1 == game.playerOne?.id) {
            if (current[0] + 1 == game.playerThree?.id && current[1] + 1 == game.playerFour?.id) ||
                (current[0] + 1 == game.playerFour?.id && current[1] + 1 == game.playerThree?.id) {
                return true
            }
        }
        
        return false
    }
    
    func getRandomPlayerIndex(nameOne: String, nameTwo: String, nameThree: String, nameFour: String) -> Int {
        if session.playersList.count == 4 &&
            !nameOne.isEmpty && !nameTwo.isEmpty && !nameThree.isEmpty && !nameFour.isEmpty &&
            nameOne != "Select Player" && nameTwo != "Select Player" && nameThree != "Select Player" && nameFour != "Select Player"   {
            return -1
        }
        
        var index = Int(arc4random_uniform(UInt32(session.playersList.count)))
        while !isPlayerSelectedUnique(playerIndex: index, nameOne: nameOne, nameTwo: nameTwo, nameThree: nameThree,nameFour: nameFour) {
            index = Int(arc4random_uniform(UInt32(session.playersList.count)))
        }
        
        return index
        
    }
    
    func isPlayerSelectedUnique(playerIndex: Int, nameOne: String, nameTwo: String, nameThree: String, nameFour: String) -> Bool {
        
        var name = ""
        try! realm.write {
            name = session.playersList[playerIndex].name
        }
        
        if  name.isEmpty ||
            name == nameOne ||
            name == nameTwo ||
            name == nameThree ||
            name == nameFour ||
            session.playersList[playerIndex].isSuspended {
            return false
        }
        
        return true;
    }
}
