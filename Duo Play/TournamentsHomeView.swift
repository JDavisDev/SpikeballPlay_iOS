//
//  TournamentsHome.swift
//  SpikeballPlay
//
//  Created by Jordan Davis on 8/11/17.
//  Copyright © 2017 HoverSlam. All rights reserved.
//

import UIKit
import RealmSwift
import Crashlytics
import Firebase
import FirebaseAuthUI

class TournamentsHomeView: UIViewController, UITableViewDataSource, UITableViewDelegate, TournamentDAODelegate {

	@IBOutlet weak var activityIndicator: UIActivityIndicatorView!
	
	let tournamentController = TournamentController()
    var tournamentList = [Tournament]()
    let realm = try! Realm()
	let tournamentFbDao = TournamentFirebaseDao()
	let fireDB = Firestore.firestore()
	var handle: AuthStateDidChangeListenerHandle?
	var onlineTournamentList = [[String:Any]]()
	
	var tournamentReference: DocumentReference?
	
    @IBOutlet weak var tournamentNameTextField: UITextField!
    @IBOutlet weak var tournamentTableView: UITableView!
	
    override func viewDidLoad() {
        tournamentTableView.delegate = self
        tournamentTableView.dataSource = self
		tournamentFbDao.delegate = self
		super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(true)
		Answers.logContentView(withName: "Tournaments Page View",
							   contentType: "Tournaments Page View",
							   contentId: "8",
							   customAttributes: [:])
		
		tournamentList.removeAll()
		updateLocalTournamentList()
    }
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		// [START remove_auth_listener]
		if let handle = handle {
			Auth.auth().removeStateDidChangeListener(handle)
		}
		// [END remove_auth_listener]
	}
	
	func showAlertMessage(title: String, message: String) {
		let alert = UIAlertController(title: title,
									  message: message, preferredStyle: .alert)
		
		alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { (action: UIAlertAction!) in
			// ok
			return
		}))
		
		present(alert, animated: true, completion: nil)
	}
	
	// ADD Tournament Button clicked
	
    @IBAction func addTournamentButtonClicked(_ sender: UIButton) {
		let alert = UIAlertController(title: "Add Tournament",
									  message: "", preferredStyle: .alert)
		
		let action = UIAlertAction(title: "Save", style: .default) { (alertAction) in
			_ = alert.textFields![0] as UITextField
			let newName = alert.textFields![0].text!
			let pw = alert.textFields![1].text!
			self.createNewTournament(newName: newName, password: pw)
			self.updateTournamentList()
			
			self.performSegue(withIdentifier: "newTournamentSettingsSegue", sender: self)
		}
		
		alert.addTextField { (textField) in
			textField.placeholder = "Tournament Name"
			textField.borderStyle = UITextBorderStyle.roundedRect
		}
		
		alert.addTextField { (textField) in
			textField.placeholder = "Editing Password (Optional)"
			textField.borderStyle = UITextBorderStyle.roundedRect
		}
		
		alert.addAction(action)
		
		alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
			// cancel
			return
		}))
		
		present(alert, animated: true, completion: nil)
    }
	
	// Create tournament from dialog
	func createNewTournament(newName: String, password: String) {
		let tournament = Tournament()
		
		if newName.count > 0 {
			tournament.name = newName
		} else {
			tournament.name = "Tournament #" + String(self.tournamentList.count + 1)
		}
		
		if password.count > 0 {
			tournament.password = password
		}
		
		let max = 2147483600
		var id = Int(arc4random_uniform(UInt32(max)))
		while !self.isIdUnique(id: id) {
			id = Int(arc4random_uniform(UInt32(max)))
		}
		
		tournament.id = Int(id)
		tournament.poolList = List<Pool>()
		tournament.teamList = List<Team>()
		tournament.url = getRandomStringForUrl(length: 12)
		tournament.userID = Auth.auth().currentUser?.uid ?? Analytics.appInstanceID()
		tournament.created_date = Date()
		tournament.creatorUserName = Auth.auth().currentUser?.displayName ?? ""
		
		try! self.realm.write {
			self.realm.add(tournament)
			self.self.tournamentList.append(tournament)
		}
		
		Analytics.logEvent("Tournament_Created", parameters: [
			"id": id ])
		
		TournamentController.setTournamentId(id: id)
		
		// do online saving
		//let challongeAPI = ChallongeTournamentAPI()
		//challongeAPI.createChallongeTournament(tournament: tournament)
		
		tournamentFbDao.addFirebaseTournament(tournament: tournament)
	}
	
	func getRandomStringForUrl(length: Int) -> String {
		let letters : NSString = "abcdefghijklmnopqrstuvwxyz_0123456789"
		let len = UInt32(letters.length)
		
		var randomString = ""
		
		for _ in 0 ..< length {
			let rand = arc4random_uniform(len)
			var nextChar = letters.character(at: Int(rand))
			randomString += NSString(characters: &nextChar, length: 1) as String
		}
		
		return randomString
	}
    
    func isIdUnique(id: Int) -> Bool {
        var count = 0
        let db = DBManager()
		db.beginWrite()
		count = realm.objects(Tournament.self).filter("id = \(id)").count
		db.commitWrite()
        return count == 0
    }
    
    @IBAction func getOnlineTournamentButtonClicked(_ sender: UIButton) {
		self.activityIndicator.startAnimating()
	
		if Auth.auth().currentUser == nil {
			loginOrSignUp(name: "beta", email: "jdevfeedback@gmail.com", pw: "testpw")
		} else {
			self.getOnlineTournaments()
		}
    }

	// CHALLONGE STUFF
