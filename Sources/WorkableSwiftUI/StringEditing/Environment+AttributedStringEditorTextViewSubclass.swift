//
//  Environment+AttributedStringEditorTextViewSubclass.swift
//  WorkableSwiftUI
//
//  Created by Ben Spratling on 8/27/25.
//

import SwiftUI

#if canImport(UIKit)

@available(iOS 15.0, *)
public extension View {
	/**
	 AttributedStringEditor uses AttributedStringEditorTextView as it's internal UITextView subclass.
	 If you need to subclass it, you can provide your subclass information via this modifier.
	 
	 ```
	 class MyCustomTextEditorClass : AttributedStringEditorTextView {
		override init(frame: CGRect, textContainer: NSTextContainer?) {
			...
		}
	 }
	 
	 ...
	 
	 AttributedStringEditor(......)
		.attributedStringEditorSubclass(MyCustomTextEditorClass.self)
	 ```
	 */
	func attributedStringEditorSubclass(_ subclass:AttributedStringEditorTextView.Type) -> some View {
		environment(\.attributedStringEditorSubclass, subclass)
	}
}

@available(iOS 15.0, *)
extension EnvironmentValues {
	
	var attributedStringEditorSubclass:AttributedStringEditorTextView.Type? {
		get { self[AttributedStringEditorTextViewSubclassEnvironmentKey.self] }
		set { self[AttributedStringEditorTextViewSubclassEnvironmentKey.self] = newValue }
	}
	
}

@available(iOS 15.0, *)
struct AttributedStringEditorTextViewSubclassEnvironmentKey: EnvironmentKey {
	
	static let defaultValue: AttributedStringEditorTextView.Type? = nil
}

#endif
