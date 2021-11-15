
import XCTest
import URLSessionNetworkClient

class RequestAdapterTests: XCTestCase {

	override func setUp() {
		URLProtocolStub.startInterceptingRequests()
	}

	override func tearDown() {
		URLProtocolStub.stopInterceptingReqeusts()
	}
	
	func test_adapt_isCalled() {
		let (spy, sut) = makeSUT()

		expect(sut: sut, numberOfCallsToBe: 1, when: { spy.adaptCalls })
	}

	func test_beforeSend_isCalled() {
		let (spy, sut) = makeSUT()

		expect(sut: sut, numberOfCallsToBe: 1, when: { spy.beforeSendCalls })
	}

	func test_onResponse_isCalled() {
		let (spy, sut) = makeSUT()

		expect(sut: sut, numberOfCallsToBe: 1, when: { spy.onResponseCalls })
	}

	func test_onError_isCalledOnError() {
		let (spy, sut) = makeSUT()

		URLProtocolStub.stub(data: nil, response: nil, error: anyNSError)

		expect(sut: sut, numberOfCallsToBe: 1, when: { spy.onErrorCalls })
	}

	func test_onError_isNotCalledOnSuccess() {
		let (spy, sut) = makeSUT()

		URLProtocolStub.stub(data: anyData, response: anyHTTPURLResponse, error: nil)

		expect(sut: sut, numberOfCallsToBe: 0, when: { spy.onErrorCalls })
	}


	func test_onSuccess_isCalledOnSuccess() {
		let (spy, sut) = makeSUT()

		URLProtocolStub.stub(data: anyData, response: anyHTTPURLResponse, error: nil)

		expect(sut: sut, numberOfCallsToBe: 1, when: { spy.onSuccessCalls })
	}

	func test_onSuccess_isNotCalledOnError() {
		let (spy, sut) = makeSUT()

		URLProtocolStub.stub(data: nil, response: nil, error: anyNSError)

		expect(sut: sut, numberOfCallsToBe: 0, when: { spy.onSuccessCalls })
	}

	// MARK: - Helpers

	private func makeSUT() -> (AdapterSpy, URLSessionNetworkClient) {
		let spy = AdapterSpy()
		let sut = URLSessionNetworkClient(session: .shared, adapters: [spy])

		return (spy, sut)
	}

	private func expect(sut: URLSessionNetworkClient, numberOfCallsToBe count: Int, when action: () -> Int, file: StaticString = #filePath, line: UInt = #line) {
		let exp = expectation(description: "Wait for completion")
		sut.send(request: .basic(baseURL: someURL)) { _ in
			exp.fulfill()
		}
		wait(for: [exp], timeout: 0.5)

		XCTAssertEqual(action(), count, file: file, line: line)
	}

	private lazy var someURL = URL(string: "https://someurl.com")!
	private lazy var anyData = Data("any data".utf8)
	private lazy var anyHTTPURLResponse = HTTPURLResponse(url: someURL, statusCode: 200, httpVersion: nil, headerFields: nil)
	private lazy var anyNSError = NSError(domain: "any error", code: 0)

	private class AdapterSpy: RequestAdapter {
		private(set) var adaptCalls = 0
		private(set) var beforeSendCalls = 0
		private(set) var onResponseCalls = 0
		private(set) var onErrorCalls = 0
		private(set) var onSuccessCalls = 0

		func adapt(_ request: inout URLRequest) {
			adaptCalls += 1
		}

		func beforeSend(_ request: URLRequest) {
			beforeSendCalls += 1
		}

		func onResponse(response: URLResponse?, data: Data?) {
			onResponseCalls += 1
		}

		func onError(request: URLRequest, error: APIError) {
			onErrorCalls += 1
		}

		func onSuccess(request: URLRequest) {
			onSuccessCalls += 1
		}
	}

}
