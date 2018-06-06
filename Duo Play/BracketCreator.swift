//
//  BracketCreator.swift
//  Duo Play
//
//  Created by Jordan Davis on 5/27/18.
//  Copyright © 2018 Jordan Davis. All rights reserved.
//

import Foundation
import RealmSwift

class BracketCreator {
	
	let realm = try! Realm()
	let tournamentDAO = TournamentFirebaseDao()
	
	var bracketController: BracketController
	var tournament: Tournament
	var isTournamentStarted: Bool
	
	var teamCount = 0
	var byeCount = 0
	var nodeList = [Node]()
	var baseBracketSize = 0
	var isEnd = false
	
	var bracketCreatorDelegate: LiveBracketViewDelegate?
	
	init(tournament: Tournament, bracketController: BracketController) {
		self.tournament = tournament
		self.isTournamentStarted = tournament.isStarted
		self.bracketController = bracketController
		self.byeCount = bracketController.getByeCount()
		self.teamCount = tournament.teamList.count
	}
	
	func createBracket() {
		createAndOrderMatchups()
	}
	
	// Setting up the bracket matchups
	// Ordering the match ups based on official tournament seeding
	private func createAndOrderMatchups() {
		var seedStringList = [String]()
		nodeList = [Node]()
		var halfNodesList = [Node]()
		
		// need a number to sim bracket size. basically, it's the next highest power of 2
		// 14 teams is a 16 team bracket wtih 2 byes that'll go to highest seeds, rest of bracket looks the same
		baseBracketSize = getNextPowerOfTwo(num: teamCount)
		
		if baseBracketSize > 0 {
			for i in 1...baseBracketSize {
				seedStringList.append(String(i))
			}
		} else {
			return
		}
		
		// 1+2 are always at the end, set that up now.
		let root = Node(value: [seedStringList[0], seedStringList[1]])
		seedStringList.removeFirst(2)
		nodeList.append(root)
		
		// handle round by round
		// create and fill nodes
		// half nodes need filled in, as they were just branched.
		// we know we've reached the end based on node counts and it's children and baseBracketSize
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
					
					// we just branched off of full nodes, so they are now halves.
					halfNodesList.append(nodeOne)
					halfNodesList.append(nodeTwo)
				}
			}
			
			addSeedToNode(nodes: halfNodesList, seedList: seedStringList)
			// check if counts match up to be the final round
			if isEnd {
				isEnd = false
				break
			}
		}
		
		// use this to make sure we only have the final round of nodes in our list
		// to gen match ups from
		var copyList = [Node]()
		
		for node in nodeList {
			if node.children.count <= 0 {
				copyList.append(node)
			}
		}
		
		createMatchupsFromNodeList(nodes: copyList)
	}
	
	// iterate thru the half nodes and add a seed to each
	private func addSeedToNode(nodes: [Node], seedList: [String]) {
		// may be able to delete the nodeList.add() in the order method above.
		// delete and re-add nodes that contain two values.
		// keep the nodeList intact with no half nodes.
		var copyList = [Node]()
		
		for node in nodeList {
			if node.value.count >= 2 {
				copyList.append(node)
			}
		}
		
		nodeList.removeAll()
		nodeList = copyList
		
		// check counts and additions of seeds to match current round
		// current round is calculated by nodes.count * 2 + 1
		// example: round 2 of nodes will always have just 2 full nodes.
		// 1v4 & 2v3. 2 nodes * 2 = 4 + 1 = 5. 1+4 = 5 & 2+3 = 5.
		// this is the same for each subsequent round.
		for node in nodes {
			for seed in seedList {
				if Int(node.value[0])! + Int(seed)! == (nodes.count * 2) + 1 {
					node.value.append(seed)
					nodeList.append(node)
					break;
				}
			}
		}
		
		// check to see if we have all we need, and call isEnd to break out of the loop above.
		if nodeList.count == baseBracketSize - 1 {
			isEnd = true
		}
	}
	
	private func createMatchupsFromNodeList(nodes: [Node]) {
		var verticalPositionCounter: Int = 1
		
		let db = DBManager()
		db.beginWrite()
		
		tournament.matchupList.removeAll()
		
		for node in nodes {
			if node.value.count == 2 {
				let game = BracketMatchup()
				
				let max = 2147483600
				var id = Int(arc4random_uniform(UInt32(max)))
				while !bracketController.isIdUnique(id: id) {
					id = Int(arc4random_uniform(UInt32(max)))
				}
				
				game.id = Int(id)
				
				game.tournament_id = tournament.id
				game.teamOne = bracketController.getTeamBySeed(seed: node.value[0])
				bracketController.resetTeamValues(team: (game.teamOne)!)
				
				game.division = "Advanced"
				game.round = 1
				game.round_position = verticalPositionCounter
				game.teamOne?.bracketVerticalPositions.append(game.round_position)
				
				// check if a node value exceeds our teams, in which case, it's a bye.
				let seedInt = Int(node.value[1])!
				if seedInt > tournament.teamList.count {
					// teamOne will get a bye here.
					game.teamTwo = nil
					game.isReported = true
					bracketController.reportByeMatch(teamToAdvance: game.teamOne!)
					tournamentDAO.addFirebaseTeam(team: game.teamOne!)
				} else {
					// not a bye, proceed normally
					game.teamTwo = bracketController.getTeamBySeed(seed: node.value[1])
					bracketController.resetTeamValues(team: (game.teamTwo)!)
					game.teamTwo?.bracketVerticalPositions.append(game.round_position)
					//tournamentDAO.addOnlineTournamentTeam(team: game.teamOne!)
					//tournamentDAO.addOnlineTournamentTeam(team: game.teamTwo!)
				}
				
				realm.add(game)
				tournament.matchupList.append(game)
				//tournamentDAO.addOnlineMatchup(matchup: game)
				verticalPositionCounter += 1
			}
		}
		
		db.commitWrite()
		
		bracketController.updateMatchups()
	}
	
	/** UTIL METHODS **/
	
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
		case 257...512:
			return 512
		default:
			return 0
		}
	}
}
