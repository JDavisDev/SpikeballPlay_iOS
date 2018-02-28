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
    
    let realm = try! Realm()
    var tournament = Tournament()
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
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        try! realm.write() {
            tournament = TournamentController.getCurrentTournament()
        }
        
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
    
    func getBracketMatchCount() -> Int {
        var count = 0
        try! realm.write {
            count = tournament.teamList.count - 1
        }
        
        return count
    }
    
    // could generate first round positions.
    // then each cell after, is in the middle of the next two cells and ofeset.
    func reloadBracket() {
        var views = scrollView.subviews
        views.removeAll()
        bracketCells.removeAll()
        bracketDict.removeAll()
        
        createFirstRoundBracketCells()
        createAdditionalBracketCells()
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
                
                let bracketCell = UIView(frame: CGRect(x: xPos, y: yPos, width: 252, height: 100))
                bracketCell.backgroundColor = UIColor.white
                
                bracketCells.append(bracketCell)
                
                let bracketPos = (x: 1, y: game)
                bracketDict[bracketCell] = bracketPos
                
                // create team labels inside the cell
                let teamOneLabel = UILabel(frame: CGRect(x: 8, y: 0, width: 252, height: 50))
                let teamTwoLabel = UILabel(frame: CGRect(x: 8, y: 50, width: 252, height: 50))
                
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
                    
                    let bracketCell = UIView(frame: CGRect(x: xPos, y: yPos, width: 252, height: 100))
                    bracketCell.backgroundColor = UIColor.white
                    
                    bracketCells.append(bracketCell)
                    
                    let bracketPos = (x: round, y: game)
                    bracketDict[bracketCell] = bracketPos
                    
                    // create team labels inside the cell
                    let teamOneLabel = UILabel(frame: CGRect(x: 8, y: 0, width: 252, height: 50))
                    let teamTwoLabel = UILabel(frame: CGRect(x: 8, y: 50, width: 252, height: 50))
                    
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
            if coord.x > 1 {
                // check if we have a matchup with these coords to fill in teams
                for team in tournament.teamList {
                    // skip round 1, ensure that each team matches the round and new vert position
                    if team.bracketRounds.count > 1 && team.bracketRounds.contains(coord.x) &&
                        team.bracketVerticalPositions.contains(coord.y) {
                        // this team belongs in this cell!
                        if team.isOnBottomOfBracketCell {
                            // has two subviews of labels, team one and team two
                            let teamLabel = bracketView.subviews[1] as! UILabel
                            teamLabel.text = team.name
                        } else {
                            let teamLabel = bracketView.subviews[0] as! UILabel
                            teamLabel.text = team.name
                        }
                    }
                }
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
