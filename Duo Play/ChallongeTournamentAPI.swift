
//  ChallongeAPI.swift
//  Duo Play
//
//  Created by Jordan Davis on 2/19/18.
//  Copyright © 2018 Jordan Davis. All rights reserved.


import Foundation
import RealmSwift

public class ChallongeTournamentAPI {
	var delegate: ChallongeTournamentAPIDelegate?
    static let challongeBaseUrl = "https://api.challonge.com/v1/"
    static let PERSONAL_API_KEY = "dtxaTM8gb4BRN13yLxwlbFmaYcteFxWwLrmAJV3h"
    static let TEST_API_KEY = "obUAOsG1dCV2bTpLqPvGy6IIB3MzF4o4TYUkze7M"
    static let SPIKEBALL_API_KEY = ""
	
	let matchupAPI = ChallongeMatchupAPI()
	
    public var tournamentList = [NSDictionary]()

	// MARK: TOURNAMENT
	
//    func getTournaments() {
//        //ChallongeAPI.challongeBaseUrl + "tournaments.json?api_key=" + ChallongeAPI.API_KEY)
//        var request = URLRequest(url: URL(string: ChallongeAPI.challongeBaseUrl + "tournaments.json?api_key=" + ChallongeAPI.TEST_API_KEY)!)
//        request.httpMethod = "GET"
//        let session = URLSession.shared; if #available(iOS 11.0, *) {
//				session.configuration.waitsForConnectivity = true
//			} else {
// Fallback on earlier versions
//			}
//        let task = session.dataTask(with: request, completionHandler: { data, response, error -> Void in
//            print(response!)
//            do {
//
//            } catch {
//                print("error")
//            }
//        })
//
//        task.resume()
//    }

