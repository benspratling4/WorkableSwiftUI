//
//  LoadingTokenBasedPagedLoadingRefreshableArrayDataController.swift
//  SwiftUIInfiniteScrollTester
//
//  Created by Ben Spratling on 4/7/23.
//

import Foundation
import Combine


///If your PagedLoadingRefreshableArrayDataController needs to track an arbitrary piece of data to feed to fetch the next page, that's a "loading token"
///store it in var nextLoadToken, and canLoadMore will be updated for you
///When you no longer have one, then you cannot load more data
open class LoadingTokenBasedPagedLoadingRefreshablePublishedElementsController<Element, LoadToken> : PagedLoadingRefreshablePublishedElementsController<Element> where Element : Identifiable {
	
	///anything that is needed to send to a service so it know which thing to fetch next
	@MainActor @Published open var nextLoadToken:LoadToken? {
		didSet {
			canLoadMore = nextLoadToken != nil
		}
	}
	
	
	//MARK: - RefreshablePublishedElementsController overrides
	
	@MainActor open override func refresh() {
		guard !isLoading else { return }
		//clear the loading token so the service will fetch the first page
		nextLoadToken = nil
		canLoadMore = true	//necessary because nextLoadToken = nil will set this to false normally
		super.refresh()
	}
	
}
