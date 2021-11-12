
import XCTest
import URLSessionNetworkClient

final class URLSessionNetworkClientTests: XCTestCase {

    override func setUp() {
        URLProtocolStub.startInterceptingRequests()
    }

    override func tearDown() {
        URLProtocolStub.stopInterceptingReqeusts()
    }

    func test_getFromURL_performsGETRequestsWithURL() {
        let exp = expectation(description: "Wait for request")

        URLProtocolStub.observeRequests { request in
            XCTAssertEqual(request.url, self.someURL)
            XCTAssertEqual(request.httpMethod, "GET")
            exp.fulfill()
        }

        makeSUT().send(request: Request.basic(baseURL: someURL), completion: { _ in })

        wait(for: [exp], timeout: 0.1)
    }

    func test_getFromURL_failsOnRequestError() {
        let requestError: NSError? = anyNSError

        let receivedError = resultErrorFor(data: nil, response: nil, error: requestError)

		XCTAssertEqual(receivedError?.domain, "URLSessionNetworkClient.APIError")
        XCTAssertEqual(receivedError?.code, requestError?.code)
    }

    func test_getFromURL_failsOnAllInvalidRepresentations() {
        XCTAssertNotNil(resultErrorFor(data: nil, response: nil, error: nil))
        XCTAssertNotNil(resultErrorFor(data: nil, response: nonHTTPURLResponse, error: nil))
        XCTAssertNotNil(resultErrorFor(data: anyData, response: nil, error: nil))
        XCTAssertNotNil(resultErrorFor(data: anyData, response: nil, error: anyNSError))
        XCTAssertNotNil(resultErrorFor(data: nil, response: nonHTTPURLResponse, error: anyNSError))
        XCTAssertNotNil(resultErrorFor(data: nil, response: anyHTTPURLResponse, error: anyNSError))
        XCTAssertNotNil(resultErrorFor(data: anyData, response: nonHTTPURLResponse, error: anyNSError))
        XCTAssertNotNil(resultErrorFor(data: anyData, response: anyHTTPURLResponse, error: anyNSError))
        XCTAssertNotNil(resultErrorFor(data: anyData, response: nonHTTPURLResponse, error: nil))
    }

    func test_getFromURL_succeedsOnHTTPURLResponseWithData() {
        let data = anyData
        let response = anyHTTPURLResponse

        let receivedValues = resultValuesFor(data: data, response: response, error: nil)

        XCTAssertEqual(receivedValues?.data, data)
        XCTAssertEqual(receivedValues?.response.url, response?.url)
        XCTAssertEqual(receivedValues?.response.statusCode, response?.statusCode)
    }

    func test_getFromURL_succeedsWithEmptyDataOnHTTPURLResponseWithNilData() {
        let response = anyHTTPURLResponse
        let receivedValues = resultValuesFor(data: nil, response: response, error: nil)
        let emptyData = Data()
        XCTAssertEqual(receivedValues?.data, emptyData)
        XCTAssertEqual(receivedValues?.response.url, response?.url)
        XCTAssertEqual(receivedValues?.response.statusCode, response?.statusCode)
    }

	func test_decode_decodesValidJSONData() throws {
		let someString = "someString"
		let jsonData = try JSONSerialization.data(withJSONObject: ["someField": someString])
		var receivedValue: SomeModel?

		let exp = expectation(description: "Wait for completion")
		resultFor(data: jsonData, response: anyHTTPURLResponse, error: nil)
			.decode(SomeModel.self, completion: { result in
				if let obj = try? result.get() {
					receivedValue = obj
					exp.fulfill()
				}
			})
		wait(for: [exp], timeout: 1)

		XCTAssertEqual(receivedValue, SomeModel(someField: someString))
	}


    // MARK: - Helpers

	struct SomeModel: Decodable, Equatable {
		let someField: String
	}

    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> URLSessionNetworkClient {
        let sut = URLSessionNetworkClient(session: .shared)
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }

    private func resultErrorFor(data: Data?, response: URLResponse?, error: Error?, file: StaticString = #filePath, line: UInt = #line) -> NSError? {
        let result = resultFor(data: data, response: response, error: error, file: file, line: line)

        switch result {
            case let .failure(error):
                return error as NSError
            default:
                XCTFail("Expected failure, got \(result) instead", file: file, line: line)
                return nil
        }
    }

    private func resultValuesFor(data: Data?, response: URLResponse?, error: Error?, file: StaticString = #filePath, line: UInt = #line) -> (data: Data, response: HTTPURLResponse)? {
        let result = resultFor(data: data, response: response, error: error, file: file, line: line)

        switch result {
            case let .success((data, response)):
                return (data, response)
            default:
                XCTFail("Expected success, got \(result) instead", file: file, line: line)
                return nil
        }
    }

    private func resultFor(data: Data?, response: URLResponse?, error: Error?, file: StaticString = #filePath, line: UInt = #line) -> Result<(Data, HTTPURLResponse), APIError> {
        URLProtocolStub.stub(data: data, response: response, error: error)
        let sut = makeSUT(file: file, line: line)
        let exp = expectation(description: "Wait for completion")

        var receivedResult: Result<(Data, HTTPURLResponse), APIError>!
        sut.send(request: Request.basic(baseURL: someURL)) { result in
            receivedResult = result
            exp.fulfill()
        }

        wait(for: [exp], timeout: 0.1)
        return receivedResult
    }

    func trackForMemoryLeaks(_ instance: AnyObject, file: StaticString = #filePath, line: UInt = #line) {
        addTeardownBlock { [weak instance] in
            XCTAssertNil(instance, "Instance should have been deallocated. Potential memory leak", file: file, line: line)
        }
    }

    private lazy var someURL = URL(string: "https://someurl.com")!
    private lazy var anyData = Data("any data".utf8)
    private lazy var anyNSError = NSError(domain: "any error", code: 0)
    private lazy var nonHTTPURLResponse = URLResponse(url: someURL, mimeType: nil, expectedContentLength: 0, textEncodingName: nil)
    private lazy var anyHTTPURLResponse = HTTPURLResponse(url: someURL, statusCode: 200, httpVersion: nil, headerFields: nil)

    private class URLProtocolStub: URLProtocol {

        private static var stub: Stub?
        private static var requestObserver: ((URLRequest) -> Void)?

        private struct Stub {
            let data: Data?
            let response: URLResponse?
            let error: Error?
        }

        static func stub(data: Data?, response: URLResponse?, error: Error?) {
            stub = Stub(data: data, response: response, error: error)
        }

        static func observeRequests(observer: @escaping (URLRequest) -> Void) {
            requestObserver = observer
        }

        static func startInterceptingRequests() {
            URLProtocol.registerClass(URLProtocolStub.self)
        }

        static func stopInterceptingReqeusts() {
            URLProtocol.unregisterClass(URLProtocolStub.self)
            stub = nil
            requestObserver = nil
        }

        override class func canInit(with request: URLRequest) -> Bool {
            true
        }

        override class func canonicalRequest(for request: URLRequest) -> URLRequest {
            return request
        }

        override func startLoading() {
            if let requestObserver = Self.requestObserver {
                client?.urlProtocolDidFinishLoading(self)
                return requestObserver(request)
            }
            if let data = Self.stub?.data {
                client?.urlProtocol(self, didLoad: data)
            }

            if let response = Self.stub?.response {
                client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            }

            if let error = Self.stub?.error {
                client?.urlProtocol(self, didFailWithError: error)
            }

            client?.urlProtocolDidFinishLoading(self)
        }

        override func stopLoading() { }

    }

}
