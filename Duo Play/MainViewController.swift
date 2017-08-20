//
//  ViewController.swift
//  SpikeballPlay
//
//  Created by Jordan Davis on 8/2/17.
//  Copyright © 2017 HoverSlam. All rights reserved.
//

import UIKit
import MessageUI

class ViewController: UIViewController, MFMailComposeViewControllerDelegate {

    @IBOutlet weak var randomPlayButton: UIButton!
    @IBOutlet weak var rulesButton: UIButton!
    @IBOutlet weak var contactButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        initButtonStyles()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func initButtonStyles() {
        randomPlayButton.layer.cornerRadius = 8
        randomPlayButton.layer.borderColor = UIColor.yellow.cgColor
        randomPlayButton.layer.borderWidth = 1
        
        rulesButton.layer.cornerRadius = 8
        rulesButton.layer.borderColor = UIColor.yellow.cgColor
        rulesButton.layer.borderWidth = 1
        
        contactButton.layer.cornerRadius = 8
        contactButton.layer.borderColor = UIColor.yellow.cgColor
        contactButton.layer.borderWidth = 1
    }

    // pick up button clicked
    @IBAction func pickUpButtonClicked(_ sender: UIButton) {
        
    }

    // tournaments button clicked
    // current no button exists...
    @IBAction func tournamentButtonClicked(_ sender: UIButton) {
        let tournamentsEnabled = true
        
        if !tournamentsEnabled {
            let alert = UIAlertController(title: "Coming Soon", message: "Sorry, this is not quite ready yet.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
                // cancel
                return
            }))
        
            present(alert, animated: true, completion: nil)
        } else {
//            let nextViewController = storyboard?.instantiateViewController(withIdentifier: "tournamentSplitView") as! UISplitViewController
//            self.present(nextViewController, animated:true, completion:nil)
        }
    }
    
    // compose email to me!
    @IBAction func contactButtonClicked(_ sender: UIButton) {
        if !MFMailComposeViewController.canSendMail() {
            return
        }
        let mailVC = MFMailComposeViewController()
        mailVC.mailComposeDelegate = self
        mailVC.setToRecipients(["jdevfeedback@gmail.com"])
        
        mailVC.setSubject("App Beta")
        mailVC.setMessageBody("Dear Developer, I have a suggestion.", isHTML: false)
        
        present(mailVC, animated: true, completion: nil)
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController,
                               didFinishWith result: MFMailComposeResult, error: Error?) {
        // Check the result or perform other tasks.
        
        // Dismiss the mail compose view controller.
        controller.dismiss(animated: true, completion: nil)
    }
    
}

