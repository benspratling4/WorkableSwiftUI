//
//  PublishedElementsController.swift
//  SwiftUIInfiniteScrollTester
//
//  Created by Ben Spratling on 4/7/23.
//

import Foundation
import Combine


open class PublishedElementsController<Element> : ObservableObject where Element : Identifiable {
	
	public init() {
	}
	
	@MainActor @Published open var elements:[Element] = []
}
