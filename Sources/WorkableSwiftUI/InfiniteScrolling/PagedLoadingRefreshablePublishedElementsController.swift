//
//  PagedLoadingRefreshableArrayDataController.swift
//  SwiftUIInfiniteScrollTester
//
//  Created by Ben Spratling on 4/7/23.
//

import Foundation
import Combine


open class PagedLoadingRefreshablePublishedElementsController<Element> : RefreshablePublishedElementsController<Element> where Element : Identifiable {
	
	///set from your View onAppear / onDisappear
	@MainActor open var isLoadMoreViewVisible:Bool = true {
		didSet {
			//if the load more cell becomes visible, load something
			if isLoadMoreViewVisible
				,oldValue == false {
				loadMore()
			}
		}
	}
	
	///override me, and call didCompleteLoad() when done
	//TODO: is there a way to force overrides to call didCompleteLoad(), like make it async?  then
	@MainActor open func loadMore() { }
	
	///override me
	@MainActor open func cancelLoading() { }
	
	//override me if you need to change how each new page of elements is added to the elements array
	@MainActor open func appendPageOfElements(_ newPage:[Element]) {
		if isRefreshing {
			elements = []
		}
		if prepends {
			elements.prependContentsWithoutCrashingFromDuplicates(newPage)
		}
		else {
			elements.appendContentsWithoutCrashingFromDuplicates(newPage)
		}
	}
	
	@MainActor open func didCompleteLoad() {
		isLoading = false
		if isRefreshing {
			didCompleteRefresh()
		}
		triggerFetchMoreIfNeeded()
	}
	
	
	///if set to true, appendPageOfElements(...) will prepend elements instead of appending
	public var prepends:Bool = false
	
	//TODO: cancel loading
	
	///set is open so subclasses from other modules can participate, but in general you should not set this directly, let loadMore() and didCompleteLoad() do that
	@MainActor @Published open var isLoading:Bool = false
	
	///whether the loadMore() function can be called and expect to get more data,
	@MainActor @Published open var canLoadMore:Bool = true
	
	//cleared at the end of each loadMore, this reflects an error if one was thrown by the loadMore
	@MainActor @Published open var latestLoadingError:Error?
	
	///this is called by didCompleteLoad(), and will call loadMore() if canLoadMore and latestLoadingError == nil
	@MainActor func triggerFetchMoreIfNeeded() {
		guard isLoadMoreViewVisible
			,latestLoadingError == nil
			else { return }
		loadMore()
	}
	
	
	//MARK: - RefreshablePublishedElementsController overrides
	
	@MainActor open override func refresh() {
		super.refresh()
		loadMore()
	}
	
}
