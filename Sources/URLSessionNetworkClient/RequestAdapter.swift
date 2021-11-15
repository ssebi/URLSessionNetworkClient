
import Foundation

public protocol RequestAdapter {

	func adapt(_ request: inout URLRequest)
	func beforeSend(_ request: URLRequest)
	func onResponse(response: URLResponse?, data: Data?)
	func onError(request: URLRequest, error: APIError)
	func onSuccess(request: URLRequest)

}

public extension RequestAdapter {

	func adapt(_ request: inout URLRequest) { }
	func beforeSend(_ request: URLRequest) { }
	func onResponse(response: URLResponse?, data: Data?) { }
	func onError(request: URLRequest, error: APIError) { }
	func onSuccess(request: URLRequest) { }
	
}
