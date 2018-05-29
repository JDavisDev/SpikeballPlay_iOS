//
//  PoolPlayMatchGenerator.swift
//  Duo Play
//
//  Created by Jordan Davis on 9/4/17.
//  Copyright © 2017 Jordan Davis. All rights reserved.
//

import Foundation
import RealmSwift

class PoolPlayMatchGenerator {
    let realm = try! Realm()
    var pool = Pool()
    var currentRound = 1
    var teamList = List<Team>()
    var teamCount = 6
    var numOfRounds = 0
    var totalMatchesToPlay = 0
    var teamOne = Team()
    var teamTwo = Team()
	var isOddNumber = false
    var matchupMatrix : [[Int]] = Array(repeating: Array(repeating: 0, count: 2), count: 2)
    var gameList = List<PoolPlayMatchup>()
    
    func generatePoolPlayGames(pool: Pool) {
        self.pool = pool
        teamCount = pool.teamList.count
        teamList = pool.teamList
        numOfRounds = teamCount - 1
		self.isOddNumber = teamCount % 2 == 0 ? false : true
														//columns       // rows
		let count = isOddNumber ? teamCount/2 + 1 : teamCount/2
        matchupMatrix = Array(repeating: Array(repeating: 0, count: count), count: 2)
		
		if teamList.count < 4 || pool.isStarted {
			return
		}

		try! realm.write {
			pool.matchupList.removeAll()
		}
		
		initMatrix()
        addMatchupsFromMatrix()
    }
    
    // set up first set up matches and numbers based on team counts
    func initMatrix() {
        var num = 1
		let matrixCount = isOddNumber ? teamCount/2 + 1 : teamCount/2
		
        for row in 0..<2 {
            for column in 0..<matrixCount {
				for values in matchupMatrix {
					if values.contains(num) {
						return
					}
				}
				
                matchupMatrix[row][column] = num
                
                if num == matrixCount {
                    num = teamCount
                } else if num > matrixCount {
                    num -= 1
                } else {
                    num += 1
                }
            }
        }
    }
    
    func addMatchupsFromMatrix() {
		try! realm.write {
			pool.matchupList.removeAll()
		}
		
		let count = isOddNumber ? teamCount/2 + 1 : teamCount/2
		
		for _ in 0..<teamCount - 1 {
			for column in 0..<count {
				try! realm.write {
					let matchup = PoolPlayMatchup()
					if teamList.count >= matchupMatrix[0][column] - 2 &&
						matchupMatrix[0][column] != 0 {
						matchup.teamOne = teamList[matchupMatrix[0][column] - 1]
					} else {
						matchup.teamOne = nil
					}
					
					if teamList.count >= matchupMatrix[1][column] - 2 &&
						matchupMatrix[1][column] != 0 {
						matchup.teamTwo = teamList[matchupMatrix[1][column] - 1]
					} else {
						matchup.teamTwo = nil
					}
					
				
					matchup.round = currentRound
					matchup.division = "Advanced"
					matchup.isReported = false
					realm.add(matchup)
					pool.matchupList.append(matchup)
				}
			}
            
            slideMatrix()
        }
    }
    
    // Move all positions clockwise except 0,0
    //     0  1  2  3
    //   _____________________
    // 0 | 1  2  3  4         |
    // 1 | 8  7  6  5         |
    //   ---------------------
    func slideMatrix() {
		let count = isOddNumber ? teamCount + 1 : teamCount
        currentRound += 1
        
        let temp = matchupMatrix[1][0]
        
        switch count {
        case 4:
            matchupMatrix[1][0] = matchupMatrix[1][1]
            matchupMatrix[1][1] = matchupMatrix[0][1]
        case 6:
            matchupMatrix[1][0] = matchupMatrix[1][1]
            matchupMatrix[1][1] = matchupMatrix[1][2]
            matchupMatrix[1][2] = matchupMatrix[0][2]
            matchupMatrix[0][2] = matchupMatrix[0][1]
        case 8:
            matchupMatrix[1][0] = matchupMatrix[1][1]
            matchupMatrix[1][1] = matchupMatrix[1][2]
            matchupMatrix[1][2] = matchupMatrix[1][3]
            matchupMatrix[1][3] = matchupMatrix[0][3]
            matchupMatrix[0][3] = matchupMatrix[0][2]
            matchupMatrix[0][2] = matchupMatrix[0][1]
        default:
            print("Matrix Slide Error")
        }
                
        matchupMatrix[0][1] = temp
        
        // dynamic algorithm progress
        //for runCount in 0..<teamCount-2 {
            //            for row in 1...0 {
            //                for column in 0..<teamCount/2 {
            //                    matchupMatrix[row][column] = matchupMatrix[row][column + 1]
            //                }
            //            }
            //        }
    }
    
