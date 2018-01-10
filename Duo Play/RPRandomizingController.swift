//
//  RPRandomizingController.swift
//  SpikeballPlay
//
//  Created by Jordan Davis on 8/4/17.
//  Copyright © 2017 HoverSlam. All rights reserved.
//
import Foundation
import RealmSwift
import Crashlytics

class RPRandomizingController {
    let session = RPSessionsView.getCurrentSession()
    let realm = try! Realm()
    var backupSittersArray = [Int]()
    // a list of player ids that are available and not on a net
    public var playersAvailable = [Int]()
    var matchupMatrix : [[Int]] = Array(repeating: Array(repeating: 0, count: 2), count: 2)
    
    public func getFourRandomPlayers() -> [Int] {
        // return four integers for the positions
        // since I'm not using 0 as an id, I can send back player id
        Answers.logCustomEvent(withName: "Randomize All Clicked",
                               customAttributes: [:])
        
        var returnArray = [Int]()
        playersAvailable = getPlayersAvailable()
        var playersWithFewerGames = getPlayersWithFewestGames()
        
        // run until we get a unique game
        if playersAvailable.count >= 4 {
            while !isGameUnique(current: returnArray) {
                returnArray.removeAll()
           
                // run this looop until return array is full
                while returnArray.count < 4 {
                    // get a random index and check if that player is 'available' by not being on a net
                    let index = Int(arc4random_uniform(UInt32(session.playersList.count)))
                    let newPlayer = session.playersList[index]
                    
    
                    if playersAvailable.contains(newPlayer.id) &&
                            (playersWithFewerGames.count <= 0 || playersWithFewerGames.contains(newPlayer.id)) &&
                            !returnArray.contains(index) {
                        returnArray.append(index)
                        
                        if(playersWithFewerGames.count > 0 && playersWithFewerGames.index(of: newPlayer.id) != nil) {
                            playersWithFewerGames.remove(at: playersWithFewerGames.index(of: newPlayer.id)!)
                        }
                    }
                }
            }
        }
        
        return randomizeArray(array: returnArray)
    }
    
    func getPlayersWithFewestGames() -> [Int] {
        var fewestGames: Int = 1000000
        var returnPlayers = [Int]()
        
        
         //this worked. lower game players were pulled up. just want to test more before this main RC.
        for index in playersAvailable {
            if session != nil && session.playersList.count > 0 && session.playersList[index - 1].gameList.count < fewestGames {
               fewestGames = session.playersList[index - 1].gameList.count
            }
        }

        // run thru each player and see if they match the fewest games
        for player in playersAvailable {
            if session.playersList[player - 1].gameList.count == fewestGames {
                returnPlayers.append(session.playersList[player - 1].id)
            }
        }
        
        return returnPlayers
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
    
    // rotate array around in a square a random amount of times to mix things up!
    func randomizeArray(array: [Int]) -> [Int] {
        if array.count >= 4 {
            matchupMatrix[0][0] = array[0]
            matchupMatrix[0][1] = array[1]
            matchupMatrix[1][0] = array[2]
            matchupMatrix[1][1] = array[3]
            var returnArray = array
            let randomInt = Int(arc4random_uniform(UInt32(10)))
            
            for _ in 1...randomInt + 2 {
                let temp = matchupMatrix[1][0]
                matchupMatrix[1][0] = matchupMatrix[1][1]
                matchupMatrix[1][1] = matchupMatrix[0][1]
                matchupMatrix[0][1] = temp
            }
            
            returnArray[0] = matchupMatrix[0][1]
            returnArray[1] = matchupMatrix[1][1]
            returnArray[2] = matchupMatrix[0][0]
            returnArray[3] = matchupMatrix[1][0]
            return returnArray
        }
        
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
        Answers.logCustomEvent(withName: "Randomize Player Clicked",
                               customAttributes: [:])
        if session.playersList.count == 4 &&
            !nameOne.isEmpty && !nameTwo.isEmpty && !nameThree.isEmpty && !nameFour.isEmpty &&
            nameOne != "Select Player" && nameTwo != "Select Player" && nameThree != "Select Player" && nameFour != "Select Player"  {
            return -1
        }
        
        if playersAvailable.count <= 0 {
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
        
        if !getPlayersAvailable().contains(playerIndex + 1) {
            return false
        }
        
        return true;
    }
}
