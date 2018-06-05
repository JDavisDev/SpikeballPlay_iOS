//
//  TeamsController.swift
//  SpikeballPlay
//
//  Created by Jordan Davis on 8/11/17.
//  Copyright © 2017 HoverSlam. All rights reserved.
//

import Foundation
import RealmSwift
import CoreData

class TeamsController {
    var playersPerPool = 8
    let realm = try! Realm()
    let tournamentController = TournamentController()
    var isNewPool = false
    let poolController = PoolsController()
    
    
    func addTeam(team: Team) {
        let newPool = getAvailablePool()
        let tournament = TournamentController.getCurrentTournament()

		try! realm.write() {
            if team.name.count == 0 {
				team.name = "Team #" + getNextTeamNameId(tournament: tournament)
            }
			
			playersPerPool = tournament.playersPerPool
            
            realm.add(team)
            newPool.teamList.append(team)
            team.pool = newPool

			if isNewPool {
                realm.add(newPool)
                tournament.poolList.append(newPool)
            }
        }
    }
	
	func insertTeamIntoCoreData(obj: Team, objPool: Pool) {
		let managedContext = CoreDataManager.sharedManager.persistentContainer.viewContext
		let entity = NSEntityDescription.entity(forEntityName: "CDTeam",
												in: managedContext)!
		let team = NSManagedObject(entity: entity,
										 insertInto: managedContext) as? CDTeam
		team?.name = obj.name
		team?.id = Int32(obj.id)
		team?.tournament_id = Int64(obj.tournament_id)
		
		do {
			try managedContext.save()
		} catch let error as NSError {
			print("Could not save. \(error), \(error.userInfo)")
		}
	}
	
	func getNextTeamNameId(tournament: Tournament) -> String {
		var count = tournament.teamList.count
		var countString = String(count)
		
		for _ in 1...tournament.teamList.count + 1 {
			if getTeamByName(name: "Team #" + countString, tournamentId: tournament.id).name == "Team #" + countString {
				// we've found a match, try another number
				count += 1
				countString = String(count)
			} else {
				return countString
			}
		}
		
		// we've went thru them all with duplicates..
		return "infinity"
	}
    
    func getTeamByName(name: String, tournamentId: Int) -> Team {
		let teams = realm.objects(Team.self).filter("name = '\(name)' AND tournament_id = \(tournamentId)")
		
		if teams.count > 0 {
			return teams.first!
		} else {
			let team = Team()
			team.name = "nil"
			return team
		}
    }
	
	func getTeamById(id: Int, tournamentId: Int) -> Team {
		let teams = realm.objects(Team.self).filter("id = \(id) AND tournament_id = \(tournamentId)")
		
		if teams.count > 0 {
			return teams.first!
		} else {
			let team = Team()
			team.name = "nil"
			return team
		}
	}
    
    func getAvailablePool() -> Pool {
        let tournament = TournamentController.getCurrentTournament()
        for pool in tournament.poolList {
            if pool.teamList.count < playersPerPool && !pool.isStarted {
                isNewPool = false
                return pool
            }
        }
        
        // no available pool, create one, append it, and return it
        isNewPool = true
        let poolCount = tournament.poolList.count
        let name = "Pool " + String(format: "%c", poolCount + 65) as String
        let pool = Pool()
		pool.tournament_id = tournament.id
        pool.name = name
        pool.teamList = List<Team>()
        pool.division = "Advanced"
        pool.isPowerPool = false
        pool.matchupList = List<PoolPlayMatchup>()
        
        return pool
    }
    
    
}
