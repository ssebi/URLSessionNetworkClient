//
//  URLSessionNetworkClientEndToEndTests.swift
//  
//
//  Created by Sebastian Vidrea on 28.01.2022.
//

import XCTest
import URLSessionNetworkClient

class URLSessionNetworkClientEndToEndTests: XCTestCase {

	func test() {
		let url = URL(string: "https://jsonplaceholder.typicode.com/posts/1")!
		let sut = URLSessionNetworkClient(session: .shared, adapters: [LoggingAdapter(logLevel: .debug)])

		let expectation = expectation(description: "Wait for completion")
		sut.send(request: .basic(baseURL: url)) { result in
			result.decode(SomeModel.self) { result in
				guard let model = try? result.get() else {
					XCTFail("Expected to decode model")
					return
				}

				XCTAssertEqual(model.userId, 1)
				XCTAssertEqual(model.id, 1)
				XCTAssertEqual(model.title, "sunt aut facere repellat provident occaecati excepturi optio reprehenderit")
				XCTAssertEqual(model.body, "quia et suscipit\nsuscipit recusandae consequuntur expedita et cum\nreprehenderit molestiae ut ut quas totam\nnostrum rerum est autem sunt rem eveniet architecto")

				expectation.fulfill()
			}

		}
		wait(for: [expectation], timeout: 5.0)
	}

	// MARK: - Helpers

	private struct SomeModel: Decodable {
		let userId: Int
		let id: Int
		let title: String
		let body: String
	}

}
