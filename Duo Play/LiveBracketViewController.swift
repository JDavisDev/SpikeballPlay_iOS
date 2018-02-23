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
    var bracketDict: [UIView : Any] = [:]
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
    
    func reloadBracket() {
        for round in 1...roundCount {
            if bracketController.getRoundGameCount(round: round) > 0 {
                for game in 1...bracketController.getRoundGameCount(round: round) {
                    // create a cell and set the base position, we'll move later based on round/match #
                    // yPos is not offsetting in the middle of other places
                    var yPos = 8
                    if(game == 1 && round > 1) {
                        yPos = (round - 1) * 75
                    } else if game > 1 && round == 1{
                        yPos = ((game - 1) * 100) + (game * 2)
                    } else if game > 1 && round > 1 {
                        yPos = (game - 1) * 100 + (round - 1) * 100
                    }
                    
                    // I think xPos is good.
                    let xPos = round == 1 ? 8 : (round - 1) * 1 + (round * 150)
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
                            teamOneLabel.text = tournament.matchupList[game - 1].teamOne?.name
                            teamTwoLabel.text = tournament.matchupList[game - 1].teamTwo?.name
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
