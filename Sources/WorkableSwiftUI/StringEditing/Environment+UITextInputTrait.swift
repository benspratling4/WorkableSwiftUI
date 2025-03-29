//
//  Environment+UITextInputTraits.swift
//  WorkableSwiftUI
//
//  Created by Ben Spratling on 3/28/25.
//

import Foundation
import UIKit
import SwiftUI



#if canImport(UIKit)
import UIKit

extension View {
	
	/**
	 SwiftUI has modifiers for many of the SwiftUI versions of the properties in UITextInputTraits
	 but won't provide the values to be read from the EnvironmentValues
	 So wrapping custom views in UIViewRepresentable means we can't use any standard SwiftUI properties.
	 Instead of declaring them all individually, this is one modifer for a collection of UITextInputTraits
	 wrapped up in a type-erased container.
	 
	 Example usage:
	 
	 ```swift
	 AttributedStringEditor($test)
		.uiTextInputTrait(\UITextView.spellCheckingType, value:.no)
		.uiTextInputTrait(\UITextView.autocapitalizationType, value:.words)
	 ```
	 */
	
	public func uiTextInputTrait<R:UITextInputTraits, V:Hashable>(_ keyPath:ReferenceWritableKeyPath<R, V>, value:V)->some View {
		transformEnvironment(\.uiTextInputTraits) { traits in
			traits[keyPath as AnyKeyPath] = UITextInputTraitsApplier(keyPath: keyPath, value: value)
		}
	}
	
}


extension EnvironmentValues {
	public var uiTextInputTraits:[AnyKeyPath:any UITraitApplying] {
		get { self[TextInputTraitKey.self] }
		set { self[TextInputTraitKey.self] = newValue }
	}
}


struct TextInputTraitKey:EnvironmentKey {
	static let defaultValue:[AnyKeyPath:any UITraitApplying] = [:]
}


public protocol UITraitApplying : Equatable, Hashable {
	func applyUITrait(_ textinput:UITextInputTraits)
	
	static var rootType: any Any.Type { get }

	static var valueType: any Any.Type { get }
	
	func isEqualTo(_ other:any UITraitApplying)->Bool
}


extension UITraitApplying {
	
	public static func ==(lhs:any UITraitApplying, rhs:any UITraitApplying)->Bool {
		lhs.isEqualTo(rhs)
	}
	
}

///Type-erases a UITraitApplying
public struct UITextInputTraitsApplier<R:UITextInputTraits, V:Hashable>:UITraitApplying, Hashable {
	
	public init(keyPath:ReferenceWritableKeyPath<R, V>, value:V){
		self.keyPath = keyPath
		self.value = value
	}
	
	public var keyPath:ReferenceWritableKeyPath<R, V>
	public var value:V
	
	
	//MARK: - UITraitApplying
	
	public func applyUITrait(_ textinput:UITextInputTraits) {
		guard let traitor = textinput as? R else { return }
		if traitor[keyPath:keyPath] != value {
			traitor[keyPath:keyPath] = value
		}
	}
	
	public static var rootType: any Any.Type {
		R.self
	}

	public static var valueType: any Any.Type {
		V.self
	}
	
	public func isEqualTo(_ other:any UITraitApplying)->Bool {
		guard let other = other as? UITextInputTraitsApplier<R, V> else {
			return false
		}
		
		return self.keyPath == other.keyPath && self.value == other.value
	}
	
}

#endif