	func startTournament(tournament: Tournament) {
		let tournamentParser = TournamentParser()
		
		let urlString = "https://api.challonge.com/v1/tournaments/" + tournament.url + "/start.json?api_key=" + ChallongeTournamentAPI.PERSONAL_API_KEY + "&include_participants=1" + "&include_matches=1"
		
		if let myURL = URL(string: urlString) {
			var request = URLRequest(url: myURL)
			request.httpMethod = "POST"
			let session = URLSession.shared; if #available(iOS 11.0, *) {
				session.configuration.waitsForConnectivity = true
			} else {
				// Fallback on earlier versions
			}
			let task = session.dataTask(with: request, completionHandler: { data, response, error -> Void in
				print(error ?? "No Error Here!")
				print(response ?? "No response :(")
				print(data ?? "No data")
				do {
					var challongeMatchups = [[String:Any]]()
					if let json = try JSONSerialization.jsonObject(with: data!) as? [String: Any] {
						if let jsonTournament = json["tournament"] as? [String:Any] {
							if let matches = jsonTournament["matches"] as? NSArray {
								for obj in matches {
									if let match = obj as? [String:Any] {
										if let match = match["match"] {
											challongeMatchups.append(match as! [String : Any])
										}
									}
								}
							}
						
							tournamentParser.parseStartedTournament(localTournament: tournament, challongeParticipants: [[String:Any]](), challongeMatchups: challongeMatchups)
						}
					} else {
						print("Failed to parse started tournament")
					}
				} catch {
					print("create challonge tournament error")
				}
			})
			
			task.resume()
		}
	}

    // Takes tournament object passed in and sends it to Challonge
    func createChallongeTournament(tournament: Tournament) {
		let baseUrl = ChallongeTournamentAPI.challongeBaseUrl
		let personalAPIKey = ChallongeTournamentAPI.PERSONAL_API_KEY
		let tournamentName = tournament.name
		let finalString = baseUrl +
			"tournaments.json?api_key=" + personalAPIKey +
			"&tournament[name]=" + tournamentName + "&" + "tournament[url]=" + tournament.url
		
		let squareBracketSet = CharacterSet(charactersIn: "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789?=:&/-._~[]")
		
		let urlString = finalString.addingPercentEncoding(withAllowedCharacters: squareBracketSet)
		if let myURL = URL(string: urlString!) {
			var request = URLRequest(url: myURL)
			request.httpMethod = "POST"
			let session = URLSession.shared
			if #available(iOS 11.0, *) {
				session.configuration.waitsForConnectivity = true
			} else {
				// Fallback on earlier versions
			}
			let task = session.dataTask(with: request, completionHandler: { data, response, error -> Void in
				do {
					if data != nil {
						if let json = try JSONSerialization.jsonObject(with: data!) as? [String: Any] {
							if let tournamentObject = json["tournament"] as? [String: Any] {
								self.delegate?.didCreateChallongeTournament(onlineTournament: tournamentObject, localTournament: tournament, success: true)
							} else {
								self.delegate?.didCreateChallongeTournament(onlineTournament: nil, localTournament: nil, success: false)
							}
						} else {
							self.delegate?.didCreateChallongeTournament(onlineTournament: nil, localTournament: nil, success: false)
						}
					} else {
						self.delegate?.didCreateChallongeTournament(onlineTournament: nil, localTournament: nil, success: false)
					}
				} catch {
					print("create challonge tournament error")
					self.delegate?.didCreateChallongeTournament(onlineTournament: nil, localTournament: nil, success: false)
				}
			})

			task.resume()
		}
    }
	
	func updateChallongeTournament(tournament: Tournament) {
		let tournamentParser = TournamentParser()
		let baseUrl = ChallongeTournamentAPI.challongeBaseUrl
		let personalAPIKey = ChallongeTournamentAPI.PERSONAL_API_KEY
		let finalString = baseUrl +
			tournament.url + ".json?api_key=" + personalAPIKey +
			""
			// params go here
		
		let squareBracketSet = CharacterSet(charactersIn: "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789?=:&/-._~[]")
		
		let urlString = finalString.addingPercentEncoding(withAllowedCharacters: squareBracketSet)
		if let myURL = URL(string: urlString!) {
			var request = URLRequest(url: myURL)
			request.httpMethod = "PUT"
			let session = URLSession.shared; if #available(iOS 11.0, *) {
				session.configuration.waitsForConnectivity = true
			} else {
				// Fallback on earlier versions
			}
			let task = session.dataTask(with: request, completionHandler: { data, response, error -> Void in
				do {
					if let json = try JSONSerialization.jsonObject(with: data!) as? [String: Any] {
						/* json[0] == key"tournament" and value: Any */
						if let tournamentObject = json["tournament"] as? [String: Any] {
							self.delegate?.didCreateChallongeTournament(onlineTournament: tournamentObject, localTournament: tournament, success: true)
						}
					}
				} catch {
					print("update challonge tournament error")
				}
			})
			
			task.resume()
		}
	}
	
	func deleteChallongeTournament(tournament: Tournament) {
		let baseUrl = ChallongeTournamentAPI.challongeBaseUrl
		let personalAPIKey = ChallongeTournamentAPI.PERSONAL_API_KEY
		let finalString = baseUrl + "tournaments/" +
			tournament.url + ".json?api_key=" + personalAPIKey
		
		let squareBracketSet = CharacterSet(charactersIn: "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789?=:&/-._~[]")
		
		let urlString = finalString.addingPercentEncoding(withAllowedCharacters: squareBracketSet)
		if let myURL = URL(string: urlString!) {
			var request = URLRequest(url: myURL)
			request.httpMethod = "DELETE"
			let session = URLSession.shared; if #available(iOS 11.0, *) {
				session.configuration.waitsForConnectivity = true
			} else {
				// Fallback on earlier versions
			}
			let task = session.dataTask(with: request, completionHandler: { data, response, error -> Void in
				// eat the response?
			})
			
			task.resume()
		}
	}
}

