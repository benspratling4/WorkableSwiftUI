//
//  IdentifiedTests.swift
//  IdentifiedTests
//
//  Created by Ben Spratling on 10/15/21.
//

import Foundation
import XCTest
@testable import WorkableSwiftUI


fileprivate struct ASampleStruct : Equatable, Codable {
	var name:String
}


final class IdentifiedTests: XCTestCase {
	
	func testIdentifiedSingleInstanceDecode() {
		let contents:String = """
			{"name":"Title"}
			"""
		let data:Data = contents.data(using: .utf8)!
		let deserialized:Identified<ASampleStruct> = try! JSONDecoder().decode(Identified<ASampleStruct>.self, from: data)
		XCTAssertEqual(deserialized.wrappedValue, ASampleStruct(name: "Title"))
	}
	
	func testIdentifiedSingleInstanceEncode() throws {
		let instance:Identified<ASampleStruct> = Identified(ASampleStruct(name: "Title"))
		let encodedData:Data = try JSONEncoder().encode(instance)
		guard let encodedString:String = String(data: encodedData, encoding: .utf8) else {
			XCTFail("could not string from encoded data")
			return
		}
		XCTAssertEqual(encodedString, """
		{"name":"Title"}
		""")
	}
	
	func testArrayMethods() {
		var items:[Identified<ASampleStruct>] = []
		items.insert(ASampleStruct(name: "Title 1"), at: 0)
		XCTAssertEqual(items.count, 1)
		
		items.insert(ASampleStruct(name: "Title 2"), at: 1)
		XCTAssertEqual(items.count, 2)
		
		let pulledItem1:ASampleStruct = items[1].wrappedValue
		XCTAssertEqual(pulledItem1.name, "Title 2")
		
		items.append(ASampleStruct(name: "Title 3"))
		let pulledItem2:ASampleStruct = items[2].wrappedValue
		XCTAssertEqual(pulledItem2.name, "Title 3")
		
//		items[2] = ASampleStruct(name: "Title 3B")
		
	}
	
}
