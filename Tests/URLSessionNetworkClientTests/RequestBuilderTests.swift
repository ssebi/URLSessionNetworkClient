//
//  RequestBuilderTests.swift
//  
//
//  Created by Sebastian Vidrea on 25.09.2021.
//

import XCTest
import URLSessionNetworkClient

class RequestBuilderTests: XCTestCase {

	func test_toURLRequest_correctlyBuildsHTTPMethod() {
		let sut = MockRequestBuilderEmptyHeaders()

		let request = sut.toURLRequest()

		XCTAssertEqual(sut.method.rawValue.uppercased(), request.httpMethod)
	}

	func test_toURLRequest_correctlyBuildsAbsoluteString() {
		let sut = MockRequestBuilderEmptyHeaders()

		let request = sut.toURLRequest()

		XCTAssertEqual(sut.baseURL.absoluteString + sut.path!, request.url?.absoluteString)
	}

	func test_toURLRequest_correctlyBuildsEmptyHeaderFields() {
		let sut = MockRequestBuilderEmptyHeaders()

		let request = sut.toURLRequest()

		request.allHTTPHeaderFields?.forEach { key, val in
			XCTFail("Expected to have no headers")
		}
		XCTAssertEqual(request.allHTTPHeaderFields?.count, 0)
	}

	func test_toURLRequest_correctlyBuildsHeaderFields() {
		let sut = MockRequestBuilderWithHeaders()

		let request = sut.toURLRequest()

		request.allHTTPHeaderFields?.forEach { key, val in
			XCTAssertEqual(val,
						   sut.headers.first(where: { $0.key == key })?.value,
						   "Expected to have the same field value")
		}
		XCTAssertEqual(request.allHTTPHeaderFields?.isEmpty, false)
	}

	func test_toURLRequest_correctlyBuildsQueryComponents() {
		let sut = MockRequestBuilderWithQueryItems()

		let request = sut.toURLRequest()

		XCTAssertEqual(request.url?.absoluteString.contains(sut.params![0].name.description), true)
		XCTAssertEqual(request.url?.absoluteString.contains(sut.params![0].value!.description), true)
	}

}


class MockRequestBuilderEmptyHeaders: RequestBuilder {

    var method: HTTPMethod = .get

    var baseURL: URL = URL(string: "https://baseURL.com")!

    var path: String? = "/get"

    var params: [URLQueryItem]?

    var headers: [String : String] = [:]

}


class MockRequestBuilderWithHeaders: RequestBuilder {

	var method: HTTPMethod = .get

	var baseURL: URL = URL(string: "https://baseURL.com")!

	var path: String? = "/get"

	var params: [URLQueryItem]?

	var headers: [String : String] = ["Content-Type": "application/json"]

}

class MockRequestBuilderWithQueryItems: RequestBuilder {

	var method: HTTPMethod = .get

	var baseURL: URL = URL(string: "https://baseURL.com")!

	var path: String? = "/get"

	var params: [URLQueryItem]? = [URLQueryItem(name: "name", value: "test")]

	var headers: [String : String] = [:]

}
