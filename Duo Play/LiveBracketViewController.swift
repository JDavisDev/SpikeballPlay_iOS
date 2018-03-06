//
//  LiveBracketViewController.swift
//  Duo Play
//
//  Created by Jordan Davis on 1/5/18.
//  Copyright © 2018 Jordan Davis. All rights reserved.
//

import UIKit
import RealmSwift

class LiveBracketViewController: UIViewController {
    // currently we are drawing everything multiple times, overlapping each other
    let realm = try! Realm()
    var tournament = Tournament()
    var bracketCellWidth = 76
    var labelWidth = 68
    //var scrollView = UIScrollView()
    @IBOutlet weak var scrollView: UIScrollView!
    
    let bracketController = BracketController()
    
    var bracketCells = [UIView]()
    var bracketDict: [UIView : (x: Int, y: Int)] = [:]
    var bracketMatchCount = 0
    var roundCount = 0
    var byeCount = 0
    var teamCount = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // add the scroll view to self.view
        //scrollView = UIScrollView(frame: <#T##CGRect#>)
        self.view.backgroundColor = UIColor.black
        self.view.addSubview(scrollView)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        try! realm.write() {
            tournament = TournamentController.getCurrentTournament()
        }
        
        bracketCellWidth = getMaxBracketWidth()
        teamCount = tournament.teamList.count
        bracketMatchCount = getBracketMatchCount()
        roundCount = bracketController.getRoundCount()
        byeCount = bracketController.getByeCount()
        reloadBracket()
        updateBracketView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getMaxBracketWidth() -> Int {
        var returnInt = 50
        
        if tournament.teamList.count > 0 {
            for team in tournament.teamList {
                if team.name.count * 10 > returnInt {
                    returnInt = team.name.count * 10
                }
            }
        }
        // label width needs to be 8 less, because name labels are left padded by 8
        labelWidth = returnInt + 12
        return returnInt + 20
    }
    
    func getBracketMatchCount() -> Int {
        var count = 0
        try! realm.write {
            count = tournament.teamList.count - 1
        }
        
        return count
    }
    
    // could generate first round positions.
    // then each cell after, is in the middle of the next two cells and offset.
    // only do ONCE
    func reloadBracket() {
        if bracketCells.count <= 0 {
            var views = scrollView.subviews
            views.removeAll()
            bracketCells.removeAll()
            bracketDict.removeAll()
            
            createFirstRoundBracketCells()
            createAdditionalBracketCells()
        }
    }
    
