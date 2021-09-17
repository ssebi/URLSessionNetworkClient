
import XCTest
import URLSessionNetworkClient

final class URLSessionNetworkClientTests: XCTestCase {

    func test_getFromURL_performsGETRequestsWithURL() {
        URLProtocolStub.startInterceptingRequests()

        let sut = makeSUT()
        let exp = expectation(description: "Wait for request")

        URLProtocolStub.observedRequests { request in
            XCTAssertEqual(request.url, self.someURL)
            XCTAssertEqual(request.httpMethod, "GET")
            exp.fulfill()
        }

        sut.get(from: someURL, completion: { _ in })

        wait(for: [exp], timeout: 0.1)
        URLProtocolStub.stopInterceptingReqeusts()
    }

    func test_getFromURL_failsOnRequestError() {
        URLProtocolStub.startInterceptingRequests()
        let sut = makeSUT()
        let url = someURL
        let error = someError
        URLProtocolStub.stub(data: nil, response: nil, error: error)

        let exp = expectation(description: "Wait for completion")

        sut.get(from: url) { result in
            switch result {
                case let .failure(receivedError as NSError):
                    XCTAssertEqual(receivedError.domain, error.domain)
                    XCTAssertEqual(receivedError.code, error.code)
                default:
                    XCTFail("Expected failure with error \(error), got \(result) instead")
            }
            exp.fulfill()
        }

        wait(for: [exp], timeout: 0.1)
        URLProtocolStub.stopInterceptingReqeusts()
    }

    // MARK: - Helpers

    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> URLSessionNetworkClient {
        let sut = URLSessionNetworkClient(session: .shared)
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }

    func trackForMemoryLeaks(_ instance: AnyObject, file: StaticString = #filePath, line: UInt = #line) {
        addTeardownBlock { [weak instance] in
            XCTAssertNil(instance, "Instance should have been deallocated. Potential memory leak", file: file, line: line)
        }
    }

    private let someURL = URL(string: "https://someurl.com")!
    private let someError = NSError(domain: "Test", code: 0)


    class URLProtocolStub: URLProtocol {

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

        static func observedRequests(observer: @escaping (URLRequest) -> Void) {
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
            requestObserver?(request)
            return true
        }

        override class func canonicalRequest(for request: URLRequest) -> URLRequest {
            return request
        }

        override func startLoading() {
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
