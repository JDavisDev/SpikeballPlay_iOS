//
//  BracketMatchCell.swift
//  Duo Play
//
//  Created by Jordan Davis on 6/12/18.
//  Copyright © 2018 Jordan Davis. All rights reserved.
//

import Foundation
import UIKit

class BracketMatchCell : UIView {
	static let width = 200
	static let height = 100
	
	@IBOutlet var contentView: UIView!
	@IBOutlet weak var teamOneLabel: UILabel!
	@IBOutlet weak var teamTwoLabel: UILabel!
	@IBOutlet weak var teamTwoWinsLabel: UILabel!
	@IBOutlet weak var teamOneWinsLabel: UILabel!
	@IBOutlet weak var teamTwoWinnerBackground: UIView!
	@IBOutlet weak var teamOneWinnerBackground: UIView!
	@IBOutlet weak var horizontalLine: UIView!
	
	@IBOutlet weak var verticalLine: UIView!
	override init(frame: CGRect) {
		super.init(frame: frame)
		commonInit()
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		commonInit()
	}
	
	func commonInit() {
		let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.dark)
		let blurEffectView = UIVisualEffectView(effect: blurEffect)
		blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
		
		Bundle.main.loadNibNamed("BracketMatchupCellView", owner: self, options: nil)
		addSubview(contentView)
		contentView.addSubview(blurEffectView)
		contentView.frame = self.bounds
		contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
	}
	
	func setWinnerCell(isWinnerCell: Bool) {
		if isWinnerCell {
			self.teamTwoLabel.text = "Champion"
			self.teamTwoLabel.textColor = UIColor.yellow
			self.teamTwoWinsLabel.isHidden = true
			self.teamOneWinsLabel.isHidden = true
			self.teamTwoWinnerBackground.isHidden = true
			self.teamOneWinnerBackground.isHidden = true
			self.verticalLine.isHidden = true
		}
	}
	
	func setTeamOneWinner() {
		teamOneWinnerBackground.backgroundColor = UIColor.yellow
		teamTwoWinnerBackground.backgroundColor = UIColor.darkGray
	}
	
	func setTeamTwoWinner() {
		teamTwoWinnerBackground.backgroundColor = UIColor.yellow
		teamOneWinnerBackground.backgroundColor = UIColor.darkGray
	}
}
