//
//  Array+AppendContesWithoutCrashing.swift
//  SwiftUIInfiniteScrollTester
//
//  Created by Ben Spratling on 4/7/23.
//

import Foundation


extension Array where Element : Identifiable {
	
	mutating func appendContentsWithoutCrashingFromDuplicates(_ contents:[Element]) {
		var allIds:Set<Element.ID> = Set(self.map({ $0.id }))
		for item in contents {
			if !allIds.contains(item.id) {
				self.append(item)
				allIds.insert(item.id)
			}
		}
	}
	
}
