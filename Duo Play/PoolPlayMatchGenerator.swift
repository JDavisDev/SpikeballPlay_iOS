//
//  PoolPlayMatchGenerator.swift
//  Duo Play
//
//  Created by Jordan Davis on 9/4/17.
//  Copyright © 2017 Jordan Davis. All rights reserved.
//

import Foundation

class PoolPlayMatchGenerator {
    var teamList: [Team]
    var teamCount: Int
    var numOfRounds: Int
    var totalMatchesToPlay: Int
    
    init(teamList: [Team]) {
        self.teamCount = teamList.count
        self.teamList = teamList
        self.numOfRounds = teamCount % 2 == 0 ? teamCount - 1 : teamCount
        self.totalMatchesToPlay = self.numOfRounds * teamCount
    }
    
    func generatePoolPlayGames() -> [PoolPlayMatchup] {
        var gameList = [PoolPlayMatchup]()
        let gamesPerRound = teamCount % 2 == 0 ? teamCount / 2 : teamCount / 2 + 1
        
        //appendRoundOneGames(gameList: gameList)
        // ROUND ONE
        for i in 1...teamCount / 2 {
            let game = PoolPlayMatchup(round: 1, teamOne: teamList[i - 1], teamTwo: teamList[teamCount - i])
            // if pass all checks, add game
            gameList.append(game)
        }
        
        if numOfRounds >= 2 {
            for round in 2...numOfRounds {
                for i in 0...gamesPerRound {
                    var opponent: Team
                    opponent = getNextOpponent(teamOne: teamList[i], gameList: gameList)
                    // get team params and make a game
                    let game = PoolPlayMatchup(round: round, teamOne: teamList[i], teamTwo: opponent)
                
                    // if pass all checks, add game
                    gameList.append(game)
                }
            }
        }
    
        
        return gameList
    }
    
    func getNextOpponent(teamOne: Team, gameList: [PoolPlayMatchup]) -> Team {
        var lastOpponentId = teamCount - 1
        
        for game in gameList {
            if game.teamOne === teamOne {
                if game.teamTwo.id < lastOpponentId {
                    lastOpponentId = game.teamTwo.id
                }
            }
        }
        
        // decrement one to change opponent
        var nextOpponent = teamList[lastOpponentId - 1]
        
        
        // we have lowest opponent id, decrement and proceed, 
        // wrapping to the top.
        
        // make sure we aren't playing ourselves
        while teamOne.id == nextOpponent.id || isMatchupDuplicate(teamOne: teamOne, teamTwo: nextOpponent, gameList: gameList) {
            
            if(nextOpponent.id >= 2) {
                nextOpponent = teamList[nextOpponent.id - 2]
            } else {
                nextOpponent = teamList[teamCount - 1]
            }
        }
        
        return nextOpponent
    }
    
    func isMatchupDuplicate(teamOne: Team, teamTwo: Team, gameList: [PoolPlayMatchup]) -> Bool {
        for game in gameList {
            if (game.teamOne === teamOne && game.teamTwo === teamTwo) || (game.teamOne === teamTwo && game.teamTwo === teamOne) {
                return true
            }
        }
        
        return false
    }
    
    
    
    /* POOL SCHEDULE **
 
 ROUND ONE
 
 1 v 8
 2 v 7
 3 v 6
 4 v 5
  all equal nine, patterns easily enough
 
 ROUND TWO
 1 v 7
 2 v
 1 v 6
 
 
 */
 
 
}
