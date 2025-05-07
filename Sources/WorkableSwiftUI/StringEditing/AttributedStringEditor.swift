//
//  AttributedStringEditor.swift
//  WorkableSwiftUI
//
//  Created by Ben Spratling on 3/23/25.
//

import Foundation
import SwiftUI
import SwiftPatterns
import UniformTypeIdentifiers



#if canImport(UIKit)
import UIKit

/**
 Includes both the text and the selection in a single property.
 It doesn't edit an attributed string, it edits a string,
 and uses attributedStringEditorFormatter to apply attributes
 
 */
@available(iOS 15.0, *)
public struct AttributedStringEditor: View {
	
	public init(_ selectedString:Binding<SelectedString>) {
		self.selectedString = selectedString
	}
	
	var selectedString:Binding<SelectedString>
	
	
	//MARK: - View
	
	public var body: some View {
		AttributedStringEditorImpl(selectedString: selectedString)
	}
	
}



///internal implementation of the UITextView UIViewRepresentable
@available(iOS 15.0, *)
struct AttributedStringEditorImpl : UIViewRepresentable {
	
	init(selectedString: Binding<SelectedString>) {
		_selectedString = selectedString
		_stateController = .init(wrappedValue: AttributedStringEditorController() )
	}
	
	@Binding
	var selectedString:SelectedString
	
	@StateObject
	var stateController:AttributedStringEditorController
	
	@Environment(\.attributedStringEditorFormatter)
	var attributedStringEditorFormatter
	
	@Environment(\.attributedStringEditorAttributes)
	var attributedStringEditorAttributes
	
	@Environment(\.uiTextInputTraits)
	var uiTextInputTraits
	
	@Environment(\.attributedStringEditorPasteHandlers)
	var attributedStringEditorPasteHandlers
	
	
	func resolvingPasteConfiguration(textView:AttributedStringEditorTextView, context: Context) {
		let types:[String] = [UTType](attributedStringEditorPasteHandlers.keys).map(\.identifier)
		
		if let existing = textView.pasteConfiguration
			,existing.acceptableTypeIdentifiers
			.filter({
				types.contains($0)
			})
			.isEmpty  {
			let newIds = types.filter({
				!existing.acceptableTypeIdentifiers.contains($0)
			})
			if !newIds.isEmpty {
				existing.addAcceptableTypeIdentifiers(newIds)
			}
		}
		else {
			//make new configuration
			let configuration = UIPasteConfiguration(acceptableTypeIdentifiers: types)
			textView.pasteConfiguration = configuration
		}
	}
	
	
	//MARK: - UIViewRepresentable
	
	func makeUIView(context: Context) -> AttributedStringEditorTextView {
		let textView = AttributedStringEditorTextView(frame: CGRect(origin: .zero, size: CGSize(width: 300.0, height: 60.0)))
		textView.isScrollEnabled = false
		textView.translatesAutoresizingMaskIntoConstraints = false
		textView.textContainerInset = .zero
		textView.textContainer.lineFragmentPadding = 0
		textView.isEditable = true
		textView.isSelectable = true
		if #available(iOS 17.0, *) {
			textView.inlinePredictionType = .no
		}
		
		for traitApplier in uiTextInputTraits.values {
			traitApplier.applyUITrait(textView)
		}
		
		//style
		textView.isOpaque = false
		textView.backgroundColor = .clear
		
		textView.typingAttributes = attributedStringEditorAttributes
		
		let string = NSMutableAttributedString(string: selectedString.string, attributes: attributedStringEditorAttributes)
		let formatted = context.environment.attributedStringEditorFormatter?(string) ?? string
		
		stateController.formatting = context.environment.attributedStringEditorFormatter
		stateController.isUpdating = true
		
		textView.attributedText = formatted
		textView.selectedRange = selectedString.selection.map({ NSRange($0, in: formatted.string) }) ?? NSRange(location: NSNotFound, length: 0)
		stateController.isUpdating = false
		
		textView.delegate = context.coordinator
		
		resolvingPasteConfiguration(textView: textView, context: context)

