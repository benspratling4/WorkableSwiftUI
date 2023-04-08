//
//  InfinitelyScrollableList.swift
//  SwiftUIInfiniteScrollTester
//
//  Created by Ben Spratling on 4/7/23.
//

import Foundation
import Combine
import SwiftUI



///Wrap me in a ScrollView to use properly
///automatically causes a PagedLoadingRefreshablePublishedElementsController to loadMore()
@available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *)
public struct InfiniteLazyVStack<Element:Identifiable, ElementView:View, EmptyStateView:View, LoadingView:View, LoadedAllView:View, ErrorView:View> : View {
	
	public init(elementsController:PagedLoadingRefreshablePublishedElementsController<Element>
		 ,@ViewBuilder _ elementViewCreator:@escaping (Element)->(ElementView)
		 ,@ViewBuilder empty:@escaping()->EmptyStateView = { InfiniteLazyVStackDefaultDefaultProvider().emptyState }
		 ,@ViewBuilder loading:@escaping()->(LoadingView) = { InfiniteLazyVStackDefaultDefaultProvider().loadingView }
		 ,@ViewBuilder loadedAll:@escaping()->(LoadedAllView) = { InfiniteLazyVStackDefaultDefaultProvider().loadedAllView }
		 ,@ViewBuilder error:@escaping(Error)->(ErrorView) = { InfiniteLazyVStackDefaultDefaultProvider().errorView($0) }
		) {
		self.elementsController = elementsController
		self.elementViewCreator = elementViewCreator
		self.emptyStateViewBuilder = empty
		self.loadingViewBuilder = loading
		self.loadedAllViewBuilder = loadedAll
		self.errorViewBuilder = error
	}
	
	@ObservedObject var elementsController:PagedLoadingRefreshablePublishedElementsController<Element>
	
	@ViewBuilder var elementViewCreator:(Element)->(ElementView)
	@ViewBuilder var emptyStateViewBuilder:()->(EmptyStateView)
	@ViewBuilder var loadingViewBuilder:()->(LoadingView)
	@ViewBuilder var loadedAllViewBuilder:()->(LoadedAllView)
	@ViewBuilder var errorViewBuilder:(Error)->(ErrorView)
	
	
	//MARK: - View
	
	public var body: some View {
		LazyVStack {
			if elementsController.elements.isEmpty {
				if elementsController.isLoading {
					//empty view, because we already have a loading indicator
				}
				else if elementsController.latestLoadingError == nil {
					emptyStateViewBuilder()
				}
			}
			else {
				ForEach(elementsController.elements, content: elementViewCreator)
			}
			if let error = elementsController.latestLoadingError {
				errorViewBuilder(error)
			}
			if elementsController.canLoadMore {
				Color.clear
					.frame(height: 1.0)
					.onAppear {
						elementsController.isLoadMoreViewVisible = true
					}
					.onDisappear {
						elementsController.isLoadMoreViewVisible = false
					}
			}
			else if elementsController.latestLoadingError == nil {
				loadedAllViewBuilder()
			}
			if elementsController.isLoading {
				loadingViewBuilder()
			}
		}
		.onAppear {
			elementsController.loadMore()
		}
		.onDisappear {
			elementsController.cancelLoading()
		}
	}
}

@available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *)
public struct InfiniteLazyVStackDefaultDefaultProvider {
	
	public init() {
	}
	
	@ViewBuilder public var emptyState:some View {
		VStack {
			Spacer(minLength: 180.0)
			Image(systemName: "square.dashed")
			Spacer(minLength: 180.0)
		}
	}
	
	@ViewBuilder public var loadingView:some View {
		Image(systemName: "ellipsis")
	}
	
	@ViewBuilder public var loadedAllView:some View {
		EmptyView()
	}
	
	@ViewBuilder public func errorView(_ error:Error)-> some View {
		if let localerror = error as? LocalizedError {
			//TODO: provide customizable localizable error view
			Text(localerror.errorDescription ?? "")
		}
		else {
			Image(systemName: "exclamationmark.triangle.fill")
				.foregroundColor(.red)
		}
	}
	
}
