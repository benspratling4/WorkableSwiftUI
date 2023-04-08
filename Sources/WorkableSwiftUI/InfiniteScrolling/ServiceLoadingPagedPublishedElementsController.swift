//
//  InfiniteScrollDataController.swift
//  SwiftUIInfiniteScrollTester
//
//  Created by Ben Spratling on 4/7/23.
//

import Foundation
import Combine
import SwiftUI


/// A PagedLoadingRefreshablePublishedElementsController that uses a DataFetchingService to get elements and loading tokens
open class ServiceLoadingPagedPublishedElementsController<Element, LoadToken, DataService:DataPageFetchingService>
	: LoadingTokenBasedPagedLoadingRefreshablePublishedElementsController<Element, LoadToken>
	where Element : Identifiable
		, DataService.Element == Element
		, DataService.LoadMoreToken == LoadToken {
	
	public init(service:DataService) {
		self.service = service
	}
	
	@MainActor open override func loadMore() {
		//don't have simultaneous loading events
		guard !isLoading
				//don't load if we know we're at the end
			,canLoadMore
			else { return }
		isLoading = true
		let token = nextLoadToken
		task = Task.detached() {
			do {
				let (newElements, newLoadToken) = try await self.service.fetchDataPage(after:token)
				await MainActor.run(body: {
					self.nextLoadToken = newLoadToken
					self.latestLoadingError = nil
					self.appendPageOfElements(newElements)
					self.didCompleteLoad()
				})
			} catch {
				await MainActor.run(body: {
					self.latestLoadingError = error
					//nextLoadToken is not changed, because presumably, we could call it again
					self.didCompleteLoad()
				})
			}
		}
	}
	
	private var task:Task<Void, Error>?
	
	public let service:DataService
	
	//MARK: - LoadingTokenBasedPagedLoadingRefreshablePublishedElementsController overrides
			
	@MainActor open override func didCompleteLoad() {
		task = nil
		super.didCompleteLoad()
	}
	
	@MainActor open override func cancelLoading() {
		task?.cancel()
	}
	
}