		return textView
	}
	
	func updateUIView(_ uiView: AttributedStringEditorTextView, context: Context) {
		stateController.formatting = context.environment.attributedStringEditorFormatter
	
		for traitApplier in uiTextInputTraits.values {
			traitApplier.applyUITrait(uiView)
		}
		
		resolvingPasteConfiguration(textView: uiView, context: context)
		
		guard !stateController.isUpdating else {
			return
		}
		stateController.isUpdating = true
		defer {
			stateController.isUpdating = false
		}
		if uiView.text != selectedString.string {
			let original = NSAttributedString(string: selectedString.string, attributes: attributedStringEditorAttributes)
			let filtered = context.environment.attributedStringEditorFormatter?(original) ?? original
			uiView.attributedText = filtered
		}
		let currentRange = selectedString.nsRange
		if uiView.selectedRange != currentRange {
			uiView.selectedRange = currentRange
		}
	}
	
	func makeCoordinator() -> Coordinator {
		Coordinator(self)
	}
	
	@available(iOS 16.0, *)
	func sizeThatFits(_ proposal: ProposedViewSize, uiView: AttributedStringEditorTextView, context: Context) -> CGSize? {
		guard let width = proposal.width else { return nil }
		var targetSize = UIView.layoutFittingCompressedSize
		targetSize.width = width
		var size = uiView.systemLayoutSizeFitting(targetSize, withHorizontalFittingPriority: .required, verticalFittingPriority: .fittingSizeLevel)

		// iOS 16 somtimes returns 0 width from systemLayoutSizeFitting, so fix that.
		size.width = width
		size.height = max(size.height, 80.0)
		return size
	}
	
}


extension SelectedString {
	
	public init(_ attrString:NSAttributedString, range:NSRange) {
		self.string = attrString.string
		if range.location != NSNotFound
			,let range = Range<String.Index>(range, in:string) {
			self.selection = range
		}
		else {
			self.selection = nil
		}
	}
	
}


@available(iOS 15.0, *)
class AttributedStringEditorController : ObservableObject {
	
	init() {
		
	}
	
	var isUpdating:Bool = false
	var formatting:((NSAttributedString)->(NSAttributedString))?
	
}


@available(iOS 15.0, *)
extension AttributedStringEditorImpl  {
	
	class Coordinator : NSObject, UITextViewDelegate {
		
		init(_ attributedStringEditor:AttributedStringEditorImpl) {
			self.attributedStringEditor = attributedStringEditor
		}
		
		var attributedStringEditor:AttributedStringEditorImpl
		
		func respondToSelectionChange(_ textView:UITextView) {
			guard !attributedStringEditor.stateController.isUpdating else { return }
			
			if textView.selectedRange != attributedStringEditor.selectedString.nsRange {
				
				attributedStringEditor.stateController.isUpdating = true
				textView.delegate = nil
				
				let attributedString = NSAttributedString(string: textView.text, attributes: attributedStringEditor.attributedStringEditorAttributes)
				let filtered = attributedStringEditor.stateController.formatting?(attributedString) ?? attributedString
				let range = textView.selectedRange
				
				textView.attributedText = filtered
				textView.selectedRange = range
				
				attributedStringEditor.selectedString = SelectedString(filtered, range: range)
				textView.delegate = self
				
				attributedStringEditor.stateController.isUpdating = false
			}
		}
		
		
		func handlePaste(_ textView: UITextView, itemProviders:[NSItemProvider]) {
			for itemProvider in itemProviders {
				var typeHandler:(UTType, AttributedStringPasteHandler)?
				for identifier in itemProvider.registeredTypeIdentifiers {
					guard let providedType = UTType(identifier) else { continue }
					var bestType:(UTType, AttributedStringPasteHandler)?
					for (aType, pasteHandler) in self.attributedStringEditor.attributedStringEditorPasteHandlers {
						guard providedType.conforms(to: aType) else { continue }
						guard let existingBestType = bestType else {
							bestType = (aType, pasteHandler)
							continue
						}
						
						//get the more specific one
						if aType.conforms(to:existingBestType.0 ) {
							//atype is more specific
							bestType = (aType, pasteHandler)
						}
					}
					if let bestType {
						typeHandler = bestType
						break
					}
 				}
				
				guard let typeHandler else {
					//if we didn't find a handler for that item provider, that's ok, we'll paste what we can
					continue
				}
				Task {
					try await typeHandler.1.handleAttributedStringPaste(itemProvider: itemProvider, textInput: textView)
					//we don't break here other item providers may also paste
				}
				
			}
		}
		
		
		//MARK: - UITextViewDelegate
		
