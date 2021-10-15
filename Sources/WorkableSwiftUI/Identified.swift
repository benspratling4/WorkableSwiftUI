//
//  File.swift
//  File
//
//  Created by Ben Spratling on 10/15/21.
//

import Foundation

///wrapper to support extensions to generics
public protocol Identifying : Identifiable {
	associatedtype Value
	var wrappedValue:Value { get }
	init(_ wrappedValue:Value)
	init(_ wrappedValue:Value, id:String)
}


///Identified is useful to wrap position-dependent value types where SwiftUI needs something "Identifiable"
///It creates its own id values with UUID, but doesn't encode those values, and can decode merely its contents
///these id's won't persist
public struct Identified<Value> : Identifying {
	public var id:String
	public var wrappedValue:Value
	public init(_ wrappedValue:Value) {
		self.id = UUID().uuidString
		self.wrappedValue = wrappedValue
	}
	
	public init(_ wrappedValue:Value, id:String) {
		self.id = id
		self.wrappedValue = wrappedValue
	}
}

extension Identified : Encodable where Value : Encodable {
	public func encode(to encoder: Encoder) throws {
		var container = encoder.singleValueContainer()
		try container.encode(wrappedValue)
	}
}

extension Identified : Decodable where Value : Decodable {
	public init(from decoder: Decoder) throws {
		let container = try decoder.singleValueContainer()
		wrappedValue = try container.decode(Value.self)
		id = UUID().uuidString
	}
}

extension Identified : Equatable where Value : Equatable {
	public static func ==(lhs:Identified<Value>, rhs:Identified<Value>)->Bool {
		return lhs.wrappedValue == rhs.wrappedValue
	}
}

extension Identified : Hashable where Value : Hashable {
	public func hash(into hasher: inout Hasher) {
		wrappedValue.hash(into: &hasher)
	}
}

extension Identified : Comparable where Value : Comparable {
	public static func < (lhs: Self, rhs: Self) -> Bool {
		return lhs.wrappedValue < rhs.wrappedValue
	}
}


extension Collection where Element : Identifying {
	/*  Can't do this because somehow Self.Index is related to the type of the thing being inserted.....???
	subscript(position: Self.Index) -> Self.Element.Value {
		get {
			return self[position].wrappedValue
		}
		set {
			self[position] = Element(newValue)
		}
	}*/
}


///for convenience, enable [Identified<SomeType>] to work as if it is a [SomeType]
extension Array where Element : Identifying {
	
	public init<S>(_ elements: S) where S : Sequence, Element.Value == S.Element {
		self = elements.map({ Element($0) })
	}
	
	public mutating func insert(_ newElement: Element.Value, at i: Int) {
		insert(Element(newElement), at: i)
	}
	
	public mutating func remove(at position: Int) -> Element.Value {
		return remove(at: position).wrappedValue
	}
	public mutating func append<S>(contentsOf newElements: S) where S : Sequence, Element.Value == S.Element {
		append(contentsOf: Self(newElements))
	}
	
	public mutating func append(_ element:Element.Value) {
		append(Element.init(element))
	}
	
	public subscript(bounds: Range<Int>) -> Array<Element.Value> {
		return self[bounds].map({ $0.wrappedValue })
	}
	
	//somehow the compiler is just not ok with ever picking this one
	public subscript(index: Int) -> Element.Value {
		get {
			return self[index].wrappedValue
		}
		set {
			self[index] = Element.init(newValue)
		}
	}
	
}
