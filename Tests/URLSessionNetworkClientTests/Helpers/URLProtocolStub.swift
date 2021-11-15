
import Foundation

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
