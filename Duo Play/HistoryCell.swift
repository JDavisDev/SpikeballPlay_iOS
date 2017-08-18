//
//  HistoryCell.swift
//  SpikeballPlay
//
//  Created by Jordan Davis on 8/6/17.
//  Copyright © 2017 HoverSlam. All rights reserved.
//

import UIKit

class HistoryCell: UITableViewCell {

    @IBOutlet weak var playerOneLabel: UILabel!
    @IBOutlet weak var teamOneScoreLabel: UILabel!
    @IBOutlet weak var teamTwoScoreLabel: UILabel!
    @IBOutlet weak var playerTwoLabel: UILabel!
    @IBOutlet weak var playerThreeLabel: UILabel!
    @IBOutlet weak var playerFourLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    var playerOne: String? {
        didSet {
            playerOneLabel.text = playerOne
        }
    }
    
    var playerTwo: String? {
        didSet {
            playerTwoLabel.text = playerTwo
        }
    }
    
    var playerThree: String? {
        didSet {
            playerThreeLabel.text = playerThree
        }
    }
    
    var playerFour: String? {
        didSet {
            playerFourLabel.text = playerFour
        }
    }
    
    var teamOneScore: String? {
        didSet {
            teamOneScoreLabel.text = teamOneScore
        }
    }
    
    var teamTwoScore: String? {
        didSet {
            teamTwoScoreLabel.text = teamTwoScore
        }
    }

}
