//
//  AttributedStringEditor+onChange.swift
//  WorkableSwiftUI
//
//  Created by Ben Spratling on 3/27/25.
//

import Foundation
import SwiftUI



@available(iOS 3.2, *)
extension View {
	/**
	 Apply attributes to the string before it is displayed.
	 Default attributes will already be applied.
	 Do not attempt to change state in this block.
	 Be efficient, this is called for every change.
	 
	 You may chain multiple of these, they do not replace each other, they are called in order.
	 
	 Example usage:
	 
	 ```swift
	 let limit = 200
	 
	 AttributedStringEditor($text)
		.attributedStringEditorFormatter { text in
			guard remainingCharacterCount < 0 else {
				return self
			}
			let changedText = mutableCopy() as! NSMutableAttributedString
			let mergedRange = NSRange(changedText.string.startIndex..<changedText.string.index(changedText.string.startIndex, offsetBy: limit), in:changedText.string)
			let redRange = NSRange(location: mergedRange.upperBound, length: changedText.length - mergedRange.upperBound)
			changedText.addAttribute(.backgroundColor, value: UIColor.red.withAlphaComponent(0.2), range: redRange)
	 
			return changedText
		}
	 ```
	 */
	public func attributedStringEditorFormatter(_ handler:@escaping(NSAttributedString)->(NSAttributedString))-> some View {
		transformEnvironment(\.attributedStringEditorFormatter) { environmentValue in
			if let existing = environmentValue {
				environmentValue = { newValue in
					existing(
						handler(newValue)
					)
				}
			}
			else {
				environmentValue = handler
			}
		}
	}
	
}


@available(iOS 3.2, *)
extension EnvironmentValues {
	public var attributedStringEditorFormatter : ((NSAttributedString)->(NSAttributedString))? {
		get {
			self[AttributedStringEditorAttributerKey.self]
		} set {
			self[AttributedStringEditorAttributerKey.self] = newValue
		}
	}
}


@available(iOS 3.2, *)
struct AttributedStringEditorAttributerKey : EnvironmentKey {
	static let defaultValue : ((NSAttributedString)->(NSAttributedString))? = nil
}