    func getTeamOne(id: Int, gameList: List<PoolPlayMatchup>) -> Team {
        var returnInt = id
        while !isTeamAvailable(id: returnInt, gameList: gameList) {
            returnInt += 1
        }
        
        return teamList[returnInt - 1];
    }
    
    func isTeamAvailable(id: Int, gameList: List<PoolPlayMatchup>) -> Bool {
        // make sure match is NOT duplicated, two teams are not the same, team has not played this round
        for game in gameList {
            if game.teamOne?.id == id || game.teamTwo?.id == id {
                if game.round == currentRound {
                    return false
                }
            }
        }
        
        return true
    }
    
    func getNextOpponent(teamOne: Team, round: Int, gameList: List<PoolPlayMatchup>) -> Team {
        // get the match they played recently and use that as starting point
        let lastOpponent = getLastOpponent(teamOne: teamOne, gameList: gameList)
        var nextOpponent = Team()
        nextOpponent.id = 0
        // make sure this is greater than 0 or wraps
        var id = lastOpponent.id
        while !isNextOpponentCorrect(teamOne: teamOne, nextOpponent: nextOpponent, round: round, gameList: gameList) {
            id -= 1
        
            if id <= 0 {
                // decrement one to change opponent
                nextOpponent = teamList[teamCount - 1]
            } else {
                nextOpponent = teamList[id - 1]
            }
            
            id = nextOpponent.id
            // we have lowest opponent id, decrement and proceed,
            // wrapping to the top.
            while teamOne.id == nextOpponent.id {
                id -= 1
                if id <= 0 {
                    // decrement one to change opponent
                    nextOpponent = teamList[teamCount - 1]
                } else {
                    nextOpponent = teamList[id - 1]
                }
                id = nextOpponent.id
            }
        }
        
        return nextOpponent
    }
    
    // get the match they played recently and use that as starting point
    func getLastOpponent(teamOne: Team, gameList: List<PoolPlayMatchup>) -> Team {
        var lastOpponent = Team()
        lastOpponent.id = 0
        
        // iterate through each match, updating the last opponent as we go. getting the highest played one
        for matchup in gameList {
            if ((matchup.teamOne?.id)! == teamOne.id) && (matchup.teamTwo?.id)! > lastOpponent.id {
                // found a match teamOne played in
                lastOpponent = matchup.teamTwo!
            } else if ((matchup.teamTwo?.id)! == teamOne.id) && (matchup.teamOne?.id)! > lastOpponent.id {
                lastOpponent = matchup.teamOne!
            }
        }
        
        return lastOpponent
    }
    
    func isNextOpponentCorrect(teamOne: Team, nextOpponent: Team, round: Int, gameList: List<PoolPlayMatchup>) -> Bool {
        if nextOpponent.id == 0 {
            return false
        }
        
        if isMatchupDuplicate(teamOne: teamOne, teamTwo: nextOpponent, gameList: gameList) {
            return false
        }
        
        // make sure match is NOT duplicated, two teams are not the same, team has not played this round
        for game in gameList {
            if game.teamOne?.id == nextOpponent.id || game.teamTwo?.id == nextOpponent.id ||
                game.teamOne?.id == teamOne.id || game.teamTwo?.id == teamOne.id {
                if game.round == round {
                    return false
                }
            }
        }
        
        return true
    }
    
    func isMatchupDuplicate(teamOne: Team, teamTwo: Team, gameList: List<PoolPlayMatchup>) -> Bool {
        for game in gameList {
            if ((game.teamOne?.id == teamOne.id && game.teamTwo?.id == teamTwo.id) ||
                (game.teamOne?.id == teamTwo.id && game.teamTwo?.id == teamOne.id)) {
                return true
            }
        }
        
        return false
    }
}