//    func parseOnlineTournaments() {
//        challongeConnector.getTournaments()
//        let onlineTournaments = challongeConnector.tournamentList
//
//        for tournament in onlineTournaments {
//            let newTournament = Tournament()
//
//            // assign properties from online tournament to realm tournament for local storage
//            newTournament.name = tournament.value(forKey: "name") as! String
//            newTournament.id = tournament.value(forKey: "id") as! Int
//            newTournament.poolList = List<Pool>()
//            newTournament.teamList = List<Team>()
//            newTournament.full_challonge_url = tournament.value(forKey: "full_challonge_url") as! String
//            newTournament.game_id = tournament.value(forKey: "game_id") as! Int
//            newTournament.isPrivate = tournament.value(forKey: "private") as! Bool
//            newTournament.live_image_url = tournament.value(forKey: "live_image_url") as! String
//            newTournament.participants_count = tournament.value(forKey: "participants_count") as! Int
//            newTournament.progress_meter = tournament.value(forKey: "progress_meter") as! Int
//            newTournament.state = tournament.value(forKey: "state") as! String
//            newTournament.teams = tournament.value(forKey: "teams") as! Bool
//            newTournament.url = tournament.value(forKey: "url") as! String
//            newTournament.tournament_type = tournament.value(forKey: "tournament_type") as! String
//
//            try! realm.write {
//                realm.add(newTournament)
//                tournamentList.append(newTournament)
//            }
//        }
//        updateTournamentList()
//
//    }
// END CHALLONGE STUFF
	
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tournamentButtonCell")
        let button = cell?.contentView.subviews[0] as! UIButton
		let progress_label = cell?.contentView.subviews[1] as! UILabel
		
        if tournamentList.count > 0 {
			button.setTitle((tournamentList[indexPath.row].value(forKeyPath: "name") as? String)!,
                        for: .normal)
			
			let progressText = String(tournamentList[indexPath.row].progress_meter) + "%"
			progress_label.text = progressText
        
            button.addTarget(self,
                         action: #selector(tournamentButton_Clicked),
                         for: .touchUpInside
            )
        }
        
        return cell!
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tournamentList.count
    }
    
    func updateLocalTournamentList() {
        // fetch session list from db
        let results = realm.objects(Tournament.self)
        for tournament in results {
            tournamentList.append(tournament)
        }
		
        updateTournamentList()
    }
	
	func getOnlineTournaments() {
		tournamentFbDao.getFirebaseTournaments()
	}
	
	// MARK - Firebase
	
	// listen for new tournaments to be created
	// maybe limit to 'official spikeball' tournaments.
	func initFbTournamentListener() {
		
	}
	
	// DELEGATION METHODS
	func didGetOnlineTournamentData() {
		activityIndicator.stopAnimating()
		
		if(TournamentController.getCurrentTournament().isReadOnly) {
			performSegue(withIdentifier: "readOnlyTournamentSelectedSegue", sender: self)
		} else {
			performSegue(withIdentifier: "tournamentSelectedSegue", sender: self)
		}
	}
	
	func didGetOnlineTournaments(onlineTournamentList: [Tournament]) {
		DispatchQueue.main.sync {
			for tournament in onlineTournamentList {
				if isTournamentUnique(tournament: tournament) {
					if realm.isInWriteTransaction {
						realm.add(tournament)
					} else {
						try! realm.write {
							realm.add(tournament)
						}
					}
					
					tournamentList.append(tournament)
				} else {
					// not unique.. let's... overwrite it?
					overwriteTournamentInRealm(newTournament: tournament)
				}
			}
		}
		
		updateTournamentList()
		activityIndicator.stopAnimating()
	}
	
	// END DELEGATION METHODS
	
	func isTournamentUnique(tournament: Tournament) -> Bool {
		var count = 0
		try! realm.write {
			count = realm.objects(Tournament.self).filter("id = \(tournament.id)").count
		}
		
		return count == 0
	}
	
	func overwriteTournamentInRealm(newTournament: Tournament) {
		let tournaments = realm.objects(Tournament.self).filter("id = \(newTournament.id)")
		
		// grab tournament that matches the online tournament
		// set the local Realm tournament to match the online one.
		
		if var tObj = tournaments.first {
			try! realm.write {
				tObj = newTournament
			}
		}
		
		updateTournamentList()
	}
	
	func updateTournamentList() {
		tournamentTableView.reloadData()
	}
	
    @IBAction func tournamentButton_Clicked(sender: UIButton) {
        let name = sender.currentTitle
        if tournamentList.count > 0 {
            for tournament in tournamentList {
                if name == tournament.name {
                    TournamentController.setTournamentId(id: tournament.id)
					
					// check if tournament is local or online and we need to download data
					if tournament.isOnline {
						// is there a password? Is this the usr who created the tournament?
						// this allows users who uninstall or w/e to fetch their tournaments with a pw.
						if tournament.password.count > 0 && tournament.userID != Analytics.appInstanceID() {
							// prompt user to fetch password. if they do not know, set to read only.
							// alert : password or read only
							showPasswordAlert(tournament: tournament)
						} else {
							// we are online, but it's public, fetch the data.
							activityIndicator.startAnimating()
							
							// let's go tournamentDAO.getTournamentData. the fetch will call parse
							// parse calls back to DAO, DAO finishes and passses back to this view.
							tournamentFbDao.getTournamentData(tournament: tournament)
						}
					} else {
						// didn't need to download data, just move forward like normal
						didGetOnlineTournamentData()
					}
                }
            }
        }
	}
	
	func showPasswordAlert(tournament: Tournament) {
		let alert = UIAlertController(title: "Password",
									  message: "Please enter password to edit this tournament.\n" +
												"Or press Read-Only to view.", preferredStyle: .alert)
		
		let submit = UIAlertAction(title: "Submit", style: .default) { (alertAction) in
			_ = alert.textFields![0] as UITextField
			let pw = alert.textFields![0].text!
			let password = tournament.password
			
			if pw == password {
				try! self.realm.write {
					tournament.isReadOnly = false
				}
				
				self.activityIndicator.startAnimating()
				self.tournamentFbDao.getTournamentData(tournament: tournament)
			} else {
				self.showPasswordResultAlert(isSuccess: false)
			}
		}
		
		alert.addAction(submit)
		
		alert.addAction(UIAlertAction(title: "Read Only", style: .default, handler: { (action: UIAlertAction!) in
			// read only
			try! self.realm.write {
				tournament.isReadOnly = true
			}
			
			self.activityIndicator.startAnimating()
			self.tournamentFbDao.getTournamentData(tournament: tournament)
		}))
		
		alert.addTextField { (textField) in
			textField.placeholder = "Tournament Password"
			textField.borderStyle = UITextBorderStyle.roundedRect
		}
		
		alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
			// cancel
			return
		}))
		
		present(alert, animated: true, completion: nil)
	}
	
	func showPasswordResultAlert(isSuccess: Bool) {
		let message = isSuccess ? "Correct" : "Incorrect"
		let alert = UIAlertController(title: "Password",
									  message: "Password is \(message)", preferredStyle: .alert)
		
		alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { (action: UIAlertAction!) in
			// ok
			return
		}))
		
		present(alert, animated: true, completion: nil)
	}
	
	func loginOrSignUp(name: String, email: String, pw: String) {
		Auth.auth().signIn(withEmail: email, password: pw) { (user, error) in
			if error != nil {
				
				Auth.auth().createUser(withEmail: email, password: pw){ (user, error) in
					if error != nil {
						// show error
						self.showAlertMessage(title: "Fetch Error", message: "Some online features may be disabled.")
						self.activityIndicator.stopAnimating()
						user?.createProfileChangeRequest().displayName = name
					}
				}
				
				return
			} else if error == nil {
				if user != nil {
					self.getOnlineTournaments()
					user?.createProfileChangeRequest().displayName = name
				}
			}
		}
	}
}
