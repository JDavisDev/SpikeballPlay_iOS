//
//  LiveBracketViewController.swift
//  Duo Play
//
//  Created by Jordan Davis on 1/5/18.
//  Copyright © 2018 Jordan Davis. All rights reserved.
//

import UIKit
import RealmSwift
import Crashlytics
import Firebase

class LiveBracketViewController: UIViewController, UIScrollViewDelegate, LiveBracketViewDelegate, ChallongeMatchupAPIDelegate {
	
	var pinch = UIPinchGestureRecognizer()
	
	@IBOutlet weak var activityIndicator: UIActivityIndicatorView!
	let challongeMatchupAPI = ChallongeMatchupAPI()
	let realm = try! Realm()
	let challongeTournamentAPI = ChallongeTournamentAPI()
    var tournament = Tournament()
	// used for quick report
	var selectedMatchup = BracketMatchup()
    var bracketCellWidth = 76
    var labelWidth = 68
    @IBOutlet weak var scrollView: UIScrollView!
    
    let bracketController = BracketController()
    
    var bracketCells = [UIView]()
    var bracketDict: [UIView : (x: Int, y: Int)] = [:]
    var bracketMatchCount = 0
    var roundCount = 0
    var byeCount = 0
    var teamCount = 0
	var frameWidth: CGFloat = 0
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
        self.view.backgroundColor = UIColor.black
        self.view.addSubview(scrollView)
		bracketController.bracketViewDelegate = self
		challongeMatchupAPI.delegate = self
		self.scrollView.delegate = self
		self.scrollView.addGestureRecognizer(pinch)
		pinch = UIPinchGestureRecognizer(target: self, action: #selector(self.pinch(sender:)))
		self.scrollView.minimumZoomScale = 1
		self.scrollView.maximumZoomScale = 10
		self.scrollView.isUserInteractionEnabled = true
		self.scrollView.contentSize = CGSize(width: 10000, height: 10000)
		
		tournament = TournamentController.getCurrentTournament()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
		clearView()
		
		activityIndicator.startAnimating()
		
		Answers.logContentView(withName: "Bracket Page View",
							   contentType: "Bracket Page View",
							   contentId: "9",
							   customAttributes: [:])
		
		Analytics.logEvent("Live_Bracket_View_Viewed", parameters: nil)
	
		// every view, let's refetch and redraw.
		// make this less dependent on other functions updating things.
		if tournament.isStarted {
			//challongeMatchupAPI.getMatchupsForTournament(tournament: tournament)
			bracketController.createBracket()
		} else {
			bracketController.createBracket()
		}
    }
	
	func clearView() {
		var views = scrollView.subviews
		views.removeAll()
		
		for cell in bracketCells {
			cell.removeFromSuperview()
		}
		
		bracketCells.removeAll()
		bracketDict.removeAll()
	}
	
	// BRACKET DELEGATE
	func bracketCreated() {
		createBracketView()
	}
	// END BRACKET DELEGATE
	
	// MATCHUP DELEGATE
	func didGetChallongeMatchups() {
		bracketController.createBracket()
	}
	// END MATCHUP DELEGATE
	
	// Pinch Controls
	@objc func pinch(sender:UIPinchGestureRecognizer) {
		if sender.state == .began || sender.state == .changed {
			self.scrollView.setZoomScale(sender.scale * sender.velocity * 20, animated: true)
			
		}
	}
		
    func getMaxBracketWidth() -> Int {
        var returnInt = 70
//		let db = DBManager()
//		//if tournament.teamList.count > 0 {
//			for team in db.getTournamentTeamsList(tournament: tournament) {
//				if team.name.count * 10 > returnInt {
//					returnInt = team.name.count * 10
//				}
//			}
//		//}
		
        // label width needs to be 8 less, because name labels are left padded by 8
        labelWidth = returnInt + 16
        return returnInt + 24
    }
    
    // could generate first round positions.
    // then each cell after, is in the middle of the next two cells and offset.
    func createBracketView() {
		let realm = try! Realm()
		try! realm.write {
			self.bracketCellWidth = self.getMaxBracketWidth()
			self.teamCount = self.tournament.teamList.count
			self.bracketMatchCount = self.teamCount - 1
			self.roundCount = self.bracketController.getRoundCount()
			self.byeCount = self.bracketController.getByeCount()
		}
		
		Answers.logCustomEvent(withName: "Bracket Drawn",
									   customAttributes: [
										"Team Count": teamCount])
		
		
		createFirstRoundBracketCells()
		createAdditionalBracketCells()
    }
    
