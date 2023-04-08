//
//  DataFecthingService.swift
//  SwiftUIInfiniteScrollTester
//
//  Created by Ben Spratling on 4/7/23.
//

import Foundation


public protocol DataPageFetchingService<Element, LoadMoreToken> : AnyObject  {
	
	associatedtype Element:Identifiable
	associatedtype LoadMoreToken
	
	func fetchDataPage(after token:LoadMoreToken?)async throws->([Element], LoadMoreToken?)
	
}

