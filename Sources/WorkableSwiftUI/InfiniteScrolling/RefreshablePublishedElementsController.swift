//
//  RefreshablePublishedElementsController.swift
//  SwiftUIInfiniteScrollTester
//
//  Created by Ben Spratling on 4/7/23.
//

import Foundation
import Combine


open class RefreshablePublishedElementsController<Element> : PublishedElementsController<Element> where Element : Identifiable {
	
	///override me
	@MainActor open func refresh() {
		guard !isRefreshing else { return }
		isRefreshing = true
	}
	
	@MainActor @Published open private(set) var isRefreshing:Bool = false
	
	@MainActor open func didCompleteRefresh() { isRefreshing = false }
}

