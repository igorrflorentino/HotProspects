//
//  Prospect.swift
//  HotProspects
//
//  Created by Igor Florentino on 31/07/24.
//

import Foundation
import SwiftData

@Model
class Prospect {
	var name: String
	var emailAddress: String
	var isContacted: Bool
	var dateAdded: Date
	
	init(name: String, emailAddress: String, isContacted: Bool, dateAdded: Date = .now) {
		self.name = name
		self.emailAddress = emailAddress
		self.isContacted = isContacted
		self.dateAdded = dateAdded
	}
}
