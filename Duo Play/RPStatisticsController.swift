//
//  RPStatisticsController.swift
//  SpikeballPlay
//
//  Created by Jordan Davis on 8/4/17.
//  Copyright © 2017 HoverSlam. All rights reserved.
//

import Foundation

class RPStatisticsController {
    
    //MARK: Sort statistics page
    public func sort(sortMethod: String) {
        switch sortMethod {
            case "Wins":
                RPController.playersList = RPController.playersList.sorted(by: winsSorter)
            break
            case "Losses":
                RPController.playersList = RPController.playersList.sorted(by: lossSorter)
            break
            case "Points For":
            RPController.playersList = RPController.playersList.sorted(by: pointsForSorter)
            break
            case "Points Against":
            RPController.playersList = RPController.playersList.sorted(by: pointsAgainstSorter)
            break
            case "Point Differential":
            RPController.playersList = RPController.playersList.sorted(by: pointDifferentialSorter)
            break
            case "Name":
            RPController.playersList = RPController.playersList.sorted(by: nameSorter)
            break
            case "Rating":
            RPController.playersList = RPController.playersList.sorted(by: ratingSorter)
            break
            default:
                RPController.playersList = RPController.playersList.sorted(by: nameSorter)
            break
            
        }
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
