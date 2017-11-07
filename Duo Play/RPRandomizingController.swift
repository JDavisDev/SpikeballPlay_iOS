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
    
    let session = RPSessionsView.getCurrentSession()
    let realm = try! Realm()
    var sittingPlayersArray = [RandomPlayer]()
    var backupSittersArray = [RandomPlayer]()
    
    public func getFourRandomPlayers() -> [RandomPlayer] {
        // return four integers for the positions
        // since I'm not using 0 as an id, I can send back player id
        var returnArray = [RandomPlayer]()
        backupSittersArray = [RandomPlayer]()
        
        // run until we get a unique game
        while !isGameUnique(currentGamePlayers: returnArray) {
            returnArray.removeAll()
            
            // if the game was not unique, make sure we grab the sitters since we cleared them
            returnArray = backupSittersArray
            
            // run this looop until return array is full
            while returnArray.count < 4 {
                // no sitters, so grab 4 randoms
                if sittingPlayersArray.count <= 0 {
                    let randomPlayer = session.playersList[Int(arc4random_uniform(UInt32(session.playersList.count)))]
                    if !returnArray.contains(randomPlayer) {
                        returnArray.append(randomPlayer)
                    }
                } else {
                    // we have sitters, so grab them and randomize them
                   // sittingPlayersArray = randomizeArray(array: sittingPlayersArray)
                    backupSittersArray = sittingPlayersArray
                    
                    // this will add the sitters to our return Array
                    // when empty, it may grab randoms and add them, though it may duplicate some
                    returnArray = sittingPlayersArray
                    sittingPlayersArray.removeAll()
                }
            }
        }
        
        for index in 0..<session.playersList.count {
            if !returnArray.contains(session.playersList[index]) {
                sittingPlayersArray.append(session.playersList[index])
            }
        }
        
        return returnArray
    }
    
    // check if the game has been reported yet
    func isGameUnique(currentGamePlayers: [RandomPlayer]) -> Bool {
        if currentGamePlayers.count < 4 { return false }
        if !isUniqueGamesLeft() { return true } /// all unique games played, so return true to prevent infinite loop
        
            for game in session.gameList {
                // try to fail fast
                if game.playerOne != nil && game.playerTwo != nil && game.playerThree != nil && game.playerFour != nil {
                    if isTeamIdsEqual(current: currentGamePlayers, game: game) {
                        if isMatchupsEqual(current: currentGamePlayers, game: game) {
                            if isNewPartner(currentGamePlayers: currentGamePlayers, game: game) {
                                return false
                            }
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
    func isTeamIdsEqual(current: [RandomPlayer], game: RandomGame) -> Bool {
        if (current[0].id + current[1].id  + 2   == (game.playerOne?.id )! + (game.playerTwo?.id )!) {
            if (current[2].id  + current[3].id  + 2 == (game.playerThree?.id )! + (game.playerFour?.id )!) {
                if (current[0].id  + current[1].id  + 2 == (game.playerThree?.id )! + (game.playerFour?.id )!) {
                    if (current[2].id  + current[3].id  + 2 == (game.playerOne?.id )! + (game.playerTwo?.id )!) {
                        return true
                    }
                }
            }
       }
        
        return false
    }
    
    // check if these teams have played with each other and the match up is identical
    func isMatchupsEqual(current: [RandomPlayer], game: RandomGame) -> Bool {
        if (current[0].id + 1 == game.playerOne?.id && current[1].id + 1 == game.playerTwo?.id) ||
            (current[0].id + 1 == game.playerTwo?.id && current[1].id + 1 == game.playerOne?.id) {
            if (current[2].id + 1 == game.playerThree?.id && current[3].id + 1 == game.playerFour?.id) ||
                (current[2].id + 1 == game.playerFour?.id && current[3].id + 1 == game.playerThree?.id) {
                return true
            }
        }

        if (current[2].id + 1 == game.playerOne?.id && current[3].id + 1 == game.playerTwo?.id) ||
            (current[2].id + 1 == game.playerTwo?.id && current[3].id + 1 == game.playerOne?.id) {
            if (current[0].id + 1 == game.playerThree?.id && current[1].id + 1 == game.playerFour?.id) ||
                (current[0].id + 1 == game.playerFour?.id && current[1].id + 1 == game.playerThree?.id) {
                return true
            }
        }
        
        return false
    }
    
    // check if each player has a NEW partner relative to the last game they played
    // currentPlayerIndices is the current game under test
    // game is the current game to compare against to see if it disqualifies this set of players
    func isNewPartner(currentGamePlayers: [RandomPlayer], game: RandomGame) -> Bool {
        // player one
        let lastGame = game.playerOne?.gameList[(game.playerOne?.gameList.index(of: game))! - 1]
        
        
        return true
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
    
    public func resetValues() {
        sittingPlayersArray.removeAll()
        backupSittersArray.removeAll()
    }
}
