//
//  View+modifying.swift
//  WorkableSwiftUI
//
//  Created by Ben Spratling on 3/27/25.
//

import SwiftUI





extension View {
	
	/**
	 You can't insert compiler directives into modify chains, so this allows a closure containing compiler directives.
	 
	 Example usage:
	 
	 ```swift
		AttributedStringEditor($editBleText)
			.modifying {
				if #available(iOS 17.0, *) {
					$0.inlinePredictionType(.no)
				} else {
					$0
				}
			}
	 ```
	 */
	public func modifying<V:View>(@ViewBuilder _ block:(AnyView)->V)->some View {
		block(AnyView(self))
	}
	
}
