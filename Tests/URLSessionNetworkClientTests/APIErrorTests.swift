
import XCTest
@testable import URLSessionNetworkClient

class APIErrorTests: XCTestCase {

	func test_error_deliversUnknownResponseOnNilURLResponse() {
		let sut = APIError.error(from: nil)

		XCTAssertEqual(sut, .unknownResponse)
	}

	func test_error_deliversRequestErrorOnErrorCodeRange400to499() {
		[400, 420, 486, 499].forEach { code in
			let response = makeHTTPURLResponse(with: code)
			let sut = APIError.error(from: response)
			XCTAssertEqual(sut, APIError.requestError(code))
		}
	}

	func test_error_deliversServerErrorOnErrorCodeRange500to599() {
		[500, 510, 590, 599].forEach { code in
			let response = makeHTTPURLResponse(with: code)
			let sut = APIError.error(from: response)
			XCTAssertEqual(sut, APIError.serverError(code))
		}
	}

	func test_error_deliversUnhandledResponseErrorOnErrorCodeOutsideThePredefinedRanges() {
		[100, 0, 10, 99, 600, 1000].forEach { code in
			let response = makeHTTPURLResponse(with: code)
			let sut = APIError.error(from: response)
			XCTAssertEqual(sut, APIError.unhandledResponse)
		}
	}

	func test_error_deliversNilOnStatusCodeRage200to299() {
		[200, 201, 222, 288, 299].forEach { code in
			let response = makeHTTPURLResponse(with: code)
			let sut = APIError.error(from: response)
			XCTAssertNil(sut)
		}
	}

	// MARK: - Helpers

	private func makeHTTPURLResponse(with code: Int) -> HTTPURLResponse {
		HTTPURLResponse(url: URL(string: "https://someurl.com")!,
						statusCode: code,
						httpVersion: nil,
						headerFields: nil)!
	}

}

extension APIError: Equatable {
	public static func == (lhs: APIError, rhs: APIError) -> Bool {
		(lhs as NSError).domain == (rhs as NSError).domain &&
		(lhs as NSError).code == (rhs as NSError).code
	}
}
