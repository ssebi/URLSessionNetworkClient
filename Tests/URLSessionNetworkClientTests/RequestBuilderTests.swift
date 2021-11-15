//
//  RequestBuilderTests.swift
//  
//
//  Created by Sebastian Vidrea on 25.09.2021.
//

import XCTest
@testable import URLSessionNetworkClient

class RequestBuilderTests: XCTestCase {

	func test_toURLRequest_correctlyBuildsHTTPMethod() {
		let sut = Request.basic(baseURL: someURL).builder.toURLRequest()

		XCTAssertEqual("GET", sut.httpMethod)
	}

	func test_toURLRequest_correctlyBuildsPath() {
		let path = "get"
		let sut = Request.basic(baseURL: someURL, path: path).builder.toURLRequest()

		XCTAssertEqual("\(someURL.absoluteString)/get", sut.url?.absoluteString)
	}

	func test_toURLRequest_correctlyBuildsEmptyHeaderFields() {
		let sut = Request.basic(baseURL: someURL).builder.toURLRequest()

		sut.allHTTPHeaderFields?.forEach { key, val in
			XCTFail("Expected to have no headers")
		}
		XCTAssertEqual(sut.allHTTPHeaderFields?.count, 0)
	}

	func test_toURLRequest_correctlyBuildsHeaderFields() {
		let headers = ["Content-Type": "application/json"]
		let sut = Request.basic(baseURL: someURL, headers: headers).builder.toURLRequest()

		sut.allHTTPHeaderFields?.forEach { key, val in
			XCTAssertEqual(val,
						   headers.first(where: { $0.key == key })?.value,
						   "Expected to have the same field value")
		}
		XCTAssertEqual(sut.allHTTPHeaderFields?.isEmpty, false)
	}

	func test_toURLRequest_correctlyBuildsQueryComponents() {
		let params = [URLQueryItem(name: "name", value: "test")]
		let sut = Request.basic(baseURL: someURL, params: params).builder.toURLRequest()

		XCTAssertEqual(sut.url?.absoluteString.contains(params[0].name.description), true)
		XCTAssertEqual(sut.url?.absoluteString.contains(params[0].value!.description), true)
	}

	func test_toURLRequest_correctlyEncodesBodywithEmptyData() {
		let model: Model? = nil
		let sut = Request.post(baseURL: someURL, path: "post", body: model)

		let request = sut.builder.toURLRequest()

		XCTAssertEqual(request.httpBody, nil)
	}

	func test_toURLRequest_correctlyEncodesBodyWithData() throws {
		let model = Model()
		let sut = Request.post(baseURL: someURL, path: "post", body: model)

		let request = sut.builder.toURLRequest()

		XCTAssertEqual(request.httpBody, try JSONEncoder().encode(model))
	}

	// MARK: - Helpers

	private let someURL = URL(string: "https://some-url.com")!

	private struct Model: Encodable {
		let someField = "someField"
	}

}
