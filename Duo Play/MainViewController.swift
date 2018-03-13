//
//  ViewController.swift
//  SpikeballPlay
//
//  Created by Jordan Davis on 8/2/17.
//  Copyright © 2017 HoverSlam. All rights reserved.
//

import UIKit
import MessageUI
import RealmSwift
import Crashlytics
import StoreKit

class ViewController: UIViewController, MFMailComposeViewControllerDelegate {

    @IBOutlet weak var tournamentButton: UIButton!
    @IBOutlet weak var randomPlayButton: UIButton!
    @IBOutlet weak var tgButton: UIButton!
    @IBOutlet weak var contactButton: UIButton!
    @IBOutlet weak var rateButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(Realm.Configuration.defaultConfiguration.fileURL!)
        // Do any additional setup after loading the view, typically from a nib.
        
        initButtonStyles()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func initButtonStyles() {
        tournamentButton.layer.cornerRadius = 20
        tournamentButton.layer.borderColor = UIColor.yellow.cgColor
        tournamentButton.layer.borderWidth = 1
        
        randomPlayButton.layer.cornerRadius = 20
        randomPlayButton.layer.borderColor = UIColor.yellow.cgColor
        randomPlayButton.layer.borderWidth = 1
        
        tgButton.layer.cornerRadius = 20
        tgButton.layer.borderColor = UIColor.yellow.cgColor
        tgButton.layer.borderWidth = 1
		
        contactButton.layer.cornerRadius = 20
        contactButton.layer.borderColor = UIColor.yellow.cgColor
        contactButton.layer.borderWidth = 1
        
        rateButton.layer.cornerRadius = 20
        rateButton.layer.borderColor = UIColor.yellow.cgColor
        rateButton.layer.borderWidth = 1
    }

    // pick up button clicked
    @IBAction func pickUpButtonClicked(_ sender: UIButton) {
        
    }

    // tournaments button clicked
    // current no button exists...
    @IBAction func tournamentButtonClicked(_ sender: UIButton) {
        
    }
    
    @IBAction func reviewAppClicked(_ sender: UIButton) {
        Answers.logContentView(withName: "Review Page View",
                               contentType: "Review Page View",
                               contentId: "7",
                               customAttributes: [:])
        
        if #available(iOS 10.3, *) {
            SKStoreReviewController.requestReview()
        } else {
            // Fallback on earlier versions
            let urlString = "https://itunes.apple.com/app/id1271793279"
            
            if let url = URL(string: urlString), UIApplication.shared.canOpenURL(url) {
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                } else {
                    UIApplication.shared.openURL(url)
                }
            }
        }
    }
    
    // compose email to me!
    @IBAction func contactButtonClicked(_ sender: UIButton) {
        Answers.logContentView(withName: "Contact Page View",
                               contentType: "Contact Page View",
                               contentId: "6",
                               customAttributes: [:])
        
        if !MFMailComposeViewController.canSendMail() {
            return
        }
        let mailVC = MFMailComposeViewController()
        mailVC.mailComposeDelegate = self
        mailVC.setToRecipients(["jdevfeedback@gmail.com"])
        
        mailVC.setSubject("App Feedback")
        mailVC.setMessageBody("Dear Developer, I have a suggestion.", isHTML: false)
        
        present(mailVC, animated: true, completion: nil)
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController,
                               didFinishWith result: MFMailComposeResult, error: Error?) {
        // Check the result or perform other tasks.
        
        // Dismiss the mail compose view controller.
        controller.dismiss(animated: true, completion: nil)
    }
	
	@IBAction func tgButtonClicked(_ sender: UIButton) {
		//may not need.
	}
	
}

