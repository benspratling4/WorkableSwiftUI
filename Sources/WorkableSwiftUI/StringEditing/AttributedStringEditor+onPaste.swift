//
//  AttributedStringEditor+onPaste.swift
//  WorkableSwiftUI
//
//  Created by Ben Spratling on 3/30/25.
//

import Foundation
import UniformTypeIdentifiers
import SwiftUI



#if canImport(UIKit)
import UIKit
import SwiftPatterns

/**
 to prevent environment thrash, these are objects not closures
 */
public protocol AttributedStringPasteHandler : AnyObject {
	
	func handleAttributedStringPaste(itemProvider:NSItemProvider, textInput:UITextInput&UIPasteConfigurationSupporting)async throws
	
}


@available(iOS 15.0, *)
extension View {
	
	public func attributedStringEditorPasteHandler(_ type:UTType, _ handler:AttributedStringPasteHandler)->some View {
		transformEnvironment(\.attributedStringEditorPasteHandlers) { dict in
			dict[type] = handler
		}
	}
	
}


@available(iOS 15.0, *)
extension EnvironmentValues {
	
	public var attributedStringEditorPasteHandlers: [UTType:AttributedStringPasteHandler] {
		get {
			self[AttributedStringEditorPastehandlerKey.self]
		} set {
			self[AttributedStringEditorPastehandlerKey.self] = newValue
		}
	}
	
}


@available(iOS 15.0, *)
struct AttributedStringEditorPastehandlerKey: EnvironmentKey {
	
	@usableFromInline
	static let defaultValue: [UTType:AttributedStringPasteHandler] = [
		.plainText:SimpleTextPasteHandler(),
	]
	
	//provide defaults for plain strings
	
}


@available(iOS 15.0, *)
open class SimpleTextPasteHandler: AttributedStringPasteHandler {
	
	public init() {
		
	}
	
	open func handleAttributedStringPaste(itemProvider:NSItemProvider, textInput:UITextInput&UIPasteConfigurationSupporting)async throws {
		//TODO: replace me with UITextInput generic implementation
		guard let textView = textInput as? UITextView else { return }
		guard itemProvider.hasItemConformingToTypeIdentifier(UTType.plainText.identifier) else { return }
		
		let data = try await withUnsafeThrowingContinuation { continuation in
			
			//TODO: handle Progress?
			
			_ = itemProvider.loadDataRepresentation(forTypeIdentifier: UTType.plainText.identifier) { dataOrNil, errorOrNil in
				if let data = dataOrNil {
					continuation.resume(returning: data)
				}
				else if let error = errorOrNil {
					continuation.resume(throwing: error)
				}
				else {
					continuation.resume(throwing: CocoaError(.fileReadUnknown))
				}
			}
		}
		
		guard let string = String(data: data, encoding: .utf8) else {
			throw DecodingError.dataCorrupted(.init(codingPath: [], debugDescription: "was not UTF8"))
		}
		await MainActor.run {
			
			//TODO: refactor to use UITextInput reference
			
			let stringToInsert = NSAttributedString(string: string, attributes: textView.typingAttributes)
			let newString = textView.attributedText.mutableCopy() as! NSMutableAttributedString
			let newIndex = newString.replaceWithPrecautionaryWhitespace(stringToInsert, at: textView.selectedRange)
			textView.attributedText = newString
			textView.selectedRange = NSRange(location: newIndex, length: 0)
		}
	}
}



#endif
