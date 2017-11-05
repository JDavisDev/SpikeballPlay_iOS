//
//  RulesWebView.swift
//  SpikeballPlay
//
//  Created by Jordan Davis on 8/4/17.
//  Copyright © 2017 HoverSlam. All rights reserved.
//

import Foundation
import UIKit
import Crashlytics

class RulesWebView : UIViewController{
    
    @IBOutlet weak var webView: UIWebView!
    let url = "https://usaspikeball.com/official-rules"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Answers.logContentView(withName: "Rules Page View",
                               contentType: "Rules Page View",
                               contentId: "5",
                               customAttributes: [:])
        let requestURL = URL(string:url)
        let request = URLRequest(url: requestURL!)
        webView.loadRequest(request)
    }
}
