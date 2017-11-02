//
//  RPStatisticsController.swift
//  SpikeballPlay
//
//  Created by Jordan Davis on 8/4/17.
//  Copyright © 2017 HoverSlam. All rights reserved.
//

import Foundation

class RPStatisticsController {
    
    let session = RPSessionsView.getCurrentSession()
    
    //varK: Sort statistics page
    public func sort(sortMethod: String) {
//        switch sortMethod {
//            case "Wins":
//                session.playersList = session.playersList.sorted(by: winsSorter)
//            break
//            case "Losses":
//                session.playersList = session.playersList?.sorted(by: lossSorter)
//            break
//            case "Points For":
//                session.playersList = session.playersList?.sorted(by: pointsForSorter)
//            break
//            case "Points Against":
//                session.playersList = session.playersList?.sorted(by: pointsAgainstSorter)
//            break
//            case "Point Differential":
//                session.playersList = session.playersList?.sorted(by: pointDifferentialSorter)
//            break
//            case "Name":
//                session.playersList = session.playersList?.sorted(by: nameSorter)
//            break
//            case "Rating":
//                session.playersList = session.playersList?.sorted(by: ratingSorter)
//            break
//            default:
//                session.playersList = session.playersList?.sorted(by: nameSorter)
//            break
//
//        }
    }
    
    func winsSorter(this:RandomPlayer, that:RandomPlayer) -> Bool {
        return this.wins > that.wins
    }
    
    func lossSorter(this:RandomPlayer, that:RandomPlayer) -> Bool {
        return this.losses > that.losses
    }
    func pointsForSorter(this:RandomPlayer, that:RandomPlayer) -> Bool {
        return this.pointsFor > that.pointsFor
    }
    func pointsAgainstSorter(this:RandomPlayer, that:RandomPlayer) -> Bool {
        return this.pointsAgainst > that.pointsAgainst
    }
    
    func pointDifferentialSorter(this:RandomPlayer, that:RandomPlayer) -> Bool {
        return this.pointsFor - this.pointsAgainst > that.pointsFor - that.pointsAgainst
    }
    
    func ratingSorter(this:RandomPlayer, that:RandomPlayer) -> Bool {
        return this.rating > that.rating
    }
    
    func nameSorter(this:RandomPlayer, that:RandomPlayer) -> Bool {
        return this.name < that.name
    }
}
