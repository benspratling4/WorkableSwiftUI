//
//  AttributedStringEditor+defaultAttributes.swift
//  WorkableSwiftUI
//
//  Created by Ben Spratling on 3/27/25.
//

import Foundation
import SwiftUI




@available(iOS 3.2, *)
extension View {
	
	/**
	 Provide default attributed string attributes to AttributedStringEditor
	 
	 Sample usage:
	 
	 ```swift
	 AttributedStringEditor($text)
		 .attributedStringEditorAttributes([
			 .font:UIFont.systemFont(ofSize: 17),
			 .foregroundColor:UIColor.label
		 ])
	 ```
	 */
	public func attributedStringEditorAttributes(_ attributes: [NSAttributedString.Key : Any]) -> some View {
		transformEnvironment(\.attributedStringEditorAttributes) { priorAttributes in
			priorAttributes.merge(attributes) { (_, new) in new }
		}
	}
	
}

@available(iOS 3.2, *)
extension EnvironmentValues {
	
	public var attributedStringEditorAttributes: [NSAttributedString.Key : Any] {
		get {
			self[AttributedStringEditorAttributesKey.self]
		} set {
			self[AttributedStringEditorAttributesKey.self] = newValue
		}
	}
	
}

@available(iOS 3.2, *)
struct AttributedStringEditorAttributesKey: EnvironmentKey {
	
	@usableFromInline
	static let defaultValue: [NSAttributedString.Key : Any] = [:]
}
