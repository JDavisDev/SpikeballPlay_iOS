//
//  BracketController.swift
//  Duo Play
//
//  Created by Jordan Davis on 12/31/17.
//  Copyright © 2017 Jordan Davis. All rights reserved.
//

import Foundation
import RealmSwift

// NEED to work on deleting unused objects...
// when deleting matchups, maybe delete all games by tournament id or something...

// Having a second round issue before the finals. teams are listed as TBD

class BracketController {
    let realm = try! Realm()
    let tournament: Tournament
    let poolList: List<Pool>
    var byeCount = 0
    var roundCount = 0
    var nodeList = [Node]()
    var isEnd = false
    var baseBracketSize = 0
    
    init() {
        tournament = TournamentController.getCurrentTournament()
        poolList = tournament.poolList
        byeCount = getByeCount()
    }
    
    // this will be called when tournament starts
    // when things change, like settings and teams.
    // be dynamic and adaptable!
    func updateBracket() {
        if tournament.teamList.count > 0 {
            seedTeams()
        }
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
        case 3:
            return 1
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
    
    func getNextPowerOfTwo(num: Int) -> Int {
        switch(num) {
        case 3...4:
            return 4
            case 5...8:
                return 8
            case 9...16:
                return 16
            case 17...32:
                return 32
            case 33...64:
                return 64
            case 65...128:
                return 128
            case 129...256:
                return 256
            default:
                return 0
        }
    }
    
    // seeding teams is okay at any point.
    // if matchups have been reported, let's block them after seeding.
    // nothing else should be able to be updated
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
            
            // we've sorted/seeded, now re-add
            var seed = 1
            for team in array {
                team.seed = seed
                tournament.teamList.append(team)
                seed += 1
            }
        }
        
        // if a match has been reported, no more matchups should be created
        // matchups will be updated as the tournament progresses
        var canCreateMatchups = true
        for matchup in tournament.matchupList {
            if matchup.isReported {
                canCreateMatchups = false
                break
            }
        }
        
