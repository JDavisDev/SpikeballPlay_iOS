//
//  BracketController.swift
//  Duo Play
//
//  Created by Jordan Davis on 12/31/17.
//  Copyright © 2017 Jordan Davis. All rights reserved.
//

import Foundation
import RealmSwift

class BracketController {
    let bracketGenerator = BracketGenerator()
    let realm = try! Realm()
    let tournament: Tournament
    let poolList: List<Pool>
    var byeCount = 0
    var roundCount = 0
    
    init() {
        tournament = TournamentController.getCurrentTournament()
        poolList = tournament.poolList
        byeCount = getByeCount()
    }
    
    func startBracket() {
        seedTeams()
    }
    
    func getRoundCount() -> Int {
        /* 5-8 players/teams: 3 rounds
         9-16 players/teams: 4 rounds
         17-32 players/teams: 5 rounds
         33-64 players/teams: 6 rounds
         65-128 players/teams: 7 rounds
         129-256 players/teams: 8 rounds */
        
        switch tournament.teamList.count {
        case 3...4:
            return 2;
        case 5...8:
            return 3
        case 9...16:
            return 4
        case 17...32:
            return 5
        case 33...64:
            return 6
        case 65...128:
            return 7
        case 129...256:
            return 8
        default:
            return 3
        }
    }
    
    // Get games needed to play this round
    // NOT how many we have so far.
    func getRoundGameCount(round: Int) -> Int {
        let teamCount = tournament.teamList.count
        let var1 = teamCount + getByeCount()
        let var2 = var1 / 2
        let final = var2 / round
        return final
    }
    
    func getByeCount() -> Int {
        let count = tournament.teamList.count
        switch count {
        case 5...8:
            return 8 - count
        case 9...16:
            return 16 - count
        case 17...32:
            return 32 - count
        case 33...64:
            return 64 - count
        case 65...128:
            return 128 - count
        case 129...256:
            return 256 - count
        default:
            return 0
        }
    }
    
    func seedTeams() {
        try! realm.write {
            var array = Array(tournament.teamList)
            tournament.teamList.removeAll()
            
            // seed the teams here based on wins, then point diff, then name
            array.sort {
                if $0.wins == $1.wins {
                    if ($0.pointsFor - $0.pointsAgainst) == ($1.pointsFor - $1.pointsAgainst) {
                        return $0.name < $1.name
                    } else {
                        return ($0.pointsFor - $0.pointsAgainst) > ($1.pointsFor - $1.pointsAgainst)
                    }
                } else {
                    return $0.wins > $1.wins
                }
            }
            
            // we've sorted/seeded, not re add
            var seed = 1
            for team in array {
                team.seed = seed
                tournament.teamList.append(team)
                seed += 1
            }
        }
        
        createMatchups()
    }
    
    // Setting up the bracket. Do not do IF we've already done it before.
    func createMatchups() {
        if tournament.matchupList.count == 0 && byeCount == 0 {
            // run through all the teams, pairing the high seeds with the low seeds. This solves round one.
            for i in 1...tournament.teamList.count / 2 {
                try! realm.write {
                    let game = BracketMatchup()
                    
                    game.teamOne = tournament.teamList[i - 1]
                    game.teamTwo = tournament.teamList[tournament.teamList.count - i]
                    game.division = "Advanced"
                    game.round = 1
                    realm.add(game)
                    tournament.matchupList.append(game)
                }
            }
        } else if tournament.matchupList.count == 0 {
            // set up byes
            for i in 1...byeCount {
                try! realm.write {
                    // give top seeds byes, keep the round flat. Can iterate through after and advance bye teams
                    let game = BracketMatchup()
                    
                    game.teamOne = tournament.teamList[i-1]
                    game.teamTwo = nil
                    game.division = "Advanced"
                    game.round = 1
                    realm.add(game)
                    tournament.matchupList.append(game)
                }
            }
            
            // now create matchups.
            var topIndex = 1
            for i in byeCount...tournament.teamList.count/2 {
                // start with teams who didn't get a bye.
                try! realm.write {
                    let game = BracketMatchup()
                    
                    game.teamOne = tournament.teamList[i]
                    game.teamTwo = tournament.teamList[tournament.teamList.count - topIndex]
                    game.division = "Advanced"
                    game.round = 1
                    game.round_position = i
                    topIndex += 1
                    realm.add(game)
                    tournament.matchupList.append(game)
                }
            }
        }
        
        createBracketIds()
    }
    
