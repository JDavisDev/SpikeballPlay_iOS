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
            case "Match Difficulty":
                array.sort { $0.matchDifficulty > $1.matchDifficulty }
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
            for player in session.playersList {
                var rating = Float(1000.0)
                var gamesPlayed = Float(0.0)
                
                for game in session.gameList {
                    if isPlayerInGame(player: player, game: game) {
                        let opponentRating = getOpponentRating(player: player, game: game)
                        let didWin = didPlayerWinGame(player: player, game: game)
                        gamesPlayed += 1
                        
                        if didWin /* win */ {
                            rating += Float(opponentRating + 400)
                        } else {
                            /* loss */
                            rating += opponentRating - 400
                        }
                    }
                }
                
                player.rating = rating / gamesPlayed
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
    
    func getOpponentRating(player: RandomPlayer, game: RandomGame) -> Float {
        var returnScore = Float(1000.0)
        
        if game.playerOne == nil && game.playerTwo == nil && game.playerThree == nil && game.playerFour == nil {
            return (returnScore)
        }
        
        // Find the current player's opposing team's rating
        switch player.id {
        // Team One
        case (game.playerOne?.id)!,
             (game.playerTwo?.id)!:
            
            if (game.playerThree?.rating)! > (game.playerFour?.rating)! {
                returnScore = (game.playerThree?.rating)! - (((game.playerThree?.rating)! - (game.playerFour?.rating)!) / 2)
            } else if (game.playerFour?.rating)! > (game.playerThree?.rating)! {
                returnScore = (game.playerFour?.rating)! - (((game.playerFour?.rating)! - (game.playerThree?.rating)!) / 2)
            } else {
                // ratings are same
                returnScore = (game.playerThree?.rating)!
            }
            break
        // Team Two
        case game.playerOne!.id,
             game.playerFour!.id:
            
            if (game.playerOne?.rating)! > (game.playerTwo?.rating)! {
                returnScore = (game.playerOne?.rating)! - (((game.playerOne?.rating)! - (game.playerTwo?.rating)!) / 2)
            } else if (game.playerTwo?.rating)! > (game.playerOne?.rating)! {
                returnScore = (game.playerTwo?.rating)! - (((game.playerTwo?.rating)! - (game.playerOne?.rating)!) / 2)
            } else {
                // ratings are same
                returnScore = (game.playerOne?.rating)!
            }
            
            break
        default:
            return 1000.0
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
        case game.playerOne!.id,
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
