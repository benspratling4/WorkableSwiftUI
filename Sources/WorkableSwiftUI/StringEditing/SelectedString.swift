//
//  EditableText.swift
//  WorkableSwiftUI
//
//  Created by Ben Spratling on 3/25/25.
//

import Foundation


public struct SelectedString : Hashable {
	
	public init(
		string:String
		,selection: Range<String.Index>?
	) {
		self.string = string
		self.selection = selection
	}
	
	public var string: String
	public var selection: Range<String.Index>?
	
}

extension SelectedString {
	
	public var nsRange:NSRange {
		selection
			.flatMap({
				NSRange($0, in:string)
			})
		?? NSRange(location: NSNotFound, length: 0)
	}
	
}