    // TODO: Update this method. if teams go quicker than others. this will only process furthest teams.
    // Remaining matches in previous rounds won't have a chance to play.
    // Could set up a loop that gets every match from EVERY ROUND
    func updateMatchups() {
        updateBracketIds()
        
        for currentRound in 1...roundCount {
            // init a new list of available teams for THIS ROUND
            var availableTeams = List<Team>()
            
            try! realm.write {
                
                // sets the teams for this round
                for team in tournament.teamList {
                    if !team.isEliminated && team.bracketRound == currentRound {
                        availableTeams.append(team)
                    }
                }
                // rounds 2> with byes are not working out. first round was good.
                if availableTeams.count >= 2 {
                    for i in 1...availableTeams.count/2 {
                        let game = BracketMatchup()
                        
                        game.teamOne = availableTeams[i - 1]
                        if availableTeams[i].id == (game.teamOne?.id)! + 1 {
                            game.teamTwo = availableTeams[i]
                            game.division = "Advanced"
                            game.round = currentRound
                            
                            if isGameUnique(game: game) {
                                realm.add(game)
                                tournament.matchupList.append(game)
                            }
                        }
                    }
                }
            }
        }
        
        // check for byes, assign the lowest seed to highest bye
        if byeCount > 0 {
            
        }
        
        var availableTeams = List<Team>()
        
    }
    
    func isGameUnique(game: BracketMatchup) -> Bool {
        for matchup in tournament.matchupList {
            if matchup == game {
                return false
            }
        }
        
        return true
    }
    
    func createBracketIds() {
        // sorted by seed at this point.
        // need to balance bracket to keep seeds where they need to be. #1 at top, #2 at bottom, etc.
        // sets the teams for this round
    }
    
    // After a match is submitted,
    // Updated tournament positions
    // this will help in figuring out who teams play NEXT.
    // Highest position will have #1, lowest position will have id = availableTeams.count
    func updateBracketIds() {
    }
    
    func drawBracket() {
        
    }
    
    func reportMatch(selectedMatchup: BracketMatchup, numOfGamesPlayed: Int, teamOneScores: [Int], teamTwoScores: [Int]) {
        // save the match!
        try! realm.write {
            
            var teamOneWins = 0
            for score in teamOneScores {
                if score == 21 {
                    teamOneWins += 1
                }
            }
            
            var teamTwoWins = 0
            for score in teamTwoScores {
                if score == 21 {
                    teamTwoWins += 1
                }
            }
            
            if teamOneWins > teamTwoWins {
                selectedMatchup.teamOne?.wins += 1
                selectedMatchup.teamTwo?.losses += 1
                selectedMatchup.teamTwo?.isEliminated = true
                selectedMatchup.teamOne?.bracketRound += 1
            } else {
                selectedMatchup.teamOne?.losses += 1
                selectedMatchup.teamTwo?.wins += 1
                selectedMatchup.teamOne?.isEliminated = true
                selectedMatchup.teamTwo?.bracketRound += 1
            }
            
            // point accumulation for seeding.
            selectedMatchup.teamOne?.pointsFor += teamOneScores[0]
            selectedMatchup.teamOne?.pointsFor += teamOneScores[1]
            selectedMatchup.teamOne?.pointsFor += teamOneScores[2]
            
            selectedMatchup.teamOne?.pointsAgainst += teamTwoScores[0]
            selectedMatchup.teamOne?.pointsAgainst += teamTwoScores[1]
            selectedMatchup.teamOne?.pointsAgainst += teamTwoScores[2]
            
            selectedMatchup.teamOneScores.append(objectsIn: teamOneScores)
            selectedMatchup.teamTwoScores.append(objectsIn: teamTwoScores)
            
            selectedMatchup.teamTwo?.pointsAgainst += teamOneScores[0]
            selectedMatchup.teamTwo?.pointsAgainst += teamOneScores[1]
            selectedMatchup.teamTwo?.pointsAgainst += teamOneScores[2]
            
            selectedMatchup.teamTwo?.pointsFor += teamTwoScores[0]
            selectedMatchup.teamTwo?.pointsFor += teamTwoScores[1]
            selectedMatchup.teamTwo?.pointsFor += teamTwoScores[2]
            
            selectedMatchup.isReported = true
        }
    }
}