    // create first round based on match counts
    func createFirstRoundBracketCells() {
		let roundGameCount = bracketController.getRoundGameCount(round: 1)
        if roundGameCount > 0 {
            for game in 1...roundGameCount {
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
                        let teamOne = tournament.matchupList[game - 1].teamOne
                        let teamTwo = tournament.matchupList[game - 1].teamTwo
						
						if tournament.matchupList[game - 1].challongeId != 0 {
							bracketCell.layer.shadowColor = UIColor.yellow as! CGColor
							bracketCell.layer.shadowOpacity = 1
							bracketCell.layer.shadowOffset = CGSize.zero
							bracketCell.layer.shadowRadius = 6
						}
						
                        teamOneLabel.text = teamOne?.name
						
                        if teamTwo == nil || teamTwo?.name == "nil" || teamTwo?.name == nil {
                            teamTwoLabel.text = "BYE"
                            teamTwoLabel.textColor = UIColor.black
                        } else {
                            teamTwoLabel.text = teamTwo?.name
							teamOneLabel.textColor = UIColor.white
							teamTwoLabel.textColor = UIColor.white
                        }
                    } else {
                        teamOneLabel.text = "TBD"
                        teamTwoLabel.text = "TBD"
						teamOneLabel.textColor = UIColor.black
						teamTwoLabel.textColor = UIColor.black
                    }
                }
                
                // tap recognizer
				// only set up if user can edit
				if !tournament.isReadOnly {
                	let gesture = UITapGestureRecognizer(target: self, action: #selector(self.matchTouched(sender:)))
                	self.view.addGestureRecognizer(gesture)
				}
            }
        }
	
