//
//  ChallongeAPI.swift
//  Duo Play
//
//  Created by Jordan Davis on 2/19/18.
//  Copyright © 2018 Jordan Davis. All rights reserved.
//

import Foundation

public class ChallongeAPI {
    static let challongeBaseUrl = "https://api.challonge.com/v1/"
    static let PERSONAL_API_KEY = "dtxaTM8gb4BRN13yLxwlbFmaYcteFxWwLrmAJV3h"
    static let TEST_API_KEY = "obUAOsG1dCV2bTpLqPvGy6IIB3MzF4o4TYUkze7M"
    static let SPIKEBALL_API_KEY = ""
    
    public var tournamentList = [NSDictionary]()
    
    func getTournaments() {
        //ChallongeAPI.challongeBaseUrl + "tournaments.json?api_key=" + ChallongeAPI.API_KEY)
        var request = URLRequest(url: URL(string: ChallongeAPI.challongeBaseUrl + "tournaments.json?api_key=" + ChallongeAPI.TEST_API_KEY)!)
        request.httpMethod = "GET"
        let session = URLSession.shared
        let task = session.dataTask(with: request, completionHandler: { data, response, error -> Void in
            print(response!)
            do {
                let json = try JSONSerialization.jsonObject(with: data!) as! [NSDictionary]
                // json is a list of NSDictionaries
                // [0] = "tournament" : Key = "tournament" value = NSDict of all the attributes
                
                // each object in the list has the key value pairs/ attribs
                self.tournamentList.removeAll()
                for obj in json {
                    self.tournamentList.append(obj.value(forKey: "tournament") as! NSDictionary)
                }
                
                if(self.tournamentList.count > 0) {
                    self.parseTournaments()
                }
            } catch {
                print("error")
            }
        })
        
        task.resume()
    }

    
    func parseData(data: Data) {
            //Get back to the main queue
            DispatchQueue.main.async {
                // update UI
            }
    }
    
    func parseTournaments() {
        let onlineTournaments = self.tournamentList
        
        for tournament in onlineTournaments {
            let newTournament = Tournament()
            
            // assign properties from online tournament to realm tournament for local storage
            newTournament.name = tournament.value(forKey: "name") as! String
            newTournament.id = (tournament.value(forKey: "id") as! Int)
            newTournament.full_challonge_url = tournament.value(forKey: "full_challonge_url") as! String
            newTournament.game_id = tournament.value(forKey: "game_id") as! Int
            newTournament.isPrivate = tournament.value(forKey: "private") as! Bool
            newTournament.live_image_url = tournament.value(forKey: "live_image_url") as! String
            newTournament.participants_count = tournament.value(forKey: "participants_count") as! Int
            newTournament.progress_meter = tournament.value(forKey: "progress_meter") as! Int
            newTournament.state = tournament.value(forKey: "state") as! String
            newTournament.teams = tournament.value(forKey: "teams") as! Bool
            newTournament.url = tournament.value(forKey: "url") as! String
            newTournament.tournament_type = tournament.value(forKey: "tournament_type") as! String
        }
    }
    
    // Takes tournament object passed in and sends it to Challonge
    func createTournament(tournament: Tournament) {
        var request = URLRequest(url: URL(string: ChallongeAPI.challongeBaseUrl +
            "tournaments.json?api_key=" + ChallongeAPI.TEST_API_KEY +
            "&tournament[name]=" + tournament.name +
            "&tournament[url]=" + tournament.url)!)
        request.httpMethod = "POST"
        let session = URLSession.shared
        let task = session.dataTask(with: request, completionHandler: { data, response, error -> Void in
            print(response!)
            do {
                let json = try JSONSerialization.jsonObject(with: data!) as! [NSDictionary]
                // json is a list of NSDictionaries
                // [0] = "tournament" : Key = "tournament" value = NSDict of all the attributes
                
                // each object in the list has the key value pairs/ attribs
                self.tournamentList.removeAll()
                for obj in json {
                    self.tournamentList.append(obj.value(forKey: "tournament") as! NSDictionary)
                }
                
                if(self.tournamentList.count > 0) {
                    self.parseTournaments()
                }
            } catch {
                print("error")
            }
        })
        
        task.resume()
    }
}
