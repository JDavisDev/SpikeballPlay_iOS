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
    
    func getPlayerRating(player: RandomPlayer) -> Float {
        var rating = Float(0.0)
        
        rating += Float(player.matchDifficulty) * 2
        rating += Float(player.pointsFor - player.pointsAgainst) * 2.0
        rating += Float(player.wins - player.losses) * 5
        
        return Float(rating)
    }
}