		func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
			true
		}
		
		func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
			true
		}
		
		func textViewDidBeginEditing(_ textView: UITextView) {
			respondToSelectionChange(textView)
		}
		
		func textViewDidEndEditing(_ textView: UITextView) {
			respondToSelectionChange(textView)
		}
		
		func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
			//multiple undos from dictation may produce incorrect ranges
			let attributedStringLength = textView.attributedText.length
			if text.isEmpty	//indicates deletion
				,NSMaxRange(range) > attributedStringLength {	//represents an error in the range values
				guard range.location < attributedStringLength else {
					//if the new selection range start is past the end of the string, we can't even.
					return false
				}
				
				let correctedRange = NSRange(
					location: range.location
					, length: attributedStringLength - range.location
				)
				
				let newAttributedString = textView.attributedText.mutableCopy() as! NSMutableAttributedString
				newAttributedString.deleteCharacters(in: correctedRange)	//inserted text is empty, so we're deleting stuff not creating it.
				textView.attributedText = newAttributedString
				return false
			}
			
			//completion spuriously calls the shouldChange multiple times with identical stuff ???
			
			return true
		}
		
		func textViewDidChange(_ textView: UITextView) {
			guard !attributedStringEditor.stateController.isUpdating else { return }

			if textView.selectedRange != attributedStringEditor.selectedString.nsRange
				|| textView.text != attributedStringEditor.selectedString.string {
				
				textView.delegate = nil
				attributedStringEditor.stateController.isUpdating = true
				
				let attributedString = NSAttributedString(string: textView.text, attributes: attributedStringEditor.attributedStringEditorAttributes)
				let filtered = attributedStringEditor.stateController.formatting?(attributedString) ?? attributedString
				
				let range = textView.selectedRange
				textView.attributedText = filtered
				textView.selectedRange = range
				
				attributedStringEditor.selectedString = SelectedString(filtered, range: range)
				
				textView.delegate = self
				attributedStringEditor.stateController.isUpdating = false
			}
		}
		
		func textViewDidChangeSelection(_ textView: UITextView) {
			respondToSelectionChange(textView)
		}
		
	}
}


@available(iOS 15.0, *)
class AttributedStringEditorTextView : UITextView {
	
	
	override func canPaste(_ itemProviders: [NSItemProvider]) -> Bool {
		//if any item provider has data for any of the types in our supported array, use it
		guard let pasteConfiguration else { return false }
		for identifier in pasteConfiguration.acceptableTypeIdentifiers {
			for itemProvider in itemProviders {
				if itemProvider.hasItemConformingToTypeIdentifier(identifier) {
					return true
				}
			}
		}
		//should we allow super here?
		return super.canPaste(itemProviders)
	}
	
	
	override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
		if action == #selector(UIResponderStandardEditActions.paste(_:)) {
			return canPaste(UIPasteboard.general.itemProviders) ?? false
		}
		else {
			return super.canPerformAction(action, withSender: sender)
		}
	}
	
	override func paste(itemProviders: [NSItemProvider]) {
//		print("paste \(itemProviders)")
		if let coordinator = delegate as? AttributedStringEditorImpl.Coordinator {
			coordinator.handlePaste(self, itemProviders: itemProviders)
		}
		else {
			super.paste(itemProviders: itemProviders)
		}
	}
	
	override func paste(_ sender: Any?) {
//		print("paste(sender)")
		if let coordinator = delegate as? AttributedStringEditorImpl.Coordinator {
			coordinator.handlePaste(self, itemProviders: UIPasteboard.general.itemProviders)
		}
		else {
			super.paste(sender)
		}
	}
	
	open override var canBecomeFirstResponder: Bool {
		true
	}
	
	open override var intrinsicContentSize: CGSize {
		let width = bounds.width
		var size = sizeThatFits(CGSize(width: width, height: .infinity))
		size.width = width
		return size
	}
	
}

#endif
