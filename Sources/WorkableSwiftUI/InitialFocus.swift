//
//  InitialFlcus.swift
//  WorkableSwiftUI
//
//  Created by Ben Spratling on 3/22/25.
//

import SwiftUI




@available(iOS 15.0, *)
extension View {
	
	/**
	 
	 Since iOS 15 doesn't handle setting FocusState correctly in onAppear,
	 This method introduces a 0.75 second delay on iOS 15 using the Main DispatchQueue.
	 
	 Usage:
	 
	 ```swift
	 struct MyView : View {
		@State var textOne = ""
		@State var textTwo = ""
		@FocusState var whichField:WhichField?
	 
		var body:some View {
			VStack {
				TextField($textOne)
					.focussed($whichField, .one)
				TextField($textTwo)
					.focussed($whichField, .two)
			}
			.initialFocus($whichField, .one)
		}
	 }
	 
	 enum WhichField : Hashabble {
		case one
		case two
	 }
	 ```
	 
	 */
	public func initialFocus<Value:Hashable>(_ focusStateBinding:FocusState<Value>.Binding, _ initialValue:Value) -> some View {
		modifier(InitialFocusViewModifier(binding: focusStateBinding, initialValue: initialValue))
	}
	
}


@available(iOS 15.0, *)
struct InitialFocusViewModifier<Value:Hashable> : ViewModifier {
	
	var binding:FocusState<Value>.Binding
	var initialValue:Value
	
	@ViewBuilder @MainActor @preconcurrency
	func body(content: Content) -> some View {
		content
			.onAppear() {
				if #available(iOS 16.0, *) {
					binding.wrappedValue = initialValue
				}
				else {
					DispatchQueue.main.asyncAfter(wallDeadline: .now() + 0.75) {
						binding.wrappedValue = initialValue
					}
				}
			}
	}
	
	
}