        if getTournamentProgress() <= 0 && canCreateMatchups {
            createMatchups()
        }
    }
    
    func getTournamentProgress() -> Int {
        if tournament.teamList.count > 0 {
            let pointsPerMatchup = Float(Float(100) / Float((tournament.teamList.count - 1)))
            var currentPoints = Float(0)
            
            for matchup in tournament.matchupList {
                if matchup.isReported {
                    currentPoints += (pointsPerMatchup)
                }
            }
            
            try! realm.write {
                tournament.progress_meter = Int(round(currentPoints))
            }
            
            return Int(round(currentPoints))
        }
        
        return 0
    }
    
    // need a way to edit these.. or finalize starting the bracket.
    // once it's began, edits can't happen.
    // once a match is submitted, it also finalizes the tournament
    // Setting up the bracket. Do not do IF we've already done it before.
    func createMatchups() {
        try! realm.write {
            tournament.matchupList.removeAll()
            
        }
        
        orderMatchups()
//        if byeCount == 0 {
//            // run through all the teams, pairing the high seeds with the low seeds. This solves round one.
//            createRoundOneNoByesMatchups()
//        } else {
//            // set up byes
//            createRoundOneWithByesMatchups()
//        }
//
//        orderMatchups()
    }
    
    func createRoundOneNoByesMatchups() {
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
    }
    
    func createRoundOneWithByesMatchups() {
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
        let iterationCount = (tournament.teamList.count % 2) == 1 ?
            tournament.teamList.count/2 + 1 :
            tournament.teamList.count/2
        for i in byeCount...iterationCount {
            // start with teams who didn't get a bye.
            try! realm.write {
                let game = BracketMatchup()
                
                game.teamOne = tournament.teamList[i]
                game.teamTwo = tournament.teamList[tournament.teamList.count - topIndex]
                game.division = "Advanced"
                game.round = 1
                topIndex += 1
                realm.add(game)
                tournament.matchupList.append(game)
            }
        }
    }
    
    // Ordering the match ups based on official tournament seeding
    // 1 seed will always be on top
    // check for nulls.
    // make recursive until it's perfect.
    // >>>>maybe start at the end and work backwards...<<<<
    func orderMatchups() {
        var seedStringList = [String]()
        
        for team in tournament.teamList {
            seedStringList.append(String(team.seed))
        }
        
        nodeList = [Node]()
        var halfNodesList = [Node]()
        
        // need a number to sim bracket size. basically, it's the next highest power of 2
        // 14 teams is a 16 team bracket wtih 2 byes that'll go to highest seeds, rest of bracket looks the same
        
        baseBracketSize = getNextPowerOfTwo(num: tournament.teamList.count)
        let root = Node(value: [seedStringList[0], seedStringList[1]])
        seedStringList.removeFirst(2)
        nodeList.append(root)
        
        // handle round by round
        // create and fill nodes
        while nodeList.count < baseBracketSize - 1 {
            halfNodesList.removeAll()
            
            for node in nodeList {
                if node.value.count > 1 && node.children.count <= 0 &&
                    !(Int(node.value[0])! + Int(node.value[1])! == baseBracketSize + 1) {
                    // two values, create two splitting branches
                    let nodeOne = Node(value: [node.value[0]])
                    let nodeTwo = Node(value: [node.value[1]])
                    
                    //add children to that node
                    node.add(child: nodeOne)
                    node.add(child: nodeTwo)
                    
                    // append both to the list for iteration
                    nodeList.append(nodeOne)
                    nodeList.append(nodeTwo)
                    
                    halfNodesList.append(nodeOne)
                    halfNodesList.append(nodeTwo)
                }
            }
            
            addSeedToNode(nodes: halfNodesList, seedList: seedStringList)
            if isEnd {
                break
            }
        }
        
        var copyList = [Node]()
        
        for node in nodeList {
            if node.children.count <= 0 {
                copyList.append(node)
            }
        }
        
        createMatchupsFromNodeList(nodes: copyList)
    }
    
    func addSeedToNode(nodes: [Node], seedList: [String]) {
        var copyList = [Node]()
        
        for node in nodeList {
            if node.value.count >= 2 {
                copyList.append(node)
            }
        }
        
        // delete and readd nodes that contain two values.
        // keep the nodeList intact with no half nodes.
        nodeList.removeAll()
        nodeList = copyList
        
        for node in nodes {
            for seed in seedList {
                if Int(node.value[0])! + Int(seed)! == (nodes.count * 2) + 1 {
                    node.value.append(seed)
                    nodeList.append(node)
                    break;
                }
            }
        }
        
        if nodeList.count == baseBracketSize - 1 {
            isEnd = true
        }
    }
    
    func createMatchupsFromNodeList(nodes: [Node]) {
        let teamsController = TeamsController()
        var verticalPositionCounter = 1
        try! realm.write {
            tournament.matchupList.removeAll()
        
            for node in nodes {
                if node.value.count == 2 {
                    let game = BracketMatchup()
                    
                    game.teamOne = teamsController.getTeamByName(name: node.value[0])
                    game.teamTwo = teamsController.getTeamByName(name: node.value[1])
                    game.division = "Advanced"
                    game.round = 1
                    game.round_position = verticalPositionCounter
                    realm.add(game)
                    tournament.matchupList.append(game)
                    verticalPositionCounter += 1
                }
            }
        }
    }
    
    // Run through teams, see if they are next to each other based on position,
    // are NOT in a matchup already, too.
    // already in realm write
    func updateMatchups() {
        let availableTeams = List<Team>()
        for team in tournament.teamList {
            var isAvailable = true
            for matchup in tournament.matchupList {
                if matchup.teamOne == team || matchup.teamTwo == team ||
                    team.isEliminated || team.bracketRounds.count <= 1 {
                        isAvailable = false
                    }
                }
            
            if isAvailable {
                availableTeams.append(team)
            }
        }
        
        for team in availableTeams {
            for teamTwo in availableTeams {
                if team.name != teamTwo.name && team.bracketRounds.last == teamTwo.bracketRounds.last &&
                    team.bracketVerticalPositions.last == teamTwo.bracketVerticalPositions.last {
                    // teams are in same spot! create a match up.
                    let game = BracketMatchup()
                    
                    game.teamOne = team
                    game.teamTwo = teamTwo
                    game.round = team.bracketRounds.last!
                    game.round_position = team.bracketVerticalPositions.last!
                    game.division = "Advanced"
                    realm.add(game)
                    tournament.matchupList.append(game)
                    availableTeams.remove(at: availableTeams.index(of: team)!)
                    availableTeams.remove(at: availableTeams.index(of: teamTwo)!)
                    break
                }
            }
        }
    }
    
    func isGameUnique(game: BracketMatchup) -> Bool {
        for matchup in tournament.matchupList {
            if matchup == game {
                return false
            }
        }
        
        return true
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
                selectedMatchup.teamOne?.bracketRounds.append(selectedMatchup.round + 1)
                advanceTeamToNextBracketPosition(winningTeam: selectedMatchup.teamOne!)
            } else {
                selectedMatchup.teamOne?.losses += 1
                selectedMatchup.teamTwo?.wins += 1
                selectedMatchup.teamOne?.isEliminated = true
                selectedMatchup.teamTwo?.bracketRounds.append(selectedMatchup.round + 1)
                advanceTeamToNextBracketPosition(winningTeam: selectedMatchup.teamTwo!)
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
        
        getTournamentProgress()
    }
    
    // based on previous position, determine next position
    // also set if the team is on the bottom or top for easy reading
    // set the property, then update the bracket view, which will set teams based on attributes.
    // already in Realm.write here.
    func advanceTeamToNextBracketPosition(winningTeam: Team) {
        var nextPos = 0
        let lastPos = winningTeam.bracketVerticalPositions.last!
        
        if lastPos % 2 == 1 {
            // odd number
            nextPos = lastPos / 2 + 1
        } else {
            nextPos = lastPos / 2
        }
        
        winningTeam.bracketVerticalPositions.append(nextPos)
        
        // a new matchup may be ready!
        updateMatchups()
    }
}