		// grab bracketCells.last! to get the furthest DOWN cell
		// that's the low point of our view
		//frameWidth = bracketCells.last!.frame.maxY + 50
    }
    
    // sets position of bracket cells for each subsequent match up
    // get bracketCells[x].frame to get x/y position, then set next bracketCells accordingly
    
    // matchups still are correct, but the display is wrong.
    func createAdditionalBracketCells() {
		if roundCount < 2 { return }
		
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
                    
                    if prevCells.count >= 2 {
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
                        
                        teamOneLabel.textColor = UIColor.black
                        teamTwoLabel.textColor = UIColor.black
                        teamOneLabel.text = "TBD"
                        teamTwoLabel.text = "TBD"
                        
                        // add ui labels to cell
                        bracketCell.addSubview(teamOneLabel)
                        bracketCell.addSubview(teamTwoLabel)
                        scrollView.addSubview(bracketCell)
						
                        // tap recognizer
                        let gesture = UITapGestureRecognizer(target: self, action: #selector(self.matchTouched(sender:)))
                        self.view.addGestureRecognizer(gesture)
                    }
                }
            }
        }
        
        // we need one more cell to display the winner
        // outside the loop because it contains different logic and doesn't count as a tournament "round"
        createWinnerCell()
    }
    
    // Create a space for the winner to move into
    func createWinnerCell() {
		if bracketCells.count > 0 && bracketDict.count > 0 {
			let prevCell = bracketCells.last!
			let bracketCell = UIView(frame: CGRect(x: prevCell.frame.maxX + 20, y: prevCell.frame.minY + 25, width: 252, height: 50))
			bracketCell.backgroundColor = UIColor.darkGray
			
			bracketCells.append(bracketCell)
			let bracketPos = (x: roundCount + 1, y: 1)
			bracketDict[bracketCell] = bracketPos
			
			// create team labels inside the cell
			// width of 8 less than the winner cell's width
			let teamOneLabel = UILabel(frame: CGRect(x: 8, y: 0, width: 244, height: 50))
			
			// add ui labels to cell
			bracketCell.addSubview(teamOneLabel)
			scrollView.addSubview(bracketCell)
			self.view.addSubview(scrollView)
			
			teamOneLabel.text = "TBD"
			teamOneLabel.textColor = UIColor.black
			
			
			updateBracketView()
			//grab bracketCells.last OR this one cell to get the first RIGHT a bracket should be.
			//let height = bracketCell.frame.maxX + 50
			//scrollView.contentSize = CGSize(width: frameWidth, height: height)
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
            
            if coord.x >= 1 {
                // check if we have a matchup with these coords to fill in teams
                for team in tournament.teamList {
                    // ensure that each team matches the round and new vert position
                    if team.bracketRounds.count >= 1 && team.bracketRounds.contains(coord.x) &&
                        team.bracketVerticalPositions.count > coord.x - 1 &&
                        team.bracketVerticalPositions[coord.x - 1] == (coord.y) {
						
						var textLabelPos = 0
                        // this team belongs in this cell!
                        if isTeamOnBottomOfBracketCell(team: team, currentRound: coord.x) {
							textLabelPos = 1
						} else {
							textLabelPos = 0
						}
						
						// has two subviews of labels, team one and team two
						let teamLabel = bracketView.subviews[textLabelPos] as! UILabel
						teamLabel.text = team.name
						
						// this means that the team moved on, color the cell accordingly
						if team.wins >= coord.x {
							teamLabel.textColor = UIColor.yellow
						} else if team.isEliminated {
							teamLabel.textColor = UIColor.black
						} else {
							teamLabel.textColor = UIColor.white
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
                }
            }
        }
		
		activityIndicator.stopAnimating()
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
//			if team.seed <= byeCount() return false?
//			if team.seed <= bracketController.baseBracketSize/2 {
//				return false
//			} else {
//				return true
//			}
			
			if tournament.teamList.count % 2 == 1 {
				// odd number
				// need a new calc method here..
				if team.seed - byeCount < tournament.teamList.count/2 {
					return false
				} else {
					return true
				}
			} else if Float(team.seed) <= Float(Float(tournament.teamList.count + byeCount)/2) {
				// need float division to get accurate results.
                return false
            } else {
                return true
            }
        }
    }
    
    @objc func matchTouched(sender:UITapGestureRecognizer) {
		var matchupFound = false
        // open score entry page, or just select a winner. Maybe a dialog for quickness
		// Get the first touch and its location in this view controller's view coordinate system
		let touchLocation = sender.location(ofTouch: 0, in: self.view)
		
		for cell in bracketCells {
			// Convert the location of the obstacle view to this view controller's view coordinate system
			let viewFrame = self.view.convert(cell.frame, from: cell.superview)
			
			// Check if the touch is inside the obstacle view
			if viewFrame.contains(touchLocation) && cell.subviews.count >= 2 {
				if(!tournament.isStarted) {
					checkStartTournament()
				} else {
					let teamOneLabel = cell.subviews[0] as! UILabel
					let teamTwoLabel = cell.subviews[1] as! UILabel
					
					if teamOneLabel.text != "BYE" && teamOneLabel.text != "TBD" &&
						teamTwoLabel.text != "BYE" && teamTwoLabel.text != "TBD" &&
						teamOneLabel.text != teamTwoLabel.text {
						
						for matchup in tournament.matchupList {
							if	!matchup.isReported &&
								matchup.teamOne != nil &&
								matchup.teamTwo != nil &&
								matchup.teamOne!.name == teamOneLabel.text &&
								matchup.teamTwo!.name == teamTwoLabel.text {
								selectedMatchup = matchup
								matchupFound = true
								break
							}
						}
						
						if matchupFound && !selectedMatchup.isReported && tournament.isQuickReport {
							let alert = UIAlertController(title: "Select Winner",
														  message: "", preferredStyle: .alert)
							
							alert.addAction(UIAlertAction(title: teamOneLabel.text, style: .default, handler: { (action: UIAlertAction!) in
								// team one!
								self.bracketController.reportMatch(selectedMatchup: self.selectedMatchup, numOfGamesPlayed: 1, teamOneScores: [1, 0, 0], teamTwoScores: [0, 0, 0])
								
								self.updateBracketView()
							}))
							
							alert.addAction(UIAlertAction(title: teamTwoLabel.text, style: .default, handler: { (action: UIAlertAction!) in
								// team two!
								self.bracketController.reportMatch(selectedMatchup: self.selectedMatchup, numOfGamesPlayed: 1, teamOneScores: [0, 0, 0], teamTwoScores: [1, 0, 0])
								
								self.updateBracketView()
							}))
							
							alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: {(action: UIAlertAction!) in
								// cancel
								return
							}))
							// Add delete in here. to maybe delete match ups and reset everything down stream...
							present(alert, animated: true, completion: nil)
						} else if matchupFound && !selectedMatchup.isReported && !tournament.isReadOnly {
							// not quick report. send to match reporter.
							Answers.logCustomEvent(withName: "Bracket Match Tapped",
												   customAttributes: [:])
							Analytics.logEvent("Live_Bracket_Match_Tapped", parameters: nil)
							performSegue(withIdentifier: "bracketReporterOnTouchSegue", sender: selectedMatchup)
						}
					}
				}
			}
		}
    }
	
	func checkStartTournament() {
		// tournament has NOT began. check if they want to finalize and begin the tournament
		let message = "Finalize participants and start tournament?"
		
		let alert = UIAlertController(title: "Start Tournament", message: message,
									  preferredStyle: .alert)
		
		alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action: UIAlertAction!) in
			self.challongeTournamentAPI.startTournament(tournament: self.tournament)
			self.challongeMatchupAPI.getMatchupsForTournament(tournament: self.tournament)
		}))
		
		alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
			// cancel
			return
		}))
		
		present(alert, animated: true, completion: nil)
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == "bracketReporterOnTouchSegue" {
			if let nextVC = segue.destination as? BracketReporterViewController {
				nextVC.selectedMatchup = sender as! BracketMatchup
			}
		}
	}
}
