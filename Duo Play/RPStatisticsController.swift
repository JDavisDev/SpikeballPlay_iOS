//
//  RPStatisticsController.swift
//  SpikeballPlay
//
//  Created by Jordan Davis on 8/4/17.
//  Copyright © 2017 HoverSlam. All rights reserved.
//

import Foundation
import RealmSwift

class RPStatisticsController {
    let realm = try! Realm()
    let session = RPSessionsView.getCurrentSession()
    
    // Sort statistics page
    public func sort(sortMethod: String) {
        
        try! realm.write {
            var array = Array(session.playersList)
            session.playersList.removeAll()
            
            switch sortMethod {
            case "Wins":
                array.sort { $0.wins > $1.wins }
                break
            case "Losses":
                array.sort { $0.losses > $1.losses }
                break
            case "Points For":
                array.sort { $0.pointsFor > $1.pointsFor }
                break
            case "Points Against":
                array.sort { $0.pointsAgainst > $1.pointsAgainst }
                break
            case "Point Differential":
                array.sort { $0.pointsFor - $0.pointsAgainst > $1.pointsFor - $1.pointsAgainst }
                break
            case "Name":
                array.sort { $0.name < $1.name }
                break
            case "Rating":
                array.sort { $0.rating > $1.rating }
                break
            case "Opponent Rating":
                array.sort { $0.totalOpponentRating > $1.totalOpponentRating }
            default:
                array.sort { $0.id < $1.id }
                break
            }
            
            for player in array {
                session.playersList.append(player)
            }
        }
    }
    
    /* ELO SYSTEM
     For each win, add your opponent's rating plus 400,
     For each loss, add your opponent's rating minus 400,
     And divide this sum by the number of played games. */
    
    func calculateRatings() {
        try! realm.write {
            // iterate thru all players and gather their opponent rating.
            // THEN go back thru and assimilate their personal rating
            // this will allow players to be updated without affecting other's ratings that round.
            for player in session.playersList {
                var opponentRating = 0
                
                for game in session.gameList {
                    let playerOne = game.playerOne
                    let playerTwo = game.playerTwo
                    let playerThree = game.playerThree
                    let playerFour = game.playerFour
                    
                    if isPlayerInGame(player: player, game: game) {
                        opponentRating += getOpponentRating(player: player, playerOne: playerOne!,
                                                            playerTwo: playerTwo!, playerThree: playerThree!,
                                                            playerFour: playerFour!)
                    }
                }
                
                player.totalOpponentRating = opponentRating
            }
            
            for player in session.playersList {
                player.rating = (player.totalOpponentRating + (400 * (player.wins - player.losses))) / (player.wins + player.losses)
            }
        }
    }
    
    func isPlayerInGame(player: RandomPlayer, game: RandomGame) -> Bool {
        if game.playerOne?.id == player.id ||
            game.playerTwo?.id == player.id ||
            game.playerThree?.id == player.id ||
            game.playerFour?.id == player.id {
            return true
        }
        
        return false
    }
    
    func getOpponentRating(player: RandomPlayer, playerOne: RandomPlayer,
                           playerTwo: RandomPlayer, playerThree: RandomPlayer,
                           playerFour: RandomPlayer) -> Int {
        var returnScore = (1000)
        
        // Find the current player's opposing team's rating
        switch player.id {
        // Team One
        case playerOne.id,
             playerTwo.id:
            let threeRating = Int(playerThree.rating)
            let fourRating = Int(playerFour.rating)
            
            if threeRating > fourRating {
                let midRating = ((threeRating - fourRating) / 2)
                returnScore = (threeRating - midRating)
            } else if fourRating > threeRating {
                let midRating = Int((fourRating - threeRating) / 2)
                returnScore = (fourRating - midRating)
            } else {
                // ratings are same
                returnScore = (threeRating)
            }
            break
        // Team Two
        case playerThree.id,
             playerFour.id:
            
            let oneRating = (playerOne.rating)
            let twoRating = (playerTwo.rating)
            
            if oneRating > twoRating {
                let midRating = ((oneRating - twoRating) / 2)
                returnScore = (oneRating - midRating)
            } else if twoRating > oneRating {
                let midRating = ((twoRating - oneRating) / 2)
                returnScore = (twoRating - midRating)
            } else {
                // ratings are same
                returnScore = (oneRating)
            }
            
            break
        default:
            return 1000
        }
        
        if returnScore <= 0 {
            returnScore = 1000
        }
        
        return returnScore
    }
    
    // find out if the player won to see if we add 400 or subtract it.
    func didPlayerWinGame(player: RandomPlayer, game: RandomGame) -> Bool {
        
        switch player.id {
        // Team One
        case (game.playerOne?.id)!,
             (game.playerTwo?.id)!:
            
            if game.teamOneScore > game.teamTwoScore {
                return true
            } else {
                return false
            }
        // Team Two
        case game.playerThree!.id,
             game.playerFour!.id:
            
            if game.teamOneScore > game.teamTwoScore {
                return false
            } else {
                return true
            }
        default:
            return false
        }
    }
    
}
