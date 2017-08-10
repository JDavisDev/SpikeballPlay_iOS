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

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    @IBAction func tournamentButtonClicked(_ sender: UIButton) {
        let alert = UIAlertController(title: "Coming Soon", message: "Sorry, this is not quite ready yet.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
            // cancel
            return
        }))
        
        present(alert, animated: true, completion: nil)
    }
    
    
    @IBAction func randomPlayButtonClicked(_ sender: UIButton) {
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

