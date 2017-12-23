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
    var pool = Pool()
    var teamList = List<Team>()
    var teamCount = 4
    var numOfRounds = 0
    var totalMatchesToPlay = 0
    
    func generatePoolPlayGames(pool: Pool) -> List<PoolPlayMatchup> {
        let gameList = List<PoolPlayMatchup>()
        self.pool = pool
        teamCount = pool.teamList.count
        teamList = pool.teamList
        numOfRounds = teamCount - 1
        let gamesPerRound = teamCount % 2 == 0 ? teamCount / 2 : teamCount / 2 + 1
        
        //appendRoundOneGames(gameList: gameList)
        // ROUND ONE
        for i in 1...teamCount / 2 {
            let game = PoolPlayMatchup() //round: 1, teamOne: teamList[i - 1], teamTwo: teamList[teamCount - i])
            // if pass all checks, add game
            
            game.teamOne = teamList[i - 1]
            game.teamTwo = teamList[teamCount - i]
            
            if !isMatchupDuplicate(teamOne: game.teamOne!, teamTwo: game.teamTwo!, gameList: gameList) {
               gameList.append(game)
            }
        }
        
        // Process rounds 2 - number of Rounds
        // WRITE THIS NEXT
        // THEN POOL PLAY MATCH REPORTING
        // OR Updating MATCH LIST AFTER GAMES ARE REPORTED
        if numOfRounds >= 2 {
            while gameList.count < teamList.count - 1 {
                // set each game
                for var i in 0..<gamesPerRound {
                    // check each team and get their opponent
                    let opponent = getNextOpponent(teamOne: teamList[i], gameList: gameList)
                    let matchup = PoolPlayMatchup()
                    matchup.teamOne = teamList[i]
                    matchup.teamTwo = opponent

                    if !isMatchupDuplicate(teamOne: matchup.teamOne!, teamTwo: matchup.teamTwo!, gameList: gameList) {
                        gameList.append(matchup)
                    }
                }
            }
        }
        
        return gameList
    }
    
    func getNextOpponent(teamOne: Team, gameList: List<PoolPlayMatchup>) -> Team {
        // get the match they played recently and use that as starting point
    
        let lastOpponent = getLastOpponent(teamOne: teamOne, gameList: gameList)
        var nextOpponent = Team()
        // make sure this is greater than 0 or wraps
        var i = lastOpponent.id - 1
        if i <= 0 {
            // decrement one to change opponent
            nextOpponent = teamList[teamCount - 1]
        } else {
            nextOpponent = teamList[i - 1]
        }

        // we have lowest opponent id, decrement and proceed, 
        // wrapping to the top.
        
        while teamOne.id == i {
            i -= 1
            if (i == 1) && teamCount - i >= 0 && teamCount - i < teamList.count {
                nextOpponent = teamList[teamCount - i]
            } else if i - 2 >= 0 &&  i - 2 < teamList.count{
                nextOpponent = teamList[i - 2]
            }
        }
        
        return nextOpponent
    }
    
    // get the match they played recently and use that as starting point
    func getLastOpponent(teamOne: Team, gameList: List<PoolPlayMatchup>) -> Team {
        var lastOpponent = Team()
        
        // iterate through each match, updating the last opponent as we go
        for matchup in pool.matchupList {
            if (matchup.teamOne?.isEqual(teamOne))! {
                // found a match teamOne played in
                lastOpponent = matchup.teamTwo!
            } else if (matchup.teamTwo?.isEqual(teamOne))! {
                lastOpponent = matchup.teamOne!
            }
        }
        
        return lastOpponent
    }
    
    func isMatchupDuplicate(teamOne: Team, teamTwo: Team, gameList: List<PoolPlayMatchup>) -> Bool {
        for game in gameList {
            if (game.teamOne == teamOne && game.teamTwo == teamTwo) || (game.teamOne == teamTwo && game.teamTwo == teamOne) {
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
