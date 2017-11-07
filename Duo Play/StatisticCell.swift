//
//  StatisticCell.swift
//  SpikeballPlay
//
//  Created by Jordan Davis on 8/5/17.
//  Copyright © 2017 HoverSlam. All rights reserved.
//

import Foundation
import UIKit

class StatisticCell : UITableViewCell {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var winLabel: UILabel!
    @IBOutlet weak var lossLabel: UILabel!
    @IBOutlet weak var pointsForLabel: UILabel!
    @IBOutlet weak var pointsAgainstLabel: UILabel!
    @IBOutlet weak var pointsDifferentialLabel: UILabel!
    @IBOutlet weak var matchDifficultyLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    var name: String? {
        didSet {
            nameLabel.text = name
        }
    }
    
    var wins: String? {
        didSet {
            winLabel.text = wins
        }
    }
    
    var losses: String? {
        didSet {
            lossLabel.text = losses
        }
    }
    
    var pointsFor: String? {
        didSet {
            pointsForLabel.text = pointsFor
        }
    }
    
    var pointsAgainst: String? {
        didSet {
            pointsAgainstLabel.text = pointsAgainst
        }
    }
    
    var pointsDifferential: String? {
        didSet {
            pointsDifferentialLabel.text = pointsDifferential
        }
    }
    
    var matchDifficulty: String? {
        didSet {
            matchDifficultyLabel.text = matchDifficulty
        }
    }
}
