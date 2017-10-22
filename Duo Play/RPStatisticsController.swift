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
    public func sort(sortMethod: String, controller: RPController) {
        switch sortMethod {
            case "Wins":
                controller.playersList = controller.playersList?.sorted(by: winsSorter)
            break
            case "Losses":
                controller.playersList = controller.playersList?.sorted(by: lossSorter)
            break
            case "Points For":
                controller.playersList = controller.playersList?.sorted(by: pointsForSorter)
            break
            case "Points Against":
                controller.playersList = controller.playersList?.sorted(by: pointsAgainstSorter)
            break
            case "Point Differential":
                controller.playersList = controller.playersList?.sorted(by: pointDifferentialSorter)
            break
            case "Name":
                controller.playersList = controller.playersList?.sorted(by: nameSorter)
            break
            case "Rating":
                controller.playersList = controller.playersList?.sorted(by: ratingSorter)
            break
            default:
                controller.playersList = controller.playersList?.sorted(by: nameSorter)
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
