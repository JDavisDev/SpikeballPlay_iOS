//
//  Division.swift
//  Duo Play
//
//  Created by Jordan Davis on 6/11/18.
//  Copyright © 2018 Jordan Davis. All rights reserved.
//

import Foundation

enum Division: String {
	case Advanced = "Advanced"
	case Premier = "Premier"
	case Womens = "Womens"
	case Intermediate = "Intermediate"
	case Pro = "Pro"
	case Beginner = "Beginner"
	case CoEd = "CoEd"
	
	func value() -> String {
		return self.rawValue
	}
	
	static let allValues = [Advanced, Premier, Womens, Intermediate, Pro, Beginner, CoEd]
}

