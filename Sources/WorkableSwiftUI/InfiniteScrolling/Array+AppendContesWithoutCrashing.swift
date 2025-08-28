//
//  Array+AppendContesWithoutCrashing.swift
//  SwiftUIInfiniteScrollTester
//
//  Created by Ben Spratling on 4/7/23.
//

import Foundation


extension Array where Element : Identifiable {
	
	public mutating func appendContentsWithoutCrashingFromDuplicates(_ contents:[Element]) {
		var allIds:Set<Element.ID> = Set(self.map({ $0.id }))
		for item in contents {
			if !allIds.contains(item.id) {
				self.append(item)
				allIds.insert(item.id)
			}
		}
	}
	
	
	public mutating func prependContentsWithoutCrashingFromDuplicates(_ contents:[Element]) {
		var allIds:Set<Element.ID> = Set(self.map({ $0.id }))
		for item in contents.reversed() {
			if !allIds.contains(item.id) {
				self.insert(item, at: 0)
				allIds.insert(item.id)
			}
		}
	}
	
}