    // create first round based on match counts
    func createFirstRoundBracketCells() {
        if bracketController.getRoundGameCount(round: 1) > 0 {
            for game in 1...bracketController.getRoundGameCount(round: 1) {
                // create a cell and set the base position, we'll move later based on round/match #
                // yPos is not offsetting in the middle of other places
                var yPos = 8
                if game > 1  {
                    yPos = ((game - 1) * 110) + 8
                }
                let xPos = 8
                
                let bracketCell = UIView(frame: CGRect(x: xPos, y: yPos, width: bracketCellWidth, height: 100))
                bracketCell.backgroundColor = UIColor.darkGray
                
                bracketCells.append(bracketCell)
                
                let bracketPos = (x: 1, y: game)
                bracketDict[bracketCell] = bracketPos
                
                // create team labels inside the cell
                let teamOneLabel = UILabel(frame: CGRect(x: 8, y: 0, width: labelWidth, height: 50))
                let teamTwoLabel = UILabel(frame: CGRect(x: 8, y: 50, width: labelWidth, height: 50))
                
                // add ui labels to cell
                bracketCell.addSubview(teamOneLabel)
                bracketCell.addSubview(teamTwoLabel)
                scrollView.addSubview(bracketCell)
                
                try! realm.write {
                    // set team labels
                    let tournament = TournamentController.getCurrentTournament()
                    
                    // make sure we have games to fill in teams
                    // otherwise, just write TBD so they can visualize the entire bracket.
                    if tournament.matchupList.count > (game - 1) && tournament.matchupList[game - 1].round == 1 {
                        teamOneLabel.text = tournament.matchupList[game - 1].teamOne?.name
                        if tournament.matchupList[game - 1].teamTwo == nil {
                            teamTwoLabel.text = "BYE"
                        } else {
                           teamTwoLabel.text = tournament.matchupList[game - 1].teamTwo?.name
                        }
                    } else {
                        teamOneLabel.text = "TBD"
                        teamTwoLabel.text = "TBD"
                    }
                }
                
                // tap recognizer
                let gesture = UITapGestureRecognizer(target: self, action: #selector(self.matchTouched(sender:)))
                self.view.addGestureRecognizer(gesture)
            }
        }
    }
    
    // sets position of bracket cells for each subsequent match up
    // get bracketCells[x].frame to get x/y position, then set next bracketCells accordingly
    
    // ONE ERROR, if reporting 8 team bracket out of order: one team moves through fast, it is placed in incorrect cells.
    // matchups still are correct, but the display is wrong.
    func createAdditionalBracketCells() {
        for round in 2...roundCount {
            if bracketController.getRoundGameCount(round: round) > 0 {
                for game in 1...bracketController.getRoundGameCount(round: round) {
                    // each matchup will go to the middle of two other matchup
                    var coord = (x: 0, y: 0)
                    var yPos = 0
                    var xPos = 0
                    var prevCells = [UIView]()
                    
                    for bracketView in bracketDict.keys {
                        coord = bracketDict[bracketView]!
                        if coord.x == round - 1 && (coord.y == ((game * 2) - 1) || coord.y == (game * 2)) {
                            // we now have ONE of the previous bracket cells we need to center on.
                            prevCells.append(bracketView)
                            if(prevCells.count == 2) {
                                break
                            }
                        }
                    }
                    // X IS GOOD
                    xPos = Int(prevCells[0].frame.maxX) + 10
                    
                    // Y IS GOOD!
                    let maxOne = Int(prevCells[0].frame.maxY)
                    let maxTwo = Int(prevCells[1].frame.maxY)
                    
                    if maxOne > maxTwo {
                        // first cell is further down, grab it's minY, maxY for other cell
                        let minY = Int(prevCells[0].frame.minY)
                        let maxY = Int(prevCells[1].frame.maxY)
                        let spaceY = minY - maxY
                        let midPoint = spaceY / 2
                        yPos = midPoint + maxY - 50
                    } else {
                        // second cell is further down, grab it's minY, maxY for other cell
                        let minY = Int(prevCells[1].frame.minY)
                        let maxY = Int(prevCells[0].frame.maxY)
                        let spaceY = minY - maxY
                        let midPoint = spaceY / 2
                        yPos = midPoint + maxY - 50
                    }
                    
                    let bracketCell = UIView(frame: CGRect(x: xPos, y: yPos, width: bracketCellWidth, height: 100))
                    bracketCell.backgroundColor = UIColor.darkGray
                    
                    bracketCells.append(bracketCell)
                    
                    let bracketPos = (x: round, y: game)
                    bracketDict[bracketCell] = bracketPos
                    
                    // create team labels inside the cell
                    let teamOneLabel = UILabel(frame: CGRect(x: 8, y: 0, width: labelWidth, height: 50))
                    let teamTwoLabel = UILabel(frame: CGRect(x: 8, y: 50, width: labelWidth, height: 50))
                    
                    // add ui labels to cell
                    bracketCell.addSubview(teamOneLabel)
                    bracketCell.addSubview(teamTwoLabel)
                    scrollView.addSubview(bracketCell)
                    
                    try! realm.write {
                        // set team labels
                        let tournament = TournamentController.getCurrentTournament()
                        
                        // make sure we have games to fill in teams
                        // otherwise, just write TBD so they can visualize the entire bracket.
                        if tournament.matchupList.count > (game - 1) && tournament.matchupList[game - 1].round == round {
                            let teamOne = tournament.matchupList[game - 1].teamOne
                            let teamTwo = tournament.matchupList[game - 1].teamTwo
                            
                            teamOne?.bracketVerticalPositions.append(game)
                            teamTwo?.bracketVerticalPositions.append(game)
                            
                            teamOneLabel.text = teamOne?.name
                            if teamTwo == nil {
                                teamTwoLabel.text = "BYE"
                            } else {
                                teamTwoLabel.text = teamTwo?.name
                            }
                        } else {
                            teamOneLabel.text = "TBD"
                            teamTwoLabel.text = "TBD"
                        }
                    }
                    
                    // tap recognizer
                    let gesture = UITapGestureRecognizer(target: self, action: #selector(self.matchTouched(sender:)))
                    self.view.addGestureRecognizer(gesture)
                }
            }
        }
        
        createWinnerCell()
    }
    
    // Create a space for the winner to move into
    func createWinnerCell() {
        let prevCell = bracketCells.last!
        let bracketCell = UIView(frame: CGRect(x: prevCell.frame.maxX + 20, y: prevCell.frame.minY + 25, width: 252, height: 50))
        bracketCell.backgroundColor = UIColor.darkGray
        
        bracketCells.append(bracketCell)
        
        // create team labels inside the cell
        // width of 8 less than the winner cell's width
        let teamOneLabel = UILabel(frame: CGRect(x: 8, y: 0, width: 244, height: 50))
        
        // add ui labels to cell
        bracketCell.addSubview(teamOneLabel)
        scrollView.addSubview(bracketCell)
        
        try! realm.write {
            // set team labels
            var nonElimTeamsCount = 0
            var nonElimTeamName = "null"
            // make sure we have games to fill in teams
            // otherwise, just write TBD so they can visualize the entire bracket.
            for team in tournament.teamList {
                if !team.isEliminated {
                    if nonElimTeamsCount == 0 {
                        nonElimTeamName = team.name
                        nonElimTeamsCount += 1
                    } else {
                        nonElimTeamsCount += 1
                    }
                }
            }
            
            if nonElimTeamsCount == 1 && nonElimTeamName != "null" {
                teamOneLabel.text = nonElimTeamName
                teamOneLabel.textColor = UIColor.yellow
            } else {
                teamOneLabel.text = "TBD"
                teamOneLabel.textColor = UIColor.black
            }
            
            
            teamOneLabel.contentMode = UIViewContentMode.center
        }
    }
    
    // as a match gets reported, update the bracket page, moving teams on.
    // if team is eliminated, gray them out.
    // run thru each round, see if a team belongs there.
    // if they do, make sure they go to the proper cell...
    func updateBracketView() {
        // coord will be x: round | y: vertical position
        var coord = (x: 0, y: 0)
        
        for bracketView in bracketDict.keys {
            coord = bracketDict[bracketView]!
            
            // skip round 1
            if coord.x >= 1 {
                // check if we have a matchup with these coords to fill in teams
                for team in tournament.teamList {
                    // skip round 1, ensure that each team matches the round and new vert position
                    if team.bracketRounds.count >= 1 && team.bracketRounds.contains(coord.x) &&
                        team.bracketVerticalPositions[coord.x - 1] == (coord.y) {
                        // this team belongs in this cell!
                        if isTeamOnBottomOfBracketCell(team: team, currentRound: coord.x) {
                            // has two subviews of labels, team one and team two
                            // put them on bottom
                            let teamLabel = bracketView.subviews[1] as! UILabel
                            teamLabel.text = team.name
                            
                            // this means that the team moved on, color the cell accordingly
                            if team.wins >= coord.x {
                                teamLabel.textColor = UIColor.yellow
                            }
                        } else {
                            // put them on top
                            let teamLabel = bracketView.subviews[0] as! UILabel
                            teamLabel.text = team.name
                            
                            // this means that the team moved on, color the cell accordingly
                            if team.wins >= coord.x {
                                teamLabel.textColor = UIColor.yellow
                            }
                        }
                    }
                }
            }
            
            // Update final 'winners' cell
            if coord.x == roundCount + 1 {
                var nonElimTeamsCount = 0
                var nonElimTeamName = "null"
                
                for team in tournament.teamList {
                    if !team.isEliminated {
                        if nonElimTeamsCount == 0 {
                            nonElimTeamName = team.name
                            nonElimTeamsCount += 1
                        } else {
                            nonElimTeamsCount += 1
                        }
                    }
                }
                
                let teamLabel = bracketView.subviews[0] as! UILabel
                
                if nonElimTeamsCount == 1 && nonElimTeamName != "null" {
                    teamLabel.text = nonElimTeamName
                    teamLabel.textColor = UIColor.yellow
                } else {
                    teamLabel.text = "TBD"
                    teamLabel.textColor = UIColor.black
                }
            }
            
        }
    }
    
    func isTeamOnBottomOfBracketCell(team: Team, currentRound: Int) -> Bool {
        if currentRound > 1 {
            let prevPosition = team.bracketVerticalPositions[currentRound - 2]
            if prevPosition % 2 == 1 {
                // odd number position
                return false
            } else {
                // even number
                return true
            }
        } else {
            // if first round, teams with higher seeds are always on top
            // so higher seed will be the teams lower than half the count of teams.
            if team.seed <= tournament.teamList.count/2{
                return false
            } else {
                return true
            }
        }
    }
    
    @objc func matchTouched(sender:UITapGestureRecognizer) {
        // open score entry page, or just select a winner. Maybe a dialog for quickness
//        if true {
//            let clickedCell = sender.view
//            let teamOneLabel = clickedCell?.subviews[0] as! UILabel
//            let teamTwoLabel = clickedCell?.subviews[1] as! UILabel
//
//            let alert = UIAlertController(title: "Select Winner",
//                                          message: "", preferredStyle: .alert)
//
//
//            alert.addAction(UIAlertAction(title: teamOneLabel.text, style: .default, handler: { (action: UIAlertAction!) in
//                // team one!
//            }))
//
//            alert.addAction(UIAlertAction(title: teamTwoLabel.text, style: .default, handler: { (action: UIAlertAction!) in
//                // teamtwo
//            }))
//
//            present(alert, animated: true, completion: nil)
//
//        }
        
    }

    
    
}
